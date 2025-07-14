# nu-plugin-dotnet

A nushell plugin that enables .NET integration and provides a reusable protocol library for creating nushell plugins in .NET.

## Maintenance status

This research project is currently **on hold** as there is to stable JSON api for Nushell plugins at this time. It would not be feasible to
maintain this across protocol compatibility breaks.

## Project Structure

This repository contains two main components:

### 1. NuPluginDotNet.Protocol Library

A standalone .NET library that implements the complete nushell plugin protocol, making it incredibly easy for .NET developers to create nushell plugins.

**Location**: `NuPluginDotNet.Protocol/`

**Features**:
- ✅ Complete nushell plugin protocol implementation
- ✅ Simple 3-method interface (`IPluginCommandHandler`)
- ✅ Automatic error handling and JSON parsing
- ✅ Debug logging support
- ✅ Signal handling (Interrupt, Reset)
- ✅ Reusable across any .NET nushell plugin

**Installation**:
```bash
dotnet add package NuPluginDotNet.Protocol
```

### 2. Main .NET Plugin

The original nu-plugin-dotnet that provides .NET integration commands for nushell, now refactored to use the protocol library.

**Location**: Root directory

**Commands**:
- `dn new` - Create new .NET objects
- `dn call` - Call methods on .NET objects
- `dn get` - Get properties/fields from .NET objects
- `dn set` - Set properties/fields on .NET objects
- `dn obj` - Create and manipulate .NET objects
- `dn load` - Load .NET assemblies
- `dn assemblies` - List loaded assemblies
- `dn types` - List types in assemblies
- `dn members` - List members of types

## Quick Start - Creating Your Own Plugin

With the `NuPluginDotNet.Protocol` library, creating a nushell plugin is incredibly simple:

### 1. Create a New Project

```bash
dotnet new console -n MyNushellPlugin
cd MyNushellPlugin
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
        return new object[] {
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
        // Your command logic here
        return new {
            String = new {
                val = $"Hello from {name}!",
                span = new { start = 0, end = 0 }
            }
        };
    }
}

public static async Task Main(string[] args)
{
    if (args.Length > 0 && args[0] == "--stdio")
    {
        Console.Write("\x04json");
        Console.Out.Flush();
    }

    var plugin = new MyPlugin();
    var protocolHandler = new NushellProtocolHandler(plugin, debugEnabled: true);
    await protocolHandler.RunProtocolAsync();
}
```

### 3. Build and Register

```bash
# Build (executable must start with 'nu_plugin_')
dotnet publish -c Release -o publish
mv publish/MyNushellPlugin.exe publish/nu_plugin_myplugin.exe

# Register with nushell
nu> plugin add ./publish/nu_plugin_myplugin.exe
```

## Examples

See the `examples/` directory for complete working examples:

- **Simple Plugin** (`examples/simple-plugin/`): Demonstrates basic plugin creation with hello, add, and greet commands

## Building This Repository

```bash
# Build the solution (includes protocol library and main plugin)
dotnet build NuPluginDotNet.sln

# Build just the protocol library
dotnet build NuPluginDotNet.Protocol/

# Build just the main plugin
dotnet build nu-plugin-dotnet.csproj

# Build the example
cd examples/simple-plugin
dotnet build
```

## Architecture

The protocol library provides a clean separation of concerns:

```
┌─────────────────────────────────────┐
│           Your Plugin               │
│    (implements IPluginCommandHandler)│
├─────────────────────────────────────┤
│      NushellProtocolHandler         │
│   (handles all protocol details)    │
├─────────────────────────────────────┤
│         Nushell Process             │
│      (JSON protocol over stdio)     │
└─────────────────────────────────────┘
```

**Before**: Monolithic 400+ line `RunAsync` method mixing protocol and business logic

**After**: 
- Clean `IPluginCommandHandler` interface (3-4 methods)
- Reusable `NushellProtocolHandler` (handles all protocol complexity)
- Your plugin focuses only on business logic

## Documentation

- **Protocol Library**: See `NuPluginDotNet.Protocol/README.md`
- **Architecture Details**: See `docs/PROTOCOL_HANDLER.md`
- **Nushell Plugin Protocol**: [Official Documentation](https://www.nushell.sh/contributor-book/plugin_protocol_reference.html)

## Requirements

- .NET 8.0 or later
- Nushell 0.104.0 or later

## Contributing

Contributions are welcome! Please feel free to submit issues and pull requests.

## License

MIT License - see LICENSE file for details.
