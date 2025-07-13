# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

### Building
```bash
# Build entire solution (protocol library + main plugin + tests)
dotnet build NuPluginDotNet.sln

# Build just the main plugin
dotnet build nu-plugin-dotnet.csproj

# Build just the protocol library
dotnet build NuPluginDotNet.Protocol/

# Build for release (single-file deployment)
dotnet publish nu-plugin-dotnet.csproj -c Release
```

### Testing

#### .NET Unit Tests (Protocol Library)
```bash
# Run all .NET unit tests
dotnet test NuPluginDotNet.sln

# Run tests with verbose output
dotnet test NuPluginDotNet.sln -v normal

# Run specific test project
dotnet test NuPluginDotNet.Tests/

# Run tests with filtering
dotnet test --filter "FullyQualifiedName~ProtocolHandler"
```

#### Plugin Integration Tests (Modern Nushell Testing)
```bash
# Run all plugin tests (recommended)
nu run-tests.nu

# Quick validation (smoke tests)
nu run-tests.nu --suite smoke

# Run specific test categories
nu run-tests.nu --suite unit           # Core functionality
nu run-tests.nu --suite integration    # End-to-end scenarios
nu run-tests.nu --suite basic          # Basic object operations
nu run-tests.nu --suite assembly       # Assembly discovery
nu run-tests.nu --suite error          # Error handling
nu run-tests.nu --suite dll            # Custom DLL integration

# Performance testing
nu run-tests.nu --suite performance
```

#### Test Structure
- **`.NET Tests`** (`NuPluginDotNet.Tests/`): Protocol library unit tests
- **`Plugin Tests`** (`tests/`): Modern Nushell integration tests using `std assert`
- **`Legacy Tests`** (`examples/tests-legacy/`): Original test files (deprecated)

### Publishing
```bash
# Publish as single-file executable (configured in csproj)
dotnet publish nu-plugin-dotnet.csproj -c Release -o publish

# The executable will be named nu_plugin_dotnet.exe (required by nushell)
```

## Architecture Overview

This repository contains a dual-purpose project:

### 1. NuPluginDotNet.Protocol Library (`NuPluginDotNet.Protocol/`)
- **Purpose**: Reusable .NET library implementing the complete nushell plugin protocol
- **Key Interface**: `IPluginCommandHandler` with 3-4 methods (Signature, Metadata, Run, Signal)
- **Core Class**: `NushellProtocolHandler` handles all protocol complexity
- **Benefit**: Enables any .NET developer to create nushell plugins by implementing a simple interface

### 2. Main Plugin (`nu-plugin-dotnet.csproj`)
- **Purpose**: Full-featured nushell plugin for .NET integration
- **Commands**: `dotnet-obj`, `dotnet-call`, `dotnet-new`, `dotnet-load`, etc.
- **Built on**: Uses the Protocol library, demonstrating its usage

### Key Components

#### Protocol Layer (`NuPluginDotNet.Protocol/`)
- `NushellProtocolHandler.cs`: Complete protocol implementation
- `PluginTypes.cs`: Type definitions for protocol messages
- Handles JSON parsing, message routing, error handling, signal processing

#### Plugin Implementation (`src/`)
- `Commands/`: Individual command implementations (`DotNetNewCommand`, `DotNetCallCommand`, etc.)
- `DotNet/`: Core .NET integration (`AssemblyManager`, `ObjectManager`)
- `Types/`: Value conversion between .NET and nushell types
- `Plugin/PluginHost.cs`: Main plugin entry point using protocol library

#### Testing (`NuPluginDotNet.Tests/`)
- Uses xUnit framework
- Tests both protocol layer and plugin functionality
- Protocol-specific tests in `ProtocolHandlerTests.cs`

## Development Notes

### Protocol Library Design
The protocol library follows clean separation of concerns:
- **Before**: Monolithic 400+ line `RunAsync` method mixing protocol and business logic
- **After**: Clean `IPluginCommandHandler` interface + reusable `NushellProtocolHandler`

### Plugin Development Workflow
1. Implement `IPluginCommandHandler` interface
2. Use `NushellProtocolHandler` to handle protocol
3. Build as executable starting with `nu_plugin_` prefix
4. Register with nushell using `plugin add`

### Assembly Management
The plugin maintains strong references to .NET objects via `ObjectManager` to prevent garbage collection issues during complex workflows.

### Testing Strategy
- Unit tests for individual commands and protocol handling
- Integration tests for full plugin workflows
- Protocol compliance tests ensuring nushell compatibility

### Build Configuration
- Target: .NET 8.0
- Single-file deployment with self-contained runtime
- Assembly name: `nu_plugin_dotnet` (required by nushell)
- Compression enabled for smaller executable size