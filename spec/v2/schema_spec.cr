# spec/v2/schema_spec.cr
require "spec"
require "../../src/acp"

describe "ACP::V2 schema types" do
  describe "open string enums" do
    it "serializes known values" do
      ACP::V2::ToolKind::SwitchMode.to_json.should eq %("switch_mode")
      ACP::V2::StopReason::EndTurn.to_json.should eq %("end_turn")
      ACP::V2::Role::Assistant.to_json.should eq %("assistant")
    end

    it "preserves unknown values" do
      kind = ACP::V2::ToolKind.from_json(%("_custom_tool"))
      kind.value.should eq "_custom_tool"
      kind.to_json.should eq %("_custom_tool")
    end

    it "exposes known values as constants" do
      ACP::V2::ToolKind::Read.value.should eq "read"
      ACP::V2::StopReason.from_json(%("cancelled")).should eq ACP::V2::StopReason::Cancelled
      ACP::V2::PlanEntryPriority.from_json(%("high")).should eq ACP::V2::PlanEntryPriority::High
    end
  end

  describe "ContentBlock" do
    it "parses known variants" do
      ACP::V2::ContentBlock.from_json(%({"type":"text","text":"hi"})).should be_a(ACP::V2::TextContent)
      ACP::V2::ContentBlock.from_json(%({"type":"image","data":"aQ==","mimeType":"image/png"})).should be_a(ACP::V2::ImageContent)
    end

    it "preserves unknown variants with their raw payload" do
      raw   = %({"type":"_video","url":"https://x"})
      block = ACP::V2::ContentBlock.from_json(raw)
      block.should be_a(ACP::V2::UnknownContentBlock)
      block.as(ACP::V2::UnknownContentBlock).type.should eq "_video"
      block.to_json.should eq raw
    end
  end

  describe "SessionUpdate" do
    it "parses message chunks (messageId is required in v2)" do
      update = ACP::V2::SessionUpdate.from_json(%({
        "sessionUpdate":"agent_message_chunk","messageId":"m1",
        "content":{"type":"text","text":"hello"}
      }))
      chunk = update.should be_a(ACP::V2::ContentChunk)
      chunk.message_id.should eq "m1"
    end

    it "parses whole-message upserts" do
      update = ACP::V2::SessionUpdate.from_json(%({
        "sessionUpdate":"agent_message","messageId":"m1",
        "content":[{"type":"text","text":"full message"}]
      }))
      message = update.should be_a(ACP::V2::AgentMessage)
      message.content.not_nil!.first.should be_a(ACP::V2::TextContent)
    end

    it "parses state updates and reads the idle stop reason" do
      update = ACP::V2::SessionUpdate.from_json(%({
        "sessionUpdate":"state_update","state":"idle","stopReason":"end_turn"
      }))
      state = update.should be_a(ACP::V2::IdleStateUpdate)
      state.stop_reason.should eq ACP::V2::StopReason::EndTurn

      ACP::V2::SessionUpdate.from_json(%({"sessionUpdate":"state_update","state":"running"}))
        .should be_a(ACP::V2::RunningStateUpdate)
    end

    it "parses the unified tool call upsert and content chunks" do
      update = ACP::V2::SessionUpdate.from_json(%({
        "sessionUpdate":"tool_call_update","toolCallId":"t1","title":"Read","kind":"read","status":"in_progress"
      }))
      tool_call = update.should be_a(ACP::V2::ToolCallUpdate)
      tool_call.kind.should eq ACP::V2::ToolKind::Read
      tool_call.status.should eq ACP::V2::ToolCallStatus::InProgress

      chunk = ACP::V2::SessionUpdate.from_json(%({
        "sessionUpdate":"tool_call_content_chunk","toolCallId":"t1",
        "content":{"type":"content","content":{"type":"text","text":"out"}}
      }))
      chunk.should be_a(ACP::V2::ToolCallContentChunk)
    end

    it "parses terminal updates and output chunks" do
      update = ACP::V2::SessionUpdate.from_json(%({
        "sessionUpdate":"terminal_update","terminalId":"term-1","command":"make",
        "cwd":"/src","exitStatus":{"exitCode":0}
      }))
      terminal = update.should be_a(ACP::V2::TerminalUpdate)
      terminal.exit_status.not_nil!.exit_code.should eq 0

      chunk = ACP::V2::SessionUpdate.from_json(%({
        "sessionUpdate":"terminal_output_chunk","terminalId":"term-1","data":"aGVsbG8="
      }))
      chunk.should be_a(ACP::V2::TerminalOutputChunk)
    end

    it "parses item-based plan updates" do
      update = ACP::V2::SessionUpdate.from_json(%({
        "sessionUpdate":"plan_update",
        "plan":{"type":"items","planId":"p1","entries":[{"content":"step","priority":"high","status":"pending"}]}
      }))
      plan  = update.should be_a(ACP::V2::PlanUpdate)
      items = plan.plan.should be_a(ACP::V2::PlanItems)
      items.plan_id.should eq "p1"
      items.entries.first.priority.should eq ACP::V2::PlanEntryPriority::High
    end

    it "preserves unknown updates" do
      raw    = %({"sessionUpdate":"_compaction","sessionId":"s","tokens":100})
      update = ACP::V2::SessionUpdate.from_json(raw)
      update.should be_a(ACP::V2::UnknownSessionUpdate)
      update.as(ACP::V2::UnknownSessionUpdate).session_update.should eq "_compaction"
      update.to_json.should eq raw
    end
  end

  describe "diffs" do
    it "parses path changes and path pair changes" do
      add = ACP::V2::DiffChange.from_json(%({"operation":"add","path":"/a.cr"}))
      add.should be_a(ACP::V2::DiffPathChange)
      move = ACP::V2::DiffChange.from_json(%({"operation":"move","oldPath":"/a.cr","path":"/b.cr"}))
      move.should be_a(ACP::V2::DiffPathPairChange)
      move.as(ACP::V2::DiffPathPairChange).old_path.should eq "/a.cr"
    end

    it "parses a diff with patch and changes" do
      diff = ACP::V2::Diff.from_json(%({
        "type":"diff",
        "patch":{"format":"git_patch","text":"@@ -1 +1 @@"},
        "changes":[{"operation":"modify","path":"/a.cr"}]
      }))
      diff.patch.not_nil!.format.should eq ACP::V2::DiffPatchFormat::GitPatch
      diff.changes.size.should eq 1
    end
  end

  describe "McpServer" do
    it "requires an explicit type discriminator, including stdio" do
      stdio = ACP::V2::McpServer.from_json(%({"type":"stdio","name":"fs","command":"/usr/bin/mcp-fs","args":[],"env":[]}))
      stdio.should be_a(ACP::V2::McpServerStdio)
      http = ACP::V2::McpServer.from_json(%({"type":"http","name":"h","url":"https://x","headers":[]}))
      http.should be_a(ACP::V2::McpServerHttp)
    end

    it "preserves unknown transports" do
      raw    = %({"type":"_quic","name":"q"})
      server = ACP::V2::McpServer.from_json(raw)
      server.should be_a(ACP::V2::UnknownMcpServer)
      server.to_json.should eq raw
    end
  end

  describe "permission requests" do
    it "parses tool call and command subjects" do
      subject = ACP::V2::RequestPermissionSubject.from_json(%({
        "type":"tool_call","toolCall":{"toolCallId":"t1","title":"Run"}
      }))
      subject.as(ACP::V2::ToolCallPermissionSubject).tool_call.title.should eq "Run"

      command = ACP::V2::RequestPermissionSubject.from_json(%({
        "type":"command","command":"rm -rf /tmp/x","cwd":"/tmp"
      }))
      command.should be_a(ACP::V2::CommandPermissionSubject)
    end

    it "parses outcomes including unknown ones" do
      ACP::V2::RequestPermissionOutcome.from_json(%({"outcome":"cancelled"}))
        .should be_a(ACP::V2::CancelledPermissionOutcome)
      ACP::V2::RequestPermissionOutcome.from_json(%({"outcome":"selected","optionId":"a"}))
        .should be_a(ACP::V2::SelectedPermissionOutcome)
      ACP::V2::RequestPermissionOutcome.from_json(%({"outcome":"_deferred"}))
        .should be_a(ACP::V2::UnknownPermissionOutcome)
    end
  end

  describe "session config options" do
    it "parses select and boolean options with configId" do
      option = ACP::V2::SessionConfigOption.from_json(%({
        "configId":"model","name":"Model","type":"select","currentValue":"gpt-5",
        "category":"model",
        "options":[{"value":"gpt-5","name":"GPT-5"}]
      }))
      sel = option.should be_a(ACP::V2::SelectConfigOption)
      sel.config_id.should eq "model"
      sel.category.should eq ACP::V2::SessionConfigOptionCategory::Model

      bool = ACP::V2::SessionConfigOption.from_json(%({
        "configId":"verbose","name":"Verbose","type":"boolean","currentValue":true
      }))
      bool.should be_a(ACP::V2::BooleanConfigOption)
    end

    it "parses grouped select options" do
      option = ACP::V2::SessionConfigOption.from_json(%({
        "configId":"model","name":"Model","type":"select","currentValue":"a",
        "options":[{"groupId":"g1","name":"Group","options":[{"value":"a","name":"A"}]}]
      }))
      option.as(ACP::V2::SelectConfigOption).options.should be_a(Array(ACP::V2::SessionConfigSelectGroup))
    end

    it "serializes SetSessionConfigOptionRequest with the right tag" do
      req = ACP::V2::SetSessionConfigOptionRequest.new(session_id: "s", config_id: "c", value: "v1")
      req.to_json.should eq %({"sessionId":"s","configId":"c","type":"id","value":"v1"})
      bool = ACP::V2::SetSessionConfigOptionRequest.new(session_id: "s", config_id: "c", value: false)
      bool.to_json.should eq %({"sessionId":"s","configId":"c","type":"boolean","value":false})
      parsed = ACP::V2::SetSessionConfigOptionRequest.from_json(%({"sessionId":"s","configId":"c","type":"boolean","value":true}))
      parsed.value.should be_true
    end
  end

  describe "initialize handshake" do
    it "uses the unified capabilities and info fields" do
      res = ACP::V2::InitializeResponse.from_json(%({
        "protocolVersion":2,
        "info":{"name":"agent","version":"1.0"},
        "capabilities":{"session":{"prompt":{"image":{}}},"auth":{"terminal":{}}},
        "authMethods":[{"type":"agent","methodId":"oauth","name":"Sign in"}]
      }))
      res.protocol_version.should eq 2
      res.info.name.should eq "agent"
      res.capabilities.not_nil!.session.not_nil!.prompt.not_nil!.image.should_not be_nil
      methods = res.auth_methods.should_not be_nil
      methods.first.should be_a(ACP::V2::AuthMethodAgent)
      methods.first.as(ACP::V2::AuthMethodAgent).method_id.should eq "oauth"
    end

    it "round-trips InitializeRequest" do
      req = ACP::V2::InitializeRequest.new(
        protocol_version: ACP::V2::PROTOCOL_VERSION,
        info: ACP::V2::Implementation.new(name: "client", version: "1.0"),
      )
      parsed = ACP::V2::InitializeRequest.from_json(req.to_json)
      parsed.protocol_version.should eq 2
      parsed.info.name.should eq "client"
    end
  end

  describe "elicitation" do
    it "parses form requests and preserves unknown modes" do
      req = ACP::V2::CreateElicitationRequest.from_json(%({
        "mode":"form","message":"Need info","sessionId":"s1",
        "requestedSchema":{"type":"object","properties":{"name":{"type":"string"}}}
      }))
      req.should be_a(ACP::V2::FormElicitationRequest)

      raw     = %({"mode":"_voice","message":"speak"})
      unknown = ACP::V2::CreateElicitationRequest.from_json(raw)
      unknown.should be_a(ACP::V2::UnknownElicitationRequest)
      unknown.to_json.should eq raw
    end

    it "parses responses" do
      accept = ACP::V2::CreateElicitationResponse.from_json(%({"action":"accept","content":{"n":"x"}}))
      accept.should be_a(ACP::V2::AcceptElicitationResponse)
      ACP::V2::CreateElicitationResponse.from_json(%({"action":"decline"}))
        .should be_a(ACP::V2::DeclineElicitationResponse)
    end
  end

  describe "session resume" do
    it "supports the replayFrom cursor" do
      req = ACP::V2::ResumeSessionRequest.from_json(%({
        "sessionId":"s1","cwd":"/src","replayFrom":{"type":"start"}
      }))
      req.replay_from.should be_a(ACP::V2::ReplayFromStart)
    end
  end
end
