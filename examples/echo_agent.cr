# examples/echo_agent.cr
require "../src/acp"

# A minimal ACP agent that echoes the user's prompt back.
#
# Build with: crystal build examples/echo_agent.cr -o bin/echo-agent
class EchoAgent < ACP::Agent
  def handle_initialize(params : ACP::InitializeRequest) : ACP::InitializeResponse
    ACP::InitializeResponse.new(
      protocol_version: ACP::PROTOCOL_VERSION,
      agent_capabilities: ACP::AgentCapabilities.new(load_session: false),
      agent_info: ACP::Implementation.new(
        name: "echo-agent",
        title: "Echo Agent",
        version: ACP::VERSION,
      ),
    )
  end

  def handle_new_session(params : ACP::NewSessionRequest) : ACP::NewSessionResponse
    ACP::NewSessionResponse.new(session_id: Random::Secure.hex(8))
  end

  def handle_prompt(params : ACP::PromptRequest) : ACP::PromptResponse
    params.prompt.each do |block|
      next unless block.is_a?(ACP::TextContent)
      # Stream the user's text right back as an agent message chunk.
      connection.session_update(
        params.session_id,
        ACP::ContentChunk.new(
          session_update: "agent_message_chunk",
          content: ACP::TextContent.new(text: "echo: #{block.text}"),
        ),
      )
    end
    ACP::PromptResponse.new(stop_reason: ACP::StopReason::EndTurn)
  end
end

ACP.serve_stdio(EchoAgent.new)
