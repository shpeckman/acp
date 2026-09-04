# acp — Agent Client Protocol for Crystal

A Crystal implementation of the [Agent Client Protocol](https://agentclientprotocol.com).
ACP connects code editors and IDEs (*clients*) with AI coding agents over
JSON-RPC 2.0, using newline-delimited JSON on stdio.

Both protocol generations are included:

- **`ACP`** — schema **v1** (protocol version 1), the stable protocol
  spoken by Zed and current agents.
- **`ACP::V2`** — schema **v2** (`2.0.0-alpha.3`), the next-generation
  protocol. It is **alpha software**: opt-in, off by default upstream,
  and subject to breaking changes.

Both namespaces share the same JSON-RPC connection core and follow the
same agent/client patterns shown below — swap `ACP::` for `ACP::V2::` to
target v2 (see [Protocol v2](#protocol-v2)).

Use this library to:

- **Build an agent** — an AI coding assistant process that editors like
  Zed can talk to.
- **Embed an agent** — drive any ACP-compatible agent from your own
  Crystal program.

Requires Crystal >= 1.21.0. No runtime dependencies outside the stdlib.

## Installation

Add it to your `shard.yml`:

```yaml
dependencies:
  acp:
    github: shpeckman/acp
```

## Building an agent

Subclass `ACP::Agent`, override the `handle_*` methods you support, and
serve on stdio. Every method you don't implement answers with a JSON-RPC
"method not found" error automatically.

```crystal
require "acp"

class MyAgent < ACP::Agent
  def handle_initialize(params : ACP::InitializeRequest) : ACP::InitializeResponse
    ACP::InitializeResponse.new(
      protocol_version: ACP::PROTOCOL_VERSION,
      agent_capabilities: ACP::AgentCapabilities.new(load_session: false),
      agent_info: ACP::Implementation.new(name: "my-agent", version: "0.1.0"),
    )
  end

  def handle_new_session(params : ACP::NewSessionRequest) : ACP::NewSessionResponse
    ACP::NewSessionResponse.new(session_id: Random::Secure.hex(8))
  end

  def handle_prompt(params : ACP::PromptRequest) : ACP::PromptResponse
    params.prompt.each do |block|
      next unless block.is_a?(ACP::TextContent)
      # Stream progress back to the client mid-turn.
      connection.session_update(params.session_id, ACP::ContentChunk.new(
        session_update: "agent_message_chunk",
        content: ACP::TextContent.new(text: "you said: #{block.text}"),
      ))
    end
    ACP::PromptResponse.new(stop_reason: ACP::StopReason::EndTurn)
  end
end

ACP.serve_stdio(MyAgent.new)
```

Inside handlers, `connection` (an `ACP::AgentConnection`) lets the agent
call the client:

| Method                                                                                                                       | ACP method                                |
|------------------------------------------------------------------------------------------------------------------------------|-------------------------------------------|
| `session_update(session_id, update)`                                                                                         | `session/update` (notification)           |
| `request_permission(...)`                                                                                                    | `session/request_permission`              |
| `read_text_file(...)` / `write_text_file(...)`                                                                               | `fs/read_text_file`, `fs/write_text_file` |
| `create_terminal(...)`, `terminal_output(...)`, `wait_for_terminal_exit(...)`, `kill_terminal(...)`, `release_terminal(...)` | `terminal/*`                              |
| `create_elicitation(...)`                                                                                                    | `elicitation/create`                      |
| `complete_elicitation(...)`                                                                                                  | `elicitation/complete` (notification)     |
| `send_ext_request(...)`, `send_ext_notification(...)`                                                                        | `_custom/methods`                         |

Overridable agent handlers: `handle_initialize`, `handle_authenticate`,
`handle_logout`, `handle_new_session`, `handle_load_session`,
`handle_list_sessions`, `handle_delete_session`, `handle_resume_session`,
`handle_close_session`, `handle_set_session_mode`,
`handle_set_session_config_option`, `handle_prompt`, `handle_cancel`
(notification), `handle_ext_request`, `handle_ext_notification`.

## Embedding an agent (client side)

Subclass `ACP::Client` to receive updates and requests from the agent,
then spawn the agent subprocess:

```crystal
require "acp"

class MyClient < ACP::Client
  def handle_session_update(notification : ACP::SessionNotification) : Nil
    if (chunk = notification.update).is_a?(ACP::ContentChunk)
      if (text = chunk.content).is_a?(ACP::TextContent)
        print text.text
      end
    end
  end

  # Implement fs/terminal/permission handlers here when you advertise
  # the corresponding capabilities.
end

process, connection = ACP::ClientConnection.spawn("my-agent", client: MyClient.new)

connection.initialize_agent(ACP::InitializeRequest.new(
  protocol_version: ACP::PROTOCOL_VERSION,
  client_capabilities: ACP::ClientCapabilities.new(
    fs: ACP::FileSystemCapabilities.new(read_text_file: true, write_text_file: true),
    terminal: false,
  ),
))

session = connection.new_session(ACP::NewSessionRequest.new(
  cwd: Dir.current,
  mcp_servers: [] of ACP::McpServer,
))

response = connection.prompt(ACP::PromptRequest.new(
  session_id: session.session_id,
  prompt: [ACP::TextContent.new(text: "fix the bug")] of ACP::ContentBlock,
))
puts response.stop_reason # => EndTurn
```

Outgoing client calls: `initialize_agent`, `authenticate`, `logout`,
`new_session`, `load_session`, `list_sessions`, `delete_session`,
`resume_session`, `close_session`, `set_session_mode`,
`set_session_config_option`, `prompt`, `cancel`.

Overridable client handlers: `handle_session_update`,
`handle_request_permission`, `handle_read_text_file`,
`handle_write_text_file`, `handle_create_terminal`,
`handle_terminal_output`, `handle_release_terminal`,
`handle_wait_for_terminal_exit`, `handle_kill_terminal`,
`handle_create_elicitation`, `handle_complete_elicitation`,
`handle_ext_request`, `handle_ext_notification`.

## Types and serialization

All types live under the `ACP` module and are generated from the
official `schema.json` (schema-v1.21.0):

- Request/response objects are `JSON::Serializable` classes with
  keyword initializers, e.g. `ACP::NewSessionRequest.new(cwd: ...,
  mcp_servers: [...])`. Optional fields are nilable and omitted from the
  wire when `nil`; `_meta` fields are exposed as `meta`.
- Enumerations map to Crystal enums with the snake_case wire format,
  e.g. `ACP::StopReason::EndTurn` ⇔ `"end_turn"`.
- Polymorphic types (`ContentBlock`, `SessionUpdate`, `ToolCallContent`,
  `McpServer`, `AuthMethod`, `RequestPermissionOutcome`,
  `SessionConfigOption`, elicitation types) are abstract base classes
  parsed via their discriminator field — `is_a?`/`case` on the concrete
  subclass is the idiomatic way to consume them.
- Open-ended protocol points preserve unknown payloads:
  `UnknownElicitationRequest`, `UnknownElicitationResponse`,
  `UnknownElicitationPropertySchema`, `UnknownMultiSelectItems`, and the
  free-form `SessionConfigOptionCategory`.
- Extension methods (`_`-prefixed) are supported on both sides via
  `send_ext_request` / `handle_ext_request` and friends.

## Protocol v2

`ACP::V2` mirrors the v1 API shape — `ACP::V2::Agent`,
`ACP::V2::Client`, `ACP::V2::AgentConnection`,
`ACP::V2::ClientConnection.spawn`, and `ACP::V2.serve_stdio` — with the
v2 wire protocol:

- **Renamed methods**: `authenticate` → `auth/login`, `logout` →
  `auth/logout` (handlers: `handle_login` / `handle_logout`; client
  calls: `login` / `logout`).
- **Sessions**: `session/load` and the session-modes API are gone.
  `resume_session` takes an optional `replay_from`
  (`ACP::V2::ReplayFromStart.new`) so agents replay missed updates.
- **Agent-owned terminal**: the `fs/*` and `terminal/*` client methods
  are removed; agents report terminal activity through
  `TerminalUpdate` / `TerminalOutputChunk` session updates.
- **Updates**: chunks require a `message_id`; whole-message upserts
  (`UserMessage`, `AgentMessage`, `AgentThought`) and the merged
  `ToolCallUpdate` upsert replace the v1 tool-call pair. The stop
  reason moved from `PromptResponse` to
  `ACP::V2::IdleStateUpdate#stop_reason`.
- **Open unions everywhere**: every polymorphic type has an
  `Unknown*` fallback class that preserves the raw payload
  (`UnknownSessionUpdate`, `UnknownContentBlock`, …), so v2 peers can
  add variants without breaking older consumers.
- **Capabilities are objects**: `{}` means supported, e.g.
  `ACP::V2::ClientCapabilities.new(elicitation: ACP::V2::ElicitationCapabilities.new(form: ACP::V2::ElicitationFormCapabilities.new))`.
- MCP over SSE was removed; `McpServer` variants carry an explicit
  `type` (`"stdio"` / `"http"`).

```crystal
class MyV2Agent < ACP::V2::Agent
  def handle_initialize(params : ACP::V2::InitializeRequest) : ACP::V2::InitializeResponse
    ACP::V2::InitializeResponse.new(
      protocol_version: ACP::V2::PROTOCOL_VERSION,
      info: ACP::V2::Implementation.new(name: "my-agent", version: "0.1.0"),
      capabilities: ACP::V2::AgentCapabilities.new,
    )
  end

  def handle_new_session(params : ACP::V2::NewSessionRequest) : ACP::V2::NewSessionResponse
    ACP::V2::NewSessionResponse.new(session_id: Random::Secure.hex(8))
  end

  def handle_prompt(params : ACP::V2::PromptRequest) : ACP::V2::PromptResponse
    connection.session_update(params.session_id, ACP::V2::ContentChunk.new(
      session_update: "agent_message_chunk",
      message_id: "msg-1",
      content: ACP::V2::TextContent.new(text: "hello from v2"),
    ))
    connection.session_update(params.session_id,
      ACP::V2::IdleStateUpdate.new(stop_reason: ACP::V2::StopReason::EndTurn))
    ACP::V2::PromptResponse.new
  end
end

ACP::V2.serve_stdio(MyV2Agent.new)
```

V2 session updates are sent with
`connection.session_update(session_id, update)`, or as a prebuilt
`ACP::V2::UpdateSessionNotification`.

## Concurrency and cancellation

`ACP::Connection` reads messages on one fiber and dispatches every
incoming request/notification to its own fiber, so a handler can call
back into the peer (e.g. request a file during a prompt turn) without
deadlocking. Writes are serialized with a lock.

- `session/cancel` is delivered to `Agent#handle_cancel`; agents should
  abort the turn and answer the pending `session/prompt` with
  `StopReason::Cancelled`.
- Protocol-level `$/cancel_request` notifications are tracked per
  request id; long-running handlers can poll
  `connection.cancel_requested?(id)`.

Raise `ACP::RpcError` (or a convenience like
`ACP::RpcError.auth_required`) from any handler to respond with a
specific JSON-RPC error code. Standard codes live in `ACP::ErrorCode`.

## Running the examples

```console
$ crystal build examples/echo_agent.cr -o bin/echo-agent
$ crystal run examples/echo_client.cr -- ./bin/echo-agent
connected to echo-agent (protocol v1)
session: 3f2a...
agent says: echo: hello from crystal
turn finished: EndTurn
```

## Development

```console
$ crystal spec
```

`src/acp/schema.cr` and `src/acp/v2/schema.cr` are generated from the
upstream `schema/v1/schema.json` and `schema/v2/schema.json` by
`tools/generate_schema.py`; the union types and JSON-RPC plumbing in
`schema_unions.cr`, `json_rpc.cr`, `connection.cr`, `agent.cr` and
`client.cr` (and their `v2/` counterparts) are hand-written.

## License

MIT
