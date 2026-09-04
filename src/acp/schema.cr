# src/acp/schema.cr
# Generated from agent-client-protocol schema (v1 schema.json @ schema-v1.21.0).
# Do not edit by hand; regenerate via tools/generate_schema.py.
module ACP
  # A unique identifier for a conversation session between a client and agent.
  alias SessionId = String
  # Unique identifier for a tool call within a session.
  alias ToolCallId = String
  # Typed identifier used for terminal values on the wire.
  alias TerminalId = String
  # Unique identifier for a permission option.
  alias PermissionOptionId = String
  # Unique identifier for an elicitation.
  alias ElicitationId = String
  # Typed identifier used for auth method values on the wire.
  alias AuthMethodId = String
  # Unique identifier for a Session Mode.
  alias SessionModeId = String
  # Unique identifier for a session configuration option.
  alias SessionConfigId = String
  # Unique identifier for a session configuration option value.
  alias SessionConfigValueId = String
  # Unique identifier for a session configuration option value group.
  alias SessionConfigGroupId = String
  # Unique identifier for a message within a session.
  alias MessageId = String

  # Type discriminator for elicitation schemas.
  enum ElicitationSchemaType
    Object
  end

  # The type of permission option being presented to the user.
  enum PermissionOptionKind
    AllowOnce
    AllowAlways
    RejectOnce
    RejectAlways
  end

  # Priority levels for plan entries.
  enum PlanEntryPriority
    High
    Medium
    Low
  end

  # Status of a plan entry in the execution flow.
  enum PlanEntryStatus
    Pending
    InProgress
    Completed
  end

  # The sender or recipient of messages and data in a conversation.
  enum Role
    Assistant
    User
  end

  # Reasons why an agent stops processing a prompt turn.
  enum StopReason
    EndTurn
    MaxTokens
    MaxTurnRequests
    Refusal
    Cancelled
  end

  # String format types for string properties in elicitation schemas.
  enum StringFormat
    Email
    Uri
    Date
    DateTime

    def to_json(json : JSON::Builder) : Nil
      json.string(case self
      in .email?     then "email"
      in .uri?       then "uri"
      in .date?      then "date"
      in .date_time? then "date-time"
      end)
    end

    def self.new(pull : JSON::PullParser)
      case s = pull.read_string
      when "email"     then Email
      when "uri"       then Uri
      when "date"      then Date
      when "date-time" then DateTime
      else                  raise JSON::ParseException.new("Unknown StringFormat value: #{s}", *pull.location_i64)
      end
    end
  end

  # Execution status of a tool call.
  enum ToolCallStatus
    Pending
    InProgress
    Completed
    Failed
  end

  # Categories of tools that can be invoked.
  enum ToolKind
    Read
    Edit
    Delete
    Move
    Search
    Execute
    Think
    Fetch
    SwitchMode
    Other
  end

  # Request to write content to a text file.
  class WriteTextFileRequest
    include JSON::Serializable

    @[JSON::Field(key: "sessionId")]
    getter session_id : SessionId

    @[JSON::Field(key: "path")]
    getter path : String

    @[JSON::Field(key: "content")]
    getter content : String

    @[JSON::Field(key: "_meta", emit_null: false)]
    getter meta : Hash(String, JSON::Any)?

    def initialize(
      *,
      @session_id : SessionId,
      @path : String,
      @content : String,
      @meta : Hash(String, JSON::Any)? = nil,
    )
    end
  end

  # Request to read content from a text file.
  class ReadTextFileRequest
    include JSON::Serializable

    @[JSON::Field(key: "sessionId")]
    getter session_id : SessionId

    @[JSON::Field(key: "path")]
    getter path : String

    @[JSON::Field(key: "line", emit_null: false)]
    getter line : UInt32?

    @[JSON::Field(key: "limit", emit_null: false)]
    getter limit : UInt32?

    @[JSON::Field(key: "_meta", emit_null: false)]
    getter meta : Hash(String, JSON::Any)?

    def initialize(
      *,
      @session_id : SessionId,
      @path : String,
      @line : UInt32? = nil,
      @limit : UInt32? = nil,
      @meta : Hash(String, JSON::Any)? = nil,
    )
    end
  end

  # Request for user permission to execute a tool call.
  class RequestPermissionRequest
    include JSON::Serializable

    @[JSON::Field(key: "sessionId")]
    getter session_id : SessionId

    @[JSON::Field(key: "toolCall")]
    getter tool_call : ToolCallUpdate

    @[JSON::Field(key: "options")]
    getter options : Array(PermissionOption)

    @[JSON::Field(key: "_meta", emit_null: false)]
    getter meta : Hash(String, JSON::Any)?

    def initialize(
      *,
      @session_id : SessionId,
      @tool_call : ToolCallUpdate,
      @options : Array(PermissionOption),
      @meta : Hash(String, JSON::Any)? = nil,
    )
    end
  end

  # An update to an existing tool call.
  class ToolCallUpdate < SessionUpdate
    @[JSON::Field(key: "sessionUpdate")]
    getter session_update : String = "tool_call_update"

    @[JSON::Field(key: "toolCallId")]
    getter tool_call_id : ToolCallId

    @[JSON::Field(key: "kind", emit_null: false)]
    getter kind : ToolKind?

    @[JSON::Field(key: "status", emit_null: false)]
    getter status : ToolCallStatus?

    @[JSON::Field(key: "title", emit_null: false)]
    getter title : String?

    @[JSON::Field(key: "content", emit_null: false)]
    getter content : Array(ToolCallContent)?

    @[JSON::Field(key: "locations", emit_null: false)]
    getter locations : Array(ToolCallLocation)?

    @[JSON::Field(key: "rawInput", emit_null: false)]
    getter raw_input : JSON::Any?

    @[JSON::Field(key: "rawOutput", emit_null: false)]
    getter raw_output : JSON::Any?

    @[JSON::Field(key: "_meta", emit_null: false)]
    getter meta : Hash(String, JSON::Any)?

    def initialize(
      *,
      @session_update : String = "tool_call_update",
      @tool_call_id : ToolCallId,
      @kind : ToolKind? = nil,
      @status : ToolCallStatus? = nil,
      @title : String? = nil,
      @content : Array(ToolCallContent)? = nil,
      @locations : Array(ToolCallLocation)? = nil,
      @raw_input : JSON::Any? = nil,
      @raw_output : JSON::Any? = nil,
      @meta : Hash(String, JSON::Any)? = nil,
    )
    end
  end

  # Optional annotations for the client. The client can use annotations to inform how objects
  # are used or displayed
  class Annotations
    include JSON::Serializable

    @[JSON::Field(key: "audience", emit_null: false)]
    getter audience : Array(Role)?

    @[JSON::Field(key: "lastModified", emit_null: false)]
    getter last_modified : String?

    @[JSON::Field(key: "priority", emit_null: false)]
    getter priority : Float64?

    @[JSON::Field(key: "_meta", emit_null: false)]
    getter meta : Hash(String, JSON::Any)?

    def initialize(
      *,
      @audience : Array(Role)? = nil,
      @last_modified : String? = nil,
      @priority : Float64? = nil,
      @meta : Hash(String, JSON::Any)? = nil,
    )
    end
  end

  # Text provided to or from an LLM.
  class TextContent < ContentBlock
    @[JSON::Field(key: "type")]
    getter type : String = "text"

    @[JSON::Field(key: "annotations", emit_null: false)]
    getter annotations : Annotations?

    @[JSON::Field(key: "text")]
    getter text : String

    @[JSON::Field(key: "_meta", emit_null: false)]
    getter meta : Hash(String, JSON::Any)?

    def initialize(
      *,
      @type : String = "text",
      @annotations : Annotations? = nil,
      @text : String,
      @meta : Hash(String, JSON::Any)? = nil,
    )
    end
  end

  # An image provided to or from an LLM.
  class ImageContent < ContentBlock
    @[JSON::Field(key: "type")]
    getter type : String = "image"

    @[JSON::Field(key: "annotations", emit_null: false)]
    getter annotations : Annotations?

    @[JSON::Field(key: "data")]
    getter data : String

    @[JSON::Field(key: "mimeType")]
    getter mime_type : String

    @[JSON::Field(key: "uri", emit_null: false)]
    getter uri : String?

    @[JSON::Field(key: "_meta", emit_null: false)]
    getter meta : Hash(String, JSON::Any)?

    def initialize(
      *,
      @type : String = "image",
      @annotations : Annotations? = nil,
      @data : String,
      @mime_type : String,
      @uri : String? = nil,
      @meta : Hash(String, JSON::Any)? = nil,
    )
    end
  end

  # Audio provided to or from an LLM.
  class AudioContent < ContentBlock
    @[JSON::Field(key: "type")]
    getter type : String = "audio"

    @[JSON::Field(key: "annotations", emit_null: false)]
    getter annotations : Annotations?

    @[JSON::Field(key: "data")]
    getter data : String

    @[JSON::Field(key: "mimeType")]
    getter mime_type : String

    @[JSON::Field(key: "_meta", emit_null: false)]
    getter meta : Hash(String, JSON::Any)?

    def initialize(
      *,
      @type : String = "audio",
      @annotations : Annotations? = nil,
      @data : String,
      @mime_type : String,
      @meta : Hash(String, JSON::Any)? = nil,
    )
    end
  end

  # A resource that the server is capable of reading, included in a prompt or tool call
  # result.
  class ResourceLink < ContentBlock
    @[JSON::Field(key: "type")]
    getter type : String = "resource_link"

    @[JSON::Field(key: "annotations", emit_null: false)]
    getter annotations : Annotations?

    @[JSON::Field(key: "description", emit_null: false)]
    getter description : String?

    @[JSON::Field(key: "mimeType", emit_null: false)]
    getter mime_type : String?

    @[JSON::Field(key: "name")]
    getter name : String

    @[JSON::Field(key: "size", emit_null: false)]
    getter size : Int64?

    @[JSON::Field(key: "title", emit_null: false)]
    getter title : String?

    @[JSON::Field(key: "uri")]
    getter uri : String

    @[JSON::Field(key: "_meta", emit_null: false)]
    getter meta : Hash(String, JSON::Any)?

    def initialize(
      *,
      @type : String = "resource_link",
      @annotations : Annotations? = nil,
      @description : String? = nil,
      @mime_type : String? = nil,
      @name : String,
      @size : Int64? = nil,
      @title : String? = nil,
      @uri : String,
      @meta : Hash(String, JSON::Any)? = nil,
    )
    end
  end

  # Text-based resource contents.
  class TextResourceContents
    include JSON::Serializable

    @[JSON::Field(key: "mimeType", emit_null: false)]
    getter mime_type : String?

    @[JSON::Field(key: "text")]
    getter text : String

    @[JSON::Field(key: "uri")]
    getter uri : String

    @[JSON::Field(key: "_meta", emit_null: false)]
    getter meta : Hash(String, JSON::Any)?

    def initialize(
      *,
      @mime_type : String? = nil,
      @text : String,
      @uri : String,
      @meta : Hash(String, JSON::Any)? = nil,
    )
    end
  end

  # Binary resource contents.
  class BlobResourceContents
    include JSON::Serializable

    @[JSON::Field(key: "blob")]
    getter blob : String

    @[JSON::Field(key: "mimeType", emit_null: false)]
    getter mime_type : String?

    @[JSON::Field(key: "uri")]
    getter uri : String

    @[JSON::Field(key: "_meta", emit_null: false)]
    getter meta : Hash(String, JSON::Any)?

    def initialize(
      *,
      @blob : String,
      @mime_type : String? = nil,
      @uri : String,
      @meta : Hash(String, JSON::Any)? = nil,
    )
    end
  end

  # The contents of a resource, embedded into a prompt or tool call result.
  class EmbeddedResource < ContentBlock
    @[JSON::Field(key: "type")]
    getter type : String = "resource"

    @[JSON::Field(key: "annotations", emit_null: false)]
    getter annotations : Annotations?

    @[JSON::Field(key: "resource")]
    getter resource : EmbeddedResourceResource

    @[JSON::Field(key: "_meta", emit_null: false)]
    getter meta : Hash(String, JSON::Any)?

    def initialize(
      *,
      @type : String = "resource",
      @annotations : Annotations? = nil,
      @resource : EmbeddedResourceResource,
      @meta : Hash(String, JSON::Any)? = nil,
    )
    end
  end

  # Standard content block (text, images, resources).
  class Content < ToolCallContent
    @[JSON::Field(key: "type")]
    getter type : String = "content"

    @[JSON::Field(key: "content")]
    getter content : ContentBlock

    @[JSON::Field(key: "_meta", emit_null: false)]
    getter meta : Hash(String, JSON::Any)?

    def initialize(
      *,
      @type : String = "content",
      @content : ContentBlock,
      @meta : Hash(String, JSON::Any)? = nil,
    )
    end
  end

  # A diff representing file modifications.
  class Diff < ToolCallContent
    @[JSON::Field(key: "type")]
    getter type : String = "diff"

    @[JSON::Field(key: "path")]
    getter path : String

    @[JSON::Field(key: "oldText", emit_null: false)]
    getter old_text : String?

    @[JSON::Field(key: "newText")]
    getter new_text : String

    @[JSON::Field(key: "_meta", emit_null: false)]
    getter meta : Hash(String, JSON::Any)?

    def initialize(
      *,
      @type : String = "diff",
      @path : String,
      @old_text : String? = nil,
      @new_text : String,
      @meta : Hash(String, JSON::Any)? = nil,
    )
    end
  end

  # Embed a terminal created with `terminal/create` by its id.
  class Terminal < ToolCallContent
    @[JSON::Field(key: "type")]
    getter type : String = "terminal"

    @[JSON::Field(key: "terminalId")]
    getter terminal_id : TerminalId

    @[JSON::Field(key: "_meta", emit_null: false)]
    getter meta : Hash(String, JSON::Any)?

    def initialize(
      *,
      @type : String = "terminal",
      @terminal_id : TerminalId,
      @meta : Hash(String, JSON::Any)? = nil,
    )
    end
  end

  # A file location being accessed or modified by a tool.
  class ToolCallLocation
    include JSON::Serializable

    @[JSON::Field(key: "path")]
    getter path : String

    @[JSON::Field(key: "line", emit_null: false)]
    getter line : UInt32?

    @[JSON::Field(key: "_meta", emit_null: false)]
    getter meta : Hash(String, JSON::Any)?

    def initialize(
      *,
      @path : String,
      @line : UInt32? = nil,
      @meta : Hash(String, JSON::Any)? = nil,
    )
    end
  end

  # An option presented to the user when requesting permission.
  class PermissionOption
    include JSON::Serializable

    @[JSON::Field(key: "optionId")]
    getter option_id : PermissionOptionId

    @[JSON::Field(key: "name")]
    getter name : String

    @[JSON::Field(key: "kind")]
    getter kind : PermissionOptionKind

    @[JSON::Field(key: "_meta", emit_null: false)]
    getter meta : Hash(String, JSON::Any)?

    def initialize(
      *,
      @option_id : PermissionOptionId,
      @name : String,
      @kind : PermissionOptionKind,
      @meta : Hash(String, JSON::Any)? = nil,
    )
    end
  end

  # Request to create a new terminal and execute a command.
  class CreateTerminalRequest
    include JSON::Serializable

    @[JSON::Field(key: "sessionId")]
    getter session_id : SessionId

    @[JSON::Field(key: "command")]
    getter command : String

    @[JSON::Field(key: "args", emit_null: false)]
    getter args : Array(String)?

    @[JSON::Field(key: "env", emit_null: false)]
    getter env : Array(EnvVariable)?

    @[JSON::Field(key: "cwd", emit_null: false)]
    getter cwd : String?

    @[JSON::Field(key: "outputByteLimit", emit_null: false)]
    getter output_byte_limit : UInt64?

    @[JSON::Field(key: "_meta", emit_null: false)]
    getter meta : Hash(String, JSON::Any)?

    def initialize(
      *,
      @session_id : SessionId,
      @command : String,
      @args : Array(String)? = nil,
      @env : Array(EnvVariable)? = nil,
      @cwd : String? = nil,
      @output_byte_limit : UInt64? = nil,
      @meta : Hash(String, JSON::Any)? = nil,
    )
    end
  end

  # An environment variable to set when launching an MCP server.
  class EnvVariable
    include JSON::Serializable

    @[JSON::Field(key: "name")]
    getter name : String

    @[JSON::Field(key: "value")]
    getter value : String

    @[JSON::Field(key: "_meta", emit_null: false)]
    getter meta : Hash(String, JSON::Any)?

    def initialize(
      *,
      @name : String,
      @value : String,
      @meta : Hash(String, JSON::Any)? = nil,
    )
    end
  end

  # Request to get the current output and status of a terminal.
  class TerminalOutputRequest
    include JSON::Serializable

    @[JSON::Field(key: "sessionId")]
    getter session_id : SessionId

    @[JSON::Field(key: "terminalId")]
    getter terminal_id : TerminalId

    @[JSON::Field(key: "_meta", emit_null: false)]
    getter meta : Hash(String, JSON::Any)?

    def initialize(
      *,
      @session_id : SessionId,
      @terminal_id : TerminalId,
      @meta : Hash(String, JSON::Any)? = nil,
    )
    end
  end

  # Request to release a terminal and free its resources.
  class ReleaseTerminalRequest
    include JSON::Serializable

    @[JSON::Field(key: "sessionId")]
    getter session_id : SessionId

    @[JSON::Field(key: "terminalId")]
    getter terminal_id : TerminalId

    @[JSON::Field(key: "_meta", emit_null: false)]
    getter meta : Hash(String, JSON::Any)?

    def initialize(
      *,
      @session_id : SessionId,
      @terminal_id : TerminalId,
      @meta : Hash(String, JSON::Any)? = nil,
    )
    end
  end

  # Request to wait for a terminal command to exit.
  class WaitForTerminalExitRequest
    include JSON::Serializable

    @[JSON::Field(key: "sessionId")]
    getter session_id : SessionId

    @[JSON::Field(key: "terminalId")]
    getter terminal_id : TerminalId

    @[JSON::Field(key: "_meta", emit_null: false)]
    getter meta : Hash(String, JSON::Any)?

    def initialize(
      *,
      @session_id : SessionId,
      @terminal_id : TerminalId,
      @meta : Hash(String, JSON::Any)? = nil,
    )
    end
  end

  # Request to kill a terminal without releasing it.
  class KillTerminalRequest
    include JSON::Serializable

    @[JSON::Field(key: "sessionId")]
    getter session_id : SessionId

    @[JSON::Field(key: "terminalId")]
    getter terminal_id : TerminalId

    @[JSON::Field(key: "_meta", emit_null: false)]
    getter meta : Hash(String, JSON::Any)?

    def initialize(
      *,
      @session_id : SessionId,
      @terminal_id : TerminalId,
      @meta : Hash(String, JSON::Any)? = nil,
    )
    end
  end

  # Type-safe elicitation schema for requesting structured user input.
  class ElicitationSchema
    include JSON::Serializable

    @[JSON::Field(key: "type")]
    getter type : ElicitationSchemaType = ElicitationSchemaType::Object

    @[JSON::Field(key: "title", emit_null: false)]
    getter title : String?

    @[JSON::Field(key: "properties")]
    getter properties : Hash(String, ElicitationPropertySchema) = Hash(String, ElicitationPropertySchema).new

    @[JSON::Field(key: "required", emit_null: false)]
    getter required : Array(String)?

    @[JSON::Field(key: "description", emit_null: false)]
    getter description : String?

    @[JSON::Field(key: "_meta", emit_null: false)]
    getter meta : Hash(String, JSON::Any)?

    def initialize(
      *,
      @type : ElicitationSchemaType = ElicitationSchemaType::Object,
      @title : String? = nil,
      @properties : Hash(String, ElicitationPropertySchema) = Hash(String, ElicitationPropertySchema).new,
      @required : Array(String)? = nil,
      @description : String? = nil,
      @meta : Hash(String, JSON::Any)? = nil,
    )
    end
  end

  # A titled enum option with a const value, human-readable title, and optional description.
  class EnumOption
    include JSON::Serializable

    @[JSON::Field(key: "const")]
    getter const : String

    @[JSON::Field(key: "title")]
    getter title : String

    @[JSON::Field(key: "description", emit_null: false)]
    getter description : String?

    @[JSON::Field(key: "_meta", emit_null: false)]
    getter meta : Hash(String, JSON::Any)?

    def initialize(
      *,
      @const : String,
      @title : String,
      @description : String? = nil,
      @meta : Hash(String, JSON::Any)? = nil,
    )
    end
  end

  # Schema for string properties in an elicitation form.
  class StringPropertySchema < ElicitationPropertySchema
    @[JSON::Field(key: "type")]
    getter type : String = "string"

    @[JSON::Field(key: "title", emit_null: false)]
    getter title : String?

    @[JSON::Field(key: "description", emit_null: false)]
    getter description : String?

    @[JSON::Field(key: "minLength", emit_null: false)]
    getter min_length : UInt32?

    @[JSON::Field(key: "maxLength", emit_null: false)]
    getter max_length : UInt32?

    @[JSON::Field(key: "pattern", emit_null: false)]
    getter pattern : String?

    @[JSON::Field(key: "format", emit_null: false)]
    getter format : StringFormat?

    @[JSON::Field(key: "default", emit_null: false)]
    getter default : String?

    @[JSON::Field(key: "enum", emit_null: false)]
    getter enum_values : Array(String)?

    @[JSON::Field(key: "oneOf", emit_null: false)]
    getter one_of : Array(EnumOption)?

    @[JSON::Field(key: "_meta", emit_null: false)]
    getter meta : Hash(String, JSON::Any)?

    def initialize(
      *,
      @type : String = "string",
      @title : String? = nil,
      @description : String? = nil,
      @min_length : UInt32? = nil,
      @max_length : UInt32? = nil,
      @pattern : String? = nil,
      @format : StringFormat? = nil,
      @default : String? = nil,
      @enum_values : Array(String)? = nil,
      @one_of : Array(EnumOption)? = nil,
      @meta : Hash(String, JSON::Any)? = nil,
    )
    end
  end

  # Schema for number (floating-point) properties in an elicitation form.
  class NumberPropertySchema < ElicitationPropertySchema
    @[JSON::Field(key: "type")]
    getter type : String = "number"

    @[JSON::Field(key: "title", emit_null: false)]
    getter title : String?

    @[JSON::Field(key: "description", emit_null: false)]
    getter description : String?

    @[JSON::Field(key: "minimum", emit_null: false)]
    getter minimum : Float64?

    @[JSON::Field(key: "maximum", emit_null: false)]
    getter maximum : Float64?

    @[JSON::Field(key: "default", emit_null: false)]
    getter default : Float64?

    @[JSON::Field(key: "_meta", emit_null: false)]
    getter meta : Hash(String, JSON::Any)?

    def initialize(
      *,
      @type : String = "number",
      @title : String? = nil,
      @description : String? = nil,
      @minimum : Float64? = nil,
      @maximum : Float64? = nil,
      @default : Float64? = nil,
      @meta : Hash(String, JSON::Any)? = nil,
    )
    end
  end

  # Schema for integer properties in an elicitation form.
  class IntegerPropertySchema < ElicitationPropertySchema
    @[JSON::Field(key: "type")]
    getter type : String = "integer"

    @[JSON::Field(key: "title", emit_null: false)]
    getter title : String?

    @[JSON::Field(key: "description", emit_null: false)]
    getter description : String?

    @[JSON::Field(key: "minimum", emit_null: false)]
    getter minimum : Int64?

    @[JSON::Field(key: "maximum", emit_null: false)]
    getter maximum : Int64?

    @[JSON::Field(key: "default", emit_null: false)]
    getter default : Int64?

    @[JSON::Field(key: "_meta", emit_null: false)]
    getter meta : Hash(String, JSON::Any)?

    def initialize(
      *,
      @type : String = "integer",
      @title : String? = nil,
      @description : String? = nil,
      @minimum : Int64? = nil,
      @maximum : Int64? = nil,
      @default : Int64? = nil,
      @meta : Hash(String, JSON::Any)? = nil,
    )
    end
  end

  # Schema for boolean properties in an elicitation form.
  class BooleanPropertySchema < ElicitationPropertySchema
    @[JSON::Field(key: "type")]
    getter type : String = "boolean"

    @[JSON::Field(key: "title", emit_null: false)]
    getter title : String?

    @[JSON::Field(key: "description", emit_null: false)]
    getter description : String?

    @[JSON::Field(key: "default", emit_null: false)]
    getter default : Bool?

    @[JSON::Field(key: "_meta", emit_null: false)]
    getter meta : Hash(String, JSON::Any)?

    def initialize(
      *,
      @type : String = "boolean",
      @title : String? = nil,
      @description : String? = nil,
      @default : Bool? = nil,
      @meta : Hash(String, JSON::Any)? = nil,
    )
    end
  end

  # String item schema for multi-select enum properties.
  class StringMultiSelectItems < MultiSelectItems
    @[JSON::Field(key: "type")]
    getter type : String = "string"

    @[JSON::Field(key: "enum")]
    getter enum_values : Array(String)

    @[JSON::Field(key: "_meta", emit_null: false)]
    getter meta : Hash(String, JSON::Any)?

    def initialize(
      *,
      @type : String = "string",
      @enum_values : Array(String),
      @meta : Hash(String, JSON::Any)? = nil,
    )
    end
  end

  # Items definition for titled multi-select enum properties.
  class TitledMultiSelectItems < MultiSelectItems
    @[JSON::Field(key: "type")]
    getter type : String = "titled"

    @[JSON::Field(key: "anyOf")]
    getter any_of : Array(EnumOption)

    @[JSON::Field(key: "_meta", emit_null: false)]
    getter meta : Hash(String, JSON::Any)?

    def initialize(
      *,
      @type : String = "titled",
      @any_of : Array(EnumOption),
      @meta : Hash(String, JSON::Any)? = nil,
    )
    end
  end

  # Schema for multi-select (array) properties in an elicitation form.
  class MultiSelectPropertySchema < ElicitationPropertySchema
    @[JSON::Field(key: "type")]
    getter type : String = "array"

    @[JSON::Field(key: "title", emit_null: false)]
    getter title : String?

    @[JSON::Field(key: "description", emit_null: false)]
    getter description : String?

    @[JSON::Field(key: "minItems", emit_null: false)]
    getter min_items : UInt64?

    @[JSON::Field(key: "maxItems", emit_null: false)]
    getter max_items : UInt64?

    @[JSON::Field(key: "items")]
    getter items : MultiSelectItems

    @[JSON::Field(key: "default", emit_null: false)]
    getter default : Array(String)?

    @[JSON::Field(key: "_meta", emit_null: false)]
    getter meta : Hash(String, JSON::Any)?

    def initialize(
      *,
      @type : String = "array",
      @title : String? = nil,
      @description : String? = nil,
      @min_items : UInt64? = nil,
      @max_items : UInt64? = nil,
      @items : MultiSelectItems,
      @default : Array(String)? = nil,
      @meta : Hash(String, JSON::Any)? = nil,
    )
    end
  end

  # Response to the `initialize` method.
  class InitializeResponse
    include JSON::Serializable

    @[JSON::Field(key: "protocolVersion")]
    getter protocol_version : ProtocolVersion

    @[JSON::Field(key: "agentCapabilities", emit_null: false)]
    getter agent_capabilities : AgentCapabilities?

    @[JSON::Field(key: "authMethods")]
    getter auth_methods : Array(AuthMethod) = Array(AuthMethod).new

    @[JSON::Field(key: "agentInfo", emit_null: false)]
    getter agent_info : Implementation?

    @[JSON::Field(key: "_meta", emit_null: false)]
    getter meta : Hash(String, JSON::Any)?

    def initialize(
      *,
      @protocol_version : ProtocolVersion,
      @agent_capabilities : AgentCapabilities? = nil,
      @auth_methods : Array(AuthMethod) = Array(AuthMethod).new,
      @agent_info : Implementation? = nil,
      @meta : Hash(String, JSON::Any)? = nil,
    )
    end
  end

  # Capabilities supported by the agent.
  class AgentCapabilities
    include JSON::Serializable

    @[JSON::Field(key: "loadSession")]
    getter load_session : Bool = false

    @[JSON::Field(key: "promptCapabilities", emit_null: false)]
    getter prompt_capabilities : PromptCapabilities?

    @[JSON::Field(key: "mcpCapabilities", emit_null: false)]
    getter mcp_capabilities : McpCapabilities?

    @[JSON::Field(key: "sessionCapabilities")]
    getter session_capabilities : SessionCapabilities = SessionCapabilities.new

    @[JSON::Field(key: "auth")]
    getter auth : AgentAuthCapabilities = AgentAuthCapabilities.new

    @[JSON::Field(key: "_meta", emit_null: false)]
    getter meta : Hash(String, JSON::Any)?

    def initialize(
      *,
      @load_session : Bool = false,
      @prompt_capabilities : PromptCapabilities? = nil,
      @mcp_capabilities : McpCapabilities? = nil,
      @session_capabilities : SessionCapabilities = SessionCapabilities.new,
      @auth : AgentAuthCapabilities = AgentAuthCapabilities.new,
      @meta : Hash(String, JSON::Any)? = nil,
    )
    end
  end

  # Prompt capabilities supported by the agent in `session/prompt` requests.
  class PromptCapabilities
    include JSON::Serializable

    @[JSON::Field(key: "image")]
    getter image : Bool = false

    @[JSON::Field(key: "audio")]
    getter audio : Bool = false

    @[JSON::Field(key: "embeddedContext")]
    getter embedded_context : Bool = false

    @[JSON::Field(key: "_meta", emit_null: false)]
    getter meta : Hash(String, JSON::Any)?

    def initialize(
      *,
      @image : Bool = false,
      @audio : Bool = false,
      @embedded_context : Bool = false,
      @meta : Hash(String, JSON::Any)? = nil,
    )
    end
  end

  # MCP capabilities supported by the agent
  class McpCapabilities
    include JSON::Serializable

    @[JSON::Field(key: "http")]
    getter http : Bool = false

    @[JSON::Field(key: "sse")]
    getter sse : Bool = false

    @[JSON::Field(key: "_meta", emit_null: false)]
    getter meta : Hash(String, JSON::Any)?

    def initialize(
      *,
      @http : Bool = false,
      @sse : Bool = false,
      @meta : Hash(String, JSON::Any)? = nil,
    )
    end
  end

  # Session capabilities supported by the agent.
  class SessionCapabilities
    include JSON::Serializable

    @[JSON::Field(key: "list", emit_null: false)]
    getter list : SessionListCapabilities?

    @[JSON::Field(key: "delete", emit_null: false)]
    getter delete : SessionDeleteCapabilities?

    @[JSON::Field(key: "additionalDirectories", emit_null: false)]
    getter additional_directories : SessionAdditionalDirectoriesCapabilities?

    @[JSON::Field(key: "resume", emit_null: false)]
    getter resume : SessionResumeCapabilities?

    @[JSON::Field(key: "close", emit_null: false)]
    getter close : SessionCloseCapabilities?

    @[JSON::Field(key: "_meta", emit_null: false)]
    getter meta : Hash(String, JSON::Any)?

    def initialize(
      *,
      @list : SessionListCapabilities? = nil,
      @delete : SessionDeleteCapabilities? = nil,
      @additional_directories : SessionAdditionalDirectoriesCapabilities? = nil,
      @resume : SessionResumeCapabilities? = nil,
      @close : SessionCloseCapabilities? = nil,
      @meta : Hash(String, JSON::Any)? = nil,
    )
    end
  end

  # Capabilities for the `session/list` method.
  class SessionListCapabilities
    include JSON::Serializable

    @[JSON::Field(key: "_meta", emit_null: false)]
    getter meta : Hash(String, JSON::Any)?

    def initialize(
      *,
      @meta : Hash(String, JSON::Any)? = nil,
    )
    end
  end

  # Capabilities for the `session/delete` method.
  class SessionDeleteCapabilities
    include JSON::Serializable

    @[JSON::Field(key: "_meta", emit_null: false)]
    getter meta : Hash(String, JSON::Any)?

    def initialize(
      *,
      @meta : Hash(String, JSON::Any)? = nil,
    )
    end
  end

  # Capabilities for additional session directories support.
  class SessionAdditionalDirectoriesCapabilities
    include JSON::Serializable

    @[JSON::Field(key: "_meta", emit_null: false)]
    getter meta : Hash(String, JSON::Any)?

    def initialize(
      *,
      @meta : Hash(String, JSON::Any)? = nil,
    )
    end
  end

  # Capabilities for the `session/resume` method.
  class SessionResumeCapabilities
    include JSON::Serializable

    @[JSON::Field(key: "_meta", emit_null: false)]
    getter meta : Hash(String, JSON::Any)?

    def initialize(
      *,
      @meta : Hash(String, JSON::Any)? = nil,
    )
    end
  end

  # Capabilities for the `session/close` method.
  class SessionCloseCapabilities
    include JSON::Serializable

    @[JSON::Field(key: "_meta", emit_null: false)]
    getter meta : Hash(String, JSON::Any)?

    def initialize(
      *,
      @meta : Hash(String, JSON::Any)? = nil,
    )
    end
  end

  # Authentication-related capabilities supported by the agent.
  class AgentAuthCapabilities
    include JSON::Serializable

    @[JSON::Field(key: "logout", emit_null: false)]
    getter logout : LogoutCapabilities?

    @[JSON::Field(key: "_meta", emit_null: false)]
    getter meta : Hash(String, JSON::Any)?

    def initialize(
      *,
      @logout : LogoutCapabilities? = nil,
      @meta : Hash(String, JSON::Any)? = nil,
    )
    end
  end

  # Logout capabilities supported by the agent.
  class LogoutCapabilities
    include JSON::Serializable

    @[JSON::Field(key: "_meta", emit_null: false)]
    getter meta : Hash(String, JSON::Any)?

    def initialize(
      *,
      @meta : Hash(String, JSON::Any)? = nil,
    )
    end
  end

  # Terminal-based authentication method.
  class AuthMethodTerminal < AuthMethod
    @[JSON::Field(key: "type")]
    getter type : String = "terminal"

    @[JSON::Field(key: "id")]
    getter id : AuthMethodId

    @[JSON::Field(key: "name")]
    getter name : String

    @[JSON::Field(key: "description", emit_null: false)]
    getter description : String?

    @[JSON::Field(key: "args", emit_null: false)]
    getter args : Array(String)?

    @[JSON::Field(key: "env", emit_null: false)]
    getter env : Hash(String, String)?

    @[JSON::Field(key: "_meta", emit_null: false)]
    getter meta : Hash(String, JSON::Any)?

    def initialize(
      *,
      @type : String = "terminal",
      @id : AuthMethodId,
      @name : String,
      @description : String? = nil,
      @args : Array(String)? = nil,
      @env : Hash(String, String)? = nil,
      @meta : Hash(String, JSON::Any)? = nil,
    )
    end
  end

  # Agent handles authentication itself through `authenticate`.
  class AuthMethodAgent < AuthMethod
    @[JSON::Field(key: "id")]
    getter id : AuthMethodId

    @[JSON::Field(key: "name")]
    getter name : String

    @[JSON::Field(key: "description", emit_null: false)]
    getter description : String?

    @[JSON::Field(key: "_meta", emit_null: false)]
    getter meta : Hash(String, JSON::Any)?

    def initialize(
      *,
      @id : AuthMethodId,
      @name : String,
      @description : String? = nil,
      @meta : Hash(String, JSON::Any)? = nil,
    )
    end
  end

  # Metadata about the implementation of the client or agent. Describes the name and version
  # of an ACP implementation, with an optional title for UI representation.
  class Implementation
    include JSON::Serializable

    @[JSON::Field(key: "name")]
    getter name : String

    @[JSON::Field(key: "title", emit_null: false)]
    getter title : String?

    @[JSON::Field(key: "version")]
    getter version : String

    @[JSON::Field(key: "_meta", emit_null: false)]
    getter meta : Hash(String, JSON::Any)?

    def initialize(
      *,
      @name : String,
      @title : String? = nil,
      @version : String,
      @meta : Hash(String, JSON::Any)? = nil,
    )
    end
  end

  # Response to the `authenticate` method.
  class AuthenticateResponse
    include JSON::Serializable

    @[JSON::Field(key: "_meta", emit_null: false)]
    getter meta : Hash(String, JSON::Any)?

    def initialize(
      *,
      @meta : Hash(String, JSON::Any)? = nil,
    )
    end
  end

  # Response to the `logout` method.
  class LogoutResponse
    include JSON::Serializable

    @[JSON::Field(key: "_meta", emit_null: false)]
    getter meta : Hash(String, JSON::Any)?

    def initialize(
      *,
      @meta : Hash(String, JSON::Any)? = nil,
    )
    end
  end

  # Response from creating a new session.
  class NewSessionResponse
    include JSON::Serializable

    @[JSON::Field(key: "sessionId")]
    getter session_id : SessionId

    @[JSON::Field(key: "modes", emit_null: false)]
    getter modes : SessionModeState?

    @[JSON::Field(key: "configOptions", emit_null: false)]
    getter config_options : Array(SessionConfigOption)?

    @[JSON::Field(key: "_meta", emit_null: false)]
    getter meta : Hash(String, JSON::Any)?

    def initialize(
      *,
      @session_id : SessionId,
      @modes : SessionModeState? = nil,
      @config_options : Array(SessionConfigOption)? = nil,
      @meta : Hash(String, JSON::Any)? = nil,
    )
    end
  end

  # The set of modes and the one currently active.
  class SessionModeState
    include JSON::Serializable

    @[JSON::Field(key: "currentModeId")]
    getter current_mode_id : SessionModeId

    @[JSON::Field(key: "availableModes")]
    getter available_modes : Array(SessionMode)

    @[JSON::Field(key: "_meta", emit_null: false)]
    getter meta : Hash(String, JSON::Any)?

    def initialize(
      *,
      @current_mode_id : SessionModeId,
      @available_modes : Array(SessionMode),
      @meta : Hash(String, JSON::Any)? = nil,
    )
    end
  end

  # A mode the agent can operate in.
  class SessionMode
    include JSON::Serializable

    @[JSON::Field(key: "id")]
    getter id : SessionModeId

    @[JSON::Field(key: "name")]
    getter name : String

    @[JSON::Field(key: "description", emit_null: false)]
    getter description : String?

    @[JSON::Field(key: "_meta", emit_null: false)]
    getter meta : Hash(String, JSON::Any)?

    def initialize(
      *,
      @id : SessionModeId,
      @name : String,
      @description : String? = nil,
      @meta : Hash(String, JSON::Any)? = nil,
    )
    end
  end

  # A possible value for a session configuration option.
  class SessionConfigSelectOption
    include JSON::Serializable

    @[JSON::Field(key: "value")]
    getter value : SessionConfigValueId

    @[JSON::Field(key: "name")]
    getter name : String

    @[JSON::Field(key: "description", emit_null: false)]
    getter description : String?

    @[JSON::Field(key: "_meta", emit_null: false)]
    getter meta : Hash(String, JSON::Any)?

    def initialize(
      *,
      @value : SessionConfigValueId,
      @name : String,
      @description : String? = nil,
      @meta : Hash(String, JSON::Any)? = nil,
    )
    end
  end

  # A group of possible values for a session configuration option.
  class SessionConfigSelectGroup
    include JSON::Serializable

    @[JSON::Field(key: "group")]
    getter group : SessionConfigGroupId

    @[JSON::Field(key: "name")]
    getter name : String

    @[JSON::Field(key: "options")]
    getter options : Array(SessionConfigSelectOption)

    @[JSON::Field(key: "_meta", emit_null: false)]
    getter meta : Hash(String, JSON::Any)?

    def initialize(
      *,
      @group : SessionConfigGroupId,
      @name : String,
      @options : Array(SessionConfigSelectOption),
      @meta : Hash(String, JSON::Any)? = nil,
    )
    end
  end

  # Response from loading an existing session.
  class LoadSessionResponse
    include JSON::Serializable

    @[JSON::Field(key: "modes", emit_null: false)]
    getter modes : SessionModeState?

    @[JSON::Field(key: "configOptions", emit_null: false)]
    getter config_options : Array(SessionConfigOption)?

    @[JSON::Field(key: "_meta", emit_null: false)]
    getter meta : Hash(String, JSON::Any)?

    def initialize(
      *,
      @modes : SessionModeState? = nil,
      @config_options : Array(SessionConfigOption)? = nil,
      @meta : Hash(String, JSON::Any)? = nil,
    )
    end
  end

  # Response from listing sessions.
  class ListSessionsResponse
    include JSON::Serializable

    @[JSON::Field(key: "sessions")]
    getter sessions : Array(SessionInfo)

    @[JSON::Field(key: "nextCursor", emit_null: false)]
    getter next_cursor : String?

    @[JSON::Field(key: "_meta", emit_null: false)]
    getter meta : Hash(String, JSON::Any)?

    def initialize(
      *,
      @sessions : Array(SessionInfo),
      @next_cursor : String? = nil,
      @meta : Hash(String, JSON::Any)? = nil,
    )
    end
  end

  # Information about a session returned by session/list
  class SessionInfo
    include JSON::Serializable

    @[JSON::Field(key: "sessionId")]
    getter session_id : SessionId

    @[JSON::Field(key: "cwd")]
    getter cwd : String

    @[JSON::Field(key: "additionalDirectories", emit_null: false)]
    getter additional_directories : Array(String)?

    @[JSON::Field(key: "title", emit_null: false)]
    getter title : String?

    @[JSON::Field(key: "updatedAt", emit_null: false)]
    getter updated_at : String?

    @[JSON::Field(key: "_meta", emit_null: false)]
    getter meta : Hash(String, JSON::Any)?

    def initialize(
      *,
      @session_id : SessionId,
      @cwd : String,
      @additional_directories : Array(String)? = nil,
      @title : String? = nil,
      @updated_at : String? = nil,
      @meta : Hash(String, JSON::Any)? = nil,
    )
    end
  end

  # Response from deleting a session.
  class DeleteSessionResponse
    include JSON::Serializable

    @[JSON::Field(key: "_meta", emit_null: false)]
    getter meta : Hash(String, JSON::Any)?

    def initialize(
      *,
      @meta : Hash(String, JSON::Any)? = nil,
    )
    end
  end

  # Response from resuming an existing session.
  class ResumeSessionResponse
    include JSON::Serializable

    @[JSON::Field(key: "modes", emit_null: false)]
    getter modes : SessionModeState?

    @[JSON::Field(key: "configOptions", emit_null: false)]
    getter config_options : Array(SessionConfigOption)?

    @[JSON::Field(key: "_meta", emit_null: false)]
    getter meta : Hash(String, JSON::Any)?

    def initialize(
      *,
      @modes : SessionModeState? = nil,
      @config_options : Array(SessionConfigOption)? = nil,
      @meta : Hash(String, JSON::Any)? = nil,
    )
    end
  end

  # Response from closing a session.
  class CloseSessionResponse
    include JSON::Serializable

    @[JSON::Field(key: "_meta", emit_null: false)]
    getter meta : Hash(String, JSON::Any)?

    def initialize(
      *,
      @meta : Hash(String, JSON::Any)? = nil,
    )
    end
  end

  # Response to `session/set_mode` method.
  class SetSessionModeResponse
    include JSON::Serializable

    @[JSON::Field(key: "_meta", emit_null: false)]
    getter meta : Hash(String, JSON::Any)?

    def initialize(
      *,
      @meta : Hash(String, JSON::Any)? = nil,
    )
    end
  end

  # Response to `session/set_config_option` method.
  class SetSessionConfigOptionResponse
    include JSON::Serializable

    @[JSON::Field(key: "configOptions")]
    getter config_options : Array(SessionConfigOption)

    @[JSON::Field(key: "_meta", emit_null: false)]
    getter meta : Hash(String, JSON::Any)?

    def initialize(
      *,
      @config_options : Array(SessionConfigOption),
      @meta : Hash(String, JSON::Any)? = nil,
    )
    end
  end

  # Response from processing a user prompt.
  class PromptResponse
    include JSON::Serializable

    @[JSON::Field(key: "stopReason")]
    getter stop_reason : StopReason

    @[JSON::Field(key: "_meta", emit_null: false)]
    getter meta : Hash(String, JSON::Any)?

    def initialize(
      *,
      @stop_reason : StopReason,
      @meta : Hash(String, JSON::Any)? = nil,
    )
    end
  end

  # Notification containing a session update from the agent.
  class SessionNotification
    include JSON::Serializable

    @[JSON::Field(key: "sessionId")]
    getter session_id : SessionId

    @[JSON::Field(key: "update")]
    getter update : SessionUpdate

    @[JSON::Field(key: "_meta", emit_null: false)]
    getter meta : Hash(String, JSON::Any)?

    def initialize(
      *,
      @session_id : SessionId,
      @update : SessionUpdate,
      @meta : Hash(String, JSON::Any)? = nil,
    )
    end
  end

  # A streamed item of content
  class ContentChunk < SessionUpdate
    @[JSON::Field(key: "sessionUpdate")]
    getter session_update : String

    @[JSON::Field(key: "content")]
    getter content : ContentBlock

    @[JSON::Field(key: "messageId", emit_null: false)]
    getter message_id : MessageId?

    @[JSON::Field(key: "_meta", emit_null: false)]
    getter meta : Hash(String, JSON::Any)?

    def initialize(
      *,
      @session_update : String,
      @content : ContentBlock,
      @message_id : MessageId? = nil,
      @meta : Hash(String, JSON::Any)? = nil,
    )
    end
  end

  # Represents a tool call that the language model has requested.
  class ToolCall < SessionUpdate
    @[JSON::Field(key: "sessionUpdate")]
    getter session_update : String = "tool_call"

    @[JSON::Field(key: "toolCallId")]
    getter tool_call_id : ToolCallId

    @[JSON::Field(key: "title")]
    getter title : String

    @[JSON::Field(key: "kind", emit_null: false)]
    getter kind : ToolKind?

    @[JSON::Field(key: "status", emit_null: false)]
    getter status : ToolCallStatus?

    @[JSON::Field(key: "content", emit_null: false)]
    getter content : Array(ToolCallContent)?

    @[JSON::Field(key: "locations", emit_null: false)]
    getter locations : Array(ToolCallLocation)?

    @[JSON::Field(key: "rawInput", emit_null: false)]
    getter raw_input : JSON::Any?

    @[JSON::Field(key: "rawOutput", emit_null: false)]
    getter raw_output : JSON::Any?

    @[JSON::Field(key: "_meta", emit_null: false)]
    getter meta : Hash(String, JSON::Any)?

    def initialize(
      *,
      @session_update : String = "tool_call",
      @tool_call_id : ToolCallId,
      @title : String,
      @kind : ToolKind? = nil,
      @status : ToolCallStatus? = nil,
      @content : Array(ToolCallContent)? = nil,
      @locations : Array(ToolCallLocation)? = nil,
      @raw_input : JSON::Any? = nil,
      @raw_output : JSON::Any? = nil,
      @meta : Hash(String, JSON::Any)? = nil,
    )
    end
  end

  # A single entry in the execution plan.
  class PlanEntry
    include JSON::Serializable

    @[JSON::Field(key: "content")]
    getter content : String

    @[JSON::Field(key: "priority")]
    getter priority : PlanEntryPriority

    @[JSON::Field(key: "status")]
    getter status : PlanEntryStatus

    @[JSON::Field(key: "_meta", emit_null: false)]
    getter meta : Hash(String, JSON::Any)?

    def initialize(
      *,
      @content : String,
      @priority : PlanEntryPriority,
      @status : PlanEntryStatus,
      @meta : Hash(String, JSON::Any)? = nil,
    )
    end
  end

  # An execution plan for accomplishing complex tasks.
  class Plan < SessionUpdate
    @[JSON::Field(key: "sessionUpdate")]
    getter session_update : String = "plan"

    @[JSON::Field(key: "entries")]
    getter entries : Array(PlanEntry)

    @[JSON::Field(key: "_meta", emit_null: false)]
    getter meta : Hash(String, JSON::Any)?

    def initialize(
      *,
      @session_update : String = "plan",
      @entries : Array(PlanEntry),
      @meta : Hash(String, JSON::Any)? = nil,
    )
    end
  end

  # Information about a command.
  class AvailableCommand
    include JSON::Serializable

    @[JSON::Field(key: "name")]
    getter name : String

    @[JSON::Field(key: "description")]
    getter description : String

    @[JSON::Field(key: "input", emit_null: false)]
    getter input : AvailableCommandInput?

    @[JSON::Field(key: "_meta", emit_null: false)]
    getter meta : Hash(String, JSON::Any)?

    def initialize(
      *,
      @name : String,
      @description : String,
      @input : AvailableCommandInput? = nil,
      @meta : Hash(String, JSON::Any)? = nil,
    )
    end
  end

  # All text that was typed after the command name is provided as input.
  class UnstructuredCommandInput
    include JSON::Serializable

    @[JSON::Field(key: "hint")]
    getter hint : String

    @[JSON::Field(key: "_meta", emit_null: false)]
    getter meta : Hash(String, JSON::Any)?

    def initialize(
      *,
      @hint : String,
      @meta : Hash(String, JSON::Any)? = nil,
    )
    end
  end

  # Available commands are ready or have changed
  class AvailableCommandsUpdate < SessionUpdate
    @[JSON::Field(key: "sessionUpdate")]
    getter session_update : String = "available_commands_update"

    @[JSON::Field(key: "availableCommands")]
    getter available_commands : Array(AvailableCommand)

    @[JSON::Field(key: "_meta", emit_null: false)]
    getter meta : Hash(String, JSON::Any)?

    def initialize(
      *,
      @session_update : String = "available_commands_update",
      @available_commands : Array(AvailableCommand),
      @meta : Hash(String, JSON::Any)? = nil,
    )
    end
  end

  # The current mode of the session has changed
  class CurrentModeUpdate < SessionUpdate
    @[JSON::Field(key: "sessionUpdate")]
    getter session_update : String = "current_mode_update"

    @[JSON::Field(key: "currentModeId")]
    getter current_mode_id : SessionModeId

    @[JSON::Field(key: "_meta", emit_null: false)]
    getter meta : Hash(String, JSON::Any)?

    def initialize(
      *,
      @session_update : String = "current_mode_update",
      @current_mode_id : SessionModeId,
      @meta : Hash(String, JSON::Any)? = nil,
    )
    end
  end

  # Session configuration options have been updated.
  class ConfigOptionUpdate < SessionUpdate
    @[JSON::Field(key: "sessionUpdate")]
    getter session_update : String = "config_option_update"

    @[JSON::Field(key: "configOptions")]
    getter config_options : Array(SessionConfigOption)

    @[JSON::Field(key: "_meta", emit_null: false)]
    getter meta : Hash(String, JSON::Any)?

    def initialize(
      *,
      @session_update : String = "config_option_update",
      @config_options : Array(SessionConfigOption),
      @meta : Hash(String, JSON::Any)? = nil,
    )
    end
  end

  # Update to session metadata. All fields are optional to support partial updates.
  class SessionInfoUpdate < SessionUpdate
    @[JSON::Field(key: "sessionUpdate")]
    getter session_update : String = "session_info_update"

    @[JSON::Field(key: "title", emit_null: false)]
    getter title : String?

    @[JSON::Field(key: "updatedAt", emit_null: false)]
    getter updated_at : String?

    @[JSON::Field(key: "_meta", emit_null: false)]
    getter meta : Hash(String, JSON::Any)?

    def initialize(
      *,
      @session_update : String = "session_info_update",
      @title : String? = nil,
      @updated_at : String? = nil,
      @meta : Hash(String, JSON::Any)? = nil,
    )
    end
  end

  # Cost information for a session.
  class Cost
    include JSON::Serializable

    @[JSON::Field(key: "amount")]
    getter amount : Float64

    @[JSON::Field(key: "currency")]
    getter currency : String

    @[JSON::Field(key: "_meta", emit_null: false)]
    getter meta : Hash(String, JSON::Any)?

    def initialize(
      *,
      @amount : Float64,
      @currency : String,
      @meta : Hash(String, JSON::Any)? = nil,
    )
    end
  end

  # Context window and cost update for a session.
  class UsageUpdate < SessionUpdate
    @[JSON::Field(key: "sessionUpdate")]
    getter session_update : String = "usage_update"

    @[JSON::Field(key: "used")]
    getter used : UInt64

    @[JSON::Field(key: "size")]
    getter size : UInt64

    @[JSON::Field(key: "cost", emit_null: false)]
    getter cost : Cost?

    @[JSON::Field(key: "_meta", emit_null: false)]
    getter meta : Hash(String, JSON::Any)?

    def initialize(
      *,
      @session_update : String = "usage_update",
      @used : UInt64,
      @size : UInt64,
      @cost : Cost? = nil,
      @meta : Hash(String, JSON::Any)? = nil,
    )
    end
  end

  # Notification sent by the agent when a URL-based elicitation is complete.
  class CompleteElicitationNotification
    include JSON::Serializable

    @[JSON::Field(key: "elicitationId")]
    getter elicitation_id : ElicitationId

    @[JSON::Field(key: "_meta", emit_null: false)]
    getter meta : Hash(String, JSON::Any)?

    def initialize(
      *,
      @elicitation_id : ElicitationId,
      @meta : Hash(String, JSON::Any)? = nil,
    )
    end
  end

  # Request parameters for the initialize method.
  class InitializeRequest
    include JSON::Serializable

    @[JSON::Field(key: "protocolVersion")]
    getter protocol_version : ProtocolVersion

    @[JSON::Field(key: "clientCapabilities", emit_null: false)]
    getter client_capabilities : ClientCapabilities?

    @[JSON::Field(key: "clientInfo", emit_null: false)]
    getter client_info : Implementation?

    @[JSON::Field(key: "_meta", emit_null: false)]
    getter meta : Hash(String, JSON::Any)?

    def initialize(
      *,
      @protocol_version : ProtocolVersion,
      @client_capabilities : ClientCapabilities? = nil,
      @client_info : Implementation? = nil,
      @meta : Hash(String, JSON::Any)? = nil,
    )
    end
  end

  # Capabilities supported by the client.
  class ClientCapabilities
    include JSON::Serializable

    @[JSON::Field(key: "fs", emit_null: false)]
    getter fs : FileSystemCapabilities?

    @[JSON::Field(key: "terminal")]
    getter terminal : Bool = false

    @[JSON::Field(key: "session", emit_null: false)]
    getter session : ClientSessionCapabilities?

    @[JSON::Field(key: "auth", emit_null: false)]
    getter auth : AuthCapabilities?

    @[JSON::Field(key: "elicitation", emit_null: false)]
    getter elicitation : ElicitationCapabilities?

    @[JSON::Field(key: "_meta", emit_null: false)]
    getter meta : Hash(String, JSON::Any)?

    def initialize(
      *,
      @fs : FileSystemCapabilities? = nil,
      @terminal : Bool = false,
      @session : ClientSessionCapabilities? = nil,
      @auth : AuthCapabilities? = nil,
      @elicitation : ElicitationCapabilities? = nil,
      @meta : Hash(String, JSON::Any)? = nil,
    )
    end
  end

  # File system capabilities that a client may support.
  class FileSystemCapabilities
    include JSON::Serializable

    @[JSON::Field(key: "readTextFile")]
    getter read_text_file : Bool = false

    @[JSON::Field(key: "writeTextFile")]
    getter write_text_file : Bool = false

    @[JSON::Field(key: "_meta", emit_null: false)]
    getter meta : Hash(String, JSON::Any)?

    def initialize(
      *,
      @read_text_file : Bool = false,
      @write_text_file : Bool = false,
      @meta : Hash(String, JSON::Any)? = nil,
    )
    end
  end

  # Session-related capabilities supported by the client.
  class ClientSessionCapabilities
    include JSON::Serializable

    @[JSON::Field(key: "configOptions", emit_null: false)]
    getter config_options : SessionConfigOptionsCapabilities?

    @[JSON::Field(key: "_meta", emit_null: false)]
    getter meta : Hash(String, JSON::Any)?

    def initialize(
      *,
      @config_options : SessionConfigOptionsCapabilities? = nil,
      @meta : Hash(String, JSON::Any)? = nil,
    )
    end
  end

  # Session configuration option capabilities supported by the client.
  class SessionConfigOptionsCapabilities
    include JSON::Serializable

    @[JSON::Field(key: "boolean", emit_null: false)]
    getter boolean : BooleanConfigOptionCapabilities?

    @[JSON::Field(key: "_meta", emit_null: false)]
    getter meta : Hash(String, JSON::Any)?

    def initialize(
      *,
      @boolean : BooleanConfigOptionCapabilities? = nil,
      @meta : Hash(String, JSON::Any)? = nil,
    )
    end
  end

  # Capabilities for boolean session configuration options.
  class BooleanConfigOptionCapabilities
    include JSON::Serializable

    @[JSON::Field(key: "_meta", emit_null: false)]
    getter meta : Hash(String, JSON::Any)?

    def initialize(
      *,
      @meta : Hash(String, JSON::Any)? = nil,
    )
    end
  end

  # Authentication capabilities supported by the client.
  class AuthCapabilities
    include JSON::Serializable

    @[JSON::Field(key: "terminal")]
    getter terminal : Bool = false

    @[JSON::Field(key: "_meta", emit_null: false)]
    getter meta : Hash(String, JSON::Any)?

    def initialize(
      *,
      @terminal : Bool = false,
      @meta : Hash(String, JSON::Any)? = nil,
    )
    end
  end

  # Elicitation capabilities supported by the client.
  class ElicitationCapabilities
    include JSON::Serializable

    @[JSON::Field(key: "form", emit_null: false)]
    getter form : ElicitationFormCapabilities?

    @[JSON::Field(key: "url", emit_null: false)]
    getter url : ElicitationUrlCapabilities?

    @[JSON::Field(key: "_meta", emit_null: false)]
    getter meta : Hash(String, JSON::Any)?

    def initialize(
      *,
      @form : ElicitationFormCapabilities? = nil,
      @url : ElicitationUrlCapabilities? = nil,
      @meta : Hash(String, JSON::Any)? = nil,
    )
    end
  end

  # Form-based elicitation capabilities.
  class ElicitationFormCapabilities
    include JSON::Serializable

    @[JSON::Field(key: "_meta", emit_null: false)]
    getter meta : Hash(String, JSON::Any)?

    def initialize(
      *,
      @meta : Hash(String, JSON::Any)? = nil,
    )
    end
  end

  # URL-based elicitation capabilities.
  class ElicitationUrlCapabilities
    include JSON::Serializable

    @[JSON::Field(key: "_meta", emit_null: false)]
    getter meta : Hash(String, JSON::Any)?

    def initialize(
      *,
      @meta : Hash(String, JSON::Any)? = nil,
    )
    end
  end

  # Request parameters for the authenticate method.
  class AuthenticateRequest
    include JSON::Serializable

    @[JSON::Field(key: "methodId")]
    getter method_id : AuthMethodId

    @[JSON::Field(key: "_meta", emit_null: false)]
    getter meta : Hash(String, JSON::Any)?

    def initialize(
      *,
      @method_id : AuthMethodId,
      @meta : Hash(String, JSON::Any)? = nil,
    )
    end
  end

  # Request parameters for the logout method.
  class LogoutRequest
    include JSON::Serializable

    @[JSON::Field(key: "_meta", emit_null: false)]
    getter meta : Hash(String, JSON::Any)?

    def initialize(
      *,
      @meta : Hash(String, JSON::Any)? = nil,
    )
    end
  end

  # Request parameters for creating a new session.
  class NewSessionRequest
    include JSON::Serializable

    @[JSON::Field(key: "cwd")]
    getter cwd : String

    @[JSON::Field(key: "additionalDirectories", emit_null: false)]
    getter additional_directories : Array(String)?

    @[JSON::Field(key: "mcpServers")]
    getter mcp_servers : Array(McpServer)

    @[JSON::Field(key: "_meta", emit_null: false)]
    getter meta : Hash(String, JSON::Any)?

    def initialize(
      *,
      @cwd : String,
      @additional_directories : Array(String)? = nil,
      @mcp_servers : Array(McpServer),
      @meta : Hash(String, JSON::Any)? = nil,
    )
    end
  end

  # An HTTP header to set when making requests to the MCP server.
  class HttpHeader
    include JSON::Serializable

    @[JSON::Field(key: "name")]
    getter name : String

    @[JSON::Field(key: "value")]
    getter value : String

    @[JSON::Field(key: "_meta", emit_null: false)]
    getter meta : Hash(String, JSON::Any)?

    def initialize(
      *,
      @name : String,
      @value : String,
      @meta : Hash(String, JSON::Any)? = nil,
    )
    end
  end

  # HTTP transport configuration for MCP.
  class McpServerHttp < McpServer
    @[JSON::Field(key: "type")]
    getter type : String = "http"

    @[JSON::Field(key: "name")]
    getter name : String

    @[JSON::Field(key: "url")]
    getter url : String

    @[JSON::Field(key: "headers")]
    getter headers : Array(HttpHeader)

    @[JSON::Field(key: "_meta", emit_null: false)]
    getter meta : Hash(String, JSON::Any)?

    def initialize(
      *,
      @type : String = "http",
      @name : String,
      @url : String,
      @headers : Array(HttpHeader),
      @meta : Hash(String, JSON::Any)? = nil,
    )
    end
  end

  # SSE transport configuration for MCP.
  class McpServerSse < McpServer
    @[JSON::Field(key: "type")]
    getter type : String = "sse"

    @[JSON::Field(key: "name")]
    getter name : String

    @[JSON::Field(key: "url")]
    getter url : String

    @[JSON::Field(key: "headers")]
    getter headers : Array(HttpHeader)

    @[JSON::Field(key: "_meta", emit_null: false)]
    getter meta : Hash(String, JSON::Any)?

    def initialize(
      *,
      @type : String = "sse",
      @name : String,
      @url : String,
      @headers : Array(HttpHeader),
      @meta : Hash(String, JSON::Any)? = nil,
    )
    end
  end

  # Stdio transport configuration for MCP.
  class McpServerStdio < McpServer
    @[JSON::Field(key: "name")]
    getter name : String

    @[JSON::Field(key: "command")]
    getter command : String

    @[JSON::Field(key: "args")]
    getter args : Array(String)

    @[JSON::Field(key: "env")]
    getter env : Array(EnvVariable)

    @[JSON::Field(key: "_meta", emit_null: false)]
    getter meta : Hash(String, JSON::Any)?

    def initialize(
      *,
      @name : String,
      @command : String,
      @args : Array(String),
      @env : Array(EnvVariable),
      @meta : Hash(String, JSON::Any)? = nil,
    )
    end
  end

  # Request parameters for loading an existing session.
  class LoadSessionRequest
    include JSON::Serializable

    @[JSON::Field(key: "mcpServers")]
    getter mcp_servers : Array(McpServer)

    @[JSON::Field(key: "cwd")]
    getter cwd : String

    @[JSON::Field(key: "additionalDirectories", emit_null: false)]
    getter additional_directories : Array(String)?

    @[JSON::Field(key: "sessionId")]
    getter session_id : SessionId

    @[JSON::Field(key: "_meta", emit_null: false)]
    getter meta : Hash(String, JSON::Any)?

    def initialize(
      *,
      @mcp_servers : Array(McpServer),
      @cwd : String,
      @additional_directories : Array(String)? = nil,
      @session_id : SessionId,
      @meta : Hash(String, JSON::Any)? = nil,
    )
    end
  end

  # Request parameters for listing existing sessions.
  class ListSessionsRequest
    include JSON::Serializable

    @[JSON::Field(key: "cwd", emit_null: false)]
    getter cwd : String?

    @[JSON::Field(key: "cursor", emit_null: false)]
    getter cursor : String?

    @[JSON::Field(key: "_meta", emit_null: false)]
    getter meta : Hash(String, JSON::Any)?

    def initialize(
      *,
      @cwd : String? = nil,
      @cursor : String? = nil,
      @meta : Hash(String, JSON::Any)? = nil,
    )
    end
  end

  # Request parameters for deleting an existing session from `session/list`.
  class DeleteSessionRequest
    include JSON::Serializable

    @[JSON::Field(key: "sessionId")]
    getter session_id : SessionId

    @[JSON::Field(key: "_meta", emit_null: false)]
    getter meta : Hash(String, JSON::Any)?

    def initialize(
      *,
      @session_id : SessionId,
      @meta : Hash(String, JSON::Any)? = nil,
    )
    end
  end

  # Request parameters for resuming an existing session.
  class ResumeSessionRequest
    include JSON::Serializable

    @[JSON::Field(key: "sessionId")]
    getter session_id : SessionId

    @[JSON::Field(key: "cwd")]
    getter cwd : String

    @[JSON::Field(key: "additionalDirectories", emit_null: false)]
    getter additional_directories : Array(String)?

    @[JSON::Field(key: "mcpServers", emit_null: false)]
    getter mcp_servers : Array(McpServer)?

    @[JSON::Field(key: "_meta", emit_null: false)]
    getter meta : Hash(String, JSON::Any)?

    def initialize(
      *,
      @session_id : SessionId,
      @cwd : String,
      @additional_directories : Array(String)? = nil,
      @mcp_servers : Array(McpServer)? = nil,
      @meta : Hash(String, JSON::Any)? = nil,
    )
    end
  end

  # Request parameters for closing an active session.
  class CloseSessionRequest
    include JSON::Serializable

    @[JSON::Field(key: "sessionId")]
    getter session_id : SessionId

    @[JSON::Field(key: "_meta", emit_null: false)]
    getter meta : Hash(String, JSON::Any)?

    def initialize(
      *,
      @session_id : SessionId,
      @meta : Hash(String, JSON::Any)? = nil,
    )
    end
  end

  # Request parameters for setting a session mode.
  class SetSessionModeRequest
    include JSON::Serializable

    @[JSON::Field(key: "sessionId")]
    getter session_id : SessionId

    @[JSON::Field(key: "modeId")]
    getter mode_id : SessionModeId

    @[JSON::Field(key: "_meta", emit_null: false)]
    getter meta : Hash(String, JSON::Any)?

    def initialize(
      *,
      @session_id : SessionId,
      @mode_id : SessionModeId,
      @meta : Hash(String, JSON::Any)? = nil,
    )
    end
  end

  # Request parameters for sending a user prompt to the agent.
  class PromptRequest
    include JSON::Serializable

    @[JSON::Field(key: "sessionId")]
    getter session_id : SessionId

    @[JSON::Field(key: "prompt")]
    getter prompt : Array(ContentBlock)

    @[JSON::Field(key: "_meta", emit_null: false)]
    getter meta : Hash(String, JSON::Any)?

    def initialize(
      *,
      @session_id : SessionId,
      @prompt : Array(ContentBlock),
      @meta : Hash(String, JSON::Any)? = nil,
    )
    end
  end

  # Response to `fs/write_text_file`
  class WriteTextFileResponse
    include JSON::Serializable

    @[JSON::Field(key: "_meta", emit_null: false)]
    getter meta : Hash(String, JSON::Any)?

    def initialize(
      *,
      @meta : Hash(String, JSON::Any)? = nil,
    )
    end
  end

  # Response containing the contents of a text file.
  class ReadTextFileResponse
    include JSON::Serializable

    @[JSON::Field(key: "content")]
    getter content : String

    @[JSON::Field(key: "_meta", emit_null: false)]
    getter meta : Hash(String, JSON::Any)?

    def initialize(
      *,
      @content : String,
      @meta : Hash(String, JSON::Any)? = nil,
    )
    end
  end

  # Response to a permission request.
  class RequestPermissionResponse
    include JSON::Serializable

    @[JSON::Field(key: "outcome")]
    getter outcome : RequestPermissionOutcome

    @[JSON::Field(key: "_meta", emit_null: false)]
    getter meta : Hash(String, JSON::Any)?

    def initialize(
      *,
      @outcome : RequestPermissionOutcome,
      @meta : Hash(String, JSON::Any)? = nil,
    )
    end
  end

  # The user selected one of the provided options.
  class SelectedPermissionOutcome < RequestPermissionOutcome
    @[JSON::Field(key: "outcome")]
    getter outcome : String = "selected"

    @[JSON::Field(key: "optionId")]
    getter option_id : PermissionOptionId

    @[JSON::Field(key: "_meta", emit_null: false)]
    getter meta : Hash(String, JSON::Any)?

    def initialize(
      *,
      @outcome : String = "selected",
      @option_id : PermissionOptionId,
      @meta : Hash(String, JSON::Any)? = nil,
    )
    end
  end

  # Response containing the ID of the created terminal.
  class CreateTerminalResponse
    include JSON::Serializable

    @[JSON::Field(key: "terminalId")]
    getter terminal_id : TerminalId

    @[JSON::Field(key: "_meta", emit_null: false)]
    getter meta : Hash(String, JSON::Any)?

    def initialize(
      *,
      @terminal_id : TerminalId,
      @meta : Hash(String, JSON::Any)? = nil,
    )
    end
  end

  # Response containing the terminal output and exit status.
  class TerminalOutputResponse
    include JSON::Serializable

    @[JSON::Field(key: "output")]
    getter output : String

    @[JSON::Field(key: "truncated")]
    getter truncated : Bool

    @[JSON::Field(key: "exitStatus", emit_null: false)]
    getter exit_status : TerminalExitStatus?

    @[JSON::Field(key: "_meta", emit_null: false)]
    getter meta : Hash(String, JSON::Any)?

    def initialize(
      *,
      @output : String,
      @truncated : Bool,
      @exit_status : TerminalExitStatus? = nil,
      @meta : Hash(String, JSON::Any)? = nil,
    )
    end
  end

  # Exit status of a terminal command.
  class TerminalExitStatus
    include JSON::Serializable

    @[JSON::Field(key: "exitCode", emit_null: false)]
    getter exit_code : UInt32?

    @[JSON::Field(key: "signal", emit_null: false)]
    getter signal : String?

    @[JSON::Field(key: "_meta", emit_null: false)]
    getter meta : Hash(String, JSON::Any)?

    def initialize(
      *,
      @exit_code : UInt32? = nil,
      @signal : String? = nil,
      @meta : Hash(String, JSON::Any)? = nil,
    )
    end
  end

  # Response to terminal/release method
  class ReleaseTerminalResponse
    include JSON::Serializable

    @[JSON::Field(key: "_meta", emit_null: false)]
    getter meta : Hash(String, JSON::Any)?

    def initialize(
      *,
      @meta : Hash(String, JSON::Any)? = nil,
    )
    end
  end

  # Response containing the exit status of a terminal command.
  class WaitForTerminalExitResponse
    include JSON::Serializable

    @[JSON::Field(key: "exitCode", emit_null: false)]
    getter exit_code : UInt32?

    @[JSON::Field(key: "signal", emit_null: false)]
    getter signal : String?

    @[JSON::Field(key: "_meta", emit_null: false)]
    getter meta : Hash(String, JSON::Any)?

    def initialize(
      *,
      @exit_code : UInt32? = nil,
      @signal : String? = nil,
      @meta : Hash(String, JSON::Any)? = nil,
    )
    end
  end

  # Response to `terminal/kill` method
  class KillTerminalResponse
    include JSON::Serializable

    @[JSON::Field(key: "_meta", emit_null: false)]
    getter meta : Hash(String, JSON::Any)?

    def initialize(
      *,
      @meta : Hash(String, JSON::Any)? = nil,
    )
    end
  end

  # Notification to cancel ongoing operations for a session.
  class CancelNotification
    include JSON::Serializable

    @[JSON::Field(key: "sessionId")]
    getter session_id : SessionId

    @[JSON::Field(key: "_meta", emit_null: false)]
    getter meta : Hash(String, JSON::Any)?

    def initialize(
      *,
      @session_id : SessionId,
      @meta : Hash(String, JSON::Any)? = nil,
    )
    end
  end
end
