using System.Text.Json;

namespace NuPluginDotNet.Protocol;

/// <summary>
/// Response wrapper for signature calls - matches nushell's expected format.
/// </summary>
public class SignatureResponse
{
    public object[] Signature { get; set; } = Array.Empty<object>();
}

/// <summary>
/// Response for metadata calls - matches nushell's expected format.
/// </summary>
public class MetadataResponse
{
    public string version { get; set; } = "1.0.0";
}

/// <summary>
/// Represents a command signature in nushell's expected format.
/// </summary>
public class CommandSignatureWrapper
{
    public required CommandSig sig { get; set; }
    public CommandExample[] examples { get; set; } = Array.Empty<CommandExample>();
}

/// <summary>
/// Command signature details in nushell's expected format.
/// </summary>
public class CommandSig
{
    public required string name { get; set; }
    public required string description { get; set; }
    public string extra_description { get; set; } = "";
    public string[] search_terms { get; set; } = Array.Empty<string>();
    public PositionalArg[] required_positional { get; set; } = Array.Empty<PositionalArg>();
    public PositionalArg[] optional_positional { get; set; } = Array.Empty<PositionalArg>();
    public PositionalArg? rest_positional { get; set; }
    public bool vectorizes_over_list { get; set; } = false;
    public NamedArg[] named { get; set; } = Array.Empty<NamedArg>();
    public string input_type { get; set; } = "Any";
    public string output_type { get; set; } = "Any";
    public object[] input_output_types { get; set; } = Array.Empty<object>();
    public bool allow_variants_without_examples { get; set; } = true;
    public bool is_filter { get; set; } = false;
    public bool creates_scope { get; set; } = false;
    public bool allows_unknown_args { get; set; } = false;
    public string category { get; set; } = "Default";
}

/// <summary>
/// Positional argument in nushell's expected format.
/// </summary>
public class PositionalArg
{
    public required string name { get; set; }
    public required string desc { get; set; }
    public required object shape { get; set; }
    public object? var_id { get; set; }
    public object? default_value { get; set; }
}

/// <summary>
/// Named argument (flag) in nushell's expected format.
/// </summary>
public class NamedArg
{
    public required string @long { get; set; }
    public string? @short { get; set; }
    public object? arg { get; set; }
    public bool required { get; set; } = false;
    public required string desc { get; set; }
    public object? var_id { get; set; }
    public object? default_value { get; set; }
}

/// <summary>
/// Command example in nushell's expected format.
/// </summary>
public class CommandExample
{
    public required string description { get; set; }
    public required string example { get; set; }
    public object? result { get; set; }
}

/// <summary>
/// Nushell shape types for command signatures - these are simple strings as per the protocol specification.
/// </summary>
public static class NuTypes
{
    public static readonly object Nothing = "Nothing";
    public static readonly object Bool = "Bool";
    public static readonly object Int = "Int";
    public static readonly object Float = "Float";
    public static readonly object String = "String";
    public static readonly object Date = "Date";
    public static readonly object Duration = "Duration";
    public static readonly object Filesize = "Filesize";
    public static readonly object List = "List";
    public static readonly object Record = "Record";
    public static readonly object Block = "Block";
    public static readonly object Closure = "Closure";
    public static readonly object Error = "Error";
    public static readonly object Binary = "Binary";
    public static readonly object CellPath = "CellPath";
    public static readonly object Range = "Range";
    public static readonly object MatchPattern = "MatchPattern";
    public static readonly object LazyRecord = "LazyRecord";
    public static readonly object Glob = "Glob";
    public static readonly object Any = "Any";
}

/// <summary>
/// Nushell values for direct serialization.
/// </summary>
public static class NuValues
{
    /// <summary>
    /// Create a nushell string value.
    /// </summary>
    public static object String(string val, int start = 0, int end = 0)
    {
        return new
        {
            String = new
            {
                val,
                span = new { start, end }
            }
        };
    }

    /// <summary>
    /// Create a nushell integer value.
    /// </summary>
    public static object Int(long val, int start = 0, int end = 0)
    {
        return new
        {
            Int = new
            {
                val,
                span = new { start, end }
            }
        };
    }

    /// <summary>
    /// Create a nushell float value.
    /// </summary>
    public static object Float(double val, int start = 0, int end = 0)
    {
        return new
        {
            Float = new
            {
                val,
                span = new { start, end }
            }
        };
    }

    /// <summary>
    /// Create a nushell boolean value.
    /// </summary>
    public static object Bool(bool val, int start = 0, int end = 0)
    {
        return new
        {
            Bool = new
            {
                val,
                span = new { start, end }
            }
        };
    }

    /// <summary>
    /// Create a nushell list value.
    /// </summary>
    public static object List(object[] vals, int start = 0, int end = 0)
    {
        return new
        {
            List = new
            {
                vals,
                span = new { start, end }
            }
        };
    }

    /// <summary>
    /// Create a nushell record value.
    /// </summary>
    public static object Record(Dictionary<string, object> val, int start = 0, int end = 0)
    {
        return new
        {
            Record = new
            {
                val,
                span = new { start, end }
            }
        };
    }

    /// <summary>
    /// Create a nushell nothing value.
    /// </summary>
    public static object Nothing(int start = 0, int end = 0)
    {
        return new
        {
            Nothing = new
            {
                span = new { start, end }
            }
        };
    }

    /// <summary>
    /// Create a nushell error value.
    /// </summary>
    public static object Error(string msg)
    {
        return new
        {
            Error = new
            {
                msg
            }
        };
    }
}

/// <summary>
/// Helper methods for creating command signatures.
/// </summary>
public static class CommandHelpers
{
    /// <summary>
    /// Create a positional argument.
    /// </summary>
    public static PositionalArg Positional(string name, string desc, object shape)
    {
        return new PositionalArg
        {
            name = name,
            desc = desc,
            shape = shape
        };
    }

    /// <summary>
    /// Create a named argument (flag).
    /// </summary>
    public static NamedArg Named(string longName, string description, string? shortName = null, object? argType = null, bool required = false)
    {
        return new NamedArg
        {
            @long = longName,
            @short = shortName,
            arg = argType,
            required = required,
            desc = description
        };
    }



    /// <summary>
    /// Create a command signature.
    /// </summary>
    public static CommandSignatureWrapper Command(
        string name,
        string description,
        PositionalArg[]? requiredPositional = null,
        PositionalArg[]? optionalPositional = null,
        PositionalArg? restPositional = null,
        NamedArg[]? named = null,
        string inputType = "Any",
        string outputType = "Any",
        string category = "Default",
        string[]? searchTerms = null,
        CommandExample[]? examples = null)
    {
        return new CommandSignatureWrapper
        {
            sig = new CommandSig
            {
                name = name,
                description = description,
                search_terms = searchTerms ?? Array.Empty<string>(),
                required_positional = requiredPositional ?? Array.Empty<PositionalArg>(),
                optional_positional = optionalPositional ?? Array.Empty<PositionalArg>(),
                rest_positional = restPositional,
                named = named ?? Array.Empty<NamedArg>(),
                input_type = inputType,
                output_type = outputType,
                input_output_types = Array.Empty<object>(),
                category = category
            },
            examples = examples ?? Array.Empty<CommandExample>()
        };
    }
} 