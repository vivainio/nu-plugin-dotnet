using System.Text.Json;
using System.Text.Json.Serialization;

namespace NuPluginDotNet.Types;

[JsonConverter(typeof(PluginValueConverter))]
public class PluginValue
{
    public PluginValueType Type { get; set; }
    public object? Value { get; set; }
    public Dictionary<string, object>? Span { get; set; }

    public static PluginValue Null() => new() { Type = PluginValueType.Nothing };
    public static PluginValue Bool(bool value) => new() { Type = PluginValueType.Bool, Value = value };
    public static PluginValue Int(long value) => new() { Type = PluginValueType.Int, Value = value };
    public static PluginValue Float(double value) => new() { Type = PluginValueType.Float, Value = value };
    public static PluginValue String(string value) => new() { Type = PluginValueType.String, Value = value };
    public static PluginValue Binary(byte[] value) => new() { Type = PluginValueType.Binary, Value = value };
    public static PluginValue Date(DateTime value) => new() { Type = PluginValueType.Date, Value = value };
    public static PluginValue Duration(TimeSpan value) => new() { Type = PluginValueType.Duration, Value = value };
    public static PluginValue List(List<PluginValue> value) => new() { Type = PluginValueType.List, Value = value };
    public static PluginValue Record(Dictionary<string, PluginValue> value) => new() { Type = PluginValueType.Record, Value = value };
    public static PluginValue Custom(string objectId, string typeName) => new() 
    { 
        Type = PluginValueType.Custom, 
        Value = new Dictionary<string, object> 
        { 
            ["object_id"] = objectId, 
            ["type_name"] = SimplifyTypeName(typeName)
        } 
    };

    public bool IsNull => Type == PluginValueType.Nothing;
    public bool IsBool => Type == PluginValueType.Bool;
    public bool IsInt => Type == PluginValueType.Int;
    public bool IsFloat => Type == PluginValueType.Float;
    public bool IsString => Type == PluginValueType.String;
    public bool IsBinary => Type == PluginValueType.Binary;
    public bool IsList => Type == PluginValueType.List;
    public bool IsRecord => Type == PluginValueType.Record;
    public bool IsCustom => Type == PluginValueType.Custom;

    public T GetValue<T>() => (T)Value!;
    public string AsString() => Value?.ToString() ?? "";
    public long AsInt() => Convert.ToInt64(Value);
    public double AsFloat() => Convert.ToDouble(Value);
    public bool AsBool() => Convert.ToBoolean(Value);
    public byte[] AsBinary() => (byte[])Value!;
    public List<PluginValue> AsList() => (List<PluginValue>)Value!;
    public Dictionary<string, PluginValue> AsRecord() => (Dictionary<string, PluginValue>)Value!;

    public string GetObjectId()
    {
        if (!IsCustom) throw new InvalidOperationException("Not a custom object");
        var dict = (Dictionary<string, object>)Value!;
        return dict["object_id"].ToString()!;
    }

    public string GetTypeName()
    {
        if (!IsCustom) throw new InvalidOperationException("Not a custom object");
        var dict = (Dictionary<string, object>)Value!;
        return dict["type_name"].ToString()!;
    }

    private static string SimplifyTypeName(string typeName)
    {
        // Remove assembly qualification from generic type parameters
        // Example: System.Collections.Generic.List`1[[System.String, System.Private.CoreLib, Version=8.0.0.0, Culture=neutral, PublicKeyToken=7cec85d7bea7798e]]
        // becomes: System.Collections.Generic.List`1[System.String]
        
        if (!typeName.Contains("["))
        {
            // Not a generic type, return as-is
            return typeName;
        }
        
        // Handle double bracket format [[...]] used by .NET for assembly-qualified generics
        if (typeName.Contains("[["))
        {
            return SimplifyDoubleBracketFormat(typeName);
        }
        
        // Handle single bracket format [param,assembly] 
        return SimplifySingleBracketFormat(typeName);
    }
    
    private static string SimplifyDoubleBracketFormat(string typeName)
    {
        // Handle format: Type`1[[Param, Assembly, ...],[Param2, Assembly2, ...]]
        var doubleBracketIndex = typeName.IndexOf("[[");
        if (doubleBracketIndex == -1) return typeName;
        
        var result = new System.Text.StringBuilder();
        result.Append(typeName.Substring(0, doubleBracketIndex + 1)); // Include up to single [
        
        // Extract content between [[ and ]]
        var contentStart = doubleBracketIndex + 2; // Skip [[
        var contentEnd = typeName.LastIndexOf("]]");
        if (contentEnd == -1) contentEnd = typeName.LastIndexOf(']');
        
        var content = typeName.Substring(contentStart, contentEnd - contentStart);
        
        // Split parameters by ],[ pattern (assembly-qualified parameters are separated by this)
        var parameters = SplitAssemblyQualifiedParameters(content);
        var simplifiedParams = new List<string>();
        
        foreach (var param in parameters)
        {
            var trimmed = param.Trim();
            if (!string.IsNullOrEmpty(trimmed))
            {
                // Remove leading/trailing brackets if present
                if (trimmed.StartsWith("[")) trimmed = trimmed.Substring(1);
                if (trimmed.EndsWith("]")) trimmed = trimmed.Substring(0, trimmed.Length - 1);
                
                // Extract just the type name (before first comma)
                var commaIndex = trimmed.IndexOf(',');
                if (commaIndex > 0)
                {
                    var typePart = trimmed.Substring(0, commaIndex).Trim();
                    simplifiedParams.Add(typePart);
                }
                else
                {
                    simplifiedParams.Add(trimmed);
                }
            }
        }
        
        result.Append(string.Join(",", simplifiedParams));
        result.Append(']');
        
        return result.ToString();
    }
    
    private static string SimplifySingleBracketFormat(string typeName)
    {
        // Handle format: Type`1[Param,Assembly,Version,...]
        var openBracketIndex = typeName.IndexOf('[');
        if (openBracketIndex == -1) return typeName;
        
        var result = new System.Text.StringBuilder();
        result.Append(typeName.Substring(0, openBracketIndex + 1));
        
        var paramSection = typeName.Substring(openBracketIndex + 1);
        var closeBracketIndex = paramSection.LastIndexOf(']');
        if (closeBracketIndex > 0)
        {
            paramSection = paramSection.Substring(0, closeBracketIndex);
        }
        
        // Split by comma and take first part (type name)
        var commaIndex = paramSection.IndexOf(',');
        if (commaIndex > 0)
        {
            result.Append(paramSection.Substring(0, commaIndex).Trim());
        }
        else
        {
            result.Append(paramSection.Trim());
        }
        
        result.Append(']');
        return result.ToString();
    }
    
    private static List<string> SplitAssemblyQualifiedParameters(string content)
    {
        // Split assembly-qualified parameters that are in format [Type, Assembly],[Type2, Assembly2]
        var parameters = new List<string>();
        var currentParam = new System.Text.StringBuilder();
        var bracketDepth = 0;
        
        for (int i = 0; i < content.Length; i++)
        {
            char c = content[i];
            
            if (c == '[')
            {
                bracketDepth++;
                currentParam.Append(c);
            }
            else if (c == ']')
            {
                bracketDepth--;
                currentParam.Append(c);
                
                if (bracketDepth == 0 && i + 1 < content.Length && content[i + 1] == ',')
                {
                    // End of a parameter
                    parameters.Add(currentParam.ToString());
                    currentParam.Clear();
                    i++; // Skip the comma
                }
            }
            else
            {
                currentParam.Append(c);
            }
        }
        
        // Add the last parameter
        if (currentParam.Length > 0)
        {
            parameters.Add(currentParam.ToString());
        }
        
        return parameters;
    }
    

}

public enum PluginValueType
{
    Nothing,
    Bool,
    Int,
    Float,
    String,
    Binary,
    Date,
    Duration,
    List,
    Record,
    Custom,
    Error
}

public class PluginValueConverter : JsonConverter<PluginValue>
{
    private static readonly bool _debugEnabled = !string.IsNullOrEmpty(Environment.GetEnvironmentVariable("NU_PLUGIN_DOTNET_DEBUG"));
    private static readonly string? _logFile = _debugEnabled ? Path.Combine(Path.GetTempPath(), "nu-plugin-dotnet.log") : null;
    
    private static void WriteDebugLog(string message)
    {
        if (!_debugEnabled || _logFile == null)
            return;
            
        try
        {
            File.AppendAllText(_logFile, $"[{DateTime.Now:HH:mm:ss.fff}] {message}\n");
        }
        catch
        {
            // Ignore logging errors to avoid causing more issues
        }
    }
    private static T? DeserializeWithLogging<T>(string json, JsonSerializerOptions options, string typeName)
    {
        try
        {
            return JsonSerializer.Deserialize<T>(json, options);
        }
        catch (Exception ex)
        {
            // Log the error with stack trace
            WriteDebugLog($"DeserializeWithLogging<{typeName}> error: {ex.Message}");
            WriteDebugLog($"Stack trace: {ex.StackTrace}");
            WriteDebugLog($"JSON: {json}");
            
            throw; // Re-throw the original exception
        }
    }

    private static byte[] ParseBinaryValueInConverter(JsonElement valueElement)
    {
        try
        {
            // Handle binary data that can come in two formats:
            // 1. As a base64-encoded string (older format)
            // 2. As an array of byte values (newer format)
            
            if (valueElement.ValueKind == JsonValueKind.String)
            {
                // Base64-encoded string format
                var base64String = valueElement.GetString();
                if (base64String != null)
                {
                    return Convert.FromBase64String(base64String);
                }
            }
            else if (valueElement.ValueKind == JsonValueKind.Array)
            {
                // Array of byte values format
                return valueElement.EnumerateArray()
                    .Select(e => (byte)e.GetInt32())
                    .ToArray();
            }
            
            // Fallback - empty byte array
            return new byte[0];
        }
        catch (Exception ex)
        {
            // Log the error with stack trace
            WriteDebugLog($"ParseBinaryValueInConverter error: {ex.Message}");
            WriteDebugLog($"Stack trace: {ex.StackTrace}");
            WriteDebugLog($"ValueKind: {valueElement.ValueKind}");
            
            // Return empty array as fallback
            return new byte[0];
        }
    }

    public override PluginValue Read(ref Utf8JsonReader reader, Type typeToConvert, JsonSerializerOptions options)
    {
        try
        {
            using var doc = JsonDocument.ParseValue(ref reader);
            var root = doc.RootElement;

            if (!root.TryGetProperty("type", out var typeElement))
                throw new JsonException("Missing 'type' property");

            var typeName = typeElement.GetString();
            var pluginValue = new PluginValue();

            pluginValue.Type = typeName switch
            {
                "Nothing" => PluginValueType.Nothing,
                "Bool" => PluginValueType.Bool,
                "Int" => PluginValueType.Int,
                "Float" => PluginValueType.Float,
                "String" => PluginValueType.String,
                "Binary" => PluginValueType.Binary,
                "Date" => PluginValueType.Date,
                "Duration" => PluginValueType.Duration,
                "List" => PluginValueType.List,
                "Record" => PluginValueType.Record,
                "Custom" => PluginValueType.Custom,
                "Error" => PluginValueType.Error,
                _ => throw new JsonException($"Unknown type: {typeName}")
            };

            if (root.TryGetProperty("val", out var valueElement))
            {
                pluginValue.Value = pluginValue.Type switch
                {
                    PluginValueType.Nothing => null,
                    PluginValueType.Bool => valueElement.GetBoolean(),
                    PluginValueType.Int => valueElement.GetInt64(),
                    PluginValueType.Float => valueElement.GetDouble(),
                    PluginValueType.String => valueElement.GetString(),
                    PluginValueType.Binary => ParseBinaryValueInConverter(valueElement),
                    PluginValueType.Date => valueElement.GetDateTime(),
                    PluginValueType.Duration => TimeSpan.FromTicks(valueElement.GetInt64()),
                    PluginValueType.List => DeserializeWithLogging<List<PluginValue>>(valueElement.GetRawText(), options, "List"),
                    PluginValueType.Record => DeserializeWithLogging<Dictionary<string, PluginValue>>(valueElement.GetRawText(), options, "Record"),
                    PluginValueType.Custom => JsonSerializer.Deserialize<Dictionary<string, object>>(valueElement.GetRawText(), options),
                    _ => valueElement.GetRawText()
                };
            }

            if (root.TryGetProperty("span", out var spanElement))
            {
                pluginValue.Span = JsonSerializer.Deserialize<Dictionary<string, object>>(spanElement.GetRawText(), options);
            }

            return pluginValue;
        }
        catch (Exception ex)
        {
            // Log the error with full stack trace
            WriteDebugLog($"PluginValueConverter.Read error: {ex.Message}");
            WriteDebugLog($"Exception type: {ex.GetType().FullName}");
            WriteDebugLog($"Stack trace: {ex.StackTrace}");
            WriteDebugLog($"Inner exception: {ex.InnerException?.Message ?? "None"}");
            WriteDebugLog($"Inner exception stack trace: {ex.InnerException?.StackTrace ?? "None"}");
            
            throw; // Re-throw the original exception
        }
    }

    public override void Write(Utf8JsonWriter writer, PluginValue value, JsonSerializerOptions options)
    {
        writer.WriteStartObject();
        
        writer.WriteString("type", value.Type switch
        {
            PluginValueType.Nothing => "Nothing",
            PluginValueType.Bool => "Bool",
            PluginValueType.Int => "Int",
            PluginValueType.Float => "Float",
            PluginValueType.String => "String",
            PluginValueType.Binary => "Binary",
            PluginValueType.Date => "Date",
            PluginValueType.Duration => "Duration",
            PluginValueType.List => "List",
            PluginValueType.Record => "Record",
            PluginValueType.Custom => "Custom",
            PluginValueType.Error => "Error",
            _ => throw new ArgumentException($"Unknown type: {value.Type}")
        });

        // For Nothing type, don't write any val property
        if (value.Type != PluginValueType.Nothing && value.Value != null)
        {
            writer.WritePropertyName("val");
            switch (value.Type)
            {
                case PluginValueType.Nothing:
                    // This case should never be reached now
                    writer.WriteNullValue();
                    break;
                case PluginValueType.Bool:
                    writer.WriteBooleanValue((bool)value.Value);
                    break;
                case PluginValueType.Int:
                    writer.WriteNumberValue((long)value.Value);
                    break;
                case PluginValueType.Float:
                    writer.WriteNumberValue((double)value.Value);
                    break;
                case PluginValueType.String:
                    writer.WriteStringValue((string)value.Value);
                    break;
                case PluginValueType.Binary:
                    writer.WriteStringValue(Convert.ToBase64String((byte[])value.Value));
                    break;
                case PluginValueType.Date:
                    writer.WriteStringValue((DateTime)value.Value);
                    break;
                case PluginValueType.Duration:
                    writer.WriteNumberValue(((TimeSpan)value.Value).Ticks);
                    break;
                default:
                    JsonSerializer.Serialize(writer, value.Value, options);
                    break;
            }
        }

        if (value.Span != null)
        {
            writer.WritePropertyName("span");
            JsonSerializer.Serialize(writer, value.Span, options);
        }

        writer.WriteEndObject();
    }
} 