# tools/generate_schema.py
#!/usr/bin/env python3
"""Generate Crystal types from the ACP schemas (v1 and v2).

Usage:
    generate_schema.py <repo> <out_dir>

<repo> is a checkout of agentclientprotocol/agent-client-protocol.
Generates <out_dir>/schema.cr (module ACP) and <out_dir>/v2/schema.cr
(module ACP::V2). Union and protocol-level types are hand-written in
schema_unions.cr / v2/schema_unions.cr and are NOT generated here.
"""
import json
import re
import sys


def ref_name(ref):
    return ref.split("/")[-1]


def doc_comment(desc, indent="  "):
    if not desc:
        return ""
    first = desc.split("\n\n")[0].replace("\n", " ")
    lines = []
    while len(first) > 90:
        cut = first.rfind(" ", 0, 90)
        if cut <= 0:
            break
        lines.append(first[:cut])
        first = first[cut + 1 :]
    lines.append(first)
    return "".join(f"{indent}# {line}\n" for line in lines)


def crystal_member(wire):
    return "".join(p.capitalize() for p in re.split(r"[_\-]+", wire))


def underscore(s):
    s = re.sub(r"([A-Z]+)([A-Z][a-z])", r"\1_\2", s)
    s = re.sub(r"([a-z0-9])([A-Z])", r"\1_\2", s)
    return s.lower()


PROP_RENAMES = {"enum": "enum_values"}

INT_FORMATS = {
    "int64": "Int64",
    "int32": "Int32",
    "uint32": "UInt32",
    "uint64": "UInt64",
    "uint16": "UInt16",
    "uint8": "UInt8",
    "int16": "Int16",
    "int8": "Int8",
}


class Config:
    def __init__(self, namespace, handwritten, includes, discr_fields, header):
        self.namespace = namespace          # extra module nesting, e.g. "V2" or None
        self.handwritten = handwritten      # defs to skip (hand-written elsewhere)
        self.includes = includes            # variant class -> abstract superclass
        self.discr_fields = discr_fields    # variant class -> [(json_key, const_or_None)]
        self.header = header


def closed_string_enum(d):
    """All variants const strings -> list of wire values; open if a free
    string variant exists; None if not a string enum."""
    for comb in ("oneOf", "anyOf"):
        if comb in d:
            vals = []
            for v in d[comb]:
                if isinstance(v, dict) and v.get("type") == "string" and "const" in v:
                    vals.append(v["const"])
                elif isinstance(v, dict) and v.get("type") == "string":
                    return "open", vals
                else:
                    return None
            return ("closed", vals) if vals else None
    if d.get("type") == "string" and "enum" in d:
        return ("closed", d["enum"])
    return None


def prop_type(p, required):
    """-> (crystal_type, nullable, const_default)"""
    nullable = False
    default = None

    if "allOf" in p and len(p["allOf"]) == 1 and "$ref" in p["allOf"][0]:
        t = ref_name(p["allOf"][0]["$ref"])
    elif "$ref" in p:
        t = ref_name(p["$ref"])
    elif "anyOf" in p:
        parts = p["anyOf"]
        nonnull = [v for v in parts if v.get("type") != "null"]
        if len(nonnull) != len(parts):
            nullable = True
        if len(nonnull) == 1:
            sub, _, _ = prop_type(nonnull[0], True)
            return (sub, True, None)
        types = []
        for v in nonnull:
            st, _, _ = prop_type(v, True)
            types.append(st)
        t = " | ".join(dict.fromkeys(types))
        return (t, True, None)
    elif "oneOf" in p:
        types = []
        for v in p["oneOf"]:
            st, _, _ = prop_type(v, True)
            types.append(st)
        t = " | ".join(dict.fromkeys(types))
    else:
        ty = p.get("type")
        if isinstance(ty, list):
            nonnull = [x for x in ty if x != "null"]
            if len(nonnull) != len(ty):
                nullable = True
            ty = nonnull[0] if nonnull else "object"
        if "const" in p and isinstance(p["const"], str):
            default = json.dumps(p["const"])
        if ty == "string":
            t = "String"
        elif ty == "integer":
            t = INT_FORMATS.get(p.get("format"), "Int64")
        elif ty == "number":
            t = "Float64"
        elif ty == "boolean":
            t = "Bool"
        elif ty == "array":
            items = p.get("items", {})
            it, _, _ = prop_type(items, True) if items else ("JSON::Any", False, None)
            t = f"Array({it})"
        elif ty == "object":
            ap = p.get("additionalProperties")
            if isinstance(ap, dict):
                if "$ref" in ap:
                    t = f"Hash(String, {ref_name(ap['$ref'])})"
                elif ap.get("type") == "string":
                    t = "Hash(String, String)"
                else:
                    t = "Hash(String, JSON::Any)"
            else:
                t = "Hash(String, JSON::Any)"
        else:
            t = "JSON::Any"
    return (t, nullable, default)


def gen_default(p, ctype):
    if "default" not in p:
        return None
    dv = p["default"]
    if isinstance(dv, str):
        return json.dumps(dv)
    if isinstance(dv, bool):
        return "true" if dv else "false"
    if isinstance(dv, (int, float)):
        return repr(dv)
    if isinstance(dv, (dict, list)) and not dv:
        return f"{ctype}.new"
    return None


def generate(defs, cfg, version_tag):
    out = []
    out.append(f"# Generated from agent-client-protocol schema ({version_tag}).")
    out.append("# Do not edit by hand; regenerate via tools/generate_schema.py.")
    out.append("module ACP")
    if cfg.namespace:
        out.append(f"  module {cfg.namespace}")
    pad = "    " if cfg.namespace else "  "

    enum_names = set()
    enum_kinds = {}
    for name, d in defs.items():
        if name in cfg.handwritten:
            continue
        k = closed_string_enum(d)
        if k:
            enum_names.add(name)
            enum_kinds[name] = k

    # ---- aliases
    for name, d in defs.items():
        if name in cfg.handwritten or name in enum_names:
            continue
        if d.get("type") == "string":
            out.append(doc_comment(d.get("description"), pad) + f"{pad}alias {name} = String")
        elif d.get("type") == "integer" and "const" not in d:
            t = INT_FORMATS.get(d.get("format"), "Int32")
            out.append(doc_comment(d.get("description"), pad) + f"{pad}alias {name} = {t}")
    out.append("")

    # ---- enums
    for name in sorted(enum_kinds):
        kind, vals = enum_kinds[name]
        d = defs[name]
        members = [(v, crystal_member(v)) for v in vals]
        if kind == "closed":
            out.append(doc_comment(d.get("description"), pad) + f"{pad}enum {name}")
            default_ok = all(underscore(m) == w for w, m in members)
            for w, m in members:
                out.append(f"{pad}  {m}")
            if not default_ok:
                out.append("")
                out.append(f"{pad}  def to_json(json : JSON::Builder) : Nil")
                out.append(f"{pad}    json.string(case self")
                for w, m in members:
                    out.append(f"{pad}    in .{underscore(m)}? then {json.dumps(w)}")
                out.append(f"{pad}    end)")
                out.append(f"{pad}  end")
                out.append("")
                out.append(f"{pad}  def self.new(pull : JSON::PullParser)")
                out.append(f"{pad}    case s = pull.read_string")
                for w, m in members:
                    out.append(f"{pad}    when {json.dumps(w)} then {m}")
                out.append(f'{pad}    else raise JSON::ParseException.new("Unknown {name} value: #{{s}}", *pull.location_i64)')
                out.append(f"{pad}    end")
                out.append(f"{pad}  end")
            out.append(f"{pad}end")
        else:
            # open string enum: extensible struct preserving unknown values
            out.append(doc_comment(d.get("description"), pad) + f"{pad}struct {name}")
            for w, m in members:
                out.append(f"{pad}  {m} = new({json.dumps(w)})")
            if members:
                out.append("")
            out.append(f"{pad}  getter value : String")
            out.append("")
            out.append(f"{pad}  def initialize(@value : String)")
            out.append(f"{pad}  end")
            out.append("")
            out.append(f"{pad}  def self.new(pull : JSON::PullParser)")
            out.append(f"{pad}    new(pull.read_string)")
            out.append(f"{pad}  end")
            out.append("")
            out.append(f"{pad}  def to_json(json : JSON::Builder) : Nil")
            out.append(f"{pad}    @value.to_json(json)")
            out.append(f"{pad}  end")
            out.append("")
            out.append(f"{pad}  def to_s(io : IO) : Nil")
            out.append(f"{pad}    io << @value")
            out.append(f"{pad}  end")
            out.append(f"{pad}end")
        out.append("")

    # ---- objects
    for name, d in defs.items():
        if name in cfg.handwritten or name in enum_names:
            continue
        if not ("properties" in d or d.get("type") == "object"):
            continue
        props = dict(d.get("properties", {}))
        required = set(d.get("required", []))
        for jkey, const in cfg.discr_fields.get(name, []):
            disc = {"type": "string"}
            if const:
                disc["const"] = const
            props = {jkey: disc, **props}
            required.add(jkey)

        desc = doc_comment(d.get("description"), pad)
        inc = cfg.includes.get(name)
        out.append(desc + f"{pad}class {name}" + (f" < {inc}" if inc else ""))
        if not inc:
            out.append(f"{pad}  include JSON::Serializable")
        out.append("")

        init_args = []
        for jkey, p in props.items():
            cname = underscore(jkey)
            if jkey == "_meta":
                cname = "meta"
            cname = PROP_RENAMES.get(cname, cname)
            ctype, nullable, const_default = prop_type(p, jkey in required)
            is_req = jkey in required
            default = const_default or gen_default(p, ctype)
            if default and ctype in enum_names and default.startswith('"'):
                if enum_kinds[ctype][0] == "closed":
                    default = f"{ctype}::{crystal_member(json.loads(default))}"
                else:
                    default = f"{ctype}.new({default})"
            nilable = nullable or (not is_req and default is None)
            ann = f'{pad}  @[JSON::Field(key: "{jkey}"'
            if nilable and not default:
                ann += ", emit_null: false"
            ann += ")]"
            out.append(ann)
            tdecl = ctype + ("?" if nilable and not ctype.endswith("?") else "")
            line = f"{pad}  getter {cname} : {tdecl}"
            if default:
                line += f" = {default}"
            out.append(line)
            out.append("")
            if default:
                init_args.append(f"@{cname} : {tdecl} = {default}")
            elif is_req and not nullable:
                init_args.append(f"@{cname} : {tdecl}")
            else:
                init_args.append(f"@{cname} : {tdecl} = nil")
        if init_args:
            out.append(f"{pad}  def initialize(")
            out.append(f"{pad}    *,")
            for a in init_args:
                out.append(f"{pad}    {a},")
            out.append(f"{pad}  )")
            out.append(f"{pad}  end")
        out.append(f"{pad}end")
        out.append("")

    if cfg.namespace:
        out.append("  end")
    out.append("end")
    return "\n".join(out).replace("\n\n\n", "\n\n") + "\n"


# ---------------------------------------------------------------------
# v1 configuration
# ---------------------------------------------------------------------

V1_HANDWRITTEN = {
    "AgentRequest", "AgentResponse", "AgentNotification",
    "ClientRequest", "ClientResponse", "ClientNotification",
    "CancelRequestNotification", "Error", "ErrorCode", "RequestId",
    "ExtRequest", "ExtResponse", "ExtNotification",
    "ProtocolVersion",
    "ContentBlock", "SessionUpdate", "ToolCallContent", "McpServer", "AuthMethod",
    "RequestPermissionOutcome", "EmbeddedResourceResource",
    "CreateElicitationRequest", "CreateElicitationResponse", "ElicitationFormMode",
    "ElicitationUrlMode", "ElicitationSessionScope", "ElicitationRequestScope",
    "ElicitationPropertySchema", "ElicitationContentValue", "MultiSelectItems",
    "SessionConfigOption", "SessionConfigSelect", "SessionConfigBoolean",
    "SessionConfigOptionCategory", "SessionConfigSelectOptions",
    "SetSessionConfigOptionRequest", "AvailableCommandInput", "ElicitationAcceptAction",
}

V1_INCLUDES = {
    "TextContent": "ContentBlock", "ImageContent": "ContentBlock",
    "AudioContent": "ContentBlock", "ResourceLink": "ContentBlock",
    "EmbeddedResource": "ContentBlock",
    "Content": "ToolCallContent", "Diff": "ToolCallContent", "Terminal": "ToolCallContent",
    "ContentChunk": "SessionUpdate", "ToolCall": "SessionUpdate",
    "ToolCallUpdate": "SessionUpdate", "Plan": "SessionUpdate",
    "AvailableCommandsUpdate": "SessionUpdate", "CurrentModeUpdate": "SessionUpdate",
    "ConfigOptionUpdate": "SessionUpdate", "SessionInfoUpdate": "SessionUpdate",
    "UsageUpdate": "SessionUpdate",
    "McpServerHttp": "McpServer", "McpServerSse": "McpServer", "McpServerStdio": "McpServer",
    "AuthMethodTerminal": "AuthMethod", "AuthMethodAgent": "AuthMethod",
    "SelectedPermissionOutcome": "RequestPermissionOutcome",
    "StringPropertySchema": "ElicitationPropertySchema",
    "NumberPropertySchema": "ElicitationPropertySchema",
    "IntegerPropertySchema": "ElicitationPropertySchema",
    "BooleanPropertySchema": "ElicitationPropertySchema",
    "MultiSelectPropertySchema": "ElicitationPropertySchema",
    "StringMultiSelectItems": "MultiSelectItems", "TitledMultiSelectItems": "MultiSelectItems",
}

V1_DISCR = {
    "TextContent": [("type", "text")], "ImageContent": [("type", "image")],
    "AudioContent": [("type", "audio")], "ResourceLink": [("type", "resource_link")],
    "EmbeddedResource": [("type", "resource")],
    "Content": [("type", "content")], "Diff": [("type", "diff")], "Terminal": [("type", "terminal")],
    "ContentChunk": [("sessionUpdate", None)], "ToolCall": [("sessionUpdate", "tool_call")],
    "ToolCallUpdate": [("sessionUpdate", "tool_call_update")], "Plan": [("sessionUpdate", "plan")],
    "AvailableCommandsUpdate": [("sessionUpdate", "available_commands_update")],
    "CurrentModeUpdate": [("sessionUpdate", "current_mode_update")],
    "ConfigOptionUpdate": [("sessionUpdate", "config_option_update")],
    "SessionInfoUpdate": [("sessionUpdate", "session_info_update")],
    "UsageUpdate": [("sessionUpdate", "usage_update")],
    "McpServerHttp": [("type", "http")], "McpServerSse": [("type", "sse")],
    "AuthMethodTerminal": [("type", "terminal")],
    "SelectedPermissionOutcome": [("outcome", "selected")],
    "StringPropertySchema": [("type", "string")], "NumberPropertySchema": [("type", "number")],
    "IntegerPropertySchema": [("type", "integer")], "BooleanPropertySchema": [("type", "boolean")],
    "MultiSelectPropertySchema": [("type", "array")],
    "StringMultiSelectItems": [("type", "string")], "TitledMultiSelectItems": [("type", "titled")],
}

# ---------------------------------------------------------------------
# v2 configuration
# ---------------------------------------------------------------------

V2_HANDWRITTEN = {
    "AgentRequest", "AgentResponse", "AgentNotification",
    "ClientRequest", "ClientResponse", "ClientNotification",
    "ProtocolLevelNotification",
    "CancelRequestNotification", "Error", "ErrorCode", "RequestId",
    "ExtRequest", "ExtResponse", "ExtNotification",
    "ProtocolVersion",
    "ContentBlock", "SessionUpdate", "StateUpdate", "ToolCallContent",
    "McpServer", "AuthMethod", "RequestPermissionSubject", "DiffChange",
    "PlanUpdateContent", "ReplayFrom", "AvailableCommandInput",
    "RequestPermissionOutcome", "CreateElicitationRequest", "CreateElicitationResponse",
    "ElicitationFormMode", "ElicitationUrlMode", "ElicitationSessionScope",
    "ElicitationRequestScope", "ElicitationPropertySchema", "ElicitationContentValue",
    "MultiSelectItems", "SessionConfigOption", "SessionConfigSelect",
    "SessionConfigBoolean", "SessionConfigSelectOptions",
    "SetSessionConfigOptionRequest", "ElicitationAcceptAction",
    "EmbeddedResourceResource",
}

V2_INCLUDES = {
    "TextContent": "ContentBlock", "ImageContent": "ContentBlock",
    "AudioContent": "ContentBlock", "ResourceLink": "ContentBlock",
    "EmbeddedResource": "ContentBlock",
    "Content": "ToolCallContent", "Diff": "ToolCallContent", "Terminal": "ToolCallContent",
    "ContentChunk": "SessionUpdate", "UserMessage": "SessionUpdate",
    "AgentMessage": "SessionUpdate", "AgentThought": "SessionUpdate",
    "StateUpdate": "SessionUpdate", "ToolCallContentChunk": "SessionUpdate",
    "ToolCallUpdate": "SessionUpdate", "TerminalUpdate": "SessionUpdate",
    "TerminalOutputChunk": "SessionUpdate", "PlanUpdate": "SessionUpdate",
    "AvailableCommandsUpdate": "SessionUpdate", "ConfigOptionUpdate": "SessionUpdate",
    "SessionInfoUpdate": "SessionUpdate", "UsageUpdate": "SessionUpdate",
    "RunningStateUpdate": "StateUpdate", "IdleStateUpdate": "StateUpdate",
    "RequiresActionStateUpdate": "StateUpdate",
    "McpServerHttp": "McpServer", "McpServerStdio": "McpServer",
    "AuthMethodTerminal": "AuthMethod", "AuthMethodAgent": "AuthMethod",
    "ToolCallPermissionSubject": "RequestPermissionSubject",
    "CommandPermissionSubject": "RequestPermissionSubject",
    "DiffPathChange": "DiffChange", "DiffPathPairChange": "DiffChange",
    "PlanItems": "PlanUpdateContent",
    "ReplayFromStart": "ReplayFrom",
    "TextCommandInput": "AvailableCommandInput",
    "SelectedPermissionOutcome": "RequestPermissionOutcome",
    "StringPropertySchema": "ElicitationPropertySchema",
    "NumberPropertySchema": "ElicitationPropertySchema",
    "IntegerPropertySchema": "ElicitationPropertySchema",
    "BooleanPropertySchema": "ElicitationPropertySchema",
    "MultiSelectPropertySchema": "ElicitationPropertySchema",
    "StringMultiSelectItems": "MultiSelectItems", "TitledMultiSelectItems": "MultiSelectItems",
}

V2_DISCR = {
    "TextContent": [("type", "text")], "ImageContent": [("type", "image")],
    "AudioContent": [("type", "audio")], "ResourceLink": [("type", "resource_link")],
    "EmbeddedResource": [("type", "resource")],
    "Content": [("type", "content")], "Diff": [("type", "diff")], "Terminal": [("type", "terminal")],
    "ContentChunk": [("sessionUpdate", None)],
    "UserMessage": [("sessionUpdate", "user_message")],
    "AgentMessage": [("sessionUpdate", "agent_message")],
    "AgentThought": [("sessionUpdate", "agent_thought")],
    "RunningStateUpdate": [("sessionUpdate", "state_update"), ("state", "running")],
    "IdleStateUpdate": [("sessionUpdate", "state_update"), ("state", "idle")],
    "RequiresActionStateUpdate": [("sessionUpdate", "state_update"), ("state", "requires_action")],
    "ToolCallContentChunk": [("sessionUpdate", "tool_call_content_chunk")],
    "ToolCallUpdate": [("sessionUpdate", "tool_call_update")],
    "TerminalUpdate": [("sessionUpdate", "terminal_update")],
    "TerminalOutputChunk": [("sessionUpdate", "terminal_output_chunk")],
    "PlanUpdate": [("sessionUpdate", "plan_update")],
    "AvailableCommandsUpdate": [("sessionUpdate", "available_commands_update")],
    "ConfigOptionUpdate": [("sessionUpdate", "config_option_update")],
    "SessionInfoUpdate": [("sessionUpdate", "session_info_update")],
    "UsageUpdate": [("sessionUpdate", "usage_update")],
    "McpServerHttp": [("type", "http")], "McpServerStdio": [("type", "stdio")],
    "AuthMethodTerminal": [("type", "terminal")], "AuthMethodAgent": [("type", "agent")],
    "ToolCallPermissionSubject": [("type", "tool_call")],
    "CommandPermissionSubject": [("type", "command")],
    "DiffPathChange": [("operation", None)],
    "DiffPathPairChange": [("operation", None)],
    "PlanItems": [("type", "items")],
    "ReplayFromStart": [("type", "start")],
    "TextCommandInput": [("type", "text")],
    "SelectedPermissionOutcome": [("outcome", "selected")],
    "StringPropertySchema": [("type", "string")], "NumberPropertySchema": [("type", "number")],
    "IntegerPropertySchema": [("type", "integer")], "BooleanPropertySchema": [("type", "boolean")],
    "MultiSelectPropertySchema": [("type", "array")],
    "StringMultiSelectItems": [("type", "string")], "TitledMultiSelectItems": [("type", "titled")],
}


def main():
    repo, out_dir = sys.argv[1], sys.argv[2]

    v1 = json.load(open(f"{repo}/schema/v1/schema.json"))["$defs"]
    cfg1 = Config(None, V1_HANDWRITTEN, V1_INCLUDES, V1_DISCR, "v1")
    with open(f"{out_dir}/schema.cr", "w") as f:
        f.write(generate(v1, cfg1, "v1 schema.json @ schema-v1.21.0"))
    print("wrote", f"{out_dir}/schema.cr")

    v2 = json.load(open(f"{repo}/schema/v2/schema.json"))["$defs"]
    cfg2 = Config("V2", V2_HANDWRITTEN, V2_INCLUDES, V2_DISCR, "v2")
    with open(f"{out_dir}/v2/schema.cr", "w") as f:
        f.write(generate(v2, cfg2, "v2 schema.json @ schema-v2.0.0-alpha.3"))
    print("wrote", f"{out_dir}/v2/schema.cr")


if __name__ == "__main__":
    main()
