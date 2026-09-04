# spec/connection_spec.cr
require "spec"
require "../src/acp"

# An in-memory agent used for connection tests.
private class TestAgent < ACP::Agent
  getter cancelled_sessions = [] of String

  def handle_initialize(params : ACP::InitializeRequest) : ACP::InitializeResponse
    ACP::InitializeResponse.new(
      protocol_version: ACP::PROTOCOL_VERSION,
      agent_capabilities: ACP::AgentCapabilities.new,
      agent_info: ACP::Implementation.new(name: "test-agent", version: "0.1.0"),
    )
  end

  def handle_new_session(params : ACP::NewSessionRequest) : ACP::NewSessionResponse
    ACP::NewSessionResponse.new(session_id: "sess-1")
  end

  def handle_prompt(params : ACP::PromptRequest) : ACP::PromptResponse
    # Stream an update, ask for permission, read a file, then end the turn.
    connection.session_update(params.session_id, ACP::ContentChunk.new(
      session_update: "agent_message_chunk",
      content: ACP::TextContent.new(text: "working..."),
    ))

    outcome = connection.request_permission(ACP::RequestPermissionRequest.new(
      session_id: params.session_id,
      tool_call: ACP::ToolCallUpdate.new(tool_call_id: "tc-1", title: "Read file"),
      options: [
        ACP::PermissionOption.new(option_id: "allow", name: "Allow", kind: ACP::PermissionOptionKind::AllowOnce),
      ],
    ))

    content = connection.read_text_file(ACP::ReadTextFileRequest.new(
      session_id: params.session_id, path: "/tmp/x.txt",
    ))

    if outcome.outcome.is_a?(ACP::SelectedPermissionOutcome) && content.content == "file-body"
      ACP::PromptResponse.new(stop_reason: ACP::StopReason::EndTurn)
    else
      ACP::PromptResponse.new(stop_reason: ACP::StopReason::Refusal)
    end
  end

  def handle_cancel(params : ACP::CancelNotification) : Nil
    @cancelled_sessions << params.session_id
  end

  def handle_ext_request(method : String, params : JSON::Any?) : JSON::Any?
    JSON.parse(%({"echo": #{method.to_json}}))
  end
end

# An in-memory client used for connection tests.
private class TestClient < ACP::Client
  getter updates = [] of ACP::SessionNotification

  def handle_session_update(notification : ACP::SessionNotification) : Nil
    @updates << notification
  end

  def handle_request_permission(params : ACP::RequestPermissionRequest) : ACP::RequestPermissionResponse
    ACP::RequestPermissionResponse.new(
      outcome: ACP::SelectedPermissionOutcome.new(option_id: params.options.first.option_id)
    )
  end

  def handle_read_text_file(params : ACP::ReadTextFileRequest) : ACP::ReadTextFileResponse
    ACP::ReadTextFileResponse.new(content: "file-body")
  end

  def handle_ext_request(method : String, params : JSON::Any?) : JSON::Any?
    JSON.parse(%({"echo": #{method.to_json}}))
  end
end

# Creates an agent/client pair connected through in-memory pipes.
private def connect
  client_in, agent_out = IO.pipe # agent -> client
  agent_in, client_out = IO.pipe # client -> agent
  agent       = TestAgent.new
  client      = TestClient.new
  agent_conn  = ACP::AgentConnection.new(agent_in, agent_out, agent)
  client_conn = ACP::ClientConnection.new(client_in, client_out, client)
  agent_conn.run_async
  {agent, client, agent_conn, client_conn}
end

describe ACP::Connection do
  it "completes the initialize handshake" do
    agent, client, agent_conn, conn = connect
    begin
      response = conn.initialize_agent(ACP::InitializeRequest.new(
        protocol_version: ACP::PROTOCOL_VERSION,
        client_capabilities: ACP::ClientCapabilities.new,
      ))
      response.protocol_version.should eq 1
      response.agent_info.not_nil!.name.should eq "test-agent"
    ensure
      conn.close
      agent_conn.close
    end
  end

  it "runs a prompt turn with updates and reverse requests" do
    agent, client, agent_conn, conn = connect
    begin
      conn.initialize_agent(ACP::InitializeRequest.new(
        protocol_version: ACP::PROTOCOL_VERSION,
        client_capabilities: ACP::ClientCapabilities.new,
      ))
      session = conn.new_session(ACP::NewSessionRequest.new(cwd: "/tmp", mcp_servers: [] of ACP::McpServer))
      session.session_id.should eq "sess-1"

      response = conn.prompt(ACP::PromptRequest.new(
        session_id: session.session_id,
        prompt: [ACP::TextContent.new(text: "hi")] of ACP::ContentBlock,
      ))
      response.stop_reason.should eq ACP::StopReason::EndTurn

      eventually { client.updates.size.should eq 1 }
      update = client.updates.first
      update.session_id.should eq "sess-1"
      chunk = update.update.should be_a(ACP::ContentChunk)
      chunk.content.as(ACP::TextContent).text.should eq "working..."
    ensure
      conn.close
      agent_conn.close
    end
  end

  it "responds with method not found for unimplemented methods" do
    agent, client, agent_conn, conn = connect
    begin
      conn.initialize_agent(ACP::InitializeRequest.new(
        protocol_version: ACP::PROTOCOL_VERSION,
        client_capabilities: ACP::ClientCapabilities.new,
      ))
      expect_raises(ACP::RpcError, /Method not found/) do
        conn.load_session(ACP::LoadSessionRequest.new(session_id: "nope", cwd: "/tmp", mcp_servers: [] of ACP::McpServer))
      end
      begin
        conn.load_session(ACP::LoadSessionRequest.new(session_id: "nope", cwd: "/tmp", mcp_servers: [] of ACP::McpServer))
      rescue ex : ACP::RpcError
        ex.code.should eq ACP::ErrorCode::MethodNotFound
      end
    ensure
      conn.close
      agent_conn.close
    end
  end

  it "delivers session/cancel notifications to the agent" do
    agent, client, agent_conn, conn = connect
    begin
      conn.cancel(ACP::CancelNotification.new(session_id: "sess-9"))
      eventually { agent.cancelled_sessions.should eq ["sess-9"] }
    ensure
      conn.close
      agent_conn.close
    end
  end

  it "supports extension requests in both directions" do
    agent, client, agent_conn, conn = connect
    begin
      result = conn.send_ext_request("_custom.method", JSON.parse(%({"a":1})))
      result.not_nil!["echo"].as_s.should eq "_custom.method"
    ensure
      conn.close
      agent_conn.close
    end
  end

  it "tracks protocol-level cancellation of requests" do
    agent, client, agent_conn, conn = connect
    begin
      conn.send_cancel_request(12345_i64)
      eventually { agent_conn.cancel_requested?(12345_i64).should be_true }
    ensure
      conn.close
      agent_conn.close
    end
  end
end

# Polls the block until it passes or a deadline expires.
private def eventually(&)
  deadline = Time.instant + 5.seconds
  loop do
    begin
      yield
      return
    rescue ex
      raise ex if Time.instant > deadline
      sleep 1.millisecond
    end
  end
end
