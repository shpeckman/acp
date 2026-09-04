# src/acp/v2/schema.cr
# Generated from agent-client-protocol schema (v2 schema.json @ schema-v2.0.0-alpha.3).
# Do not edit by hand; regenerate via tools/generate_schema.py.
module ACP
  module V2
    # A unique identifier for a conversation session between a client and agent.
    alias SessionId = String
    # Unique identifier for a tool call within a session.
    alias ToolCallId = String
    # An Internet media type identifying the format of protocol content.
    alias MediaType = String
    # An absolute filesystem path used by the protocol.
    alias AbsolutePath = String
    # Unique identifier for an agent-owned terminal within a session.
    alias TerminalId = String
    # Unique identifier for a permission option.
    alias PermissionOptionId = String
    # Unique identifier for an elicitation.
    alias ElicitationId = String
    # Typed identifier used for auth method values on the wire.
    alias AuthMethodId = String
    # Unique identifier for a session configuration option.
    alias SessionConfigId = String
    # Unique identifier for a session configuration option value.
    alias SessionConfigValueId = String
    # Unique identifier for a session configuration option value group.
    alias SessionConfigGroupId = String
    # An opaque cursor used to paginate `session/list` results.
    alias SessionListCursor = String
    # Unique identifier for a message within a session.
    alias MessageId = String
    # Unique identifier for a plan within a session.
    alias PlanId = String

    # Kind of file content represented by a diff change.
    struct DiffFileType
      Text      = new("text")
      Binary    = new("binary")
      Directory = new("directory")
      Symlink   = new("symlink")

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

    # Text patch format used by [`DiffPatch`].
    struct DiffPatchFormat
      GitPatch = new("git_patch")

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

    # Type discriminator for elicitation schemas.
    enum ElicitationSchemaType
      Object
    end

    # Theme an icon is designed for.
    struct IconTheme
      Light = new("light")
      Dark  = new("dark")

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

    # The type of permission option being presented to the user.
    struct PermissionOptionKind
      AllowOnce    = new("allow_once")
      AllowAlways  = new("allow_always")
      RejectOnce   = new("reject_once")
      RejectAlways = new("reject_always")

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

    # Priority levels for plan entries.
    struct PlanEntryPriority
      High   = new("high")
      Medium = new("medium")
      Low    = new("low")

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

    # Status of a plan entry in the execution flow.
    struct PlanEntryStatus
      Pending    = new("pending")
      InProgress = new("in_progress")
      Completed  = new("completed")
      Cancelled  = new("cancelled")

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

    # The sender or recipient of messages and data in a conversation.
    struct Role
      Assistant = new("assistant")
      User      = new("user")

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

    # Semantic category for a session configuration option.
    struct SessionConfigOptionCategory
      Mode         = new("mode")
      Model        = new("model")
      ModelConfig  = new("model_config")
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

    # Reasons why an agent stops active session work.
    struct StopReason
      EndTurn         = new("end_turn")
      MaxTokens       = new("max_tokens")
      MaxTurnRequests = new("max_turn_requests")
      Refusal         = new("refusal")
      Cancelled       = new("cancelled")

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

    # String format types for string properties in elicitation schemas.
    struct StringFormat
      Email    = new("email")
      Uri      = new("uri")
      Date     = new("date")
      DateTime = new("date-time")

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

    # Execution status of a tool call.
    struct ToolCallStatus
      Pending    = new("pending")
      InProgress = new("in_progress")
      Completed  = new("completed")
      Failed     = new("failed")
      Cancelled  = new("cancelled")

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

    # Categories of tools that can be invoked.
    struct ToolKind
      Read       = new("read")
      Edit       = new("edit")
      Delete     = new("delete")
      Move       = new("move")
      Search     = new("search")
      Execute    = new("execute")
      Think      = new("think")
      Fetch      = new("fetch")
      SwitchMode = new("switch_mode")
      Other      = new("other")

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

    # Request for user permission to proceed with an operation.
    class RequestPermissionRequest
      include JSON::Serializable

      @[JSON::Field(key: "sessionId")]
      getter session_id : SessionId

      @[JSON::Field(key: "title")]
      getter title : String

      @[JSON::Field(key: "description", emit_null: false)]
      getter description : String?

      @[JSON::Field(key: "subject", emit_null: false)]
      getter subject : RequestPermissionSubject?

      @[JSON::Field(key: "options")]
      getter options : Array(PermissionOption)

      @[JSON::Field(key: "_meta", emit_null: false)]
      getter meta : Hash(String, JSON::Any)?

      def initialize(
        *,
        @session_id : SessionId,
        @title : String,
        @description : String? = nil,
        @subject : RequestPermissionSubject? = nil,
        @options : Array(PermissionOption),
        @meta : Hash(String, JSON::Any)? = nil,
      )
      end
    end

    # Represents an upsert for a tool call that the language model has requested.
    class ToolCallUpdate < SessionUpdate
      @[JSON::Field(key: "sessionUpdate")]
      getter session_update : String = "tool_call_update"

      @[JSON::Field(key: "toolCallId")]
      getter tool_call_id : ToolCallId

      @[JSON::Field(key: "title", emit_null: false)]
      getter title : String?

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
        @session_update : String = "tool_call_update",
        @tool_call_id : ToolCallId,
        @title : String? = nil,
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

      @[JSON::Field(key: "text")]
      getter text : String

      @[JSON::Field(key: "annotations", emit_null: false)]
      getter annotations : Annotations?

      @[JSON::Field(key: "_meta", emit_null: false)]
      getter meta : Hash(String, JSON::Any)?

      def initialize(
        *,
        @type : String = "text",
        @text : String,
        @annotations : Annotations? = nil,
        @meta : Hash(String, JSON::Any)? = nil,
      )
      end
    end

    # An image provided to or from an LLM.
    class ImageContent < ContentBlock
      @[JSON::Field(key: "type")]
      getter type : String = "image"

      @[JSON::Field(key: "data")]
      getter data : String

      @[JSON::Field(key: "mimeType")]
      getter mime_type : MediaType

      @[JSON::Field(key: "uri", emit_null: false)]
      getter uri : String?

      @[JSON::Field(key: "annotations", emit_null: false)]
      getter annotations : Annotations?

      @[JSON::Field(key: "_meta", emit_null: false)]
      getter meta : Hash(String, JSON::Any)?

      def initialize(
        *,
        @type : String = "image",
        @data : String,
        @mime_type : MediaType,
        @uri : String? = nil,
        @annotations : Annotations? = nil,
        @meta : Hash(String, JSON::Any)? = nil,
      )
      end
    end

    # Audio provided to or from an LLM.
    class AudioContent < ContentBlock
      @[JSON::Field(key: "type")]
      getter type : String = "audio"

      @[JSON::Field(key: "data")]
      getter data : String

      @[JSON::Field(key: "mimeType")]
      getter mime_type : MediaType

      @[JSON::Field(key: "annotations", emit_null: false)]
      getter annotations : Annotations?

      @[JSON::Field(key: "_meta", emit_null: false)]
      getter meta : Hash(String, JSON::Any)?

      def initialize(
        *,
        @type : String = "audio",
        @data : String,
        @mime_type : MediaType,
        @annotations : Annotations? = nil,
        @meta : Hash(String, JSON::Any)? = nil,
      )
      end
    end

    # An optionally-sized icon that can be displayed in a user interface.
    class Icon
      include JSON::Serializable

      @[JSON::Field(key: "src")]
      getter src : String

      @[JSON::Field(key: "mimeType", emit_null: false)]
      getter mime_type : MediaType?

      @[JSON::Field(key: "sizes", emit_null: false)]
      getter sizes : Array(String)?

      @[JSON::Field(key: "theme", emit_null: false)]
      getter theme : IconTheme?

      def initialize(
        *,
        @src : String,
        @mime_type : MediaType? = nil,
        @sizes : Array(String)? = nil,
        @theme : IconTheme? = nil,
      )
      end
    end

    # A resource that the server is capable of reading, included in a prompt or tool call
    # result.
    class ResourceLink < ContentBlock
      @[JSON::Field(key: "type")]
      getter type : String = "resource_link"

      @[JSON::Field(key: "name")]
      getter name : String

      @[JSON::Field(key: "uri")]
      getter uri : String

      @[JSON::Field(key: "title", emit_null: false)]
      getter title : String?

      @[JSON::Field(key: "description", emit_null: false)]
      getter description : String?

      @[JSON::Field(key: "icons", emit_null: false)]
      getter icons : Array(Icon)?

      @[JSON::Field(key: "mimeType", emit_null: false)]
      getter mime_type : MediaType?

      @[JSON::Field(key: "size", emit_null: false)]
      getter size : Int64?

      @[JSON::Field(key: "annotations", emit_null: false)]
      getter annotations : Annotations?

      @[JSON::Field(key: "_meta", emit_null: false)]
      getter meta : Hash(String, JSON::Any)?

      def initialize(
        *,
        @type : String = "resource_link",
        @name : String,
        @uri : String,
        @title : String? = nil,
        @description : String? = nil,
        @icons : Array(Icon)? = nil,
        @mime_type : MediaType? = nil,
        @size : Int64? = nil,
        @annotations : Annotations? = nil,
        @meta : Hash(String, JSON::Any)? = nil,
      )
      end
    end

    # Text-based resource contents.
    class TextResourceContents
      include JSON::Serializable

      @[JSON::Field(key: "text")]
      getter text : String

      @[JSON::Field(key: "uri")]
      getter uri : String

      @[JSON::Field(key: "mimeType", emit_null: false)]
      getter mime_type : MediaType?

      @[JSON::Field(key: "_meta", emit_null: false)]
      getter meta : Hash(String, JSON::Any)?

      def initialize(
        *,
        @text : String,
        @uri : String,
        @mime_type : MediaType? = nil,
        @meta : Hash(String, JSON::Any)? = nil,
      )
      end
    end

    # Binary resource contents.
    class BlobResourceContents
      include JSON::Serializable

      @[JSON::Field(key: "blob")]
      getter blob : String

      @[JSON::Field(key: "uri")]
      getter uri : String

      @[JSON::Field(key: "mimeType", emit_null: false)]
      getter mime_type : MediaType?

      @[JSON::Field(key: "_meta", emit_null: false)]
      getter meta : Hash(String, JSON::Any)?

      def initialize(
        *,
        @blob : String,
        @uri : String,
        @mime_type : MediaType? = nil,
        @meta : Hash(String, JSON::Any)? = nil,
      )
      end
    end

    # The contents of a resource, embedded into a prompt or tool call result.
    class EmbeddedResource < ContentBlock
      @[JSON::Field(key: "type")]
      getter type : String = "resource"

      @[JSON::Field(key: "resource")]
      getter resource : EmbeddedResourceResource

      @[JSON::Field(key: "annotations", emit_null: false)]
      getter annotations : Annotations?

      @[JSON::Field(key: "_meta", emit_null: false)]
      getter meta : Hash(String, JSON::Any)?

      def initialize(
        *,
        @type : String = "resource",
        @resource : EmbeddedResourceResource,
        @annotations : Annotations? = nil,
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

    # Operation metadata for add, delete, and modify changes.
    class DiffPathChange < DiffChange
      @[JSON::Field(key: "operation")]
      getter operation : String

      @[JSON::Field(key: "path")]
      getter path : AbsolutePath

      def initialize(
        *,
        @operation : String,
        @path : AbsolutePath,
      )
      end
    end

    # Operation metadata for move and copy changes.
    class DiffPathPairChange < DiffChange
      @[JSON::Field(key: "operation")]
      getter operation : String

      @[JSON::Field(key: "oldPath")]
      getter old_path : AbsolutePath

      @[JSON::Field(key: "path")]
      getter path : AbsolutePath

      def initialize(
        *,
        @operation : String,
        @old_path : AbsolutePath,
        @path : AbsolutePath,
      )
      end
    end

    # Renderable patch text and its format.
    class DiffPatch
      include JSON::Serializable

      @[JSON::Field(key: "format")]
      getter format : DiffPatchFormat

      @[JSON::Field(key: "text")]
      getter text : String

      def initialize(
        *,
        @format : DiffPatchFormat,
        @text : String,
      )
      end
    end

    # File changes produced by a tool call.
    class Diff < ToolCallContent
      @[JSON::Field(key: "type")]
      getter type : String = "diff"

      @[JSON::Field(key: "changes")]
      getter changes : Array(DiffChange)

      @[JSON::Field(key: "patch", emit_null: false)]
      getter patch : DiffPatch?

      @[JSON::Field(key: "_meta", emit_null: false)]
      getter meta : Hash(String, JSON::Any)?

      def initialize(
        *,
        @type : String = "diff",
        @changes : Array(DiffChange),
        @patch : DiffPatch? = nil,
        @meta : Hash(String, JSON::Any)? = nil,
      )
      end
    end

    # A display-only reference to an agent-owned terminal.
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
      getter path : AbsolutePath

      @[JSON::Field(key: "line", emit_null: false)]
      getter line : UInt32?

      @[JSON::Field(key: "_meta", emit_null: false)]
      getter meta : Hash(String, JSON::Any)?

      def initialize(
        *,
        @path : AbsolutePath,
        @line : UInt32? = nil,
        @meta : Hash(String, JSON::Any)? = nil,
      )
      end
    end

    # Permission request details for a tool call.
    class ToolCallPermissionSubject < RequestPermissionSubject
      @[JSON::Field(key: "type")]
      getter type : String = "tool_call"

      @[JSON::Field(key: "toolCall")]
      getter tool_call : ToolCallUpdate

      def initialize(
        *,
        @type : String = "tool_call",
        @tool_call : ToolCallUpdate,
      )
      end
    end

    # Permission request details for a command.
    class CommandPermissionSubject < RequestPermissionSubject
      @[JSON::Field(key: "type")]
      getter type : String = "command"

      @[JSON::Field(key: "command")]
      getter command : String

      @[JSON::Field(key: "cwd")]
      getter cwd : AbsolutePath

      @[JSON::Field(key: "toolCallId", emit_null: false)]
      getter tool_call_id : ToolCallId?

      @[JSON::Field(key: "terminalId", emit_null: false)]
      getter terminal_id : TerminalId?

      @[JSON::Field(key: "_meta", emit_null: false)]
      getter meta : Hash(String, JSON::Any)?

      def initialize(
        *,
        @type : String = "command",
        @command : String,
        @cwd : AbsolutePath,
        @tool_call_id : ToolCallId? = nil,
        @terminal_id : TerminalId? = nil,
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

      @[JSON::Field(key: "info")]
      getter info : Implementation

      @[JSON::Field(key: "capabilities")]
      getter capabilities : AgentCapabilities = AgentCapabilities.new

      @[JSON::Field(key: "authMethods", emit_null: false)]
      getter auth_methods : Array(AuthMethod)?

      @[JSON::Field(key: "_meta", emit_null: false)]
      getter meta : Hash(String, JSON::Any)?

      def initialize(
        *,
        @protocol_version : ProtocolVersion,
        @info : Implementation,
        @capabilities : AgentCapabilities = AgentCapabilities.new,
        @auth_methods : Array(AuthMethod)? = nil,
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

    # Capabilities supported by the agent.
    class AgentCapabilities
      include JSON::Serializable

      @[JSON::Field(key: "session", emit_null: false)]
      getter session : SessionCapabilities?

      @[JSON::Field(key: "auth", emit_null: false)]
      getter auth : AgentAuthCapabilities?

      @[JSON::Field(key: "_meta", emit_null: false)]
      getter meta : Hash(String, JSON::Any)?

      def initialize(
        *,
        @session : SessionCapabilities? = nil,
        @auth : AgentAuthCapabilities? = nil,
        @meta : Hash(String, JSON::Any)? = nil,
      )
      end
    end

    # Session capabilities supported by the agent.
    class SessionCapabilities
      include JSON::Serializable

      @[JSON::Field(key: "prompt", emit_null: false)]
      getter prompt : PromptCapabilities?

      @[JSON::Field(key: "mcp", emit_null: false)]
      getter mcp : McpCapabilities?

      @[JSON::Field(key: "delete", emit_null: false)]
      getter delete : SessionDeleteCapabilities?

      @[JSON::Field(key: "additionalDirectories", emit_null: false)]
      getter additional_directories : SessionAdditionalDirectoriesCapabilities?

      @[JSON::Field(key: "_meta", emit_null: false)]
      getter meta : Hash(String, JSON::Any)?

      def initialize(
        *,
        @prompt : PromptCapabilities? = nil,
        @mcp : McpCapabilities? = nil,
        @delete : SessionDeleteCapabilities? = nil,
        @additional_directories : SessionAdditionalDirectoriesCapabilities? = nil,
        @meta : Hash(String, JSON::Any)? = nil,
      )
      end
    end

    # Prompt capabilities supported by the agent in `session/prompt` requests.
    class PromptCapabilities
      include JSON::Serializable

      @[JSON::Field(key: "image", emit_null: false)]
      getter image : PromptImageCapabilities?

      @[JSON::Field(key: "audio", emit_null: false)]
      getter audio : PromptAudioCapabilities?

      @[JSON::Field(key: "embeddedContext", emit_null: false)]
      getter embedded_context : PromptEmbeddedContextCapabilities?

      @[JSON::Field(key: "_meta", emit_null: false)]
      getter meta : Hash(String, JSON::Any)?

      def initialize(
        *,
        @image : PromptImageCapabilities? = nil,
        @audio : PromptAudioCapabilities? = nil,
        @embedded_context : PromptEmbeddedContextCapabilities? = nil,
        @meta : Hash(String, JSON::Any)? = nil,
      )
      end
    end

    # Capabilities for image content in prompt requests.
    class PromptImageCapabilities
      include JSON::Serializable

      @[JSON::Field(key: "_meta", emit_null: false)]
      getter meta : Hash(String, JSON::Any)?

      def initialize(
        *,
        @meta : Hash(String, JSON::Any)? = nil,
      )
      end
    end

    # Capabilities for audio content in prompt requests.
    class PromptAudioCapabilities
      include JSON::Serializable

      @[JSON::Field(key: "_meta", emit_null: false)]
      getter meta : Hash(String, JSON::Any)?

      def initialize(
        *,
        @meta : Hash(String, JSON::Any)? = nil,
      )
      end
    end

    # Capabilities for embedded context in prompt requests.
    class PromptEmbeddedContextCapabilities
      include JSON::Serializable

      @[JSON::Field(key: "_meta", emit_null: false)]
      getter meta : Hash(String, JSON::Any)?

      def initialize(
        *,
        @meta : Hash(String, JSON::Any)? = nil,
      )
      end
    end

    # MCP capabilities supported by the agent for session lifecycle requests.
    class McpCapabilities
      include JSON::Serializable

      @[JSON::Field(key: "stdio", emit_null: false)]
      getter stdio : McpStdioCapabilities?

      @[JSON::Field(key: "http", emit_null: false)]
      getter http : McpHttpCapabilities?

      @[JSON::Field(key: "_meta", emit_null: false)]
      getter meta : Hash(String, JSON::Any)?

      def initialize(
        *,
        @stdio : McpStdioCapabilities? = nil,
        @http : McpHttpCapabilities? = nil,
        @meta : Hash(String, JSON::Any)? = nil,
      )
      end
    end

    # Capabilities for stdio MCP server transports.
    class McpStdioCapabilities
      include JSON::Serializable

      @[JSON::Field(key: "_meta", emit_null: false)]
      getter meta : Hash(String, JSON::Any)?

      def initialize(
        *,
        @meta : Hash(String, JSON::Any)? = nil,
      )
      end
    end

    # Capabilities for HTTP MCP server transports.
    class McpHttpCapabilities
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

    # Authentication-related extension capabilities supported by the agent.
    class AgentAuthCapabilities
      include JSON::Serializable

      @[JSON::Field(key: "_meta", emit_null: false)]
      getter meta : Hash(String, JSON::Any)?

      def initialize(
        *,
        @meta : Hash(String, JSON::Any)? = nil,
      )
      end
    end

    # An environment variable to set when launching a process.
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

    # Terminal-based authentication method.
    class AuthMethodTerminal < AuthMethod
      @[JSON::Field(key: "type")]
      getter type : String = "terminal"

      @[JSON::Field(key: "methodId")]
      getter method_id : AuthMethodId

      @[JSON::Field(key: "name")]
      getter name : String

      @[JSON::Field(key: "description", emit_null: false)]
      getter description : String?

      @[JSON::Field(key: "args", emit_null: false)]
      getter args : Array(String)?

      @[JSON::Field(key: "env", emit_null: false)]
      getter env : Array(EnvVariable)?

      @[JSON::Field(key: "_meta", emit_null: false)]
      getter meta : Hash(String, JSON::Any)?

      def initialize(
        *,
        @type : String = "terminal",
        @method_id : AuthMethodId,
        @name : String,
        @description : String? = nil,
        @args : Array(String)? = nil,
        @env : Array(EnvVariable)? = nil,
        @meta : Hash(String, JSON::Any)? = nil,
      )
      end
    end

    # Agent handles authentication itself through `auth/login`.
    class AuthMethodAgent < AuthMethod
      @[JSON::Field(key: "type")]
      getter type : String = "agent"

      @[JSON::Field(key: "methodId")]
      getter method_id : AuthMethodId

      @[JSON::Field(key: "name")]
      getter name : String

      @[JSON::Field(key: "description", emit_null: false)]
      getter description : String?

      @[JSON::Field(key: "_meta", emit_null: false)]
      getter meta : Hash(String, JSON::Any)?

      def initialize(
        *,
        @type : String = "agent",
        @method_id : AuthMethodId,
        @name : String,
        @description : String? = nil,
        @meta : Hash(String, JSON::Any)? = nil,
      )
      end
    end

    # Response to the `auth/login` method.
    class LoginAuthResponse
      include JSON::Serializable

      @[JSON::Field(key: "_meta", emit_null: false)]
      getter meta : Hash(String, JSON::Any)?

      def initialize(
        *,
        @meta : Hash(String, JSON::Any)? = nil,
      )
      end
    end

    # Response to the `auth/logout` method.
    class LogoutAuthResponse
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

      @[JSON::Field(key: "configOptions", emit_null: false)]
      getter config_options : Array(SessionConfigOption)?

      @[JSON::Field(key: "_meta", emit_null: false)]
      getter meta : Hash(String, JSON::Any)?

      def initialize(
        *,
        @session_id : SessionId,
        @config_options : Array(SessionConfigOption)? = nil,
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

      @[JSON::Field(key: "groupId")]
      getter group_id : SessionConfigGroupId

      @[JSON::Field(key: "name")]
      getter name : String

      @[JSON::Field(key: "options")]
      getter options : Array(SessionConfigSelectOption)

      @[JSON::Field(key: "_meta", emit_null: false)]
      getter meta : Hash(String, JSON::Any)?

      def initialize(
        *,
        @group_id : SessionConfigGroupId,
        @name : String,
        @options : Array(SessionConfigSelectOption),
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
      getter next_cursor : SessionListCursor?

      @[JSON::Field(key: "_meta", emit_null: false)]
      getter meta : Hash(String, JSON::Any)?

      def initialize(
        *,
        @sessions : Array(SessionInfo),
        @next_cursor : SessionListCursor? = nil,
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
      getter cwd : AbsolutePath

      @[JSON::Field(key: "additionalDirectories", emit_null: false)]
      getter additional_directories : Array(AbsolutePath)?

      @[JSON::Field(key: "title", emit_null: false)]
      getter title : String?

      @[JSON::Field(key: "updatedAt", emit_null: false)]
      getter updated_at : String?

      @[JSON::Field(key: "_meta", emit_null: false)]
      getter meta : Hash(String, JSON::Any)?

      def initialize(
        *,
        @session_id : SessionId,
        @cwd : AbsolutePath,
        @additional_directories : Array(AbsolutePath)? = nil,
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

      @[JSON::Field(key: "configOptions", emit_null: false)]
      getter config_options : Array(SessionConfigOption)?

      @[JSON::Field(key: "_meta", emit_null: false)]
      getter meta : Hash(String, JSON::Any)?

      def initialize(
        *,
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

    # Response acknowledging that a user prompt was accepted.
    class PromptResponse
      include JSON::Serializable

      @[JSON::Field(key: "_meta", emit_null: false)]
      getter meta : Hash(String, JSON::Any)?

      def initialize(
        *,
        @meta : Hash(String, JSON::Any)? = nil,
      )
      end
    end

    # Notification containing a session update from the agent.
    class UpdateSessionNotification
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

    # A streamed item of message content.
    class ContentChunk < SessionUpdate
      @[JSON::Field(key: "sessionUpdate")]
      getter session_update : String

      @[JSON::Field(key: "messageId")]
      getter message_id : MessageId

      @[JSON::Field(key: "content")]
      getter content : ContentBlock

      @[JSON::Field(key: "_meta", emit_null: false)]
      getter meta : Hash(String, JSON::Any)?

      def initialize(
        *,
        @session_update : String,
        @message_id : MessageId,
        @content : ContentBlock,
        @meta : Hash(String, JSON::Any)? = nil,
      )
      end
    end

    # A user message upsert.
    class UserMessage < SessionUpdate
      @[JSON::Field(key: "sessionUpdate")]
      getter session_update : String = "user_message"

      @[JSON::Field(key: "messageId")]
      getter message_id : MessageId

      @[JSON::Field(key: "content", emit_null: false)]
      getter content : Array(ContentBlock)?

      @[JSON::Field(key: "_meta", emit_null: false)]
      getter meta : Hash(String, JSON::Any)?

      def initialize(
        *,
        @session_update : String = "user_message",
        @message_id : MessageId,
        @content : Array(ContentBlock)? = nil,
        @meta : Hash(String, JSON::Any)? = nil,
      )
      end
    end

    # An agent message upsert.
    class AgentMessage < SessionUpdate
      @[JSON::Field(key: "sessionUpdate")]
      getter session_update : String = "agent_message"

      @[JSON::Field(key: "messageId")]
      getter message_id : MessageId

      @[JSON::Field(key: "content", emit_null: false)]
      getter content : Array(ContentBlock)?

      @[JSON::Field(key: "_meta", emit_null: false)]
      getter meta : Hash(String, JSON::Any)?

      def initialize(
        *,
        @session_update : String = "agent_message",
        @message_id : MessageId,
        @content : Array(ContentBlock)? = nil,
        @meta : Hash(String, JSON::Any)? = nil,
      )
      end
    end

    # An agent thought or reasoning message upsert.
    class AgentThought < SessionUpdate
      @[JSON::Field(key: "sessionUpdate")]
      getter session_update : String = "agent_thought"

      @[JSON::Field(key: "messageId")]
      getter message_id : MessageId

      @[JSON::Field(key: "content", emit_null: false)]
      getter content : Array(ContentBlock)?

      @[JSON::Field(key: "_meta", emit_null: false)]
      getter meta : Hash(String, JSON::Any)?

      def initialize(
        *,
        @session_update : String = "agent_thought",
        @message_id : MessageId,
        @content : Array(ContentBlock)? = nil,
        @meta : Hash(String, JSON::Any)? = nil,
      )
      end
    end

    # Foreground work is in progress.
    class RunningStateUpdate < StateUpdate
      @[JSON::Field(key: "state")]
      getter state : String = "running"

      @[JSON::Field(key: "sessionUpdate")]
      getter session_update : String = "state_update"

      @[JSON::Field(key: "_meta", emit_null: false)]
      getter meta : Hash(String, JSON::Any)?

      def initialize(
        *,
        @state : String = "running",
        @session_update : String = "state_update",
        @meta : Hash(String, JSON::Any)? = nil,
      )
      end
    end

    # The agent is ready to process a new prompt.
    class IdleStateUpdate < StateUpdate
      @[JSON::Field(key: "state")]
      getter state : String = "idle"

      @[JSON::Field(key: "sessionUpdate")]
      getter session_update : String = "state_update"

      @[JSON::Field(key: "stopReason", emit_null: false)]
      getter stop_reason : StopReason?

      @[JSON::Field(key: "_meta", emit_null: false)]
      getter meta : Hash(String, JSON::Any)?

      def initialize(
        *,
        @state : String = "idle",
        @session_update : String = "state_update",
        @stop_reason : StopReason? = nil,
        @meta : Hash(String, JSON::Any)? = nil,
      )
      end
    end

    # Foreground work is blocked on user action.
    class RequiresActionStateUpdate < StateUpdate
      @[JSON::Field(key: "state")]
      getter state : String = "requires_action"

      @[JSON::Field(key: "sessionUpdate")]
      getter session_update : String = "state_update"

      @[JSON::Field(key: "_meta", emit_null: false)]
      getter meta : Hash(String, JSON::Any)?

      def initialize(
        *,
        @state : String = "requires_action",
        @session_update : String = "state_update",
        @meta : Hash(String, JSON::Any)? = nil,
      )
      end
    end

    # A streamed item of tool-call content.
    class ToolCallContentChunk < SessionUpdate
      @[JSON::Field(key: "sessionUpdate")]
      getter session_update : String = "tool_call_content_chunk"

      @[JSON::Field(key: "toolCallId")]
      getter tool_call_id : ToolCallId

      @[JSON::Field(key: "content")]
      getter content : ToolCallContent

      @[JSON::Field(key: "_meta", emit_null: false)]
      getter meta : Hash(String, JSON::Any)?

      def initialize(
        *,
        @session_update : String = "tool_call_content_chunk",
        @tool_call_id : ToolCallId,
        @content : ToolCallContent,
        @meta : Hash(String, JSON::Any)? = nil,
      )
      end
    end

    # An authoritative replacement snapshot of terminal output bytes.
    class TerminalOutput
      include JSON::Serializable

      @[JSON::Field(key: "data")]
      getter data : String

      @[JSON::Field(key: "_meta", emit_null: false)]
      getter meta : Hash(String, JSON::Any)?

      def initialize(
        *,
        @data : String,
        @meta : Hash(String, JSON::Any)? = nil,
      )
      end
    end

    # Exit information for an agent-owned terminal.
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

    # An upsert for the stored state of an agent-owned terminal.
    class TerminalUpdate < SessionUpdate
      @[JSON::Field(key: "sessionUpdate")]
      getter session_update : String = "terminal_update"

      @[JSON::Field(key: "terminalId")]
      getter terminal_id : TerminalId

      @[JSON::Field(key: "command", emit_null: false)]
      getter command : String?

      @[JSON::Field(key: "cwd", emit_null: false)]
      getter cwd : AbsolutePath?

      @[JSON::Field(key: "output", emit_null: false)]
      getter output : TerminalOutput?

      @[JSON::Field(key: "exitStatus", emit_null: false)]
      getter exit_status : TerminalExitStatus?

      @[JSON::Field(key: "_meta", emit_null: false)]
      getter meta : Hash(String, JSON::Any)?

      def initialize(
        *,
        @session_update : String = "terminal_update",
        @terminal_id : TerminalId,
        @command : String? = nil,
        @cwd : AbsolutePath? = nil,
        @output : TerminalOutput? = nil,
        @exit_status : TerminalExitStatus? = nil,
        @meta : Hash(String, JSON::Any)? = nil,
      )
      end
    end

    # A chunk of bytes appended to an agent-owned terminal's output.
    class TerminalOutputChunk < SessionUpdate
      @[JSON::Field(key: "sessionUpdate")]
      getter session_update : String = "terminal_output_chunk"

      @[JSON::Field(key: "terminalId")]
      getter terminal_id : TerminalId

      @[JSON::Field(key: "data")]
      getter data : String

      @[JSON::Field(key: "_meta", emit_null: false)]
      getter meta : Hash(String, JSON::Any)?

      def initialize(
        *,
        @session_update : String = "terminal_output_chunk",
        @terminal_id : TerminalId,
        @data : String,
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

    # A plan represented as structured entries.
    class PlanItems < PlanUpdateContent
      @[JSON::Field(key: "type")]
      getter type : String = "items"

      @[JSON::Field(key: "planId")]
      getter plan_id : PlanId

      @[JSON::Field(key: "entries")]
      getter entries : Array(PlanEntry)

      @[JSON::Field(key: "_meta", emit_null: false)]
      getter meta : Hash(String, JSON::Any)?

      def initialize(
        *,
        @type : String = "items",
        @plan_id : PlanId,
        @entries : Array(PlanEntry),
        @meta : Hash(String, JSON::Any)? = nil,
      )
      end
    end

    # A content update for a plan identified by ID.
    class PlanUpdate < SessionUpdate
      @[JSON::Field(key: "sessionUpdate")]
      getter session_update : String = "plan_update"

      @[JSON::Field(key: "plan")]
      getter plan : PlanUpdateContent

      @[JSON::Field(key: "_meta", emit_null: false)]
      getter meta : Hash(String, JSON::Any)?

      def initialize(
        *,
        @session_update : String = "plan_update",
        @plan : PlanUpdateContent,
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
    class TextCommandInput < AvailableCommandInput
      @[JSON::Field(key: "type")]
      getter type : String = "text"

      @[JSON::Field(key: "hint")]
      getter hint : String

      @[JSON::Field(key: "_meta", emit_null: false)]
      getter meta : Hash(String, JSON::Any)?

      def initialize(
        *,
        @type : String = "text",
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

      @[JSON::Field(key: "info")]
      getter info : Implementation

      @[JSON::Field(key: "capabilities")]
      getter capabilities : ClientCapabilities = ClientCapabilities.new

      @[JSON::Field(key: "_meta", emit_null: false)]
      getter meta : Hash(String, JSON::Any)?

      def initialize(
        *,
        @protocol_version : ProtocolVersion,
        @info : Implementation,
        @capabilities : ClientCapabilities = ClientCapabilities.new,
        @meta : Hash(String, JSON::Any)? = nil,
      )
      end
    end

    # Capabilities supported by the client.
    class ClientCapabilities
      include JSON::Serializable

      @[JSON::Field(key: "auth", emit_null: false)]
      getter auth : AuthCapabilities?

      @[JSON::Field(key: "elicitation", emit_null: false)]
      getter elicitation : ElicitationCapabilities?

      @[JSON::Field(key: "_meta", emit_null: false)]
      getter meta : Hash(String, JSON::Any)?

      def initialize(
        *,
        @auth : AuthCapabilities? = nil,
        @elicitation : ElicitationCapabilities? = nil,
        @meta : Hash(String, JSON::Any)? = nil,
      )
      end
    end

    # Authentication capabilities supported by the client.
    class AuthCapabilities
      include JSON::Serializable

      @[JSON::Field(key: "terminal", emit_null: false)]
      getter terminal : TerminalAuthCapabilities?

      @[JSON::Field(key: "_meta", emit_null: false)]
      getter meta : Hash(String, JSON::Any)?

      def initialize(
        *,
        @terminal : TerminalAuthCapabilities? = nil,
        @meta : Hash(String, JSON::Any)? = nil,
      )
      end
    end

    # Capabilities for terminal authentication methods.
    class TerminalAuthCapabilities
      include JSON::Serializable

      @[JSON::Field(key: "_meta", emit_null: false)]
      getter meta : Hash(String, JSON::Any)?

      def initialize(
        *,
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

    # Request parameters for the `auth/login` method.
    class LoginAuthRequest
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

    # Request parameters for the `auth/logout` method.
    class LogoutAuthRequest
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
      getter cwd : AbsolutePath

      @[JSON::Field(key: "additionalDirectories", emit_null: false)]
      getter additional_directories : Array(AbsolutePath)?

      @[JSON::Field(key: "mcpServers", emit_null: false)]
      getter mcp_servers : Array(McpServer)?

      @[JSON::Field(key: "_meta", emit_null: false)]
      getter meta : Hash(String, JSON::Any)?

      def initialize(
        *,
        @cwd : AbsolutePath,
        @additional_directories : Array(AbsolutePath)? = nil,
        @mcp_servers : Array(McpServer)? = nil,
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

      @[JSON::Field(key: "headers", emit_null: false)]
      getter headers : Array(HttpHeader)?

      @[JSON::Field(key: "_meta", emit_null: false)]
      getter meta : Hash(String, JSON::Any)?

      def initialize(
        *,
        @type : String = "http",
        @name : String,
        @url : String,
        @headers : Array(HttpHeader)? = nil,
        @meta : Hash(String, JSON::Any)? = nil,
      )
      end
    end

    # Stdio transport configuration for MCP.
    class McpServerStdio < McpServer
      @[JSON::Field(key: "type")]
      getter type : String = "stdio"

      @[JSON::Field(key: "name")]
      getter name : String

      @[JSON::Field(key: "command")]
      getter command : AbsolutePath

      @[JSON::Field(key: "args", emit_null: false)]
      getter args : Array(String)?

      @[JSON::Field(key: "env", emit_null: false)]
      getter env : Array(EnvVariable)?

      @[JSON::Field(key: "_meta", emit_null: false)]
      getter meta : Hash(String, JSON::Any)?

      def initialize(
        *,
        @type : String = "stdio",
        @name : String,
        @command : AbsolutePath,
        @args : Array(String)? = nil,
        @env : Array(EnvVariable)? = nil,
        @meta : Hash(String, JSON::Any)? = nil,
      )
      end
    end

    # Request parameters for listing existing sessions.
    class ListSessionsRequest
      include JSON::Serializable

      @[JSON::Field(key: "cwd", emit_null: false)]
      getter cwd : AbsolutePath?

      @[JSON::Field(key: "cursor", emit_null: false)]
      getter cursor : SessionListCursor?

      @[JSON::Field(key: "_meta", emit_null: false)]
      getter meta : Hash(String, JSON::Any)?

      def initialize(
        *,
        @cwd : AbsolutePath? = nil,
        @cursor : SessionListCursor? = nil,
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
      getter cwd : AbsolutePath

      @[JSON::Field(key: "additionalDirectories", emit_null: false)]
      getter additional_directories : Array(AbsolutePath)?

      @[JSON::Field(key: "mcpServers", emit_null: false)]
      getter mcp_servers : Array(McpServer)?

      @[JSON::Field(key: "replayFrom", emit_null: false)]
      getter replay_from : ReplayFrom?

      @[JSON::Field(key: "_meta", emit_null: false)]
      getter meta : Hash(String, JSON::Any)?

      def initialize(
        *,
        @session_id : SessionId,
        @cwd : AbsolutePath,
        @additional_directories : Array(AbsolutePath)? = nil,
        @mcp_servers : Array(McpServer)? = nil,
        @replay_from : ReplayFrom? = nil,
        @meta : Hash(String, JSON::Any)? = nil,
      )
      end
    end

    # Inclusive replay cursor requesting replay from the start of the conversation.
    class ReplayFromStart < ReplayFrom
      @[JSON::Field(key: "type")]
      getter type : String = "start"

      @[JSON::Field(key: "_meta", emit_null: false)]
      getter meta : Hash(String, JSON::Any)?

      def initialize(
        *,
        @type : String = "start",
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

    # Notification to cancel ongoing operations for a session.
    class CancelSessionNotification
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
end
