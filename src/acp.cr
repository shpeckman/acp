# src/acp.cr
require "json"

require "./acp/version"
require "./acp/json_rpc"
require "./acp/schema_unions"
require "./acp/schema"
require "./acp/v2/schema_unions"
require "./acp/v2/schema"
require "./acp/connection"
require "./acp/agent"
require "./acp/client"
require "./acp/v2/agent"
require "./acp/v2/client"

# A Crystal implementation of the Agent Client Protocol (ACP), schema v1.
#
# ACP lets code editors and IDEs (clients) communicate with AI coding
# agents over JSON-RPC 2.0, using newline-delimited JSON on stdio.
#
# - To **build an agent**: subclass `ACP::Agent` and serve it with
#   `ACP.serve_stdio`.
# - To **embed an agent**: subclass `ACP::Client` and launch the agent
#   with `ACP::ClientConnection.spawn`.
#
# See https://agentclientprotocol.com for the protocol specification.
module ACP
end
