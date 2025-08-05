# Design Document

## Overview

The main .NET plugin is designed as a comprehensive bridge between nushell and the .NET ecosystem. It leverages the NuPluginDotNet.Protocol library for all protocol communication while focusing on the core business logic of .NET integration. The design follows a modular architecture with clear separation of concerns between different functional areas.

## Architecture

The plugin follows a layered architecture with dependency injection and clear module boundaries:

```
┌─────────────────────────────────────┐
│            Program.cs               │
│        (Entry Point)                │
├─────────────────────────────────────┤
│           PluginHost                │
│    (IPluginCommandHandler)          │
├─────────────────────────────────────┤
│        CommandRegistry              │
│      (Command Routing)              │
├─────────────────────────────────────┤
│          Commands Layer             │
│  (DotNetNewCommand, CallCommand,    │
│   GetCommand, SetCommand, etc.)     │
├─────────────────────────────────────┤
│         Core Services               │
│ (ObjectManager, AssemblyManager,    │
│  ValueConverter, ReflectionHelper)  │
├─────────────────────────────────────┤
│      NuPluginDotNet.Protocol        │
│     (Protocol Communication)        │
└─────────────────────────────────────┘
```

### Key Design Principles

1. **Separation of Concerns**: Protocol handling is delegated to the protocol library
2. **Modular Design**: Each functional area is encapsulated in its own module
3. **Type Safety**: Strong typing throughout with comprehensive error handling
4. **Performance**: Efficient object management and caching strategies
5. **Extensibility**: Easy to add new commands and functionality

## Components and Interfaces

### Entry Point: Program.cs

```csharp
public class Program
{
    public static async Task<int> Main(string[] args)
    {
        // Send encoding declaration as required by nushell protocol
        // Initialize and run PluginHost
    }
}
```

**Responsibilities**:
- Protocol encoding setup
- PluginHost initialization
- Top-level error handling

### Plugin Host: PluginHost.cs

```csharp
public class PluginHost : IPluginCommandHandler
{
    public async Task<SignatureResponse> HandleSignatureAsync();
    public async Task<MetadataResponse> HandleMetadataAsync();
    public async Task<object> HandleRunAsync(JsonElement runElement);
    public async Task HandleSignalAsync(JsonElement signalElement);
}
```

**Responsibilities**:
- Implement IPluginCommandHandler interface
- Initialize core services (ObjectManager, AssemblyManager, ValueConverter)
- Route commands to CommandRegistry
- Convert between protocol format and internal types

### Command Registry: CommandRegistry.cs

```csharp
public class CommandRegistry
{
    public object[] GetSignatures();
    public async Task<PluginValue> ExecuteAsync(string commandName, PluginCall call);
}
```

**Responsibilities**:
- Register all available commands
- Route command execution to appropriate command handlers
- Provide command signatures for nushell

### Core Services

#### ObjectManager

```csharp
public class ObjectManager
{
    public string RegisterObject(object obj);
    public object GetObject(string objectId);
    public void DisposeObject(string objectId);
    public void CollectGarbage();
}
```

**Design Features**:
- Thread-safe object storage using ConcurrentDictionary
- Unique ID generation for object references
- Weak references to allow garbage collection
- Automatic disposal for IDisposable objects

#### AssemblyManager

```csharp
public class AssemblyManager
{
    public Assembly LoadAssembly(string assemblyPath);
    public Assembly LoadAssemblyByName(string assemblyName);
    public Type? FindType(string typeName);
    public Assembly[] GetLoadedAssemblies();
}
```

**Design Features**:
- Isolated AssemblyLoadContext for plugin assemblies
- Assembly caching to prevent duplicate loading
- Dependency resolution with fallback strategies
- Type discovery across all loaded assemblies

#### ValueConverter

```csharp
public class ValueConverter
{
    public object ConvertToClr(PluginValue nushellValue, Type targetType);
    public PluginValue ConvertFromClr(object clrObject);
}
```

**Design Features**:
- Bidirectional conversion between nushell and .NET types
- Support for complex types including generics
- Custom object handling with object ID references
- Comprehensive error handling for conversion failures

## Data Models

### PluginValue System

```csharp
public class PluginValue
{
    public PluginValueType Type { get; set; }
    public object? Value { get; set; }
    public bool IsCustom => Type == PluginValueType.Custom;
    
    public static PluginValue Custom(string objectId, string typeName);
    public string GetObjectId();
    public string GetTypeName();
}

public enum PluginValueType
{
    Nothing, String, Int, Float, Bool, List, Record, Binary, Custom, Error
}
```

### Command System

```csharp
public class PluginCall
{
    public CommandHead Head { get; set; }
    public List<PluginValue> Positional { get; set; }
    public Dictionary<string, PluginValue> Named { get; set; }
    public PluginValue? Input { get; set; }
}

public class CommandArgs
{
    public string GetPositionalString(int index);
    public List<PluginValue>? GetOptionalList(string name);
    public string? GetOptionalString(string name);
}
```

## Command Implementation Design

### Base Command Pattern

```csharp
public abstract class BaseCommand
{
    protected ObjectManager ObjectManager { get; }
    protected AssemblyManager AssemblyManager { get; }
    protected ValueConverter ValueConverter { get; }
    
    public abstract Task<PluginValue> ExecuteAsync(CommandArgs args);
    protected PluginValue CreateError(string message, Exception? ex = null);
}
```

### Specific Commands

#### DotNetNewCommand
- **Purpose**: Create .NET object instances
- **Key Features**:
  - Generic type syntax conversion (List[string] → List`1[System.String])
  - Constructor overload resolution
  - Assembly loading on demand
  - Object registration for lifetime management

#### DotNetCallCommand
- **Purpose**: Invoke methods on objects or static methods on types
- **Key Features**:
  - Instance vs static method detection
  - Method overload resolution
  - Async method handling (Task unwrapping)
  - Generic method support
  - Parameter type conversion

#### DotNetGetCommand / DotNetSetCommand
- **Purpose**: Property and field access
- **Key Features**:
  - Property vs field detection
  - Indexed property support
  - Type conversion for set operations
  - Read-only property handling

## Error Handling Strategy

### Exception Hierarchy

```csharp
public class PluginError
{
    public string Message { get; set; }
    public string? Type { get; set; }
    public string? StackTrace { get; set; }
    public PluginError? InnerException { get; set; }
}
```

### Error Handling Levels

1. **Protocol Level**: Handled by NuPluginDotNet.Protocol
   - JSON parsing errors
   - Invalid message formats
   - Communication failures

2. **Command Level**: Handled by individual commands
   - Type not found errors
   - Method resolution failures
   - Parameter conversion errors

3. **Service Level**: Handled by core services
   - Assembly loading failures
   - Object lifetime issues
   - Type conversion problems

### Error Response Format

All errors are converted to nushell-compatible format:

```csharp
private object FormatErrorValue(PluginValue errorValue)
{
    return new {
        Error = new {
            msg = "Plugin execution error",
            help = detailedMessage,
            labels = new[] {
                new {
                    text = errorMessage,
                    span = new { start = 0, end = 0 }
                }
            }
        }
    };
}
```

## Type Conversion Design

### Conversion Strategy

The type conversion system handles bidirectional conversion between nushell's dynamic type system and .NET's static type system:

#### Nushell → .NET Conversion

```csharp
public object ConvertToClr(PluginValue nushellValue, Type targetType)
{
    return nushellValue.Type switch
    {
        PluginValueType.String => ConvertString(nushellValue.Value, targetType),
        PluginValueType.Int => ConvertInteger(nushellValue.Value, targetType),
        PluginValueType.Float => ConvertFloat(nushellValue.Value, targetType),
        PluginValueType.List => ConvertList(nushellValue.Value, targetType),
        PluginValueType.Record => ConvertRecord(nushellValue.Value, targetType),
        PluginValueType.Custom => ResolveCustomObject(nushellValue),
        _ => throw new InvalidOperationException($"Cannot convert {nushellValue.Type} to {targetType}")
    };
}
```

#### .NET → Nushell Conversion

```csharp
public PluginValue ConvertFromClr(object clrObject)
{
    return clrObject switch
    {
        null => new PluginValue { Type = PluginValueType.Nothing },
        string s => new PluginValue { Type = PluginValueType.String, Value = s },
        int or long or short or byte => new PluginValue { Type = PluginValueType.Int, Value = Convert.ToInt64(clrObject) },
        float or double or decimal => new PluginValue { Type = PluginValueType.Float, Value = Convert.ToDouble(clrObject) },
        bool b => new PluginValue { Type = PluginValueType.Bool, Value = b },
        IEnumerable enumerable => ConvertEnumerable(enumerable),
        _ => ConvertToCustomObject(clrObject)
    };
}
```

## Generic Type Support

### User-Friendly Generic Syntax

The plugin supports user-friendly generic type syntax that gets converted to .NET's internal format:

```csharp
public static class GenericTypeConverter
{
    public static string ConvertToInternalTypeName(string userTypeName)
    {
        // Convert "List[string]" to "System.Collections.Generic.List`1[System.String]"
        // Convert "Dictionary[string,int]" to "System.Collections.Generic.Dictionary`2[System.String,System.Int32]"
    }
}
```

### Generic Method Support

Generic methods are handled through type inference and explicit type parameter specification:

```csharp
private MethodInfo ConstructGenericMethod(MethodInfo genericMethod, Type[] typeArguments)
{
    return genericMethod.MakeGenericMethod(typeArguments);
}
```

## Performance Considerations

### Object Caching
- Assembly caching to avoid repeated loading
- Type resolution caching for frequently used types
- Method info caching for reflection performance

### Memory Management
- Weak references in ObjectManager to allow garbage collection
- Proper disposal of IDisposable objects
- Assembly unloading support for long-running scenarios

### Async Operations
- Full async/await support throughout the pipeline
- Task unwrapping for async .NET methods
- Non-blocking I/O operations

## Testing Strategy

### Unit Testing Approach

1. **Command Tests**: Test each command in isolation with mock dependencies
2. **Service Tests**: Test core services (ObjectManager, AssemblyManager, ValueConverter)
3. **Integration Tests**: Test complete command flows with real .NET objects
4. **Error Handling Tests**: Verify proper error handling and formatting

### Test Structure

```
tests/
├── unit/
│   ├── Commands/
│   │   ├── DotNetNewCommandTests.cs
│   │   ├── DotNetCallCommandTests.cs
│   │   └── DotNetGetSetCommandTests.cs
│   ├── Services/
│   │   ├── ObjectManagerTests.cs
│   │   ├── AssemblyManagerTests.cs
│   │   └── ValueConverterTests.cs
│   └── Utilities/
│       └── GenericTypeConverterTests.cs
├── integration/
│   ├── BasicFunctionalityTests.cs
│   ├── AssemblyLoadingTests.cs
│   └── ErrorHandlingTests.cs
└── TestLibrary/
    └── TestClasses.cs (for testing purposes)
```

## Security Considerations

### Assembly Loading Security
- Configurable restrictions on assembly loading paths
- Validation of assembly signatures where required
- Isolation through AssemblyLoadContext

### Reflection Security
- Limit access to sensitive types and members
- Validate type names and member access
- Prevent access to internal framework types

### Resource Management
- Memory usage monitoring and limits
- CPU usage considerations for long-running operations
- Proper cleanup of resources and handles