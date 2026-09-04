# src/acp/client.cr
module ACP
  # Base class for ACP clients (editors / IDEs).
  #
  # Subclass it and override the `handle_*` methods for the capabilities
  # your client advertises. Unimplemented request methods respond with a
  # JSON-RPC "method not found" error; notifications default to no-ops.
  abstract class Client
    # The connection this client is serving on (available once connected).
    property! connection : ClientConnection

    # Handles a session update streamed by the agent (`session/update`).
    def handle_session_update(notification : SessionNotification) : Nil
    end

    # Handles a permission request from the agent
    # (`session/request_permission`).
    def handle_request_permission(params : RequestPermissionRequest) : RequestPermissionResponse
      raise RpcError.method_not_found("session/request_permission")
    end

    # Reads a text file from the client's file system (`fs/read_text_file`).
    def handle_read_text_file(params : ReadTextFileRequest) : ReadTextFileResponse
      raise RpcError.method_not_found("fs/read_text_file")
    end

    # Writes a text file to the client's file system (`fs/write_text_file`).
    def handle_write_text_file(params : WriteTextFileRequest) : WriteTextFileResponse
      raise RpcError.method_not_found("fs/write_text_file")
    end

    # Creates a terminal (`terminal/create`).
    def handle_create_terminal(params : CreateTerminalRequest) : CreateTerminalResponse
      raise RpcError.method_not_found("terminal/create")
    end

    # Reads terminal output (`terminal/output`).
    def handle_terminal_output(params : TerminalOutputRequest) : TerminalOutputResponse
      raise RpcError.method_not_found("terminal/output")
    end

    # Releases a terminal (`terminal/release`).
    def handle_release_terminal(params : ReleaseTerminalRequest) : ReleaseTerminalResponse
      raise RpcError.method_not_found("terminal/release")
    end

    # Waits for a terminal command to exit (`terminal/wait_for_exit`).
    def handle_wait_for_terminal_exit(params : WaitForTerminalExitRequest) : WaitForTerminalExitResponse
      raise RpcError.method_not_found("terminal/wait_for_exit")
    end

    # Kills a terminal command (`terminal/kill`).
    def handle_kill_terminal(params : KillTerminalRequest) : KillTerminalResponse
      raise RpcError.method_not_found("terminal/kill")
    end

    # Handles an elicitation request (`elicitation/create`).
    def handle_create_elicitation(params : CreateElicitationRequest) : CreateElicitationResponse
      raise RpcError.method_not_found("elicitation/create")
    end

    # Handles an elicitation completion (`elicitation/complete` notification).
    def handle_complete_elicitation(notification : CompleteElicitationNotification) : Nil
    end

    # Handles an extension method request (methods beginning with `_`).
    def handle_ext_request(method : String, params : JSON::Any?) : JSON::Any?
      raise RpcError.method_not_found(method)
    end

    # Handles an extension notification (methods beginning with `_`).
    def handle_ext_notification(method : String, params : JSON::Any?) : Nil
    end
  end

  # A `Client` implementation that ignores all notifications and rejects
  # all requests. Used by `ClientConnection.spawn` when no client is given.
  class NullClient < Client
  end

  # Client-side connection: sends requests to an agent and dispatches
  # agent requests and notifications to a `Client` implementation.
  #
  # Typically created via `ClientConnection.spawn` to launch the agent as
  # a subprocess:
  #
  # ```
  # conn = ACP::ClientConnection.spawn("my-agent", client: MyClient.new)
  # info = conn.initialize_agent(ACP::InitializeRequest.new(...))
  # session = conn.new_session(ACP::NewSessionRequest.new(cwd: "/tmp", mcp_servers: [] of ACP::McpServer))
  # ```
  class ClientConnection < Connection
    getter client : Client

    def initialize(input : IO, output : IO, @client : Client)
      super(input, output)
      @client.connection = self
      run_async
    end

    # Launches *command* as a subprocess and connects to it over stdio.
    #
    # The agent's stderr is inherited by default (useful for logging);
    # pass `error: Process::Redirect::Pipe` and read `#process.error` to
    # capture it instead.
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

    # ------------------------------------------------------------------
    # Requests the client can send to the agent
    # ------------------------------------------------------------------

    # Negotiates the protocol version and exchanges capabilities
    # (`initialize`). Must be the first request sent on the connection.
    def initialize_agent(params : InitializeRequest) : InitializeResponse
      send_request("initialize", params, as: InitializeResponse)
    end

    # Authenticates with the agent (`authenticate`).
    def authenticate(params : AuthenticateRequest) : AuthenticateResponse
      send_request("authenticate", params, as: AuthenticateResponse)
    end

    # Logs out of the agent (`logout`).
    def logout(params : LogoutRequest) : LogoutResponse
      send_request("logout", params, as: LogoutResponse)
    end

    # Creates a new conversation session (`session/new`).
    def new_session(params : NewSessionRequest) : NewSessionResponse
      send_request("session/new", params, as: NewSessionResponse)
    end

    # Resumes an existing session (`session/load`).
    def load_session(params : LoadSessionRequest) : LoadSessionResponse
      send_request("session/load", params, as: LoadSessionResponse)
    end

    # Lists existing sessions (`session/list`).
    def list_sessions(params : ListSessionsRequest) : ListSessionsResponse
      send_request("session/list", params, as: ListSessionsResponse)
    end

    # Deletes a session (`session/delete`).
    def delete_session(params : DeleteSessionRequest) : DeleteSessionResponse
      send_request("session/delete", params, as: DeleteSessionResponse)
    end

    # Resumes a session without replaying the conversation (`session/resume`).
    def resume_session(params : ResumeSessionRequest) : ResumeSessionResponse
      send_request("session/resume", params, as: ResumeSessionResponse)
    end

    # Closes a session (`session/close`).
    def close_session(params : CloseSessionRequest) : CloseSessionResponse
      send_request("session/close", params, as: CloseSessionResponse)
    end

    # Sets the session mode (`session/set_mode`).
    def set_session_mode(params : SetSessionModeRequest) : SetSessionModeResponse
      send_request("session/set_mode", params, as: SetSessionModeResponse)
    end

    # Sets a session configuration option (`session/set_config_option`).
    def set_session_config_option(params : SetSessionConfigOptionRequest) : SetSessionConfigOptionResponse
      send_request("session/set_config_option", params, as: SetSessionConfigOptionResponse)
    end

    # Sends a user prompt to the agent (`session/prompt`).
    #
    # Blocks until the agent finishes the prompt turn and returns its
    # stop reason. Session updates arrive via
    # `Client#handle_session_update` in the meantime.
    def prompt(params : PromptRequest) : PromptResponse
      send_request("session/prompt", params, as: PromptResponse)
    end

    # Cancels ongoing operations for a session (`session/cancel`).
    def cancel(params : CancelNotification) : Nil
      send_notification("session/cancel", params)
    end

    # Cancels ongoing operations for a session (`session/cancel`).
    def cancel(session_id : SessionId) : Nil
      send_notification("session/cancel", CancelNotification.new(session_id: session_id))
    end

    protected def handle_request(method : String, params : JSON::Any?) : String?
      case method
      when "session/request_permission"
        parse_params(params, RequestPermissionRequest) { |p| client.handle_request_permission(p) }
      when "fs/read_text_file"
        parse_params(params, ReadTextFileRequest) { |p| client.handle_read_text_file(p) }
      when "fs/write_text_file"
        parse_params(params, WriteTextFileRequest) { |p| client.handle_write_text_file(p) }
      when "terminal/create"
        parse_params(params, CreateTerminalRequest) { |p| client.handle_create_terminal(p) }
      when "terminal/output"
        parse_params(params, TerminalOutputRequest) { |p| client.handle_terminal_output(p) }
      when "terminal/release"
        parse_params(params, ReleaseTerminalRequest) { |p| client.handle_release_terminal(p) }
      when "terminal/wait_for_exit"
        parse_params(params, WaitForTerminalExitRequest) { |p| client.handle_wait_for_terminal_exit(p) }
      when "terminal/kill"
        parse_params(params, KillTerminalRequest) { |p| client.handle_kill_terminal(p) }
      when "elicitation/create"
        parse_params(params, CreateElicitationRequest) { |p| client.handle_create_elicitation(p) }
      else
        if method.starts_with?("_")
          result = client.handle_ext_request(method, params)
          result.try(&.to_json)
        else
          raise RpcError.method_not_found(method)
        end
      end
    end

    protected def handle_notification(method : String, params : JSON::Any?) : Nil
      case method
      when "session/update"
        p = SessionNotification.from_json(params.try(&.to_json) || "null")
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
