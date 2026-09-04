# spec/schema_spec.cr
require "spec"
require "../src/acp"

private def round_trip(value)
  value.class.from_json(value.to_json)
end

describe "ACP schema types" do
  describe "string enums" do
    it "serializes to snake_case wire values" do
      ACP::ToolKind::SwitchMode.to_json.should eq %("switch_mode")
      ACP::ToolCallStatus::InProgress.to_json.should eq %("in_progress")
      ACP::StopReason::MaxTurnRequests.to_json.should eq %("max_turn_requests")
      ACP::Role::Assistant.to_json.should eq %("assistant")
      ACP::PermissionOptionKind::AllowAlways.to_json.should eq %("allow_always")
      ACP::PlanEntryPriority::High.to_json.should eq %("high")
      ACP::PlanEntryStatus::Completed.to_json.should eq %("completed")
    end

    it "parses wire values" do
      ACP::ToolKind.from_json(%("read")).should eq ACP::ToolKind::Read
      ACP::StopReason.from_json(%("cancelled")).should eq ACP::StopReason::Cancelled
    end

    it "round-trips the dashed StringFormat member" do
      ACP::StringFormat::DateTime.to_json.should eq %("date-time")
      ACP::StringFormat.from_json(%("date-time")).should eq ACP::StringFormat::DateTime
    end
  end

  describe "RequestId" do
    it "supports integer and string ids" do
      n = ACP::CancelRequestNotification.from_json(%({"requestId": 42}))
      n.request_id.should eq 42_i64
      s = ACP::CancelRequestNotification.from_json(%({"requestId": "abc"}))
      s.request_id.should eq "abc"
    end
  end

  describe "ContentBlock" do
    it "parses the text variant via the type discriminator" do
      block = ACP::ContentBlock.from_json(%({"type":"text","text":"hello"}))
      block.should be_a(ACP::TextContent)
      block.as(ACP::TextContent).text.should eq "hello"
    end

    it "parses every variant" do
      ACP::ContentBlock.from_json(%({"type":"image","data":"aW1n","mimeType":"image/png"})).should be_a(ACP::ImageContent)
      ACP::ContentBlock.from_json(%({"type":"audio","data":"YXVk","mimeType":"audio/wav"})).should be_a(ACP::AudioContent)
      ACP::ContentBlock.from_json(%({"type":"resource_link","uri":"file:///x","name":"x"})).should be_a(ACP::ResourceLink)
      resource = ACP::ContentBlock.from_json(%({"type":"resource","resource":{"uri":"file:///x","text":"body"}}))
      resource.should be_a(ACP::EmbeddedResource)
    end

    it "round-trips" do
      block  = ACP::TextContent.new(text: "hi")
      parsed = ACP::ContentBlock.from_json(block.to_json)
      parsed.should be_a(ACP::TextContent)
      parsed.as(ACP::TextContent).text.should eq "hi"
      parsed.to_json.should eq %({"type":"text","text":"hi"})
    end

    it "rejects unknown variants" do
      expect_raises(JSON::SerializableError) { ACP::ContentBlock.from_json(%({"type":"video"})) }
    end
  end

  describe "SessionUpdate" do
    it "parses message chunks with three discriminator values" do
      %w(user_message_chunk agent_message_chunk agent_thought_chunk).each do |kind|
        update = ACP::SessionUpdate.from_json(%({"sessionUpdate":"#{kind}","content":{"type":"text","text":"x"}}))
        update.should be_a(ACP::ContentChunk)
        update.as(ACP::ContentChunk).session_update.should eq kind
      end
    end

    it "parses tool calls" do
      update = ACP::SessionUpdate.from_json(%({"sessionUpdate":"tool_call","toolCallId":"t1","title":"Read file","kind":"read","status":"pending"}))
      update.should be_a(ACP::ToolCall)
      tool_call = update.as(ACP::ToolCall)
      tool_call.tool_call_id.should eq "t1"
      tool_call.kind.should eq ACP::ToolKind::Read
    end

    it "parses plans and mode updates" do
      plan = ACP::SessionUpdate.from_json(%({"sessionUpdate":"plan","entries":[{"content":"step 1","priority":"high","status":"pending"}]}))
      plan.should be_a(ACP::Plan)
      mode = ACP::SessionUpdate.from_json(%({"sessionUpdate":"current_mode_update","currentModeId":"normal"}))
      mode.should be_a(ACP::CurrentModeUpdate)
    end

    it "round-trips a tool call" do
      tool_call = ACP::ToolCall.new(tool_call_id: "t1", title: "Edit", kind: ACP::ToolKind::Edit)
      parsed    = ACP::SessionUpdate.from_json(tool_call.to_json)
      parsed.should be_a(ACP::ToolCall)
      parsed.as(ACP::ToolCall).title.should eq "Edit"
    end
  end

  describe "ToolCallContent" do
    it "parses content, diff and terminal variants" do
      ACP::ToolCallContent.from_json(%({"type":"content","content":{"type":"text","text":"x"}})).should be_a(ACP::Content)
      ACP::ToolCallContent.from_json(%({"type":"diff","path":"/a.cr","newText":"b"})).should be_a(ACP::Diff)
      ACP::ToolCallContent.from_json(%({"type":"terminal","terminalId":"t1"})).should be_a(ACP::Terminal)
    end
  end

  describe "McpServer" do
    it "parses the stdio variant without a type field" do
      server = ACP::McpServer.from_json(%({"name":"fs","command":"npx","args":["-y","mcp-fs"],"env":[]}))
      server.should be_a(ACP::McpServerStdio)
      server.as(ACP::McpServerStdio).command.should eq "npx"
    end

    it "parses http and sse variants via the type field" do
      ACP::McpServer.from_json(%({"type":"http","name":"h","url":"https://x","headers":[]})).should be_a(ACP::McpServerHttp)
      ACP::McpServer.from_json(%({"type":"sse","name":"s","url":"https://x","headers":[]})).should be_a(ACP::McpServerSse)
    end

    it "round-trips an stdio server" do
      server = ACP::McpServerStdio.new(name: "fs", command: "mcp-fs", args: ["--verbose"], env: [ACP::EnvVariable.new(name: "DEBUG", value: "1")])
      parsed = ACP::McpServer.from_json(server.to_json)
      parsed.should be_a(ACP::McpServerStdio)
      parsed.as(ACP::McpServerStdio).args.should eq ["--verbose"]
    end
  end

  describe "AuthMethod" do
    it "parses the default agent method without a type field" do
      method = ACP::AuthMethod.from_json(%({"id":"oauth","name":"Sign in"}))
      method.should be_a(ACP::AuthMethodAgent)
    end

    it "parses the terminal method via the type field" do
      method = ACP::AuthMethod.from_json(%({"type":"terminal","id":"tui","name":"Terminal login"}))
      method.should be_a(ACP::AuthMethodTerminal)
    end
  end

  describe "RequestPermissionOutcome" do
    it "parses selected and cancelled outcomes" do
      selected = ACP::RequestPermissionOutcome.from_json(%({"outcome":"selected","optionId":"allow"}))
      selected.should be_a(ACP::SelectedPermissionOutcome)
      selected.as(ACP::SelectedPermissionOutcome).option_id.should eq "allow"

      cancelled = ACP::RequestPermissionOutcome.from_json(%({"outcome":"cancelled"}))
      cancelled.should be_a(ACP::CancelledPermissionOutcome)
    end

    it "round-trips the cancelled outcome" do
      ACP::CancelledPermissionOutcome.new.to_json.should eq %({"outcome":"cancelled"})
    end
  end

  describe "SessionConfigOption" do
    it "parses select options with flat and grouped option lists" do
      flat = ACP::SessionConfigOption.from_json(%({
        "id":"model","name":"Model","type":"select","currentValue":"gpt-5",
        "options":[{"value":"gpt-5","name":"GPT-5"}]
      }))
      flat.should be_a(ACP::SelectConfigOption)
      flat.as(ACP::SelectConfigOption).options.should be_a(Array(ACP::SessionConfigSelectOption))

      grouped = ACP::SessionConfigOption.from_json(%({
        "id":"model","name":"Model","type":"select","currentValue":"gpt-5",
        "options":[{"group":"g1","name":"Group 1","options":[{"value":"gpt-5","name":"GPT-5"}]}]
      }))
      grouped.as(ACP::SelectConfigOption).options.should be_a(Array(ACP::SessionConfigSelectGroup))
    end

    it "parses boolean options" do
      option = ACP::SessionConfigOption.from_json(%({"id":"v","name":"Verbose","type":"boolean","currentValue":true}))
      option.should be_a(ACP::BooleanConfigOption)
      option.as(ACP::BooleanConfigOption).current_value.should be_true
    end

    it "parses the open category type" do
      option = ACP::SessionConfigOption.from_json(%({
        "id":"m","name":"M","type":"boolean","currentValue":false,"category":"thought_level"
      }))
      option.as(ACP::BooleanConfigOption).category.should eq ACP::SessionConfigOptionCategory::ThoughtLevel
    end
  end

  describe "SetSessionConfigOptionRequest" do
    it "serializes boolean values with the boolean tag" do
      req = ACP::SetSessionConfigOptionRequest.new(session_id: "s1", config_id: "c1", value: true)
      req.to_json.should eq %({"sessionId":"s1","configId":"c1","value":true,"type":"boolean"})
    end

    it "serializes select values without a tag" do
      req = ACP::SetSessionConfigOptionRequest.new(session_id: "s1", config_id: "c1", value: "gpt-5")
      req.to_json.should eq %({"sessionId":"s1","configId":"c1","value":"gpt-5"})
    end

    it "parses both shapes" do
      bool = ACP::SetSessionConfigOptionRequest.from_json(%({"sessionId":"s","configId":"c","type":"boolean","value":true}))
      bool.value.should be_true
      sel = ACP::SetSessionConfigOptionRequest.from_json(%({"sessionId":"s","configId":"c","value":"v1"}))
      sel.value.should eq "v1"
    end
  end

  describe "elicitation" do
    it "parses a session-scoped form request" do
      req = ACP::CreateElicitationRequest.from_json(%({
        "mode":"form","message":"Need info","sessionId":"s1",
        "requestedSchema":{"type":"object","properties":{"name":{"type":"string"}}}
      }))
      req.should be_a(ACP::FormElicitationRequest)
      form = req.as(ACP::FormElicitationRequest)
      form.requested_schema.properties["name"].should be_a(ACP::StringPropertySchema)
      form.session_id.should eq "s1"
    end

    it "parses a request-scoped url request" do
      req = ACP::CreateElicitationRequest.from_json(%({
        "mode":"url","message":"Open this","elicitationId":"e1","url":"https://x","requestId":7
      }))
      req.should be_a(ACP::UrlElicitationRequest)
      req.as(ACP::UrlElicitationRequest).request_id.should eq 7_i64
    end

    it "preserves unknown modes with their raw payload" do
      raw = %({"mode":"_voice","message":"speak","sessionId":"s1","extra":[1,2]})
      req = ACP::CreateElicitationRequest.from_json(raw)
      req.should be_a(ACP::UnknownElicitationRequest)
      req.mode.should eq "_voice"
      req.to_json.should eq raw
    end

    it "parses elicitation responses" do
      accept = ACP::CreateElicitationResponse.from_json(%({"action":"accept","content":{"name":"kim","age":3,"ok":true,"tags":["a","b"],"score":1.5}}))
      accept.should be_a(ACP::AcceptElicitationResponse)
      content = accept.as(ACP::AcceptElicitationResponse).content.not_nil!
      content["name"].should eq "kim"
      content["age"].should eq 3_i64
      content["ok"].should be_true
      content["tags"].should eq ["a", "b"]
      content["score"].should eq 1.5

      ACP::CreateElicitationResponse.from_json(%({"action":"decline"})).should be_a(ACP::DeclineElicitationResponse)
      ACP::CreateElicitationResponse.from_json(%({"action":"cancel"})).should be_a(ACP::CancelElicitationResponse)

      unknown = ACP::CreateElicitationResponse.from_json(%({"action":"_deferred","later":true}))
      unknown.should be_a(ACP::UnknownElicitationResponse)
      unknown.to_json.should eq %({"action":"_deferred","later":true})
    end

    it "preserves unknown property schemas" do
      schema = ACP::ElicitationSchema.from_json(%({
        "type":"object",
        "properties":{"x":{"type":"_color","hue":12},"y":{"type":"integer","minimum":1}}
      }))
      schema.properties["x"].should be_a(ACP::UnknownElicitationPropertySchema)
      schema.properties["x"].to_json.should eq %({"type":"_color","hue":12})
      schema.properties["y"].should be_a(ACP::IntegerPropertySchema)
    end
  end

  describe "initialize handshake types" do
    it "round-trips InitializeRequest" do
      req = ACP::InitializeRequest.new(
        protocol_version: 1,
        client_capabilities: ACP::ClientCapabilities.new(
          fs: ACP::FileSystemCapabilities.new(read_text_file: true),
          terminal: true,
        ),
        client_info: ACP::Implementation.new(name: "zed", version: "1.0"),
      )
      parsed = ACP::InitializeRequest.from_json(req.to_json)
      parsed.protocol_version.should eq 1
      parsed.client_capabilities.not_nil!.fs.not_nil!.read_text_file.should be_true
      parsed.client_info.not_nil!.name.should eq "zed"
    end

    it "round-trips InitializeResponse" do
      res = ACP::InitializeResponse.new(
        protocol_version: 1,
        agent_capabilities: ACP::AgentCapabilities.new(load_session: true),
        auth_methods: [ACP::AuthMethodAgent.new(id: "oauth", name: "OAuth")] of ACP::AuthMethod,
      )
      parsed = ACP::InitializeResponse.from_json(res.to_json)
      parsed.agent_capabilities.not_nil!.load_session.should be_true
      parsed.auth_methods.first.should be_a(ACP::AuthMethodAgent)
    end
  end

  describe "Error" do
    it "serializes with code, message and optional data" do
      ACP::Error.new(-32601, "Method not found").to_json.should eq %({"code":-32601,"message":"Method not found"})
      error = ACP::Error.from_json(%({"code":-32800,"message":"Request cancelled","data":{"by":"user"}}))
      error.code.should eq ACP::ErrorCode::RequestCancelled
      error.data.not_nil!["by"].as_s.should eq "user"
    end
  end
end
