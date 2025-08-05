# nu-plugin-dotnet

A nushell plugin that enables .NET integration and provides a reusable protocol library for creating nushell plugins in .NET.

## Features

This plugin provides comprehensive .NET integration for nushell with two main components:

- **Complete .NET Object Integration** - Create, manipulate, and call methods on any .NET object
- **Assembly Loading** - Load .NET assemblies and explore their types and members  
- **Type Conversion** - Automatic conversion between nushell values and .NET types
- **Generic Type Support** - Work with generic types using user-friendly syntax
- **Reusable Protocol Library** - Create your own nushell plugins easily
- **Modern Testing** - Comprehensive test suite with nushell best practices
- **Cross-Platform** - Works on Windows, Linux, and macOS

## Installation

### Installing the Plugin

1. **Download or build the plugin**:
   ```bash
   # Clone the repository
   git clone https://github.com/vivainio/nu-plugin-dotnet.git
   cd nu-plugin-dotnet
   
   # Build the plugin
   dotnet publish -c Release -r win-x64 --self-contained true -p:PublishSingleFile=true -o ./publish/
   ```

2. **Register with nushell**:
   ```nushell
   # Register the plugin
   plugin add ./publish/nu_plugin_dotnet.exe
   
   # Verify installation
   plugin list | where name == "dotnet"
   ```

### Installing the Protocol Library

For creating your own plugins:

```bash
dotnet add package NuPluginDotNet.Protocol
```

## Usage

### Basic .NET Object Operations

```nushell
# Create .NET objects
let $datetime = dn new "System.DateTime" --args [2023, 12, 25]
let $list = dn new "List[string]"

# Call methods
$list | dn call "Add" "Hello"
$list | dn call "Add" "World"
$datetime | dn call "AddDays" 7

# Access properties
$list | dn get "Count"
$datetime | dn get "DayOfWeek"
```

### Assembly and Type Exploration

```nushell
# Load assemblies
dn load "path/to/your/library.dll"

# Explore loaded assemblies
dn assemblies

# List types
dn types | where name =~ "Http"

# Examine type members
dn members "System.String"
```

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

## Building and Testing This Repository

### Building

```bash
# Build the solution (includes protocol library and main plugin)
dotnet build NuPluginDotNet.sln

# Build just the protocol library
dotnet build NuPluginDotNet.Protocol/

# Build just the main plugin
dotnet build nu-plugin-dotnet.csproj

# Build for release (single-file deployment)
dotnet publish nu-plugin-dotnet.csproj -c Release

# Build the example
cd examples/simple-plugin
dotnet build
```

### Testing

This project uses modern Nushell testing patterns with `std assert` for reliable, maintainable tests.

#### Quick Start Testing

```bash
# Run all tests
nu run-tests.nu

# Quick validation (smoke tests)
nu run-tests.nu --suite smoke

# Run specific test categories
nu run-tests.nu --suite unit
nu run-tests.nu --suite integration
```

#### Available Test Suites

| Suite | Description | Purpose |
|-------|-------------|---------|
| `all` | Complete test suite | Full validation (default) |
| `smoke` | Quick functionality check | CI/CD validation |
| `unit` | Unit tests only | Core functionality |
| `integration` | Integration tests | End-to-end scenarios |
| `performance` | Performance benchmarks | Speed validation |

#### Individual Test Categories

```bash
# Basic functionality tests
nu run-tests.nu --suite basic

# Assembly and type discovery tests  
nu run-tests.nu --suite assembly

# Error handling and edge cases
nu run-tests.nu --suite error

# Custom DLL integration tests
nu run-tests.nu --suite dll
```

#### Test Structure

```
tests/
├── mod.nu                          # Main test module
├── unit/                           # Unit tests
│   ├── basic-functionality.nu      # Object creation, method calls
│   ├── assembly-operations.nu      # Assembly/type discovery  
│   └── error-handling.nu          # Error cases and validation
├── integration/                    # Integration tests
│   └── custom-dll.nu              # End-to-end DLL scenarios
└── simple-modern-tests.nu         # Standalone modern test example
```

#### Modern Testing Features

Our test suite demonstrates Nushell testing best practices:

- ✅ **`std assert`** - Official Nushell assertion library
- ✅ **AAA Pattern** - Arrange, Act, Assert structure
- ✅ **Descriptive Names** - Clear test descriptions
- ✅ **Error Testing** - Comprehensive error validation
- ✅ **Conditional Tests** - Skip tests when dependencies unavailable
- ✅ **Modular Structure** - Organized by functionality
- ✅ **CI/CD Ready** - Exit codes and automation support

#### Example Test Output

```
🧪 Nu Plugin .NET - Comprehensive Test Suite
=============================================

✅ Plugin verified and available

🎯 Running Basic Functionality Tests
====================================
🧪 Running 18 basic functionality tests...

  ✅ test dn-new creates StringBuilder
  ✅ test dn-new creates ArrayList
  ✅ test dn-call static Math.Max
  ✅ test dn-get string Length
  ...

📊 Basic Tests: 18 passed, 0 failed
✅ All basic functionality tests passed!

📊 FINAL TEST SUMMARY
=====================
🎉 ALL TEST SUITES PASSED!

✅ Plugin Status: PRODUCTION READY
✅ All core functionality verified
✅ Error handling robust
✅ Custom DLL integration working
```

#### CI/CD Integration

The test suite is designed for automation:

```yaml
# GitHub Actions example
- name: Run Tests
  run: |
    nu run-tests.nu --suite smoke  # Quick validation
    nu run-tests.nu --suite all    # Full test suite
```

#### Writing New Tests

Follow modern Nushell patterns:

```nu
use std assert

def "test my new feature" [] {
    # Arrange
    let input = "test data"
    
    # Act
    let result = (dn new "MyType")
    
    # Assert
    assert ($result | str contains "expected")
}
```

For more details, see `docs/testing-best-practices.md`.

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
