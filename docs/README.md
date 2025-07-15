# Nushell Plugin Documentation

This directory contains comprehensive documentation for implementing nushell plugins, with a focus on the JSON protocol specification and practical implementation examples.

## Available Documentation

### 📋 [JSON Protocol Specification](json-protocol-specification.md)
Complete reference for the JSON-based communication protocol between nushell and plugins. This document covers:
- Protocol handshake and message types
- All data types and value formats
- Stream handling and engine calls
- Error handling patterns
- Best practices for protocol implementation

### 📝 [JSON Examples and Samples](plugin-json-examples.md)
Concrete JSON examples showing real message exchanges between nushell and plugins. Includes:
- Complete plugin session examples
- Error handling scenarios
- Data type demonstrations
- Streaming examples
- Engine call examples
- Custom value operations

### 🛠️ [.NET Plugin Implementation Guide](dotnet-plugin-implementation-guide.md)
Practical guide for implementing nushell plugins in .NET with complete code examples:
- Basic plugin structure and templates
- Message processing and command handling
- .NET object manipulation
- Streaming support
- Error handling
- Project configuration and best practices

### 📖 [General Plugin Protocol Reference](nushell-plugin-protocol-reference.md)
General overview of the nushell plugin system covering:
- Plugin requirements and lifecycle
- Communication modes (stdio/socket)
- Version compatibility
- Security considerations
- Performance tips

## Quick Start

If you're implementing a .NET plugin:
1. Start with the [.NET Plugin Implementation Guide](dotnet-plugin-implementation-guide.md)
2. Reference the [JSON Protocol Specification](json-protocol-specification.md) for details
3. Use the [JSON Examples](plugin-json-examples.md) for concrete implementation patterns

If you're implementing a plugin in another language:
1. Begin with the [JSON Protocol Specification](json-protocol-specification.md)
2. Study the [JSON Examples](plugin-json-examples.md) for message formats
3. Follow the patterns shown in the .NET guide, adapted to your language

## Protocol Overview

Nushell plugins communicate via JSON messages over stdin/stdout or local sockets. The basic flow is:

1. **Handshake**: Plugin declares encoding type, exchanges Hello messages
2. **Registration**: Engine requests plugin signature (available commands)
3. **Execution**: Engine sends Run commands, plugin responds with results
4. **Cleanup**: Engine sends Goodbye message when shutting down

### Message Types

- **Hello**: Version and feature negotiation
- **Call**: Engine requests (Metadata, Signature, Run, CustomValueOp)
- **CallResponse**: Plugin responses (Value, Error, Stream)
- **Signal**: Interrupt/Reset notifications
- **EngineCall**: Plugin requests to engine (GetConfig, GetEnvVar, etc.)
- **Stream**: Data streaming (Data, End, Ack, Drop)

### Key Concepts

- **Spans**: Source code position information for error reporting
- **Custom Values**: Plugin-specific data types that can be passed between commands
- **Streaming**: Efficient handling of large datasets
- **Engine Calls**: Plugin access to nushell engine functionality

## Getting Help

- For protocol questions, see the [JSON Protocol Specification](json-protocol-specification.md)
- For implementation examples, check the [JSON Examples](plugin-json-examples.md)
- For .NET-specific guidance, use the [.NET Implementation Guide](dotnet-plugin-implementation-guide.md)
- For general plugin concepts, refer to the [Protocol Reference](nushell-plugin-protocol-reference.md)

## External Resources

- [Official Nushell Plugin Documentation](https://www.nushell.sh/book/plugins.html)
- [Nushell Plugin Protocol Reference](https://www.nushell.sh/contributor-book/plugin_protocol_reference.html)
- [Nu Plugin Rust Crate](https://docs.rs/nu-plugin/latest/nu_plugin/)
- [Nu Protocol Documentation](https://docs.rs/nu-protocol/latest/nu_protocol/) 