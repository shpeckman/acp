# spec/v2/connection_spec.cr
require "spec"
require "../../src/acp"

# An in-memory v2 agent used for connection tests.
private class TestV2Agent < ACP::V2::Agent
  getter cancelled_sessions = [] of String

  def handle_initialize(params : ACP::V2::InitializeRequest) : ACP::V2::InitializeResponse
    ACP::V2::InitializeResponse.new(
      protocol_version: ACP::V2::PROTOCOL_VERSION,
      info: ACP::V2::Implementation.new(name: "test-v2-agent", version: "0.1.0"),
      capabilities: ACP::V2::AgentCapabilities.new(
        session: ACP::V2::SessionCapabilities.new(
          prompt: ACP::V2::PromptCapabilities.new(image: ACP::V2::PromptImageCapabilities.new)
        )
      ),
    )
  end

  def handle_new_session(params : ACP::V2::NewSessionRequest) : ACP::V2::NewSessionResponse
    ACP::V2::NewSessionResponse.new(session_id: "v2-sess-1")
  end

  def handle_resume_session(params : ACP::V2::ResumeSessionRequest) : ACP::V2::ResumeSessionResponse
    ACP::V2::ResumeSessionResponse.new
  end

  def handle_prompt(params : ACP::V2::PromptRequest) : ACP::V2::PromptResponse
    connection.session_update(params.session_id, ACP::V2::ContentChunk.new(
      session_update: "agent_message_chunk",
      message_id: "m1",
      content: ACP::V2::TextContent.new(text: "working..."),
    ))

    outcome = connection.request_permission(ACP::V2::RequestPermissionRequest.new(
      session_id: params.session_id,
      title: "Allow tool?",
      subject: ACP::V2::ToolCallPermissionSubject.new(
        tool_call: ACP::V2::ToolCallUpdate.new(tool_call_id: "tc-1", title: "Run tests")
      ),
      options: [
        ACP::V2::PermissionOption.new(option_id: "allow", name: "Allow", kind: ACP::V2::PermissionOptionKind::AllowOnce),
      ],
    ))

    stop = outcome.outcome.is_a?(ACP::V2::SelectedPermissionOutcome) ? ACP::V2::StopReason::EndTurn : ACP::V2::StopReason::Refusal

    # v2 reports the stop reason via an idle state update.
    connection.session_update(params.session_id, ACP::V2::IdleStateUpdate.new(stop_reason: stop))

    ACP::V2::PromptResponse.new
  end

  def handle_cancel(params : ACP::V2::CancelSessionNotification) : Nil
    @cancelled_sessions << params.session_id
  end
end

# An in-memory v2 client used for connection tests.
private class TestV2Client < ACP::V2::Client
  getter updates = [] of ACP::V2::UpdateSessionNotification

  def handle_session_update(notification : ACP::V2::UpdateSessionNotification) : Nil
    @updates << notification
  end

  def handle_request_permission(params : ACP::V2::RequestPermissionRequest) : ACP::V2::RequestPermissionResponse
    ACP::V2::RequestPermissionResponse.new(
      outcome: ACP::V2::SelectedPermissionOutcome.new(option_id: params.options.first.option_id)
    )
  end
end

private def connect_v2
  client_in, agent_out = IO.pipe
  agent_in, client_out = IO.pipe
  agent       = TestV2Agent.new
  client      = TestV2Client.new
  agent_conn  = ACP::V2::AgentConnection.new(agent_in, agent_out, agent)
  client_conn = ACP::V2::ClientConnection.new(client_in, client_out, client)
  agent_conn.run_async
  {agent, client, agent_conn, client_conn}
end

describe "ACP::V2 connection" do
  it "completes the v2 initialize handshake" do
    agent, client, agent_conn, conn = connect_v2
    begin
      response = conn.initialize_agent(ACP::V2::InitializeRequest.new(
        protocol_version: ACP::V2::PROTOCOL_VERSION,
        info: ACP::V2::Implementation.new(name: "test-client", version: "0.1.0"),
      ))
      response.protocol_version.should eq 2
      response.info.name.should eq "test-v2-agent"
      response.capabilities.not_nil!.session.not_nil!.prompt.not_nil!.image.should_not be_nil
    ensure
      conn.close
      agent_conn.close
    end
  end

  it "runs a v2 prompt turn with updates and permission subject" do
    agent, client, agent_conn, conn = connect_v2
    begin
      conn.initialize_agent(ACP::V2::InitializeRequest.new(
        protocol_version: ACP::V2::PROTOCOL_VERSION,
        info: ACP::V2::Implementation.new(name: "test-client", version: "0.1.0"),
      ))
      session = conn.new_session(ACP::V2::NewSessionRequest.new(cwd: "/tmp"))
      session.session_id.should eq "v2-sess-1"

      conn.prompt(ACP::V2::PromptRequest.new(
        session_id: session.session_id,
        prompt: [ACP::V2::TextContent.new(text: "hi")] of ACP::V2::ContentBlock,
      ))

      eventually_v2 { client.updates.size.should eq 2 }
      client.updates[0].update.should be_a(ACP::V2::ContentChunk)
      idle = client.updates[1].update.should be_a(ACP::V2::IdleStateUpdate)
      idle.stop_reason.should eq ACP::V2::StopReason::EndTurn
    ensure
      conn.close
      agent_conn.close
    end
  end

  it "resumes sessions with replayFrom" do
    agent, client, agent_conn, conn = connect_v2
    begin
      conn.resume_session(ACP::V2::ResumeSessionRequest.new(
        session_id: "s1",
        cwd: "/tmp",
        replay_from: ACP::V2::ReplayFromStart.new,
      ))
    ensure
      conn.close
      agent_conn.close
    end
  end

  it "delivers session/cancel notifications" do
    agent, client, agent_conn, conn = connect_v2
    begin
      conn.cancel("sess-7")
      eventually_v2 { agent.cancelled_sessions.should eq ["sess-7"] }
    ensure
      conn.close
      agent_conn.close
    end
  end
end

private def eventually_v2(&)
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
