using System.Text.Json;
using System.Text.Json.Serialization;
using System.Collections.Generic;
using System.Threading.Tasks;
using NuPluginDotNet.Commands;
using NuPluginDotNet.DotNet;
using NuPluginDotNet.Types;

namespace NuPluginDotNet.Plugin;

public class PluginHost
{
    private readonly CommandRegistry? _commandRegistry;
    private readonly ObjectManager? _objectManager;
    private readonly AssemblyManager? _assemblyManager;
    private readonly ValueConverter? _valueConverter;
    private readonly bool _initializationSucceeded = false;
    private readonly string _logFile;


    public PluginHost()
    {
        _logFile = Path.Combine(Path.GetTempPath(), "nu-plugin-dotnet-debug.log");
        
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
            
            _initializationSucceeded = true;
            WriteLog("Initialization completed successfully");
        }
        catch (Exception ex)
        {
            WriteLog($"Initialization failed: {ex.Message}");
            _initializationSucceeded = false;
        }
    }

    private void WriteLog(string message)
    {
        try
        {
            File.AppendAllText(_logFile, $"[{DateTime.Now:HH:mm:ss.fff}] {message}\n");
        }
        catch
        {
            // Ignore logging errors to avoid causing more issues
        }
    }

    public async Task RunAsync()
    {
        WriteLog("RunAsync started - implementing correct nushell plugin protocol");
        
        try
        {
            WriteLog("RunAsync started - encoding declaration already sent by Main");
            
            // Send Hello message immediately after encoding (following Python plugin pattern)
            var hello = new
            {
                Hello = new
                {
                    protocol = "nu-plugin",
                    version = "0.104.0",
                    features = new object[] { }
                }
            };
            var helloJson = JsonSerializer.Serialize(hello);
            Console.WriteLine(helloJson);
            Console.Out.Flush();
            WriteLog($"Hello message sent: {helloJson}");
            
            // Now use regular Console I/O for JSON protocol
            Console.InputEncoding = System.Text.Encoding.UTF8;
            Console.OutputEncoding = System.Text.Encoding.UTF8;
            
            // Read and respond to messages
            string? line;
            while ((line = await Console.In.ReadLineAsync()) != null)
            {
                WriteLog($"Received message: {line}");
                
                if (string.IsNullOrWhiteSpace(line))
                {
                    WriteLog("Empty line, continuing");
                    continue;
                }
                
                try
                {
                    // Handle simple string messages like "Goodbye"
                    if (line.StartsWith('"') && line.EndsWith('"'))
                    {
                        var message = JsonSerializer.Deserialize<string>(line);
                        if (message == "Goodbye")
                        {
                            WriteLog("Received Goodbye message, plugin exiting");
                            break;
                        }
                        else
                        {
                            WriteLog($"Received unknown string message: {message}");
                            continue;
                        }
                    }
                    
                    // Parse the raw JSON to determine message type
                    using var jsonDoc = JsonDocument.Parse(line);
                    var root = jsonDoc.RootElement;
                    
                    object? response = null;
                    
                    if (root.TryGetProperty("Hello", out var helloElement))
                    {
                        WriteLog("Received Hello message - no response needed (already sent)");
                        continue; // Don't send a response, we already sent Hello at startup
                    }
                    else if (root.TryGetProperty("Call", out var callElement))
                    {
                        WriteLog("Received Call message");
                        response = await HandleCall(callElement);
                    }
                    else
                    {
                        WriteLog($"Unknown message format: {line}");
                        response = CreateErrorResponse($"Unknown message format");
                    }
                    
                    if (response != null)
                    {
                        var responseJson = JsonSerializer.Serialize(response);
                        Console.WriteLine(responseJson); // WriteLine already adds newline
                        Console.Out.Flush(); // Immediate flush is critical
                        WriteLog($"Response sent: {responseJson}");
                    }
                }
                catch (JsonException ex)
                {
                    WriteLog($"JSON error: {ex.Message}");
                    var errorResponse = CreateErrorResponse($"JSON parsing error: {ex.Message}");
                    var errorJson = JsonSerializer.Serialize(errorResponse);
                    Console.WriteLine(errorJson);
                    Console.Out.Flush();
                }
                catch (Exception ex)
                {
                    WriteLog($"Command error: {ex.Message}");
                    var errorResponse = CreateErrorResponse($"Internal error: {ex.Message}");
                    var errorJson = JsonSerializer.Serialize(errorResponse);
                    Console.WriteLine(errorJson);
                    Console.Out.Flush();
                }
            }
            
            WriteLog("Input stream ended, plugin finishing");
        }
        catch (Exception ex)
        {
            WriteLog($"Fatal error: {ex.Message}");
            WriteLog($"Stack trace: {ex.StackTrace}");
            Environment.Exit(1);
        }
        finally
        {
            WriteLog("Plugin finished");
        }
    }
    
    private object HandleHello()
    {
        WriteLog("Handling Hello request - sending Hello response");
        
        return new
        {
            Hello = new
            {
                protocol = "nu-plugin",
                version = "0.104.0", // Match current nushell version
                features = new object[] { } // Empty features array
            }
        };
    }
    
    private async Task<object> HandleCall(JsonElement callElement)
    {
        WriteLog("Handling Call request");
        
        // Parse the call - it should be a 2-tuple [id, call_type]
        if (callElement.ValueKind == JsonValueKind.Array)
        {
            var callArray = callElement.EnumerateArray().ToArray();
            if (callArray.Length >= 2)
            {
                var callId = callArray[0].GetInt32();
                
                // Check if the second element is a string (simple call type) or object (complex call)
                if (callArray[1].ValueKind == JsonValueKind.String)
                {
                    // Simple call types like "Signature", "Metadata"
                    var callType = callArray[1].GetString();
                    WriteLog($"Call ID: {callId}, Type: {callType}");
                    
                    var callResponse = callType switch
                    {
                        "Signature" => HandleSignature(),
                        "Metadata" => HandleMetadata(),
                        _ => (object)new { Error = new { msg = $"Unknown call type: {callType}" } }
                    };
                    
                    return new
                    {
                        CallResponse = new object[] { callId, callResponse }
                    };
                }
                else if (callArray[1].ValueKind == JsonValueKind.Object)
                {
                    // Complex call like "Run"
                    var callObj = callArray[1];
                    if (callObj.TryGetProperty("Run", out var runElement))
                    {
                        WriteLog($"Call ID: {callId}, Type: Run");
                        var runResponse = await HandleRunCall(runElement);
                        return new
                        {
                            CallResponse = new object[] { callId, runResponse }
                        };
                    }
                    else
                    {
                        WriteLog($"Call ID: {callId}, Unknown complex call type");
                        return new
                        {
                            CallResponse = new object[] { callId, new { Error = new { msg = "Unknown complex call type" } } }
                        };
                    }
                }
            }
        }
        
        return CreateErrorResponse("Invalid call format");
    }

    private object HandleSignature()
    {
        WriteLog("Handling signature request");
        
        var signatures = _commandRegistry?.GetSignatures();
        
        // Return the signatures directly as nushell expects them
        return signatures?.FirstOrDefault() ?? new { Signature = new object[0] };
    }

    private object HandleMetadata()
    {
        WriteLog("Handling metadata request");
        
        return new
        {
            Metadata = new
            {
                version = "1.0.0" // Plugin version
            }
        };
    }

    private async Task<PluginResponse> HandleRun(PluginRequest request)
    {
        WriteLog("Handling run request");
        
        try
        {
            if (!_initializationSucceeded || _commandRegistry == null)
            {
                WriteLog("Initialization not successful, returning error");
                return CreateErrorResponse("Plugin initialization failed. Please check your .NET installation.");
            }

            var call = request.Call;
            if (call == null)
            {
                WriteLog("No call information in request");
                return CreateErrorResponse("Missing call information");
            }

            WriteLog($"Executing command: {call.Head.Name}");
            var result = await _commandRegistry.ExecuteAsync(call.Head.Name, call);
            WriteLog("Command executed successfully");
            
            return new PluginResponse
            {
                Type = "Value",
                Value = result
            };
        }
        catch (Exception ex)
        {
            WriteLog($"Error executing command: {ex.Message}");
            return CreateErrorResponse(ex.Message);
        }
    }

    private async Task<object> HandleRunCall(JsonElement runElement)
    {
        WriteLog("Handling Run call");
        
        try
        {
            if (!_initializationSucceeded || _commandRegistry == null)
            {
                WriteLog("Initialization not successful, returning error");
                return new { Error = new { msg = "Plugin initialization failed. Please check your .NET installation." } };
            }

            // Parse the run call structure
            if (!runElement.TryGetProperty("name", out var nameElement) ||
                !runElement.TryGetProperty("call", out var callElement))
            {
                WriteLog("Missing name or call in run element");
                return new { Error = new { msg = "Invalid run call format" } };
            }

            var commandName = nameElement.GetString();
            WriteLog($"Executing command: {commandName}");

            // Create a simple PluginCall from the JSON
            var pluginCall = new PluginCall
            {
                Head = new CommandHead { Name = commandName ?? "" },
                Positional = new List<PluginValue>(),
                Named = new Dictionary<string, PluginValue>(),
                Input = null
            };

            // Parse positional arguments if any
            if (callElement.TryGetProperty("positional", out var positionalElement) && 
                positionalElement.ValueKind == JsonValueKind.Array)
            {
                foreach (var item in positionalElement.EnumerateArray())
                {
                    pluginCall.Positional.Add(JsonElementToPluginValue(item));
                }
            }

            // Parse named arguments if any
            if (callElement.TryGetProperty("named", out var namedElement) && 
                namedElement.ValueKind == JsonValueKind.Array)
            {
                foreach (var item in namedElement.EnumerateArray())
                {
                    if (item.ValueKind == JsonValueKind.Array)
                    {
                        var namedArray = item.EnumerateArray().ToArray();
                        if (namedArray.Length >= 2)
                        {
                            var key = namedArray[0].GetString();
                            if (key != null)
                            {
                                pluginCall.Named[key] = JsonElementToPluginValue(namedArray[1]);
                            }
                        }
                    }
                }
            }

            // Parse input if any
            if (runElement.TryGetProperty("input", out var inputElement))
            {
                pluginCall.Input = ParseInputValue(inputElement);
            }

            // Execute the command
            var result = await _commandRegistry.ExecuteAsync(commandName ?? "", pluginCall);
            WriteLog("Command executed successfully");
            
            // Return PipelineData format as expected by nushell
            var nushellValue = ConvertPluginValueToNushellValue(result);
            return new { PipelineData = new { Value = new object[] { nushellValue, null } } };
        }
        catch (Exception ex)
        {
            WriteLog($"Error executing run call: {ex.Message}");
            return new { Error = new { msg = ex.Message } };
        }
    }
    
    private PluginValue JsonElementToPluginValue(JsonElement element)
    {
        // Handle nushell value format: {"String": {"val": "value", "span": {...}}}
        if (element.ValueKind == JsonValueKind.Object)
        {
            foreach (var property in element.EnumerateObject())
            {
                var typeName = property.Name;
                var valueObj = property.Value;
                
                if (valueObj.TryGetProperty("val", out var valElement))
                {
                    return typeName switch
                    {
                        "String" => ParseStringValue(valElement.GetString()),
                        "Int" => new PluginValue { Type = PluginValueType.Int, Value = valElement.GetInt64() },
                        "Float" => new PluginValue { Type = PluginValueType.Float, Value = valElement.GetDouble() },
                        "Bool" => new PluginValue { Type = PluginValueType.Bool, Value = valElement.GetBoolean() },
                        "Custom" => ParseCustomObject(valElement),
                        _ => new PluginValue { Type = PluginValueType.String, Value = valElement.ToString() }
                    };
                }
            }
        }
        
        // Fallback to simple conversion
        return element.ValueKind switch
        {
            JsonValueKind.String => new PluginValue { Type = PluginValueType.String, Value = element.GetString() },
            JsonValueKind.Number => new PluginValue { Type = PluginValueType.Int, Value = element.GetInt64() },
            JsonValueKind.True => new PluginValue { Type = PluginValueType.Bool, Value = true },
            JsonValueKind.False => new PluginValue { Type = PluginValueType.Bool, Value = false },
            JsonValueKind.Null => new PluginValue { Type = PluginValueType.Nothing, Value = null },
            _ => new PluginValue { Type = PluginValueType.String, Value = element.ToString() }
        };
    }

    private PluginValue ParseStringValue(string? stringValue)
    {
        // Check if this is an encoded custom object
        if (stringValue != null && stringValue.StartsWith("__CUSTOM_OBJECT__") && stringValue.EndsWith("__"))
        {
            var objectId = stringValue.Substring("__CUSTOM_OBJECT__".Length, stringValue.Length - "__CUSTOM_OBJECT__".Length - 2);
            
            // Try to get the object from the object manager to determine its type
            var obj = _objectManager?.GetObject(objectId);
            if (obj != null)
            {
                var typeName = obj.GetType().FullName ?? obj.GetType().Name;
                return PluginValue.Custom(objectId, typeName);
            }
        }
        
        // Regular string
        return new PluginValue { Type = PluginValueType.String, Value = stringValue };
    }

    private PluginValue ParseCustomObject(JsonElement valElement)
    {
        // Parse custom object format: {"object_id": "...", "type_name": "..."}
        if (valElement.TryGetProperty("object_id", out var objectIdElement) &&
            valElement.TryGetProperty("type_name", out var typeNameElement))
        {
            var objectId = objectIdElement.GetString();
            var typeName = typeNameElement.GetString();
            
            if (objectId != null && typeName != null)
            {
                return PluginValue.Custom(objectId, typeName);
            }
        }
        
        // Fallback to string
        return new PluginValue { Type = PluginValueType.String, Value = valElement.ToString() };
    }

    private PluginValue? ParseInputValue(JsonElement inputElement)
    {
        // Handle different input formats
        if (inputElement.ValueKind == JsonValueKind.String)
        {
            var inputStr = inputElement.GetString();
            if (inputStr == "Empty")
            {
                return null; // No input
            }
            return new PluginValue { Type = PluginValueType.String, Value = inputStr };
        }
        
        // Input format: {"Value": [{"String": {"val": "System.Math", "span": {...}}}, null]}
        if (inputElement.TryGetProperty("Value", out var valueElement) && 
            valueElement.ValueKind == JsonValueKind.Array)
        {
            var valueArray = valueElement.EnumerateArray().ToArray();
            if (valueArray.Length > 0 && valueArray[0].ValueKind != JsonValueKind.Null)
            {
                return JsonElementToPluginValue(valueArray[0]);
            }
        }
        
        return null;
    }
    
    private object ConvertPluginValueToNushellValue(PluginValue value)
    {
        // Convert PluginValue to nushell object format (matching Python plugin)
        var span = new { start = 0, end = 0 };
        return value.Type switch
        {
            PluginValueType.String => new { String = new { val = value.Value, span } },
            PluginValueType.Int => new { Int = new { val = value.Value, span } },
            PluginValueType.Float => new { Float = new { val = value.Value, span } },
            PluginValueType.Bool => new { Bool = new { val = value.Value, span } },
            PluginValueType.List => new { List = new { vals = value.AsList().Select(ConvertPluginValueToNushellValue).ToArray(), span } },
            PluginValueType.Record => new { Record = new { val = value.AsRecord().ToDictionary(kvp => kvp.Key, kvp => ConvertPluginValueToNushellValue(kvp.Value)), span } },
            PluginValueType.Custom => new { String = new { val = $"__CUSTOM_OBJECT__{value.GetObjectId()}__", span } }, // Encode custom objects as special strings
            PluginValueType.Nothing => new { Nothing = new { span } }, // Return Nothing object with span for void type
            PluginValueType.Error => throw new Exception(((PluginError)value.Value!).Message), // Convert error to exception so nushell can handle it properly
            _ => new { String = new { val = value.Value?.ToString() ?? "", span } }
        };
    }

    private static PluginResponse CreateErrorResponse(string message)
    {
        return new PluginResponse
        {
            Type = "Error",
            Value = new PluginError
            {
                Message = message
            }
        };
    }
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