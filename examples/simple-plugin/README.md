# Simple Nushell Plugin Example

This example demonstrates how easy it is to create nushell plugins with .NET using the new `NushellProtocolHandler`.

## What This Example Shows

- **Clean Architecture**: Protocol handling is completely separated from business logic
- **Simple Interface**: Just implement `IPluginCommandHandler` with 3-4 methods
- **Easy Command Registration**: Register commands with simple dictionary mapping
- **Proper Error Handling**: Automatic conversion of exceptions to nushell errors
- **Protocol Compliance**: Full compliance with nushell plugin protocol

## Commands Provided

1. **hello** - Says hello to the world
2. **add** - Adds two numbers together
3. **greet** - Greets a person by name

## Building and Running

1. Build the plugin:
   ```bash
   cd examples/simple-plugin
   dotnet build
   ```

2. Publish as a single executable:
   ```bash
   dotnet publish -c Release
   ```

3. Register with nushell:
   ```bash
   nu> plugin add ./bin/Release/net8.0/win-x64/publish/nu_plugin_simple.exe
   ```

4. Use the commands:
   ```bash
   nu> hello
   nu> add 5 3
   nu> greet "Alice"
   ```

## Code Structure

### Main Entry Point
```csharp
public static async Task Main(string[] args)
{
    // Handle protocol requirements
    if (args.Length > 0 && args[0] == "--stdio")
    {
        Console.Write("\x04json");
        Console.Out.Flush();
    }

    // Create plugin and protocol handler
    var plugin = new SimplePlugin();
    var protocolHandler = new NushellProtocolHandler(plugin, debugEnabled: true);

    // Start the protocol
    await protocolHandler.RunProtocolAsync();
}
```

### Command Handler Interface
```csharp
public class SimplePlugin : IPluginCommandHandler
{
    public async Task<object> HandleSignatureAsync() { /* return signatures */ }
    public async Task<object> HandleMetadataAsync() { /* return metadata */ }
    public async Task<object> HandleRunAsync(JsonElement runElement) { /* execute commands */ }
}
```

## Key Benefits

1. **No Protocol Complexity**: The `NushellProtocolHandler` handles all protocol details
2. **Focus on Logic**: You only write your command logic
3. **Easy Testing**: Business logic can be unit tested independently
4. **Clean Code**: Clear separation of concerns
5. **Extensible**: Easy to add new commands

## Comparison with Traditional Approach

### Before (Monolithic)
- Mixed protocol and business logic
- Hard to test
- Complex error handling
- Protocol details scattered throughout code

### After (With Protocol Handler)
- Clean separation of concerns
- Easy to test business logic
- Automatic error handling
- Protocol complexity hidden

This example shows how the `NushellProtocolHandler` makes nushell plugin development in .NET much simpler and more maintainable. 