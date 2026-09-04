# src/acp/connection.cr
require "json"
require "set"

module ACP
  # A bidirectional JSON-RPC 2.0 connection over newline-delimited JSON
  # (the ACP stdio transport).
  #
  # The connection reads messages from an input IO, dispatches incoming
  # requests and notifications to subclass-implemented handlers, and
  # correlates outgoing requests with their responses.
  #
  # Each incoming request/notification is handled in its own fiber, so
  # handlers may themselves send requests to the peer and await responses
  # without deadlocking the read loop. Writes are serialized internally.
  abstract class Connection
    @input  : IO
    @output : IO
    @pending            = Hash(String, Channel(JSON::Any)).new
    @pending_lock       = Mutex.new
    @write_lock         = Mutex.new
    @cancelled_requests = Set(String).new
    @cancelled_lock     = Mutex.new
    @in_flight          = 0
    @in_flight_lock     = Mutex.new
    @next_id            = Atomic(Int64).new(0_i64)
    @closed             = false

    def initialize(@input : IO, @output : IO)
    end

    # Whether the connection has been closed or the peer hung up.
    def closed? : Bool
      @closed
    end

    # Runs the read loop, blocking the current fiber until the peer closes
    # the input stream or the connection is closed.
    #
    # Incoming messages are dispatched to fibers spawned per message.
    def run : Nil
      while line = @input.gets(chomp: true)
        next if line.blank?
        handle_line(line)
      end
    rescue IO::Error
      # input closed
    ensure
      wait_for_in_flight
      shutdown
    end

    # Runs the read loop in a new fiber and returns it.
    def run_async : Fiber
      spawn run
    end

    # Closes the connection, failing all pending requests.
    def close : Nil
      shutdown
    end

    # Sends a request and blocks the current fiber until the peer responds.
    #
    # *params* may be any JSON-serializable object, `JSON::Any`, or `nil`.
    # The result is parsed as `R`. Raises `RpcError` on an error response.
    def send_request(method : String, params, as result_type : R.class) : R forall R
      id      = @next_id.add(1)
      key     = id.to_json
      channel = Channel(JSON::Any).new(1)
      @pending_lock.synchronize { @pending[key] = channel }
      begin
        write_message do |json|
          json.object do
            json.field "jsonrpc", "2.0"
            json.field "id", id
            json.field "method", method
            unless params.nil?
              json.field "params" { params.to_json(json) }
            end
          end
        end
        response = channel.receive
        if error = response["error"]?
          raise RpcError.new(error["code"].as_i.to_i32, error["message"].as_s, error["data"]?)
        end
        result = response["result"]? || JSON::Any.new(nil)
        R.from_json(result.to_json)
      ensure
        @pending_lock.synchronize { @pending.delete(key) }
      end
    end

    # Sends a request expecting no meaningful result (`null` or `{}`).
    def send_request(method : String, params = nil) : Nil
      send_request(method, params, as: JSON::Any)
      nil
    end

    # Sends a notification (no response expected).
    #
    # *params* may be any JSON-serializable object, `JSON::Any`, or `nil`.
    def send_notification(method : String, params = nil) : Nil
      write_message do |json|
        json.object do
          json.field "jsonrpc", "2.0"
          json.field "method", method
          unless params.nil?
            json.field "params" { params.to_json(json) }
          end
        end
      end
    end

    # Sends an extension request (a method beginning with `_`).
    def send_ext_request(method : String, params : JSON::Any? = nil) : JSON::Any?
      result = send_request(method, params, as: JSON::Any)
      result.raw.nil? ? nil : result
    end

    # Sends an extension notification (a method beginning with `_`).
    def send_ext_notification(method : String, params : JSON::Any? = nil) : Nil
      send_notification(method, params)
    end

    # Asks the peer to cancel the request with the given id
    # (`$/cancel_request`).
    def send_cancel_request(request_id : RequestId) : Nil
      send_notification(CANCEL_REQUEST_METHOD, CancelRequestNotification.new(request_id))
    end

    # Whether a `$/cancel_request` notification was received for *id*.
    #
    # Request handlers can poll this to cooperatively abort processing.
    def cancel_requested?(id : RequestId) : Bool
      @cancelled_lock.synchronize { @cancelled_requests.includes?(id.to_json) }
    end

    # :nodoc:
    # Called when a `$/cancel_request` notification arrives. The default
    # implementation only records the id (see `#cancel_requested?`);
    # subclasses may override to react immediately.
    protected def cancel_request_received(id : RequestId) : Nil
    end

    # :nodoc:
    # Handles an incoming request. Must return the result serialized as a
    # raw JSON string (`nil` produces a `null` result). Raise `RpcError`
    # to respond with an error.
    protected abstract def handle_request(method : String, params : JSON::Any?) : String?

    # :nodoc:
    # Handles an incoming notification.
    protected abstract def handle_notification(method : String, params : JSON::Any?) : Nil

    private def handle_line(line : String) : Nil
      any =
        begin
          JSON.parse(line)
        rescue JSON::ParseException
          # Unparseable input: respond with a parse error (id is null).
          write_error(nil, RpcError.parse_error)
          return
        end

      message =
        begin
          RawMessage.parse(any)
        rescue JSON::ParseException
          write_error(nil, RpcError.parse_error)
          return
        end

      case message.kind
      in .response?
        handle_response(message)
      in .request?
        dispatch_async { handle_incoming_request(message) }
      in .notification?
        dispatch_async { handle_incoming_notification(message) }
      end
    end

    # Runs a message handler in a new fiber, tracked so that `run` can wait
    # for in-flight handlers to finish after the input stream closes.
    private def dispatch_async(&block : ->) : Nil
      @in_flight_lock.synchronize { @in_flight += 1 }
      spawn do
        begin
          block.call
        ensure
          @in_flight_lock.synchronize { @in_flight -= 1 }
        end
      end
    end

    private def wait_for_in_flight : Nil
      until @in_flight_lock.synchronize { @in_flight }.zero?
        sleep 1.millisecond
      end
    end

    private def handle_response(message : RawMessage) : Nil
      id = message.id
      return if id.nil? # cannot correlate a response without an id
      key     = id.to_json
      channel = @pending_lock.synchronize { @pending[key]? }
      return unless channel # unknown or already answered id
      obj = JSON::Any.new({} of String => JSON::Any).as_h.dup
      if error = message.error
        obj["error"] = JSON.parse(error.to_json)
      else
        obj["result"] = message.result || JSON::Any.new(nil)
      end
      channel.send(JSON::Any.new(obj))
    end

    private def handle_incoming_request(message : RawMessage) : Nil
      id     = message.id.not_nil!
      method = message.method.not_nil!
      begin
        result = handle_request(method, message.params)
        write_result(id, result)
      rescue ex : RpcError
        write_error(id, ex)
      rescue ex : JSON::ParseException
        write_error(id, RpcError.invalid_params(ex.message || "Invalid params"))
      rescue ex
        write_error(id, RpcError.internal("#{ex.class}: #{ex.message}"))
      ensure
        @cancelled_lock.synchronize { @cancelled_requests.delete(id.to_json) }
      end
    end

    private def handle_incoming_notification(message : RawMessage) : Nil
      method = message.method.not_nil!
      if method == CANCEL_REQUEST_METHOD
        if params = message.params
          begin
            cancel = CancelRequestNotification.from_json(params.to_json)
            @cancelled_lock.synchronize { @cancelled_requests << cancel.request_id.to_json }
            cancel_request_received(cancel.request_id)
          rescue JSON::ParseException
            # ignore malformed cancellation notifications
          end
        end
        return
      end
      handle_notification(method, message.params)
    rescue ex
      # Notifications must not produce responses; log to stderr instead.
      STDERR.puts "acp: error handling notification #{method}: #{ex.message}"
    end

    private def write_result(id : RequestId, result : String?) : Nil
      write_message do |json|
        json.object do
          json.field "jsonrpc", "2.0"
          json.field "id", id
          json.field "result" { json.raw(result || "null") }
        end
      end
    end

    private def write_error(id : RequestId?, error : RpcError) : Nil
      write_message do |json|
        json.object do
          json.field "jsonrpc", "2.0"
          json.field "id", id
          json.field "error", error.to_error
        end
      end
    end

    private def write_message(& : JSON::Builder ->) : Nil
      payload = JSON.build { |json| yield json }
      @write_lock.synchronize do
        @output.puts(payload)
        @output.flush
      end
    end

    private def shutdown : Nil
      return if @closed
      @closed = true
      @pending_lock.synchronize do
        @pending.each_value do |channel|
          error = JSON.parse(RpcError.internal("Connection closed").to_error.to_json)
          channel.send(JSON::Any.new({"error" => error}))
        end
        @pending.clear
      end
    end
  end
end
