# Nushell Plugin Protocol Handler

## Overview

The `NushellProtocolHandler` is a complete implementation of the [nushell plugin protocol](https://www.nushell.sh/contributor-book/plugin_protocol_reference.html) that makes it incredibly easy for .NET developers to create nushell plugins. 

By extracting all the protocol complexity into a separate class, developers can focus on their business logic while the protocol handler manages all communication with nushell.

## Architecture

### Before (Monolithic)
```
┌─────────────────────────────────────────┐
│               PluginHost                │
│  ┌─────────────────────────────────────┐ │
│  │        Protocol Logic              │ │
│  │  • JSON parsing                    │ │
│  │  • Message routing                 │ │
│  │  • Hello handshake                 │ │
│  │  • Call/Response handling          │ │
│  │  • Error management                │ │
│  └─────────────────────────────────────┘ │
│  ┌─────────────────────────────────────┐ │
│  │        Business Logic              │ │
│  │  • Command execution               │ │
│  │  • Assembly management             │ │
│  │  • Value conversion                │ │
│  └─────────────────────────────────────┘ │
└─────────────────────────────────────────┘
```

### After (Separated)
```
┌─────────────────────────────────────────┐
│        NushellProtocolHandler          │
│  • JSON parsing                        │
│  • Message routing                     │
│  • Hello handshake                     │
│  • Call/Response handling              │
│  • Error management                    │
│  • Signal handling                     │
└─────────────────────────────────────────┘
                    │
                    │ IPluginCommandHandler
                    ▼
┌─────────────────────────────────────────┐
│           Your Plugin Logic             │
│  • HandleSignatureAsync()              │
│  • HandleMetadataAsync()               │
│  • HandleRunAsync()                    │
│  • HandleSignalAsync() [optional]      │
└─────────────────────────────────────────┘
```

## Benefits

1. **Clean Separation**: Protocol logic is completely separated from business logic
2. **Easy to Use**: Implement just 3-4 methods to create a working plugin
3. **Protocol Compliance**: Automatically handles all nushell protocol requirements
4. **Error Handling**: Built-in error handling and logging
5. **Extensible**: Easy to add new features without touching protocol code
6. **Testable**: Business logic can be unit tested independently
7. **Reusable**: Protocol handler can be used by any .NET nushell plugin

## Quick Start

### 1. Implement the Interface

```csharp
using NuPluginDotNet.Plugin;
using System.Text.Json;

public class MyPlugin : IPluginCommandHandler
{
    public async Task<object> HandleSignatureAsync()
    {
        // Return your command signatures
        return new[] { /* your signatures */ };
    }

    public async Task<object> HandleMetadataAsync()
    {
        // Return plugin metadata
        return new { version = "1.0.0" };
    }

    public async Task<object> HandleRunAsync(JsonElement runElement)
    {
        // Execute commands
        var name = runElement.GetProperty("name").GetString();
        // ... your command logic
        return result;
    }
}
```

### 2. Create Main Entry Point

```csharp
public static async Task Main(string[] args)
{
    // Handle nushell protocol requirements
    if (args.Length > 0 && args[0] == "--stdio")
    {
        Console.Write("\x04json");
        Console.Out.Flush();
    }

    // Create plugin and protocol handler
    var plugin = new MyPlugin();
    var protocolHandler = new NushellProtocolHandler(plugin, debugEnabled: true);

    // Start the protocol
    await protocolHandler.RunProtocolAsync();
}
```

### 3. That's It!

Your plugin is now ready to work with nushell. The protocol handler takes care of:
- Encoding negotiation
- Hello message exchange
- Call/Response routing
- Error handling
- Signal processing
- Logging (if enabled)

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

## Advanced Usage

### Custom Protocol Handler

You can extend the protocol handler for specialized use cases:

```csharp
public class CustomProtocolHandler : NushellProtocolHandler
{
    public CustomProtocolHandler(IPluginCommandHandler handler) 
        : base(handler, debugEnabled: true) 
    {
    }

    // Override methods to customize behavior
}
```

### Error Handling

The protocol handler automatically converts exceptions to nushell error format:

```csharp
public async Task<object> HandleRunAsync(JsonElement runElement)
{
    try
    {
        // Your command logic
        return result;
    }
    catch (Exception ex)
    {
        // Exception is automatically converted to nushell error format
        throw; // or return CreateError(ex.Message)
    }
}
```

### Logging and Debugging

Enable debug logging to see all protocol communication:

```csharp
var protocolHandler = new NushellProtocolHandler(plugin, debugEnabled: true);
```

Debug logs are written to: `%TEMP%/nu-plugin-protocol-debug.log`

## Protocol Implementation Details

The `NushellProtocolHandler` implements the complete nushell plugin protocol specification:

### Message Flow
1. **Encoding Declaration**: `\x04json` sent on startup
2. **Hello Exchange**: Protocol version and feature negotiation
3. **Call Processing**: Handle Signature, Metadata, and Run calls
4. **Response Generation**: Proper CallResponse format with call IDs
5. **Signal Handling**: Process Interrupt and Reset signals
6. **Graceful Shutdown**: Handle Goodbye messages

### Supported Message Types
- **Hello**: Protocol handshake
- **Call**: Command execution requests
- **Signal**: Interrupt and reset signals
- **Goodbye**: Graceful shutdown

### Error Handling
- JSON parsing errors
- Command execution errors
- Protocol violations
- Exception propagation

## Migration Guide

### From Old PluginHost

If you're migrating from the old monolithic `PluginHost`, here's what changed:

**Before:**
```csharp
public class PluginHost
{
    public async Task RunAsync()
    {
        // Mixed protocol and business logic
    }
}
```

**After:**
```csharp
public class MyPlugin : IPluginCommandHandler
{
    // Only business logic methods
    public async Task<object> HandleSignatureAsync() { ... }
    public async Task<object> HandleMetadataAsync() { ... }
    public async Task<object> HandleRunAsync(JsonElement runElement) { ... }
}

// In Main:
var handler = new NushellProtocolHandler(new MyPlugin());
await handler.RunProtocolAsync();
```

## Examples

See the complete examples in:
- `examples/SimplePluginExample.cs` - Basic plugin with multiple commands
- `src/Plugin/PluginHost.cs` - Full-featured plugin using the protocol handler

## Best Practices

1. **Keep Business Logic Separate**: Don't mix protocol concerns with your command logic
2. **Use Async/Await**: All interface methods are async for good reason
3. **Handle Errors Gracefully**: Let exceptions bubble up or return error objects
4. **Enable Debugging**: Use debug logging during development
5. **Test Independently**: Unit test your IPluginCommandHandler implementation
6. **Follow Conventions**: Use proper nushell value formats in responses

## Troubleshooting

### Common Issues

1. **Plugin Not Recognized**: Ensure executable name starts with `nu_plugin_`
2. **Protocol Errors**: Enable debug logging to see message exchange
3. **Command Not Found**: Check your signature definitions
4. **Value Format Errors**: Ensure you're returning proper nushell value objects

### Debug Logging

Enable debug logging and check the log file:
```csharp
var handler = new NushellProtocolHandler(plugin, debugEnabled: true);
```

Log file location: `%TEMP%/nu-plugin-protocol-debug.log`

## Conclusion

The `NushellProtocolHandler` dramatically simplifies nushell plugin development in .NET by:
- Handling all protocol complexity
- Providing a clean, simple interface
- Enabling easy testing and debugging
- Following separation of concerns principles

This makes it much easier for .NET developers to create powerful nushell plugins without needing to understand the intricate details of the nushell plugin protocol. 