# examples/echo_client.cr
require "../src/acp"

# A minimal ACP client that launches the echo agent, starts a session,
# and sends one prompt.
#
# Usage:
#   crystal build examples/echo_agent.cr -o bin/echo-agent
#   crystal run examples/echo_client.cr -- ./bin/echo-agent
class PrintingClient < ACP::Client
  def handle_session_update(notification : ACP::SessionNotification) : Nil
    update = notification.update
    if update.is_a?(ACP::ContentChunk)
      if (content = update.content).is_a?(ACP::TextContent)
        puts "agent says: #{content.text}"
      end
    end
  end
end

command = ARGV.first? || "./bin/echo-agent"

process, connection = ACP::ClientConnection.spawn(command, client: PrintingClient.new)

begin
  response = connection.initialize_agent(ACP::InitializeRequest.new(
    protocol_version: ACP::PROTOCOL_VERSION,
    client_capabilities: ACP::ClientCapabilities.new,
    client_info: ACP::Implementation.new(name: "echo-client", version: ACP::VERSION),
  ))
  puts "connected to #{response.agent_info.try(&.name)} (protocol v#{response.protocol_version})"

  session = connection.new_session(ACP::NewSessionRequest.new(
    cwd: Dir.current,
    mcp_servers: [] of ACP::McpServer,
  ))
  puts "session: #{session.session_id}"

  result = connection.prompt(ACP::PromptRequest.new(
    session_id: session.session_id,
    prompt: [ACP::TextContent.new(text: "hello from crystal")] of ACP::ContentBlock,
  ))
  puts "turn finished: #{result.stop_reason}"
ensure
  connection.close
  process.terminate rescue nil
end
