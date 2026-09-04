# src/acp/json_rpc.cr
# JSON-RPC 2.0 primitives and protocol-level types of the Agent Client Protocol.
#
# This file is hand-written (not generated from the schema).

module ACP
  # The id of a JSON-RPC request, used to correlate the matching response.
  alias RequestId = Int64 | String

  # Version of the ACP protocol this library implements (schema v1).
  alias ProtocolVersion = Int32

  # The protocol version implemented by this library.
  PROTOCOL_VERSION = ProtocolVersion.new(1)

  # Predefined error codes for common JSON-RPC and ACP-specific errors.
  #
  # These codes follow the JSON-RPC 2.0 specification for standard errors
  # and use the reserved range (-32000 to -32099) for protocol-specific errors.
  module ErrorCode
    # Invalid JSON was received by the server.
    ParseError = -32700
    # The JSON sent is not a valid Request object.
    InvalidRequest = -32600
    # The method does not exist or is not available.
    MethodNotFound = -32601
    # Invalid method parameter(s).
    InvalidParams = -32602
    # Internal JSON-RPC error.
    InternalError = -32603
    # Execution of the method was aborted due to a cancellation request.
    RequestCancelled = -32800
    # Authentication is required before this operation can be performed.
    AuthRequired = -32000
    # A given resource, such as a file, was not found.
    ResourceNotFound = -32002
  end

  # JSON-RPC error object.
  #
  # Represents an error that occurred during method execution, following the
  # JSON-RPC 2.0 error object specification with optional additional data.
  class Error
    include JSON::Serializable

    # A number indicating the error type that occurred.
    getter code : Int32

    # A string providing a short description of the error.
    getter message : String

    # Optional primitive or structured value with additional information.
    @[JSON::Field(emit_null: false)]
    getter data : JSON::Any?

    def initialize(@code : Int32, @message : String, @data : JSON::Any? = nil)
    end

    def to_s(io : IO) : Nil
      io << "ACP error " << code << ": " << message
    end
  end

  # Exception raised for JSON-RPC errors.
  #
  # Raise it from a request handler to respond with a specific error code;
  # thrown by `Connection#send_request` when the peer responds with an error.
  class RpcError < Exception
    getter code : Int32
    getter data : JSON::Any?

    def initialize(@code : Int32, message : String, @data : JSON::Any? = nil, cause : Exception? = nil)
      super(message, cause: cause)
    end

    def self.parse_error(message : String = "Parse error") : self
      new(ErrorCode::ParseError, message)
    end

    def self.invalid_request(message : String = "Invalid request") : self
      new(ErrorCode::InvalidRequest, message)
    end

    def self.method_not_found(method : String) : self
      new(ErrorCode::MethodNotFound, "Method not found: #{method}")
    end

    def self.invalid_params(message : String = "Invalid params") : self
      new(ErrorCode::InvalidParams, message)
    end

    def self.internal(message : String = "Internal error") : self
      new(ErrorCode::InternalError, message)
    end

    def self.request_cancelled(message : String = "Request cancelled") : self
      new(ErrorCode::RequestCancelled, message)
    end

    def self.auth_required(message : String = "Authentication required") : self
      new(ErrorCode::AuthRequired, message)
    end

    def self.resource_not_found(message : String = "Resource not found") : self
      new(ErrorCode::ResourceNotFound, message)
    end

    def to_error : Error
      Error.new(@code, message || "Internal error", @data)
    end
  end

  # Notification to cancel an ongoing request (`$/cancel_request`).
  #
  # See protocol docs: [Cancellation](https://agentclientprotocol.com/protocol/cancellation)
  class CancelRequestNotification
    include JSON::Serializable

    # The ID of the request to cancel.
    @[JSON::Field(key: "requestId")]
    getter request_id : RequestId

    # The _meta property is reserved by ACP to attach additional metadata.
    @[JSON::Field(key: "_meta", emit_null: false)]
    getter meta : Hash(String, JSON::Any)?

    def initialize(@request_id : RequestId, @meta : Hash(String, JSON::Any)? = nil)
    end
  end

  # The method name of the protocol-level cancellation notification.
  CANCEL_REQUEST_METHOD = "$/cancel_request"

  # Payload of an extension method request (methods beginning with `_`).
  #
  # Extension methods provide a way to add custom functionality while
  # maintaining protocol compatibility.
  struct ExtRequest
    include JSON::Serializable

    # The extension method name. Must begin with `_`.
    getter method : String

    # Method-specific parameters (arbitrary JSON).
    @[JSON::Field(emit_null: false)]
    getter params : JSON::Any?

    def initialize(@method : String, @params : JSON::Any? = nil)
    end
  end

  # Payload of an extension notification (methods beginning with `_`).
  struct ExtNotification
    include JSON::Serializable

    # The extension method name. Must begin with `_`.
    getter method : String

    # Method-specific parameters (arbitrary JSON).
    @[JSON::Field(emit_null: false)]
    getter params : JSON::Any?

    def initialize(@method : String, @params : JSON::Any? = nil)
    end
  end

  # Result payload of an extension method response.
  struct ExtResponse
    include JSON::Serializable

    # Arbitrary response data.
    @[JSON::Field(emit_null: false)]
    getter result : JSON::Any?

    def initialize(@result : JSON::Any? = nil)
    end
  end

  # The parsed classification of an incoming JSON-RPC message line.
  enum MessageKind
    # A request (`method` + `id`): expects a response.
    Request
    # A notification (`method`, no `id`): one-way.
    Notification
    # A response to a previous request (`result` or `error`).
    Response
  end

  # :nodoc:
  # A raw, minimally-parsed JSON-RPC message.
  struct RawMessage
    getter kind   : MessageKind
    getter id     : RequestId?
    getter method : String?
    getter params : JSON::Any?
    getter result : JSON::Any?
    getter error  : Error?

    def initialize(@kind, @id, @method, @params, @result, @error)
    end

    def self.parse(json : JSON::Any) : RawMessage
      obj    = json.as_h
      method = obj["method"]?.try(&.as_s?)
      if m = method
        if id_any = obj["id"]?
          id = parse_id(id_any)
          new(MessageKind::Request, id, m, obj["params"]?, nil, nil)
        else
          new(MessageKind::Notification, nil, m, obj["params"]?, nil, nil)
        end
      else
        id = obj["id"]?.try { |v| parse_id(v) }
        if err = obj["error"]?
          new(MessageKind::Response, id, nil, nil, nil, Error.from_json(err.to_json))
        else
          new(MessageKind::Response, id, nil, nil, obj["result"]?, nil)
        end
      end
    end

    def self.parse_id(value : JSON::Any) : RequestId?
      case raw = value.raw
      when Int64  then raw
      when String then raw
      when Nil    then nil
      else
        raise JSON::ParseException.new("Invalid request id: #{raw.inspect}", 0, 0)
      end
    end
  end
end
