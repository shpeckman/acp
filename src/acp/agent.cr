# src/acp/agent.cr
module ACP
  # Base class for ACP agents.
  #
  # Subclass it and override the `handle_*` methods for the methods your
  # agent supports. Unimplemented methods respond with a JSON-RPC
  # "method not found" error, except `handle_cancel` which defaults to a
  # no-op.
  #
  # Use an `AgentConnection` (via `Agent#connection`, set by
  # `AgentConnection.new`/`ACP.serve_stdio`) to send requests and
  # notifications to the client, e.g. `connection.session_update(...)`.
  abstract class Agent
    # The connection this agent is serving on (available once serving).
    property! connection : AgentConnection

    # Negotiates the protocol version and exchanges capabilities.
    def handle_initialize(params : InitializeRequest) : InitializeResponse
      raise RpcError.method_not_found("initialize")
    end

    # Authenticates with the agent (`authenticate`).
    def handle_authenticate(params : AuthenticateRequest) : AuthenticateResponse
      raise RpcError.method_not_found("authenticate")
    end

    # Logs out of the agent (`logout`).
    def handle_logout(params : LogoutRequest) : LogoutResponse
      raise RpcError.method_not_found("logout")
    end

    # Creates a new conversation session (`session/new`).
    def handle_new_session(params : NewSessionRequest) : NewSessionResponse
      raise RpcError.method_not_found("session/new")
    end

    # Resumes an existing session (`session/load`).
    def handle_load_session(params : LoadSessionRequest) : LoadSessionResponse
      raise RpcError.method_not_found("session/load")
    end

    # Lists existing sessions (`session/list`).
    def handle_list_sessions(params : ListSessionsRequest) : ListSessionsResponse
      raise RpcError.method_not_found("session/list")
    end

    # Deletes a session (`session/delete`).
    def handle_delete_session(params : DeleteSessionRequest) : DeleteSessionResponse
      raise RpcError.method_not_found("session/delete")
    end

    # Resumes a session without replaying the conversation (`session/resume`).
    def handle_resume_session(params : ResumeSessionRequest) : ResumeSessionResponse
      raise RpcError.method_not_found("session/resume")
    end

    # Closes a session and frees its resources (`session/close`).
    def handle_close_session(params : CloseSessionRequest) : CloseSessionResponse
      raise RpcError.method_not_found("session/close")
    end

    # Sets the session mode (`session/set_mode`).
    def handle_set_session_mode(params : SetSessionModeRequest) : SetSessionModeResponse
      raise RpcError.method_not_found("session/set_mode")
    end

    # Sets a session configuration option (`session/set_config_option`).
    def handle_set_session_config_option(params : SetSessionConfigOptionRequest) : SetSessionConfigOptionResponse
      raise RpcError.method_not_found("session/set_config_option")
    end

    # Processes a user prompt turn (`session/prompt`).
    #
    # Implementations typically stream progress via
    # `connection.session_update` and return when the turn ends.
    def handle_prompt(params : PromptRequest) : PromptResponse
      raise RpcError.method_not_found("session/prompt")
    end

    # Cancels ongoing operations for a session (`session/cancel`
    # notification). Default implementation does nothing.
    def handle_cancel(params : CancelNotification) : Nil
    end

    # Handles an extension method request (methods beginning with `_`).
    def handle_ext_request(method : String, params : JSON::Any?) : JSON::Any?
      raise RpcError.method_not_found(method)
    end

    # Handles an extension notification (methods beginning with `_`).
    def handle_ext_notification(method : String, params : JSON::Any?) : Nil
    end
  end

  # Server-side connection: reads client messages from an input stream,
  # dispatches them to an `Agent`, and sends agent requests and
  # notifications to the client.
  class AgentConnection < Connection
    getter agent : Agent

    def initialize(input : IO, output : IO, @agent : Agent)
      super(input, output)
      @agent.connection = self
    end

    # ------------------------------------------------------------------
    # Requests the agent can send to the client
    # ------------------------------------------------------------------

    # Asks the user for permission to run a tool call
    # (`session/request_permission`).
    def request_permission(params : RequestPermissionRequest) : RequestPermissionResponse
      send_request("session/request_permission", params, as: RequestPermissionResponse)
    end

    # Reads a text file from the client's file system (`fs/read_text_file`).
    def read_text_file(params : ReadTextFileRequest) : ReadTextFileResponse
      send_request("fs/read_text_file", params, as: ReadTextFileResponse)
    end

    # Writes a text file to the client's file system (`fs/write_text_file`).
    def write_text_file(params : WriteTextFileRequest) : WriteTextFileResponse
      send_request("fs/write_text_file", params, as: WriteTextFileResponse)
    end

    # Creates a terminal in the client (`terminal/create`).
    def create_terminal(params : CreateTerminalRequest) : CreateTerminalResponse
      send_request("terminal/create", params, as: CreateTerminalResponse)
    end

    # Reads output from a terminal (`terminal/output`).
    def terminal_output(params : TerminalOutputRequest) : TerminalOutputResponse
      send_request("terminal/output", params, as: TerminalOutputResponse)
    end

    # Releases a terminal (`terminal/release`).
    def release_terminal(params : ReleaseTerminalRequest) : ReleaseTerminalResponse
      send_request("terminal/release", params, as: ReleaseTerminalResponse)
    end

    # Waits for a terminal command to exit (`terminal/wait_for_exit`).
    def wait_for_terminal_exit(params : WaitForTerminalExitRequest) : WaitForTerminalExitResponse
      send_request("terminal/wait_for_exit", params, as: WaitForTerminalExitResponse)
    end

    # Kills a terminal command without releasing it (`terminal/kill`).
    def kill_terminal(params : KillTerminalRequest) : KillTerminalResponse
      send_request("terminal/kill", params, as: KillTerminalResponse)
    end

    # Requests structured user input from the client (`elicitation/create`).
    def create_elicitation(params : CreateElicitationRequest) : CreateElicitationResponse
      send_request("elicitation/create", params, as: CreateElicitationResponse)
    end

    # ------------------------------------------------------------------
    # Notifications the agent can send to the client
    # ------------------------------------------------------------------

    # Streams a session update to the client (`session/update`).
    def session_update(session_id : SessionId, update : SessionUpdate) : Nil
      send_notification("session/update", SessionNotification.new(session_id: session_id, update: update))
    end

    # Streams a session update to the client (`session/update`).
    def session_update(notification : SessionNotification) : Nil
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
      when "authenticate"
        parse_params(params, AuthenticateRequest) { |p| agent.handle_authenticate(p) }
      when "logout"
        parse_params(params, LogoutRequest) { |p| agent.handle_logout(p) }
      when "session/new"
        parse_params(params, NewSessionRequest) { |p| agent.handle_new_session(p) }
      when "session/load"
        parse_params(params, LoadSessionRequest) { |p| agent.handle_load_session(p) }
      when "session/list"
        parse_params(params, ListSessionsRequest) { |p| agent.handle_list_sessions(p) }
      when "session/delete"
        parse_params(params, DeleteSessionRequest) { |p| agent.handle_delete_session(p) }
      when "session/resume"
        parse_params(params, ResumeSessionRequest) { |p| agent.handle_resume_session(p) }
      when "session/close"
        parse_params(params, CloseSessionRequest) { |p| agent.handle_close_session(p) }
      when "session/set_mode"
        parse_params(params, SetSessionModeRequest) { |p| agent.handle_set_session_mode(p) }
      when "session/set_config_option"
        parse_params(params, SetSessionConfigOptionRequest) { |p| agent.handle_set_session_config_option(p) }
      when "session/prompt"
        parse_params(params, PromptRequest) { |p| agent.handle_prompt(p) }
      else
        if method.starts_with?("_")
          result = agent.handle_ext_request(method, params)
          result.try(&.to_json)
        else
          raise RpcError.method_not_found(method)
        end
      end
    end

    protected def handle_notification(method : String, params : JSON::Any?) : Nil
      case method
      when "session/cancel"
        p = CancelNotification.from_json(params.try(&.to_json) || "null")
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

  # Serves *agent* on the given input/output streams (stdio by default),
  # blocking until the client closes the connection.
  #
  # ```
  # ACP.serve_stdio(MyAgent.new)
  # ```
  def self.serve_stdio(agent : Agent, input : IO = STDIN, output : IO = STDOUT) : Nil
    AgentConnection.new(input, output, agent).run
  end
end
