# src/acp/v2/schema_unions.cr
# Discriminated-union base classes and special types of the ACP schema v2
# (2.0.0-alpha.3).
#
# This file is hand-written (not generated from the schema).
#
# Unlike v1, every v2 union is open-ended: unknown discriminator values
# are preserved as `Unknown*` classes carrying the raw JSON payload, per
# the enum-variant-extension RFD.

module ACP
  module V2
    # The protocol version implemented by this module.
    PROTOCOL_VERSION = 2

    alias ProtocolVersion = Int32

    # Resource contents embedded in a message: text or blob.
    alias EmbeddedResourceResource = TextResourceContents | BlobResourceContents

    # A value in elicitation response content.
    alias ElicitationContentValue = String | Int64 | Float64 | Bool | Array(String)

    # Options of a select-type session configuration option:
    # either a flat list or a grouped list.
    alias SessionConfigSelectOptions = Array(SessionConfigSelectOption) | Array(SessionConfigSelectGroup)

    # Defines a raw-payload-preserving fallback class for an open union,
    # plus an accessor for the union's discriminator field.
    macro define_raw_fallback(class_name, base, discriminator)
      # Fallback for unknown or custom variants of the union, preserving the
      # raw payload for storage, replay, proxying, or forwarding.
      class {{class_name}} < {{base}}
        # The raw JSON payload.
        getter raw : JSON::Any

        def initialize(@raw : JSON::Any)
        end

        # The (unknown) discriminator value of this variant.
        def {{discriminator.id.underscore}} : String?
          @raw[{{discriminator}}]?.try(&.as_s?)
        end

        def self.new(pull : JSON::PullParser)
          new(JSON::Any.new(pull))
        end

        def to_json(json : JSON::Builder) : Nil
          @raw.to_json(json)
        end
      end
    end

    # A single unit of content within a message.
    abstract class ContentBlock
      include JSON::Serializable

      def self.new(pull : JSON::PullParser)
        any  = JSON::Any.new(pull)
        json = any.to_json
        case any["type"]?.try(&.as_s?)
        when "text"          then TextContent.from_json(json)
        when "image"         then ImageContent.from_json(json)
        when "audio"         then AudioContent.from_json(json)
        when "resource_link" then ResourceLink.from_json(json)
        when "resource"      then EmbeddedResource.from_json(json)
        else                      UnknownContentBlock.new(any)
        end
      end
    end

    define_raw_fallback UnknownContentBlock, ContentBlock, "type"

    # Different types of updates that can be sent during session processing.
    abstract class SessionUpdate
      include JSON::Serializable

      def self.new(pull : JSON::PullParser)
        any  = JSON::Any.new(pull)
        json = any.to_json
        case any["sessionUpdate"]?.try(&.as_s?)
        when "user_message_chunk", "agent_message_chunk", "agent_thought_chunk"
          ContentChunk.from_json(json)
        when "user_message"              then UserMessage.from_json(json)
        when "agent_message"             then AgentMessage.from_json(json)
        when "agent_thought"             then AgentThought.from_json(json)
        when "state_update"              then StateUpdate.from_json(json)
        when "tool_call_content_chunk"   then ToolCallContentChunk.from_json(json)
        when "tool_call_update"          then ToolCallUpdate.from_json(json)
        when "terminal_update"           then TerminalUpdate.from_json(json)
        when "terminal_output_chunk"     then TerminalOutputChunk.from_json(json)
        when "plan_update"               then PlanUpdate.from_json(json)
        when "available_commands_update" then AvailableCommandsUpdate.from_json(json)
        when "config_option_update"      then ConfigOptionUpdate.from_json(json)
        when "session_info_update"       then SessionInfoUpdate.from_json(json)
        when "usage_update"              then UsageUpdate.from_json(json)
        else                                  UnknownSessionUpdate.new(any)
        end
      end
    end

    define_raw_fallback UnknownSessionUpdate, SessionUpdate, "sessionUpdate"

    # Lifecycle state of a session (running, idle, or requires action).
    abstract class StateUpdate < SessionUpdate
      def self.new(pull : JSON::PullParser)
        any  = JSON::Any.new(pull)
        json = any.to_json
        case any["state"]?.try(&.as_s?)
        when "running"         then RunningStateUpdate.from_json(json)
        when "idle"            then IdleStateUpdate.from_json(json)
        when "requires_action" then RequiresActionStateUpdate.from_json(json)
        else                        UnknownStateUpdate.new(any)
        end
      end
    end

    define_raw_fallback UnknownStateUpdate, StateUpdate, "state"

    # Content produced by a tool call.
    abstract class ToolCallContent
      include JSON::Serializable

      def self.new(pull : JSON::PullParser)
        any  = JSON::Any.new(pull)
        json = any.to_json
        case any["type"]?.try(&.as_s?)
        when "content"  then Content.from_json(json)
        when "diff"     then Diff.from_json(json)
        when "terminal" then Terminal.from_json(json)
        else                 UnknownToolCallContent.new(any)
        end
      end
    end

    define_raw_fallback UnknownToolCallContent, ToolCallContent, "type"

    # Configuration for connecting to an MCP server.
    #
    # Both known transports (`http`, `stdio`) carry an explicit `type`
    # discriminator; unknown future transports are preserved.
    abstract class McpServer
      include JSON::Serializable

      def self.new(pull : JSON::PullParser)
        any  = JSON::Any.new(pull)
        json = any.to_json
        case any["type"]?.try(&.as_s?)
        when "http"  then McpServerHttp.from_json(json)
        when "stdio" then McpServerStdio.from_json(json)
        else              UnknownMcpServer.new(any)
        end
      end
    end

    define_raw_fallback UnknownMcpServer, McpServer, "type"

    # An authentication method advertised by the agent.
    abstract class AuthMethod
      include JSON::Serializable

      def self.new(pull : JSON::PullParser)
        any  = JSON::Any.new(pull)
        json = any.to_json
        case any["type"]?.try(&.as_s?)
        when "terminal" then AuthMethodTerminal.from_json(json)
        when "agent"    then AuthMethodAgent.from_json(json)
        else                 UnknownAuthMethod.new(any)
        end
      end
    end

    define_raw_fallback UnknownAuthMethod, AuthMethod, "type"

    # Structured context about the operation requiring permission.
    abstract class RequestPermissionSubject
      include JSON::Serializable

      def self.new(pull : JSON::PullParser)
        any  = JSON::Any.new(pull)
        json = any.to_json
        case any["type"]?.try(&.as_s?)
        when "tool_call" then ToolCallPermissionSubject.from_json(json)
        when "command"   then CommandPermissionSubject.from_json(json)
        else                  UnknownPermissionSubject.new(any)
        end
      end
    end

    define_raw_fallback UnknownPermissionSubject, RequestPermissionSubject, "type"

    # A structured file operation within a diff.
    #
    # `add`, `delete` and `modify` produce `DiffPathChange`;
    # `move` and `copy` produce `DiffPathPairChange`.
    abstract class DiffChange
      include JSON::Serializable

      def self.new(pull : JSON::PullParser)
        any  = JSON::Any.new(pull)
        json = any.to_json
        case any["operation"]?.try(&.as_s?)
        when "add", "delete", "modify" then DiffPathChange.from_json(json)
        when "move", "copy"            then DiffPathPairChange.from_json(json)
        else                                UnknownDiffChange.new(any)
        end
      end
    end

    define_raw_fallback UnknownDiffChange, DiffChange, "operation"

    # The content of a plan update.
    abstract class PlanUpdateContent
      include JSON::Serializable

      def self.new(pull : JSON::PullParser)
        any  = JSON::Any.new(pull)
        json = any.to_json
        case any["type"]?.try(&.as_s?)
        when "items" then PlanItems.from_json(json)
        else              UnknownPlanUpdateContent.new(any)
        end
      end
    end

    define_raw_fallback UnknownPlanUpdateContent, PlanUpdateContent, "type"

    # Cursor describing where session replay should start from.
    abstract class ReplayFrom
      include JSON::Serializable

      def self.new(pull : JSON::PullParser)
        any  = JSON::Any.new(pull)
        json = any.to_json
        case any["type"]?.try(&.as_s?)
        when "start" then ReplayFromStart.from_json(json)
        else              UnknownReplayFrom.new(any)
        end
      end
    end

    define_raw_fallback UnknownReplayFrom, ReplayFrom, "type"

    # Input specification for an available command.
    abstract class AvailableCommandInput
      include JSON::Serializable

      def self.new(pull : JSON::PullParser)
        any  = JSON::Any.new(pull)
        json = any.to_json
        case any["type"]?.try(&.as_s?)
        when "text" then TextCommandInput.from_json(json)
        else             UnknownCommandInput.new(any)
        end
      end
    end

    define_raw_fallback UnknownCommandInput, AvailableCommandInput, "type"

    # The outcome of a permission request.
    abstract class RequestPermissionOutcome
      include JSON::Serializable

      def self.new(pull : JSON::PullParser)
        any  = JSON::Any.new(pull)
        json = any.to_json
        case any["outcome"]?.try(&.as_s?)
        when "cancelled" then CancelledPermissionOutcome.from_json(json)
        when "selected"  then SelectedPermissionOutcome.from_json(json)
        else                  UnknownPermissionOutcome.new(any)
        end
      end
    end

    define_raw_fallback UnknownPermissionOutcome, RequestPermissionOutcome, "outcome"

    # The permission request was cancelled by the client.
    class CancelledPermissionOutcome < RequestPermissionOutcome
      @[JSON::Field(key: "outcome")]
      getter outcome : String = "cancelled"

      def initialize(@outcome : String = "cancelled")
      end
    end

    # Request from the agent to elicit structured user input.
    abstract class CreateElicitationRequest
      include JSON::Serializable

      def self.new(pull : JSON::PullParser)
        any  = JSON::Any.new(pull)
        json = any.to_json
        case any["mode"]?.try(&.as_s?)
        when "form" then FormElicitationRequest.from_json(json)
        when "url"  then UrlElicitationRequest.from_json(json)
        else             UnknownElicitationRequest.new(any)
        end
      end
    end

    # Form-based elicitation where the client renders a form from a schema.
    class FormElicitationRequest < CreateElicitationRequest
      @[JSON::Field(key: "mode")]
      getter mode : String = "form"

      # A human-readable message describing what input is needed.
      getter message : String

      # A JSON Schema describing the form fields to present to the user.
      @[JSON::Field(key: "requestedSchema")]
      getter requested_schema : ElicitationSchema

      # The session this elicitation is tied to (session scope).
      @[JSON::Field(key: "sessionId", emit_null: false)]
      getter session_id : SessionId?

      # Optional tool call within the session.
      @[JSON::Field(key: "toolCallId", emit_null: false)]
      getter tool_call_id : ToolCallId?

      # The request this elicitation is tied to (request scope).
      @[JSON::Field(key: "requestId", emit_null: false)]
      getter request_id : ::ACP::RequestId?

      # The _meta property is reserved by ACP to attach additional metadata.
      @[JSON::Field(key: "_meta", emit_null: false)]
      getter meta : Hash(String, JSON::Any)?

      def initialize(
        *,
        @message : String,
        @requested_schema : ElicitationSchema,
        @session_id : SessionId? = nil,
        @tool_call_id : ToolCallId? = nil,
        @request_id : ::ACP::RequestId? = nil,
        @meta : Hash(String, JSON::Any)? = nil,
        @mode : String = "form",
      )
      end
    end

    # URL-based elicitation where the client directs the user to a URL.
    class UrlElicitationRequest < CreateElicitationRequest
      @[JSON::Field(key: "mode")]
      getter mode : String = "url"

      # A human-readable message describing what input is needed.
      getter message : String

      # The unique identifier for this elicitation.
      @[JSON::Field(key: "elicitationId")]
      getter elicitation_id : ElicitationId

      # The URL to direct the user to.
      getter url : String

      # The session this elicitation is tied to (session scope).
      @[JSON::Field(key: "sessionId", emit_null: false)]
      getter session_id : SessionId?

      # Optional tool call within the session.
      @[JSON::Field(key: "toolCallId", emit_null: false)]
      getter tool_call_id : ToolCallId?

      # The request this elicitation is tied to (request scope).
      @[JSON::Field(key: "requestId", emit_null: false)]
      getter request_id : ::ACP::RequestId?

      # The _meta property is reserved by ACP to attach additional metadata.
      @[JSON::Field(key: "_meta", emit_null: false)]
      getter meta : Hash(String, JSON::Any)?

      def initialize(
        *,
        @message : String,
        @elicitation_id : ElicitationId,
        @url : String,
        @session_id : SessionId? = nil,
        @tool_call_id : ToolCallId? = nil,
        @request_id : ::ACP::RequestId? = nil,
        @meta : Hash(String, JSON::Any)? = nil,
        @mode : String = "url",
      )
      end
    end

    define_raw_fallback UnknownElicitationRequest, CreateElicitationRequest, "mode"

    # Response to an elicitation request.
    abstract class CreateElicitationResponse
      include JSON::Serializable

      def self.new(pull : JSON::PullParser)
        any  = JSON::Any.new(pull)
        json = any.to_json
        case any["action"]?.try(&.as_s?)
        when "accept"  then AcceptElicitationResponse.from_json(json)
        when "decline" then DeclineElicitationResponse.from_json(json)
        when "cancel"  then CancelElicitationResponse.from_json(json)
        else                UnknownElicitationResponse.new(any)
        end
      end
    end

    # The user accepted the elicitation and provided content.
    class AcceptElicitationResponse < CreateElicitationResponse
      @[JSON::Field(key: "action")]
      getter action : String = "accept"

      # The user-provided content, if any, matching the requested schema.
      @[JSON::Field(key: "content", emit_null: false)]
      getter content : Hash(String, ElicitationContentValue)?

      def initialize(*, @content : Hash(String, ElicitationContentValue)? = nil, @action : String = "accept")
      end
    end

    # The user declined the elicitation.
    class DeclineElicitationResponse < CreateElicitationResponse
      @[JSON::Field(key: "action")]
      getter action : String = "decline"

      def initialize(*, @action : String = "decline")
      end
    end

    # The elicitation was cancelled.
    class CancelElicitationResponse < CreateElicitationResponse
      @[JSON::Field(key: "action")]
      getter action : String = "cancel"

      def initialize(*, @action : String = "cancel")
      end
    end

    define_raw_fallback UnknownElicitationResponse, CreateElicitationResponse, "action"

    # Property schema for elicitation form fields.
    abstract class ElicitationPropertySchema
      include JSON::Serializable

      def self.new(pull : JSON::PullParser)
        any  = JSON::Any.new(pull)
        json = any.to_json
        case any["type"]?.try(&.as_s?)
        when "string"  then StringPropertySchema.from_json(json)
        when "number"  then NumberPropertySchema.from_json(json)
        when "integer" then IntegerPropertySchema.from_json(json)
        when "boolean" then BooleanPropertySchema.from_json(json)
        when "array"   then MultiSelectPropertySchema.from_json(json)
        else                UnknownElicitationPropertySchema.new(any)
        end
      end
    end

    define_raw_fallback UnknownElicitationPropertySchema, ElicitationPropertySchema, "type"

    # Items of a multi-select elicitation property.
    abstract class MultiSelectItems
      include JSON::Serializable

      def self.new(pull : JSON::PullParser)
        any  = JSON::Any.new(pull)
        json = any.to_json
        case any["type"]?.try(&.as_s?)
        when "string" then StringMultiSelectItems.from_json(json)
        when "titled" then TitledMultiSelectItems.from_json(json)
        else               UnknownMultiSelectItems.new(any)
        end
      end
    end

    define_raw_fallback UnknownMultiSelectItems, MultiSelectItems, "type"

    # A session configuration option selector and its current state.
    abstract class SessionConfigOption
      include JSON::Serializable

      def self.new(pull : JSON::PullParser)
        any  = JSON::Any.new(pull)
        json = any.to_json
        case any["type"]?.try(&.as_s?)
        when "select"  then SelectConfigOption.from_json(json)
        when "boolean" then BooleanConfigOption.from_json(json)
        else                UnknownSessionConfigOption.new(any)
        end
      end
    end

    define_raw_fallback UnknownSessionConfigOption, SessionConfigOption, "type"

    # A single-value selector (dropdown) session configuration option.
    class SelectConfigOption < SessionConfigOption
      @[JSON::Field(key: "type")]
      getter type : String = "select"

      # Unique identifier for the configuration option.
      @[JSON::Field(key: "configId")]
      getter config_id : SessionConfigId

      # Human-readable label for the option.
      getter name : String

      # Optional description for the Client to display to the user.
      @[JSON::Field(key: "description", emit_null: false)]
      getter description : String?

      # Optional semantic category for this option (UX only).
      @[JSON::Field(key: "category", emit_null: false)]
      getter category : SessionConfigOptionCategory?

      # The currently selected value.
      @[JSON::Field(key: "currentValue")]
      getter current_value : SessionConfigValueId

      # The set of selectable options.
      getter options : SessionConfigSelectOptions

      # The _meta property is reserved by ACP to attach additional metadata.
      @[JSON::Field(key: "_meta", emit_null: false)]
      getter meta : Hash(String, JSON::Any)?

      def initialize(
        *,
        @config_id : SessionConfigId,
        @name : String,
        @current_value : SessionConfigValueId,
        @options : SessionConfigSelectOptions,
        @description : String? = nil,
        @category : SessionConfigOptionCategory? = nil,
        @meta : Hash(String, JSON::Any)? = nil,
        @type : String = "select",
      )
      end
    end

    # A boolean on/off toggle session configuration option.
    class BooleanConfigOption < SessionConfigOption
      @[JSON::Field(key: "type")]
      getter type : String = "boolean"

      # Unique identifier for the configuration option.
      @[JSON::Field(key: "configId")]
      getter config_id : SessionConfigId

      # Human-readable label for the option.
      getter name : String

      # Optional description for the Client to display to the user.
      @[JSON::Field(key: "description", emit_null: false)]
      getter description : String?

      # Optional semantic category for this option (UX only).
      @[JSON::Field(key: "category", emit_null: false)]
      getter category : SessionConfigOptionCategory?

      # The current value of the boolean option.
      @[JSON::Field(key: "currentValue")]
      getter current_value : Bool

      # The _meta property is reserved by ACP to attach additional metadata.
      @[JSON::Field(key: "_meta", emit_null: false)]
      getter meta : Hash(String, JSON::Any)?

      def initialize(
        *,
        @config_id : SessionConfigId,
        @name : String,
        @current_value : Bool,
        @description : String? = nil,
        @category : SessionConfigOptionCategory? = nil,
        @meta : Hash(String, JSON::Any)? = nil,
        @type : String = "boolean",
      )
      end
    end

    # Request to update a session configuration option.
    #
    # `value` is a `SessionConfigValueId` for select options (`type` is
    # `"id"`) or a `Bool` for boolean options (`type` is `"boolean"`).
    class SetSessionConfigOptionRequest
      include JSON::Serializable

      # The ID of the session to update.
      @[JSON::Field(key: "sessionId")]
      getter session_id : SessionId

      # The ID of the configuration option to update.
      @[JSON::Field(key: "configId")]
      getter config_id : SessionConfigId

      # Variant tag: `"id"` for value IDs, `"boolean"` for booleans.
      @[JSON::Field(key: "type")]
      getter type : String

      # The new value: a value ID (select options) or a boolean.
      @[JSON::Field(key: "value")]
      getter value : SessionConfigValueId | Bool

      # The _meta property is reserved by ACP to attach additional metadata.
      @[JSON::Field(key: "_meta", emit_null: false)]
      getter meta : Hash(String, JSON::Any)?

      def initialize(
        *,
        @session_id : SessionId,
        @config_id : SessionConfigId,
        @value : SessionConfigValueId | Bool,
        @meta : Hash(String, JSON::Any)? = nil,
      )
        @type = @value.is_a?(Bool) ? "boolean" : "id"
      end
    end
  end
end
