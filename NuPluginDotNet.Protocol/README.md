# NuPluginDotNet.Protocol

A .NET library that implements the [nushell plugin protocol](https://www.nushell.sh/contributor-book/plugin_protocol_reference.html), making it incredibly easy to create nushell plugins in .NET.

## Overview

This library handles all the complexity of the nushell plugin protocol, allowing you to focus on your plugin's business logic. Simply implement the `IPluginCommandHandler` interface and let the `NushellProtocolHandler` manage all communication with nushell.

## Features

- ✅ **Complete Protocol Implementation** - Handles all nushell plugin protocol requirements
- ✅ **Simple Interface** - Just implement 3-4 methods to create a working plugin
- ✅ **Error Handling** - Automatic error handling and conversion to nushell format
- ✅ **Debug Logging** - Optional logging for troubleshooting protocol communication
- ✅ **Signal Support** - Handle Interrupt (Ctrl+C) and Reset signals
- ✅ **Type Safe** - Strongly typed with full IntelliSense support

## Quick Start

### 1. Install the Package

```bash
dotnet add package NuPluginDotNet.Protocol
```

### 2. Implement the Interface

```csharp
using NuPluginDotNet.Protocol;
using System.Text.Json;

public class MyPlugin : IPluginCommandHandler
{
    public async Task<object> HandleSignatureAsync()
    {
        // Return your command signatures
        return new[] {
            new {
                sig = new {
                    name = "my-command",
                    description = "My custom command",
                    // ... signature details
                }
            }
        };
    }

    public async Task<object> HandleMetadataAsync()
    {
        return new { version = "1.0.0" };
    }

    public async Task<object> HandleRunAsync(JsonElement runElement)
    {
        var name = runElement.GetProperty("name").GetString();
        // Execute your command logic here
        return new {
            String = new {
                val = $"Hello from {name}!",
                span = new { start = 0, end = 0 }
            }
        };
    }
}
```

### 3. Create Main Entry Point

```csharp
public static async Task Main(string[] args)
{
    // Handle nushell protocol requirements
    if (args.Length > 0 && args[0] == "--stdio")
    {
        Console.Write("\x04json");
        Console.Out.Flush();
    }

    // Create plugin and start protocol
    var plugin = new MyPlugin();
    var protocolHandler = new NushellProtocolHandler(plugin, debugEnabled: true);
    await protocolHandler.RunProtocolAsync();
}
```

### 4. Build and Register

```bash
# Build your plugin
dotnet publish -c Release

# Register with nushell (executable must start with 'nu_plugin_')
nu> plugin add ./bin/Release/net8.0/publish/nu_plugin_myplugin.exe
```

## Interface Reference

### IPluginCommandHandler

```csharp
public interface IPluginCommandHandler
{
    /// <summary>
    /// Handle the Signature call - return command signatures.
    /// Called when nushell wants to know what commands your plugin provides.
    /// </summary>
    Task<object> HandleSignatureAsync();
    
    /// <summary>
    /// Handle the Metadata call - return plugin metadata.
    /// Called when nushell wants information about your plugin.
    /// </summary>
    Task<object> HandleMetadataAsync();
    
    /// <summary>
    /// Handle the Run call - execute a command.
    /// Called when nushell wants to execute one of your commands.
    /// </summary>
    Task<object> HandleRunAsync(JsonElement runElement);
    
    /// <summary>
    /// Handle Signal messages (optional - default implementation does nothing).
    /// Called when nushell sends signals like Interrupt (Ctrl+C) or Reset.
    /// </summary>
    Task HandleSignalAsync(JsonElement signalElement) => Task.CompletedTask;
}
```

## What This Library Handles

The `NushellProtocolHandler` automatically manages:

- **Encoding Negotiation** - Proper protocol setup
- **Hello Message Exchange** - Protocol version and feature negotiation  
- **Call/Response Routing** - Routing messages to your handlers
- **Error Handling** - Converting exceptions to nushell error format
- **Signal Processing** - Handling Interrupt and Reset signals
- **Message Parsing** - JSON parsing and validation
- **Logging** - Optional debug logging for troubleshooting

## Debugging

Enable debug logging to see all protocol communication:

```csharp
var protocolHandler = new NushellProtocolHandler(plugin, debugEnabled: true);
```

Debug logs are written to: `%TEMP%/nu-plugin-protocol-debug.log`

## Complete Example

See the [examples directory](https://github.com/nushell/nu-plugin-dotnet/tree/main/examples) for complete working examples.

## Requirements

- .NET 8.0 or later
- Nushell 0.104.0 or later

## License

MIT License - see LICENSE file for details.

## Contributing

Contributions are welcome! Please see the main repository for contributing guidelines. 