# .NET Plugin Implementation Guide

This guide provides practical guidance for implementing nushell plugins in .NET, focusing on the JSON protocol communication.

## Overview

A .NET nushell plugin is a console application that:
1. Communicates via JSON messages over stdin/stdout
2. Follows the nushell plugin protocol
3. Has an executable name starting with `nu_plugin_`

## Basic Plugin Structure

### Program.cs Template
```csharp
using System;
using System.IO;
using System.Text.Json;
using System.Threading.Tasks;

namespace MyNuPlugin
{
    class Program
    {
        static async Task Main(string[] args)
        {
            var plugin = new MyPlugin();
            await plugin.RunAsync();
        }
    }
}
```

### Plugin Class Template
```csharp
public class MyPlugin
{
    private readonly JsonSerializerOptions _jsonOptions;
    
    public MyPlugin()
    {
        _jsonOptions = new JsonSerializerOptions
        {
            PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
            WriteIndented = false
        };
    }
    
    public async Task RunAsync()
    {
        // Step 1: Send encoding type
        await Console.Out.WriteAsync("\x04json");
        await Console.Out.FlushAsync();
        
        // Step 2: Send Hello message immediately 
        await SendHelloMessage();
        
        // Step 3: Handle messages from engine
        string line;
        while ((line = await Console.In.ReadLineAsync()) != null)
        {
            await ProcessMessage(line);
        }
    }
    
    private async Task SendHelloMessage()
    {
        var hello = new
        {
            Hello = new
            {
                protocol = "nu-plugin",
                version = "0.94.0",
                features = new object[0]
            }
        };
        
        var json = JsonSerializer.Serialize(hello, _jsonOptions);
        await Console.Out.WriteLineAsync(json);
        await Console.Out.FlushAsync();
    }
}
```

## Message Processing

### Core Message Handler
```csharp
private async Task ProcessMessage(string jsonMessage)
{
    try
    {
        using var document = JsonDocument.Parse(jsonMessage);
        var root = document.RootElement;
        
        if (root.TryGetProperty("Hello", out var hello))
        {
            await HandleHello(hello);
        }
        else if (root.TryGetProperty("Call", out var call))
        {
            await HandleCall(call);
        }
        else if (root.TryGetProperty("Signal", out var signal))
        {
            await HandleSignal(signal);
        }
        else if (root.ValueKind == JsonValueKind.String && 
                 root.GetString() == "Goodbye")
        {
            Environment.Exit(0);
        }
    }
    catch (Exception ex)
    {
        // Log error to stderr
        await Console.Error.WriteLineAsync($"Error processing message: {ex.Message}");
    }
}
```

### Hello Message Handler
```csharp
private async Task HandleHello(JsonElement hello)
{
    // This is the engine responding to our Hello message
    // We can validate the engine version and features here
    var protocol = hello.GetProperty("protocol").GetString();
    var version = hello.GetProperty("version").GetString();
    var features = hello.GetProperty("features");
    
    // Validate protocol compatibility
    if (protocol != "nu-plugin")
    {
        throw new InvalidOperationException($"Invalid protocol: {protocol}");
    }
    
    // Log or store engine version and features if needed
    // No response needed - the handshake is complete
}
```

### Call Message Handler
```csharp
private async Task HandleCall(JsonElement call)
{
    if (call.ValueKind != JsonValueKind.Array || call.GetArrayLength() != 2)
        return;
        
    var callId = call[0].GetInt32();
    var callType = call[1];
    
    if (callType.ValueKind == JsonValueKind.String)
    {
        var callTypeStr = callType.GetString();
        switch (callTypeStr)
        {
            case "Metadata":
                await HandleMetadata(callId);
                break;
            case "Signature":
                await HandleSignature(callId);
                break;
        }
    }
    else if (callType.TryGetProperty("Run", out var runCall))
    {
        await HandleRun(callId, runCall);
    }
    else if (callType.TryGetProperty("CustomValueOp", out var customOp))
    {
        await HandleCustomValueOp(callId, customOp);
    }
}
```

## Command Implementation

### Metadata Response
```csharp
private async Task HandleMetadata(int callId)
{
    var response = new
    {
        CallResponse = new object[]
        {
            callId,
            new
            {
                Metadata = new
                {
                    version = "1.0.0"
                }
            }
        }
    };
    
    await SendResponse(response);
}
```

### Signature Response
```csharp
private async Task HandleSignature(int callId)
{
    var signatures = new[]
    {
        new
        {
            sig = new
            {
                name = "dn-obj",
                description = "Work with .NET objects",
                extra_description = "Create, manipulate and invoke .NET objects",
                search_terms = new[] { "dotnet", "object", "clr" },
                required_positional = new object[0],
                optional_positional = new[]
                {
                    new
                    {
                        name = "type_name",
                        desc = "The .NET type name to create",
                        shape = "String",
                        var_id = (object?)null,
                        default_value = (object?)null
                    }
                },
                rest_positional = (object?)null,
                named = new[]
                {
                    new
                    {
                        @long = "new",
                        @short = "n",
                        arg = (object?)null,
                        required = false,
                        desc = "Create a new instance",
                        var_id = (object?)null,
                        default_value = (object?)null
                    }
                },
                input_type = "Any",
                output_type = "Any",
                input_output_types = new object[0],
                allow_variants_without_examples = false,
                is_filter = false,
                creates_scope = false,
                allows_unknown_args = false,
                category = "Default"
            },
            examples = new[]
            {
                new
                {
                    example = "dn-obj System.String --new",
                    description = "Create a new string object",
                    result = CreateNuValue("System.String")
                }
            }
        }
    };
    
    var response = new
    {
        CallResponse = new object[]
        {
            callId,
            new { Signature = signatures }
        }
    };
    
    await SendResponse(response);
}
```

### Run Command Handler
```csharp
private async Task HandleRun(int callId, JsonElement runCall)
{
    try
    {
        var commandName = runCall.GetProperty("name").GetString();
        var call = runCall.GetProperty("call");
        var input = runCall.GetProperty("input");
        
        object result = commandName switch
        {
            "dn-obj" => await HandleDnObj(call, input),
            "dn-types" => await HandleDnTypes(call, input),
            _ => throw new InvalidOperationException($"Unknown command: {commandName}")
        };
        
        var response = new
        {
            CallResponse = new object[] { callId, result }
        };
        
        await SendResponse(response);
    }
    catch (Exception ex)
    {
        await SendError(callId, ex.Message, "plugin::execution_error");
    }
}
```

## .NET Object Handling

### Creating .NET Objects
```csharp
private async Task<object> HandleDnObj(JsonElement call, JsonElement input)
{
    var positional = call.GetProperty("positional");
    var named = call.GetProperty("named");
    
    // Get type name from positional args
    string? typeName = null;
    if (positional.GetArrayLength() > 0)
    {
        var firstArg = positional[0];
        if (firstArg.TryGetProperty("String", out var stringArg))
        {
            typeName = stringArg.GetProperty("val").GetString();
        }
    }
    
    // Check for --new flag
    bool createNew = false;
    foreach (var namedArg in named.EnumerateArray())
    {
        if (namedArg.GetArrayLength() == 2)
        {
            var flagName = namedArg[0].GetString();
            if (flagName == "new")
            {
                createNew = true;
                break;
            }
        }
    }
    
    if (string.IsNullOrEmpty(typeName))
    {
        throw new ArgumentException("Type name is required");
    }
    
    // Create .NET object
    var type = Type.GetType(typeName);
    if (type == null)
    {
        throw new ArgumentException($"Type '{typeName}' not found");
    }
    
    if (createNew)
    {
        var instance = Activator.CreateInstance(type);
        return new
        {
            Value = CreateCustomValue("DotNetObject", SerializeObject(instance))
        };
    }
    else
    {
        return new
        {
            Value = CreateNuValue(type.FullName)
        };
    }
}
```

### Custom Value Creation
```csharp
private object CreateCustomValue(string name, byte[] data)
{
    return new
    {
        Custom = new
        {
            val = new
            {
                type = "PluginCustomValue",
                name = name,
                data = data,
                notify_on_drop = false
            },
            span = new { start = 0, end = 0 }
        }
    };
}

private byte[] SerializeObject(object obj)
{
    if (obj == null) return new byte[0];
    
    // Simple serialization - in practice you'd use more sophisticated methods
    var json = JsonSerializer.Serialize(obj, _jsonOptions);
    return System.Text.Encoding.UTF8.GetBytes(json);
}
```

### Nu Value Creation Helpers
```csharp
private object CreateNuValue(string value)
{
    return new
    {
        String = new
        {
            val = value,
            span = new { start = 0, end = value.Length }
        }
    };
}

private object CreateNuValue(int value)
{
    return new
    {
        Int = new
        {
            val = value,
            span = new { start = 0, end = 0 }
        }
    };
}

private object CreateNuValue(bool value)
{
    return new
    {
        Bool = new
        {
            val = value,
            span = new { start = 0, end = 0 }
        }
    };
}

private object CreateNuRecord(Dictionary<string, object> fields)
{
    return new
    {
        Record = new
        {
            val = fields,
            span = new { start = 0, end = 0 }
        }
    };
}

private object CreateNuList(params object[] items)
{
    return new
    {
        List = new
        {
            vals = items,
            span = new { start = 0, end = 0 }
        }
    };
}
```

## Streaming Support

### Stream Response
```csharp
private async Task<object> HandleDnTypes(JsonElement call, JsonElement input)
{
    // Start a stream
    var streamId = GetNextStreamId();
    
    // Send stream header response
    var streamResponse = new
    {
        ListStream = new
        {
            id = streamId,
            span = new { start = 0, end = 0 }
        }
    };
    
    // Start background task to send stream data
    _ = Task.Run(async () => await SendTypeStream(streamId));
    
    return streamResponse;
}

private async Task SendTypeStream(int streamId)
{
    try
    {
        var assemblies = AppDomain.CurrentDomain.GetAssemblies();
        
        foreach (var assembly in assemblies)
        {
            foreach (var type in assembly.GetTypes())
            {
                var typeInfo = CreateNuRecord(new Dictionary<string, object>
                {
                    ["name"] = CreateNuValue(type.Name),
                    ["full_name"] = CreateNuValue(type.FullName ?? type.Name),
                    ["namespace"] = CreateNuValue(type.Namespace ?? ""),
                    ["is_public"] = CreateNuValue(type.IsPublic),
                    ["is_class"] = CreateNuValue(type.IsClass)
                });
                
                var streamData = new
                {
                    Data = new object[]
                    {
                        streamId,
                        new { List = typeInfo }
                    }
                };
                
                await SendResponse(streamData);
            }
        }
        
        // End stream
        var endMessage = new { End = streamId };
        await SendResponse(endMessage);
    }
    catch (Exception ex)
    {
        await Console.Error.WriteLineAsync($"Stream error: {ex.Message}");
    }
}
```

## Error Handling

### Error Response
```csharp
private async Task SendError(int callId, string message, string code = null, string help = null)
{
    var error = new
    {
        CallResponse = new object[]
        {
            callId,
            new
            {
                Error = new
                {
                    msg = message,
                    labels = new object[0],
                    code = code,
                    url = (object?)null,
                    help = help,
                    inner = new object[0]
                }
            }
        }
    };
    
    await SendResponse(error);
}

private async Task SendErrorWithLabel(int callId, string message, string labelText, int start, int end)
{
    var error = new
    {
        CallResponse = new object[]
        {
            callId,
            new
            {
                Error = new
                {
                    msg = message,
                    labels = new[]
                    {
                        new
                        {
                            text = labelText,
                            span = new { start = start, end = end }
                        }
                    },
                    code = (object?)null,
                    url = (object?)null,
                    help = (object?)null,
                    inner = new object[0]
                }
            }
        }
    };
    
    await SendResponse(error);
}
```

## Utility Methods

### Response Sending
```csharp
private async Task SendResponse(object response)
{
    var json = JsonSerializer.Serialize(response, _jsonOptions);
    await Console.Out.WriteLineAsync(json);
    await Console.Out.FlushAsync();
}
```

### Stream ID Management
```csharp
private int _nextStreamId = 1;

private int GetNextStreamId()
{
    return _nextStreamId++;
}
```

### Signal Handling
```csharp
private async Task HandleSignal(JsonElement signal)
{
    var signalType = signal.GetString();
    
    switch (signalType)
    {
        case "Interrupt":
            // Handle interrupt - cancel operations
            await Console.Error.WriteLineAsync("Received interrupt signal");
            break;
            
        case "Reset":
            // Reset plugin state
            _nextStreamId = 1;
            break;
    }
}
```

## Project Configuration

### .csproj File
```xml
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <OutputType>Exe</OutputType>
    <TargetFramework>net8.0</TargetFramework>
    <AssemblyName>nu_plugin_dotnet</AssemblyName>
    <RootNamespace>NuPluginDotNet</RootNamespace>
    <Nullable>enable</Nullable>
  </PropertyGroup>
  
  <ItemGroup>
    <PackageReference Include="System.Text.Json" Version="8.0.0" />
  </ItemGroup>
</Project>
```

### Directory Structure
```
nu-plugin-dotnet/
├── Program.cs
├── Plugin.cs
├── Commands/
│   ├── DnObjCommand.cs
│   ├── DnTypesCommand.cs
│   └── DnLoadAsmCommand.cs
├── Models/
│   ├── NuValue.cs
│   └── DotNetObject.cs
└── nu-plugin-dotnet.csproj
```

## Best Practices

### 1. Message Validation
Always validate incoming JSON messages and handle malformed data gracefully.

### 2. Error Reporting
Provide clear error messages with helpful context and suggestions.

### 3. Resource Management
Properly dispose of .NET objects and handle memory cleanup.

### 4. Type Safety
Use proper type checking when working with .NET reflection.

### 5. Performance
Use streaming for large datasets and avoid blocking operations.

### 6. Logging
Use stderr for diagnostic messages, not stdout (which is used for protocol communication).

## Testing

### Manual Testing
```bash
# Test plugin directly
echo '{"Hello":{"protocol":"nu-plugin","version":"0.94.0","features":[]}}' | ./nu_plugin_dotnet

# Test in nushell
plugin add ./nu_plugin_dotnet
plugin use dotnet
dn-obj System.String --new
```

### Unit Testing Example
```csharp
[Test]
public async Task TestHandleMetadata()
{
    var plugin = new MyPlugin();
    var callId = 1;
    
    // Capture output
    var output = new StringWriter();
    Console.SetOut(output);
    
    await plugin.HandleMetadata(callId);
    
    var result = output.ToString();
    Assert.That(result, Contains.Substring("Metadata"));
    Assert.That(result, Contains.Substring("1.0.0"));
}
```

This guide provides a complete foundation for implementing nushell plugins in .NET using the JSON protocol. 