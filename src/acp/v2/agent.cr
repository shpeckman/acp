# src/acp/v2/agent.cr
module ACP
  module V2
    # Base class for ACP v2 agents (schema 2.0.0-alpha).
    #
    # Subclass it and override the `handle_*` methods for the methods your
    # agent supports. Unimplemented methods respond with a JSON-RPC
    # "method not found" error, except `handle_cancel` which defaults to a
    # no-op.
    #
    # Note that in v2 the stop reason is reported via an idle
    # `StateUpdate` (`IdleStateUpdate#stop_reason`) streamed with
    # `session/update` before the `session/prompt` response, not in the
    # `PromptResponse` itself.
    abstract class Agent
      # The connection this agent is serving on (available once serving).
      property! connection : AgentConnection

      # Negotiates the protocol version and exchanges capabilities.
      def handle_initialize(params : InitializeRequest) : InitializeResponse
        raise ::ACP::RpcError.method_not_found("initialize")
      end

      # Authenticates with the agent (`auth/login`).
      def handle_login(params : LoginAuthRequest) : LoginAuthResponse
        raise ::ACP::RpcError.method_not_found("auth/login")
      end

      # Logs out of the agent (`auth/logout`).
      def handle_logout(params : LogoutAuthRequest) : LogoutAuthResponse
        raise ::ACP::RpcError.method_not_found("auth/logout")
      end

      # Creates a new conversation session (`session/new`).
      def handle_new_session(params : NewSessionRequest) : NewSessionResponse
        raise ::ACP::RpcError.method_not_found("session/new")
      end

      # Lists existing sessions (`session/list`).
      def handle_list_sessions(params : ListSessionsRequest) : ListSessionsResponse
        raise ::ACP::RpcError.method_not_found("session/list")
      end

      # Deletes a session (`session/delete`).
      def handle_delete_session(params : DeleteSessionRequest) : DeleteSessionResponse
        raise ::ACP::RpcError.method_not_found("session/delete")
      end

      # Resumes a session, optionally replaying from a cursor
      # (`session/resume`).
      def handle_resume_session(params : ResumeSessionRequest) : ResumeSessionResponse
        raise ::ACP::RpcError.method_not_found("session/resume")
      end

      # Closes a session and frees its resources (`session/close`).
      def handle_close_session(params : CloseSessionRequest) : CloseSessionResponse
        raise ::ACP::RpcError.method_not_found("session/close")
      end

      # Sets a session configuration option (`session/set_config_option`).
      def handle_set_session_config_option(params : SetSessionConfigOptionRequest) : SetSessionConfigOptionResponse
        raise ::ACP::RpcError.method_not_found("session/set_config_option")
      end

      # Processes a user prompt turn (`session/prompt`).
      def handle_prompt(params : PromptRequest) : PromptResponse
        raise ::ACP::RpcError.method_not_found("session/prompt")
      end

      # Cancels ongoing operations for a session (`session/cancel`
      # notification). Default implementation does nothing.
      def handle_cancel(params : CancelSessionNotification) : Nil
      end

      # Handles an extension method request (methods beginning with `_`).
      def handle_ext_request(method : String, params : JSON::Any?) : JSON::Any?
        raise ::ACP::RpcError.method_not_found(method)
      end

      # Handles an extension notification (methods beginning with `_`).
      def handle_ext_notification(method : String, params : JSON::Any?) : Nil
      end
    end

    # Server-side v2 connection: reads client messages from an input
    # stream, dispatches them to a `V2::Agent`, and sends agent requests
    # and notifications to the client.
    class AgentConnection < ::ACP::Connection
      getter agent : Agent

      def initialize(input : IO, output : IO, @agent : Agent)
        super(input, output)
        @agent.connection = self
      end

      # ----------------------------------------------------------------
      # Requests the agent can send to the client
      # ----------------------------------------------------------------

      # Asks the user for permission to run an operation
      # (`session/request_permission`).
      def request_permission(params : RequestPermissionRequest) : RequestPermissionResponse
        send_request("session/request_permission", params, as: RequestPermissionResponse)
      end

      # Requests structured user input from the client (`elicitation/create`).
      def create_elicitation(params : CreateElicitationRequest) : CreateElicitationResponse
        send_request("elicitation/create", params, as: CreateElicitationResponse)
      end

      # ----------------------------------------------------------------
      # Notifications the agent can send to the client
      # ----------------------------------------------------------------

      # Streams a session update to the client (`session/update`).
      def session_update(session_id : SessionId, update : SessionUpdate) : Nil
        send_notification("session/update", UpdateSessionNotification.new(session_id: session_id, update: update))
      end

      # Streams a session update to the client (`session/update`).
      def session_update(notification : UpdateSessionNotification) : Nil
        send_notification("session/update", notification)
      end

      # Completes a URL-mode elicitation (`elicitation/complete`).
      def complete_elicitation(notification : CompleteElicitationNotification) : Nil
        send_notification("elicitation/complete", notification)
      end

      protected def handle_request(method : String, params : JSON::Any?) : String?
        case method
        when "initialize"
          parse_params(params, InitializeRequest) { |p| agent.handle_initialize(p) }
        when "auth/login"
          parse_params(params, LoginAuthRequest) { |p| agent.handle_login(p) }
        when "auth/logout"
          parse_params(params, LogoutAuthRequest) { |p| agent.handle_logout(p) }
        when "session/new"
          parse_params(params, NewSessionRequest) { |p| agent.handle_new_session(p) }
        when "session/list"
          parse_params(params, ListSessionsRequest) { |p| agent.handle_list_sessions(p) }
        when "session/delete"
          parse_params(params, DeleteSessionRequest) { |p| agent.handle_delete_session(p) }
        when "session/resume"
          parse_params(params, ResumeSessionRequest) { |p| agent.handle_resume_session(p) }
        when "session/close"
          parse_params(params, CloseSessionRequest) { |p| agent.handle_close_session(p) }
        when "session/set_config_option"
          parse_params(params, SetSessionConfigOptionRequest) { |p| agent.handle_set_session_config_option(p) }
        when "session/prompt"
          parse_params(params, PromptRequest) { |p| agent.handle_prompt(p) }
        else
          if method.starts_with?("_")
            result = agent.handle_ext_request(method, params)
            result.try(&.to_json)
          else
            raise ::ACP::RpcError.method_not_found(method)
          end
        end
      end

      protected def handle_notification(method : String, params : JSON::Any?) : Nil
        case method
        when "session/cancel"
          p = CancelSessionNotification.from_json(params.try(&.to_json) || "null")
          agent.handle_cancel(p)
        else
          agent.handle_ext_notification(method, params) if method.starts_with?("_")
        end
      end

      private def parse_params(params : JSON::Any?, as type : T.class, & : T -> _) : String? forall T
        parsed = T.from_json(params.try(&.to_json) || "null")
        yield(parsed).to_json
      end
    end

    # Serves a v2 *agent* on the given input/output streams (stdio by
    # default), blocking until the client closes the connection.
    def self.serve_stdio(agent : Agent, input : IO = STDIN, output : IO = STDOUT) : Nil
      AgentConnection.new(input, output, agent).run
    end
  end
end
