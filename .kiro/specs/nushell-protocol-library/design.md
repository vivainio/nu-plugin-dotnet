# Design Document

## Overview

The NuPluginDotNet.Protocol library implements a clean abstraction layer over the nushell plugin protocol, providing a simple interface for .NET developers to create nushell plugins. The design follows the principle of separation of concerns, where the library handles all protocol complexity while the plugin developer focuses solely on business logic.

## Architecture

The library follows a layered architecture pattern:

```
┌─────────────────────────────────────┐
│        Plugin Implementation       │
│    (implements IPluginCommandHandler)│
├─────────────────────────────────────┤
│      NushellProtocolHandler         │
│   (protocol communication layer)    │
├─────────────────────────────────────┤
│         Helper Classes              │
│  (NuValues, CommandHelpers, Types)  │
├─────────────────────────────────────┤
│         Nushell Process             │
│      (JSON protocol over stdio)     │
└─────────────────────────────────────┘
```

### Key Design Principles

1. **Single Responsibility**: Each class has one clear purpose
2. **Abstraction**: Complex protocol details are hidden from plugin developers
3. **Type Safety**: Strong typing with comprehensive IntelliSense support
4. **Error Resilience**: Graceful handling of all error conditions
5. **Debugging Support**: Comprehensive logging for troubleshooting

## Components and Interfaces

### Core Interface: IPluginCommandHandler

```csharp
public interface IPluginCommandHandler
{
    Task<SignatureResponse> HandleSignatureAsync();
    Task<MetadataResponse> HandleMetadataAsync();
    Task<object> HandleRunAsync(JsonElement runElement);
    Task HandleSignalAsync(JsonElement signalElement); // Optional with default implementation
}
```

**Design Rationale**: This interface provides the minimal surface area needed for plugin functionality while maintaining flexibility for different plugin types.

### Protocol Handler: NushellProtocolHandler

The main orchestrator class that manages the complete plugin lifecycle:

**Responsibilities**:
- Protocol handshaking (Hello message exchange)
- Message parsing and routing
- Error handling and conversion
- Debug logging
- Signal processing

**Key Methods**:
- `RunProtocolAsync()`: Main entry point that starts the protocol loop
- `SendHelloMessageAsync()`: Initiates protocol handshake
- `ProcessMessagesAsync()`: Main message processing loop
- `ProcessCallMessageAsync()`: Routes Call messages to appropriate handlers

### Helper Classes

#### NuValues
Static helper class providing factory methods for creating nushell-compatible values:

```csharp
public static class NuValues
{
    public static object String(string val, int start = 0, int end = 0);
    public static object Int(long val, int start = 0, int end = 0);
    public static object Float(double val, int start = 0, int end = 0);
    public static object Bool(bool val, int start = 0, int end = 0);
    public static object List(object[] vals, int start = 0, int end = 0);
    public static object Record(Dictionary<string, object> val, int start = 0, int end = 0);
    public static object Nothing(int start = 0, int end = 0);
    public static object Error(string msg);
}
```

#### CommandHelpers
Static helper class for creating command signatures:

```csharp
public static class CommandHelpers
{
    public static PositionalArg Positional(string name, string desc, object shape);
    public static NamedArg Named(string longName, string description, string? shortName = null, object? argType = null, bool required = false);
    public static CommandSignatureWrapper Command(string name, string description, /* ... parameters ... */);
}
```

## Data Models

### Response Types

```csharp
public class SignatureResponse
{
    public object[] Signature { get; set; } = Array.Empty<object>();
}

public class MetadataResponse
{
    public string version { get; set; } = "1.0.0";
}
```

### Command Signature Types

```csharp
public class CommandSignatureWrapper
{
    public required CommandSig sig { get; set; }
    public CommandExample[] examples { get; set; } = Array.Empty<CommandExample>();
}

public class CommandSig
{
    public required string name { get; set; }
    public required string description { get; set; }
    public string extra_description { get; set; } = "";
    public PositionalArg[] required_positional { get; set; } = Array.Empty<PositionalArg>();
    public PositionalArg[] optional_positional { get; set; } = Array.Empty<PositionalArg>();
    public NamedArg[] named { get; set; } = Array.Empty<NamedArg>();
    public string input_type { get; set; } = "Any";
    public string output_type { get; set; } = "Any";
    public string category { get; set; } = "Default";
    // ... additional properties
}
```

## Error Handling

### Error Handling Strategy

1. **Protocol Errors**: JSON parsing errors, invalid message formats
   - Caught at protocol level
   - Converted to nushell error format
   - Logged for debugging
   - Plugin continues running

2. **User Code Errors**: Exceptions in plugin implementation
   - Caught in message processing
   - Wrapped in CallErrorResponse
   - Stack trace logged if debugging enabled
   - Error details sanitized for user

3. **System Errors**: File I/O, network issues
   - Logged with full details
   - Graceful degradation where possible
   - Clear error messages to user

### Error Response Format

```csharp
private object CreateCallErrorResponse(int callId, string message)
{
    return new
    {
        CallResponse = new object[] { callId, CreateError(message) }
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
```

## Testing Strategy

### Unit Testing Approach

1. **Protocol Handler Tests**
   - Message parsing validation
   - Error handling verification
   - Response format validation
   - Signal processing tests

2. **Helper Class Tests**
   - NuValues output format validation
   - CommandHelpers signature generation
   - Type conversion accuracy

3. **Integration Tests**
   - End-to-end protocol communication
   - Real nushell interaction simulation
   - Error scenario testing

### Test Structure

```
NuPluginDotNet.Protocol.Tests/
├── Unit/
│   ├── NushellProtocolHandlerTests.cs
│   ├── NuValuesTests.cs
│   ├── CommandHelpersTests.cs
│   └── TypeTests.cs
├── Integration/
│   ├── ProtocolCommunicationTests.cs
│   └── ErrorHandlingTests.cs
└── TestHelpers/
    ├── MockPluginHandler.cs
    └── ProtocolTestUtilities.cs
```

### Testing Patterns

1. **Mock-based Testing**: Use mock IPluginCommandHandler implementations
2. **Callback Testing**: Utilize JsonSentCallback for verifying sent messages
3. **Scenario Testing**: Test complete protocol flows from start to finish
4. **Error Injection**: Deliberately trigger error conditions to verify handling

## Performance Considerations

### Memory Management
- Minimal object allocation in hot paths
- Proper disposal of JsonDocument instances
- Efficient string handling for large messages

### I/O Optimization
- Asynchronous I/O operations throughout
- Buffered console operations
- Minimal blocking operations

### Logging Performance
- Conditional logging to avoid string formatting overhead
- File I/O only when debugging enabled
- Structured logging for efficient parsing

## Security Considerations

### Input Validation
- All JSON input validated before processing
- Malformed messages handled gracefully
- No code execution from untrusted input

### Error Information Disclosure
- Stack traces only in debug mode
- Sanitized error messages in production
- No sensitive system information in errors

### Resource Protection
- Bounded message processing
- Timeout handling for long operations
- Memory usage monitoring

## Extensibility Design

### Plugin Interface Evolution
- Optional methods with default implementations
- Backward compatibility for interface changes
- Feature detection through protocol negotiation

### Protocol Version Support
- Version-aware message handling
- Graceful degradation for unsupported features
- Forward compatibility planning

### Custom Value Types
- Extensible type system through NuValues
- Plugin-specific value type support
- Type conversion framework