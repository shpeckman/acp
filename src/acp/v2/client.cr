# src/acp/v2/client.cr
module ACP
  module V2
    # Base class for ACP v2 clients (schema 2.0.0-alpha).
    #
    # Subclass it and override the `handle_*` methods for the capabilities
    # your client advertises. Unimplemented request methods respond with a
    # JSON-RPC "method not found" error; notifications default to no-ops.
    abstract class Client
      # The connection this client is serving on (available once connected).
      property! connection : ClientConnection

      # Handles a session update streamed by the agent (`session/update`).
      def handle_session_update(notification : UpdateSessionNotification) : Nil
      end

      # Handles a permission request from the agent
      # (`session/request_permission`).
      def handle_request_permission(params : RequestPermissionRequest) : RequestPermissionResponse
        raise ::ACP::RpcError.method_not_found("session/request_permission")
      end

      # Handles an elicitation request (`elicitation/create`).
      def handle_create_elicitation(params : CreateElicitationRequest) : CreateElicitationResponse
        raise ::ACP::RpcError.method_not_found("elicitation/create")
      end

      # Handles an elicitation completion (`elicitation/complete` notification).
      def handle_complete_elicitation(notification : CompleteElicitationNotification) : Nil
      end

      # Handles an extension method request (methods beginning with `_`).
      def handle_ext_request(method : String, params : JSON::Any?) : JSON::Any?
        raise ::ACP::RpcError.method_not_found(method)
      end

      # Handles an extension notification (methods beginning with `_`).
      def handle_ext_notification(method : String, params : JSON::Any?) : Nil
      end
    end

    # A `V2::Client` implementation that ignores all notifications and
    # rejects all requests. Used by `ClientConnection.spawn` when no
    # client is given.
    class NullClient < Client
    end

    # Client-side v2 connection: sends requests to an agent and dispatches
    # agent requests and notifications to a `V2::Client` implementation.
    class ClientConnection < ::ACP::Connection
      getter client : Client

      def initialize(input : IO, output : IO, @client : Client)
        super(input, output)
        @client.connection = self
        run_async
      end

      # Launches *command* as a subprocess and connects to it over stdio.
      def self.spawn(
        command : String,
        args : Array(String) = [] of String,
        env : Process::Env? = nil,
        clear_env : Bool = false,
        chdir : String? = nil,
        error : Process::Redirect = Process::Redirect::Inherit,
        client : Client? = nil,
      ) : {Process, ClientConnection}
        process = Process.new(
          command, args,
          env: env, clear_env: clear_env, chdir: chdir || Dir.current,
          input: Process::Redirect::Pipe,
          output: Process::Redirect::Pipe,
          error: error,
        )
        connection = new(process.output, process.input, client || NullClient.new)
        {process, connection}
      end

      # ----------------------------------------------------------------
      # Requests the client can send to the agent
      # ----------------------------------------------------------------

      # Negotiates the protocol version and exchanges capabilities
      # (`initialize`). Must be the first request sent on the connection.
      def initialize_agent(params : InitializeRequest) : InitializeResponse
        send_request("initialize", params, as: InitializeResponse)
      end

      # Authenticates with the agent (`auth/login`).
      def login(params : LoginAuthRequest) : LoginAuthResponse
        send_request("auth/login", params, as: LoginAuthResponse)
      end

      # Logs out of the agent (`auth/logout`).
      def logout(params : LogoutAuthRequest) : LogoutAuthResponse
        send_request("auth/logout", params, as: LogoutAuthResponse)
      end

      # Creates a new conversation session (`session/new`).
      def new_session(params : NewSessionRequest) : NewSessionResponse
        send_request("session/new", params, as: NewSessionResponse)
      end

      # Lists existing sessions (`session/list`).
      def list_sessions(params : ListSessionsRequest) : ListSessionsResponse
        send_request("session/list", params, as: ListSessionsResponse)
      end

      # Deletes a session (`session/delete`).
      def delete_session(params : DeleteSessionRequest) : DeleteSessionResponse
        send_request("session/delete", params, as: DeleteSessionResponse)
      end

      # Resumes a session, optionally replaying from a cursor
      # (`session/resume`).
      def resume_session(params : ResumeSessionRequest) : ResumeSessionResponse
        send_request("session/resume", params, as: ResumeSessionResponse)
      end

      # Closes a session (`session/close`).
      def close_session(params : CloseSessionRequest) : CloseSessionResponse
        send_request("session/close", params, as: CloseSessionResponse)
      end

      # Sets a session configuration option (`session/set_config_option`).
      def set_session_config_option(params : SetSessionConfigOptionRequest) : SetSessionConfigOptionResponse
        send_request("session/set_config_option", params, as: SetSessionConfigOptionResponse)
      end

      # Sends a user prompt to the agent (`session/prompt`).
      #
      # Blocks until the agent finishes the prompt turn. Session updates
      # (message chunks, tool calls, state updates) arrive via
      # `Client#handle_session_update` in the meantime.
      def prompt(params : PromptRequest) : PromptResponse
        send_request("session/prompt", params, as: PromptResponse)
      end

      # Cancels ongoing operations for a session (`session/cancel`).
      def cancel(params : CancelSessionNotification) : Nil
        send_notification("session/cancel", params)
      end

      # Cancels ongoing operations for a session (`session/cancel`).
      def cancel(session_id : SessionId) : Nil
        send_notification("session/cancel", CancelSessionNotification.new(session_id: session_id))
      end

      protected def handle_request(method : String, params : JSON::Any?) : String?
        case method
        when "session/request_permission"
          parse_params(params, RequestPermissionRequest) { |p| client.handle_request_permission(p) }
        when "elicitation/create"
          parse_params(params, CreateElicitationRequest) { |p| client.handle_create_elicitation(p) }
        else
          if method.starts_with?("_")
            result = client.handle_ext_request(method, params)
            result.try(&.to_json)
          else
            raise ::ACP::RpcError.method_not_found(method)
          end
        end
      end

      protected def handle_notification(method : String, params : JSON::Any?) : Nil
        case method
        when "session/update"
          p = UpdateSessionNotification.from_json(params.try(&.to_json) || "null")
          client.handle_session_update(p)
        when "elicitation/complete"
          p = CompleteElicitationNotification.from_json(params.try(&.to_json) || "null")
          client.handle_complete_elicitation(p)
        else
          client.handle_ext_notification(method, params) if method.starts_with?("_")
        end
      end

      private def parse_params(params : JSON::Any?, as type : T.class, & : T -> _) : String? forall T
        parsed = T.from_json(params.try(&.to_json) || "null")
        yield(parsed).to_json
      end
    end
  end
end
