using System.Text.Json;
using System.Text.Json.Serialization;
using System.Collections.Generic;
using System.Threading.Tasks;
using NuPluginDotNet.Commands;
using NuPluginDotNet.DotNet;
using NuPluginDotNet.Types;
using NuPluginDotNet.Protocol;

namespace NuPluginDotNet.Plugin;

public class PluginHost : IPluginCommandHandler
{
    private readonly CommandRegistry? _commandRegistry;
    private readonly ObjectManager? _objectManager;
    private readonly AssemblyManager? _assemblyManager;
    private readonly ValueConverter? _valueConverter;
    private readonly bool _initializationSucceeded = false;
    private readonly string? _logFile;
    private readonly bool _debugEnabled;
    private readonly NushellProtocolHandler _protocolHandler;

    public PluginHost()
    {
        _debugEnabled = !string.IsNullOrEmpty(Environment.GetEnvironmentVariable("NU_PLUGIN_DOTNET_DEBUG"));
        _logFile = _debugEnabled ? Path.Combine(Path.GetTempPath(), "nu-plugin-dotnet-debug.log") : null;
        
        try
        {
            WriteLog("Plugin starting...");
            
            WriteLog("Initializing ObjectManager...");
            _objectManager = new ObjectManager();
            
            WriteLog("Initializing AssemblyManager...");
            _assemblyManager = new AssemblyManager();
            
            WriteLog("Initializing ValueConverter...");
            _valueConverter = new ValueConverter(_objectManager);
            
            WriteLog("Initializing CommandRegistry...");
            _commandRegistry = new CommandRegistry(_objectManager, _assemblyManager, _valueConverter);
            
            WriteLog("Initializing Protocol Handler...");
            _protocolHandler = new NushellProtocolHandler(this, _debugEnabled);
            
            _initializationSucceeded = true;
            WriteLog("Initialization completed successfully");
        }
        catch (Exception ex)
        {
            WriteLog($"Initialization failed: {ex.Message}");
            WriteLog($"Exception type: {ex.GetType().FullName}");
            WriteLog($"Stack trace: {ex.StackTrace ?? "No stack trace available"}");
            _initializationSucceeded = false;
            
            // Create a minimal protocol handler even if initialization failed
            _protocolHandler = new NushellProtocolHandler(this, _debugEnabled);
        }
    }

    private void WriteLog(string message)
    {
        if (!_debugEnabled || _logFile == null)
            return;
            
        try
        {
            File.AppendAllText(_logFile, $"[{DateTime.Now:HH:mm:ss.fff}] [Host] {message}\n");
        }
        catch
        {
            // Ignore logging errors to avoid causing more issues
        }
    }

    public async Task RunAsync()
    {
        WriteLog("Starting plugin with protocol handler");
        
        if (!_initializationSucceeded)
        {
            WriteLog("Plugin initialization failed - protocol handler will return errors");
        }
        
        try
        {
            await _protocolHandler.RunProtocolAsync();
        }
        catch (Exception ex)
        {
            WriteLog($"Protocol handler error: {ex.Message}");
            WriteLog($"Stack trace: {ex.StackTrace}");
            throw;
        }
        finally
        {
            WriteLog("Plugin finished");
        }
    }

    #region IPluginCommandHandler Implementation
    
    public async Task<object> HandleSignatureAsync()
    {
        WriteLog("Handling Signature request");
        
        if (!_initializationSucceeded || _commandRegistry == null)
        {
            return CreateError("Plugin not properly initialized");
        }
        
        try
        {
            var signatures = _commandRegistry.GetSignatures();
            WriteLog($"Returning {signatures.Count} command signatures");
            return signatures;
        }
        catch (Exception ex)
        {
            WriteLog($"Error getting signatures: {ex.Message}");
            return CreateError($"Failed to get signatures: {ex.Message}");
        }
    }
    
    public async Task<object> HandleMetadataAsync()
    {
        WriteLog("Handling Metadata request");
        
        return new
        {
            version = "1.0.0"
        };
    }
    
    public async Task<object> HandleRunAsync(JsonElement runElement)
    {
        WriteLog("Handling Run request");
        
        if (!_initializationSucceeded || _commandRegistry == null || _valueConverter == null)
        {
            WriteLog("Plugin not properly initialized - returning error");
            return CreateError("Plugin not properly initialized");
        }
        
        try
        {
            // Parse the run element
            var name = runElement.GetProperty("name").GetString() ?? "";
            var call = runElement.GetProperty("call");
            var input = runElement.TryGetProperty("input", out var inputElement) ? inputElement : (JsonElement?)null;
            
            WriteLog($"Running command: {name}");
            
            // Convert to plugin request format
            var pluginCall = new PluginCall
            {
                Head = new CommandHead { Name = name }
            };
            
            // Parse positional arguments
            if (call.TryGetProperty("positional", out var positionalElement) && positionalElement.ValueKind == JsonValueKind.Array)
            {
                foreach (var arg in positionalElement.EnumerateArray())
                {
                    pluginCall.Positional.Add(JsonElementToPluginValue(arg));
                }
            }
            
            // Parse named arguments
            if (call.TryGetProperty("named", out var namedElement) && namedElement.ValueKind == JsonValueKind.Object)
            {
                foreach (var prop in namedElement.EnumerateObject())
                {
                    pluginCall.Named[prop.Name] = JsonElementToPluginValue(prop.Value);
                }
            }
            
            // Parse input
            if (input.HasValue)
            {
                pluginCall.Input = ParseInputValue(input.Value);
            }
            
            var request = new PluginRequest
            {
                Type = "Run",
                Call = pluginCall
            };
            
            // Execute the command
            var response = await HandleRun(request);
            
            // Convert response to nushell format
            var pluginValue = response.Value as PluginValue ?? new PluginValue { Type = PluginValueType.Nothing };
            return ConvertPluginValueToNushellValue(pluginValue);
        }
        catch (Exception ex)
        {
            WriteLog($"Error handling run command: {ex.Message}");
            WriteLog($"Stack trace: {ex.StackTrace}");
            return CreateError($"Command execution failed: {ex.Message}");
        }
    }
    
    public async Task HandleSignalAsync(JsonElement signalElement)
    {
        WriteLog($"Handling Signal: {signalElement}");
        // Default implementation - signals can be handled here if needed
    }
    
    #endregion

    #region Helper Methods (moved from original implementation)
    
    private async Task<PluginResponse> HandleRun(PluginRequest request)
    {
        WriteLog($"[COMMAND_HANDLER] Handling Run request for command: {request.Call?.Head.Name}");
        
        if (!_initializationSucceeded)
        {
            WriteLog("[COMMAND_HANDLER] Plugin not initialized");
            return CreateErrorResponse("Plugin not properly initialized");
        }
        
        if (_commandRegistry == null)
        {
            WriteLog("[COMMAND_HANDLER] Command registry is null");
            return CreateErrorResponse("Command registry not available");
        }
        
        try
        {
            WriteLog($"[COMMAND_HANDLER] Executing command: {request.Call?.Head.Name}");
            var result = await _commandRegistry.ExecuteAsync(request.Call!.Head.Name, request.Call!);
            WriteLog($"[COMMAND_HANDLER] Command executed successfully");
            
            return new PluginResponse
            {
                Type = "Value",
                Value = result
            };
        }
        catch (Exception ex)
        {
            WriteLog($"[COMMAND_HANDLER] Command execution failed: {ex.Message}");
            WriteLog($"[COMMAND_HANDLER] Exception type: {ex.GetType().FullName}");
            WriteLog($"[COMMAND_HANDLER] Stack trace: {ex.StackTrace ?? "No stack trace available"}");
            
            return CreateErrorResponse($"Command execution failed: {ex.Message}");
        }
    }

    private PluginValue JsonElementToPluginValue(JsonElement element)
    {
        WriteLog($"[JSON_CONVERTER] Converting JsonElement: {element.ValueKind}");
        
        return element.ValueKind switch
        {
            JsonValueKind.Object when element.TryGetProperty("String", out var stringVal) => 
                ParseStringValue(stringVal.TryGetProperty("val", out var val) ? val.GetString() : null),
            JsonValueKind.Object when element.TryGetProperty("Int", out var intVal) => 
                new PluginValue 
                { 
                    Type = PluginValueType.Int, 
                    Value = intVal.TryGetProperty("val", out var val) ? val.GetInt64() : 0 
                },
            JsonValueKind.Object when element.TryGetProperty("Float", out var floatVal) => 
                new PluginValue 
                { 
                    Type = PluginValueType.Float, 
                    Value = floatVal.TryGetProperty("val", out var val) ? val.GetDouble() : 0.0 
                },
            JsonValueKind.Object when element.TryGetProperty("Bool", out var boolVal) => 
                new PluginValue 
                { 
                    Type = PluginValueType.Bool, 
                    Value = boolVal.TryGetProperty("val", out var val) ? val.GetBoolean() : false 
                },
            JsonValueKind.Object when element.TryGetProperty("Nothing", out _) => 
                new PluginValue { Type = PluginValueType.Nothing },
            JsonValueKind.Object when element.TryGetProperty("Binary", out var binaryVal) => 
                ParseBinaryValue(binaryVal),
            JsonValueKind.Object when element.TryGetProperty("List", out var listVal) => 
                new PluginValue 
                { 
                    Type = PluginValueType.List, 
                    Value = listVal.TryGetProperty("vals", out var vals) && vals.ValueKind == JsonValueKind.Array
                        ? vals.EnumerateArray().Select(JsonElementToPluginValue).ToList()
                        : new List<PluginValue>()
                },
            JsonValueKind.Object when element.TryGetProperty("Record", out var recordVal) => 
                new PluginValue 
                { 
                    Type = PluginValueType.Record, 
                    Value = recordVal.TryGetProperty("val", out var val) && val.ValueKind == JsonValueKind.Object
                        ? val.EnumerateObject().ToDictionary(p => p.Name, p => JsonElementToPluginValue(p.Value))
                        : new Dictionary<string, PluginValue>()
                },
            JsonValueKind.Object when element.TryGetProperty("Custom", out var customVal) => 
                ParseCustomObject(customVal),
            _ => new PluginValue { Type = PluginValueType.String, Value = element.GetRawText() }
        };
    }

    private PluginValue ParseStringValue(string? stringValue)
    {
        WriteLog($"[STRING_PARSER] Parsing string value: {stringValue}");
        
        if (stringValue == null)
            return new PluginValue { Type = PluginValueType.Nothing };
            
        // Try to detect if it's a file path and return appropriate type
        if (File.Exists(stringValue) || Directory.Exists(stringValue))
        {
            WriteLog($"[STRING_PARSER] Detected file/directory path: {stringValue}");
            return new PluginValue 
            { 
                Type = PluginValueType.String, 
                Value = stringValue 
            };
        }
        
        // Try to parse as number
        if (long.TryParse(stringValue, out var longVal))
        {
            WriteLog($"[STRING_PARSER] Detected integer: {longVal}");
            return new PluginValue 
            { 
                Type = PluginValueType.Int, 
                Value = longVal 
            };
        }
        
        if (double.TryParse(stringValue, out var doubleVal))
        {
            WriteLog($"[STRING_PARSER] Detected float: {doubleVal}");
            return new PluginValue 
            { 
                Type = PluginValueType.Float, 
                Value = doubleVal 
            };
        }
        
        // Default to string
        return new PluginValue 
        { 
            Type = PluginValueType.String, 
            Value = stringValue 
        };
    }

    private PluginValue ParseBinaryValue(JsonElement valElement)
    {
        WriteLog("[BINARY_PARSER] Parsing binary value");
        
        try
        {
            if (valElement.TryGetProperty("val", out var val) && val.ValueKind == JsonValueKind.Array)
            {
                var bytes = val.EnumerateArray().Select(x => (byte)x.GetInt32()).ToArray();
                WriteLog($"[BINARY_PARSER] Parsed {bytes.Length} bytes");
                return new PluginValue 
                { 
                    Type = PluginValueType.Binary, 
                    Value = bytes 
                };
            }
        }
        catch (Exception ex)
        {
            WriteLog($"[BINARY_PARSER] Error parsing binary: {ex.Message}");
        }
        
        return new PluginValue { Type = PluginValueType.Nothing };
    }

    private PluginValue ParseCustomObject(JsonElement valElement)
    {
        WriteLog("[CUSTOM_PARSER] Parsing custom object");
        
        try
        {
            return new PluginValue 
            { 
                Type = PluginValueType.Custom, 
                Value = valElement.GetRawText() 
            };
        }
        catch (Exception ex)
        {
            WriteLog($"[CUSTOM_PARSER] Error parsing custom object: {ex.Message}");
            return new PluginValue { Type = PluginValueType.Nothing };
        }
    }

    private PluginValue? ParseInputValue(JsonElement inputElement)
    {
        WriteLog("[INPUT_PARSER] Parsing input value");
        
        try
        {
            if (inputElement.ValueKind == JsonValueKind.String)
            {
                var inputType = inputElement.GetString();
                if (inputType == "Empty")
                {
                    return new PluginValue { Type = PluginValueType.Nothing };
                }
            }
            else if (inputElement.ValueKind == JsonValueKind.Object)
            {
                if (inputElement.TryGetProperty("Value", out var valueElement))
                {
                    return JsonElementToPluginValue(valueElement);
                }
            }
            
            WriteLog($"[INPUT_PARSER] Unknown input format: {inputElement.ValueKind}");
            return null;
        }
        catch (Exception ex)
        {
            WriteLog($"[INPUT_PARSER] Error parsing input: {ex.Message}");
            return null;
        }
    }

    private object ConvertPluginValueToNushellValue(PluginValue value)
    {
        WriteLog($"[NUSHELL_CONVERTER] Converting PluginValue to Nushell format: {value.Type}");
        
        return value.Type switch
        {
            PluginValueType.String => new { String = new { val = value.Value?.ToString() ?? "", span = new { start = 0, end = 0 } } },
            PluginValueType.Int => new { Int = new { val = Convert.ToInt64(value.Value ?? 0), span = new { start = 0, end = 0 } } },
            PluginValueType.Float => new { Float = new { val = Convert.ToDouble(value.Value ?? 0.0), span = new { start = 0, end = 0 } } },
            PluginValueType.Bool => new { Bool = new { val = Convert.ToBoolean(value.Value ?? false), span = new { start = 0, end = 0 } } },
            PluginValueType.Nothing => new { Nothing = new { span = new { start = 0, end = 0 } } },
            PluginValueType.List when value.Value is List<PluginValue> list => new 
            { 
                List = new 
                { 
                    vals = list.Select(ConvertPluginValueToNushellValue).ToArray(),
                    span = new { start = 0, end = 0 } 
                } 
            },
            PluginValueType.Record when value.Value is Dictionary<string, PluginValue> dict => new 
            { 
                Record = new 
                { 
                    val = dict.ToDictionary(
                        kvp => kvp.Key, 
                        kvp => ConvertPluginValueToNushellValue(kvp.Value)
                    ),
                    span = new { start = 0, end = 0 } 
                } 
            },
            PluginValueType.Binary when value.Value is byte[] bytes => new { Binary = new { val = bytes, span = new { start = 0, end = 0 } } },
            PluginValueType.Custom => new { String = new { val = $"{value.GetTypeName()}@{value.GetObjectId()}", span = new { start = 0, end = 0 } } },
            _ => new { String = new { val = value.Value?.ToString() ?? "", span = new { start = 0, end = 0 } } }
        };
    }

    private static PluginResponse CreateErrorResponse(string message)
    {
        return new PluginResponse
        {
            Type = "Error",
            Value = new PluginValue
            {
                Type = PluginValueType.Error,
                Value = message
            }
        };
    }
    
    private object CreateError(string message)
    {
        return new
        {
            Error = new
            {
                msg = message
            }
        };
    }
    
    #endregion
}

public class PluginRequest
{
    public string? Type { get; set; }
    public object? Value { get; set; }
    public PluginCall? Call { get; set; }
    
    // For Hello message
    public HelloMessage? Hello { get; set; }
}

public class HelloMessage
{
    public string Protocol { get; set; } = "";
    public string Version { get; set; } = "";
    public object[] Features { get; set; } = Array.Empty<object>();
}

public class PluginCall
{
    public CommandHead Head { get; set; } = new();
    public List<PluginValue> Positional { get; set; } = new();
    public Dictionary<string, PluginValue> Named { get; set; } = new();
    public PluginValue? Input { get; set; }
}

public class CommandHead
{
    public string Name { get; set; } = "";
    public Dictionary<string, object>? Span { get; set; }
}

public class PluginResponse
{
    public string Type { get; set; } = "";
    public object? Value { get; set; }
}

public class CommandSignature
{
    public string Name { get; set; } = "";
    public string Description { get; set; } = "";
    public string Category { get; set; } = "";
    public List<CommandParameter> Parameters { get; set; } = new();
}

public class CommandParameter
{
    public string Name { get; set; } = "";
    public string Description { get; set; } = "";
    public bool Required { get; set; }
    public string Type { get; set; } = "";
}

public class PluginError
{
    public string Message { get; set; } = "";
    public string? StackTrace { get; set; }
    public string? Type { get; set; }
    public PluginError? InnerException { get; set; }
} 