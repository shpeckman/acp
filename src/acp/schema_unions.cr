# src/acp/schema_unions.cr
# Discriminated-union base classes and special types of the ACP schema v1.
#
# This file is hand-written (not generated from the schema).

module ACP
  # A single unit of content within a message.
  #
  # Parsed polymorphically based on the `type` discriminator field.
  abstract class ContentBlock
    include JSON::Serializable

    use_json_discriminator "type", {
      text:          TextContent,
      image:         ImageContent,
      audio:         AudioContent,
      resource_link: ResourceLink,
      resource:      EmbeddedResource,
    }
  end

  # Different types of updates that can be sent during session processing.
  #
  # Parsed polymorphically based on the `sessionUpdate` discriminator field.
  abstract class SessionUpdate
    include JSON::Serializable

    use_json_discriminator "sessionUpdate", {
      user_message_chunk:        ContentChunk,
      agent_message_chunk:       ContentChunk,
      agent_thought_chunk:       ContentChunk,
      tool_call:                 ToolCall,
      tool_call_update:          ToolCallUpdate,
      plan:                      Plan,
      available_commands_update: AvailableCommandsUpdate,
      current_mode_update:       CurrentModeUpdate,
      config_option_update:      ConfigOptionUpdate,
      session_info_update:       SessionInfoUpdate,
      usage_update:              UsageUpdate,
    }
  end

  # Content produced by a tool call.
  #
  # Parsed polymorphically based on the `type` discriminator field.
  abstract class ToolCallContent
    include JSON::Serializable

    use_json_discriminator "type", {
      content:  Content,
      diff:     Diff,
      terminal: Terminal,
    }
  end

  # Configuration for connecting to an MCP server.
  #
  # `http` and `sse` variants carry a `type` discriminator; the `stdio`
  # variant is selected when no `type` field is present.
  abstract class McpServer
    include JSON::Serializable

    def self.new(pull : JSON::PullParser)
      any  = JSON::Any.new(pull)
      json = any.to_json
      case any["type"]?.try(&.as_s?)
      when "http" then McpServerHttp.from_json(json)
      when "sse"  then McpServerSse.from_json(json)
      else             McpServerStdio.from_json(json)
      end
    end
  end

  # An authentication method advertised by the agent.
  #
  # The `terminal` variant carries a `type` discriminator; the default
  # agent-handled method is selected when no `type` field is present.
  abstract class AuthMethod
    include JSON::Serializable

    def self.new(pull : JSON::PullParser)
      any  = JSON::Any.new(pull)
      json = any.to_json
      case any["type"]?.try(&.as_s?)
      when "terminal" then AuthMethodTerminal.from_json(json)
      else                 AuthMethodAgent.from_json(json)
      end
    end
  end

  # The outcome of a permission request.
  #
  # Parsed polymorphically based on the `outcome` discriminator field.
  abstract class RequestPermissionOutcome
    include JSON::Serializable

    use_json_discriminator "outcome", {
      cancelled: CancelledPermissionOutcome,
      selected:  SelectedPermissionOutcome,
    }
  end

  # The permission request was cancelled by the client.
  class CancelledPermissionOutcome < RequestPermissionOutcome
    @[JSON::Field(key: "outcome")]
    getter outcome : String = "cancelled"

    def initialize(@outcome : String = "cancelled")
    end
  end

  # Resource contents embedded in a message: text or blob.
  alias EmbeddedResourceResource = TextResourceContents | BlobResourceContents

  # A value in elicitation response content.
  alias ElicitationContentValue = String | Int64 | Float64 | Bool | Array(String)

  # Options of a select-type session configuration option:
  # either a flat list or a grouped list.
  alias SessionConfigSelectOptions = Array(SessionConfigSelectOption) | Array(SessionConfigSelectGroup)

  # Input specification for an available command.
  alias AvailableCommandInput = UnstructuredCommandInput

  # Semantic category for a session configuration option.
  #
  # Open-ended string type: known categories are provided as constants,
  # unknown values are preserved. Category names beginning with `_` are
  # free for custom use.
  struct SessionConfigOptionCategory
    # Session mode selector.
    Mode = new("mode")
    # Model selector.
    Model = new("model")
    # Model-related configuration parameter.
    ModelConfig = new("model_config")
    # Thought/reasoning level selector.
    ThoughtLevel = new("thought_level")

    getter value : String

    def initialize(@value : String)
    end

    def self.new(pull : JSON::PullParser)
      new(pull.read_string)
    end

    def to_json(json : JSON::Builder) : Nil
      @value.to_json(json)
    end

    def to_s(io : IO) : Nil
      io << @value
    end
  end

  # A session configuration option selector and its current state.
  #
  # Parsed polymorphically based on the `type` discriminator field:
  # `"select"` (dropdown) or `"boolean"` (on/off toggle).
  abstract class SessionConfigOption
    include JSON::Serializable

    use_json_discriminator "type", {
      select:  SelectConfigOption,
      boolean: BooleanConfigOption,
    }
  end

  # A single-value selector (dropdown) session configuration option.
  class SelectConfigOption < SessionConfigOption
    @[JSON::Field(key: "type")]
    getter type : String = "select"

    # Unique identifier for the configuration option.
    @[JSON::Field(key: "id")]
    getter id : SessionConfigId

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
      @id : SessionConfigId,
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
    @[JSON::Field(key: "id")]
    getter id : SessionConfigId

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
      @id : SessionConfigId,
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
  # The `value` is a `SessionConfigValueId` for select options or a `Bool`
  # for boolean options (in which case `type` is `"boolean"`).
  class SetSessionConfigOptionRequest
    include JSON::Serializable

    # The ID of the session to update.
    @[JSON::Field(key: "sessionId")]
    getter session_id : SessionId

    # The ID of the configuration option to update.
    @[JSON::Field(key: "configId")]
    getter config_id : SessionConfigId

    # The new value: a value ID (select options) or a boolean.
    @[JSON::Field(key: "value")]
    getter value : SessionConfigValueId | Bool

    # Variant tag, present (and equal to `"boolean"`) for boolean options.
    @[JSON::Field(key: "type", emit_null: false)]
    getter type : String?

    # The _meta property is reserved by ACP to attach additional metadata.
    @[JSON::Field(key: "_meta", emit_null: false)]
    getter meta : Hash(String, JSON::Any)?

    def initialize(
      @session_id : SessionId,
      @config_id : SessionConfigId,
      @value : SessionConfigValueId | Bool,
      @meta : Hash(String, JSON::Any)? = nil,
    )
      @type = @value.is_a?(Bool) ? "boolean" : nil
    end
  end

  # Property schema for elicitation form fields.
  #
  # Parsed polymorphically based on the `type` field. Unknown types are
  # preserved as `UnknownElicitationPropertySchema` with their raw payload.
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

  # A custom or future elicitation property schema, preserved raw.
  class UnknownElicitationPropertySchema < ElicitationPropertySchema
    # The raw JSON payload of the schema.
    getter raw : JSON::Any

    def initialize(@raw : JSON::Any)
    end

    # The (unknown) schema type.
    def type : String?
      @raw["type"]?.try(&.as_s?)
    end

    def self.new(pull : JSON::PullParser)
      new(JSON::Any.new(pull))
    end

    def to_json(json : JSON::Builder) : Nil
      @raw.to_json(json)
    end
  end

  # Items of a multi-select elicitation property.
  #
  # Parsed polymorphically based on the `type` field. Unknown types are
  # preserved as `UnknownMultiSelectItems` with their raw payload.
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

  # A custom or future multi-select item list, preserved raw.
  class UnknownMultiSelectItems < MultiSelectItems
    # The raw JSON payload.
    getter raw : JSON::Any

    def initialize(@raw : JSON::Any)
    end

    # The (unknown) item list type.
    def type : String?
      @raw["type"]?.try(&.as_s?)
    end

    def self.new(pull : JSON::PullParser)
      new(JSON::Any.new(pull))
    end

    def to_json(json : JSON::Builder) : Nil
      @raw.to_json(json)
    end
  end

  # Request from the agent to elicit structured user input.
  #
  # Parsed polymorphically based on the `mode` field (`"form"` or `"url"`).
  # Unknown modes are preserved as `UnknownElicitationRequest`.
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
    getter request_id : RequestId?

    # The _meta property is reserved by ACP to attach additional metadata.
    @[JSON::Field(key: "_meta", emit_null: false)]
    getter meta : Hash(String, JSON::Any)?

    def initialize(
      @message : String,
      @requested_schema : ElicitationSchema,
      @session_id : SessionId? = nil,
      @tool_call_id : ToolCallId? = nil,
      @request_id : RequestId? = nil,
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
    getter request_id : RequestId?

    # The _meta property is reserved by ACP to attach additional metadata.
    @[JSON::Field(key: "_meta", emit_null: false)]
    getter meta : Hash(String, JSON::Any)?

    def initialize(
      @message : String,
      @elicitation_id : ElicitationId,
      @url : String,
      @session_id : SessionId? = nil,
      @tool_call_id : ToolCallId? = nil,
      @request_id : RequestId? = nil,
      @meta : Hash(String, JSON::Any)? = nil,
      @mode : String = "url",
    )
    end
  end

  # A custom or future elicitation mode, preserved raw.
  #
  # Clients that do not understand the mode should preserve the raw payload
  # when storing, replaying, proxying, or forwarding elicitation requests.
  class UnknownElicitationRequest < CreateElicitationRequest
    # The raw JSON payload of the request.
    getter raw : JSON::Any

    def initialize(@raw : JSON::Any)
    end

    # The (unknown) elicitation mode.
    def mode : String?
      @raw["mode"]?.try(&.as_s?)
    end

    # A human-readable message describing what input is needed.
    def message : String?
      @raw["message"]?.try(&.as_s?)
    end

    def self.new(pull : JSON::PullParser)
      new(JSON::Any.new(pull))
    end

    def to_json(json : JSON::Builder) : Nil
      @raw.to_json(json)
    end
  end

  # Response to an elicitation request.
  #
  # Parsed polymorphically based on the `action` field (`"accept"`,
  # `"decline"`, `"cancel"`). Unknown actions are preserved as
  # `UnknownElicitationResponse`.
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

    def initialize(@content : Hash(String, ElicitationContentValue)? = nil, @action : String = "accept")
    end
  end

  # The user declined the elicitation.
  class DeclineElicitationResponse < CreateElicitationResponse
    @[JSON::Field(key: "action")]
    getter action : String = "decline"

    def initialize(@action : String = "decline")
    end
  end

  # The elicitation was cancelled.
  class CancelElicitationResponse < CreateElicitationResponse
    @[JSON::Field(key: "action")]
    getter action : String = "cancel"

    def initialize(@action : String = "cancel")
    end
  end

  # A custom or future elicitation action, preserved raw.
  class UnknownElicitationResponse < CreateElicitationResponse
    # The raw JSON payload of the response.
    getter raw : JSON::Any

    def initialize(@raw : JSON::Any)
    end

    # The (unknown) elicitation action.
    def action : String?
      @raw["action"]?.try(&.as_s?)
    end

    def self.new(pull : JSON::PullParser)
      new(JSON::Any.new(pull))
    end

    def to_json(json : JSON::Builder) : Nil
      @raw.to_json(json)
    end
  end
end
