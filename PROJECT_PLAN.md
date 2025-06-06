# Nushell .NET Plugin Project Plan

## 🎯 Project Overview

**Goal**: Create a nushell plugin that allows seamless integration and usage of .NET classes within nushell scripts and commands.

**Plugin Name**: `nu-plugin-dotnet`

**Target Audience**: Nushell users who want to leverage .NET ecosystem libraries and functionality directly in their shell scripts.

## 🏗️ Architecture Overview

### Core Components

1. **Plugin Entry Point** - Main nushell plugin interface (JSON-based communication)
2. **Type System Bridge** - Converts between nushell values and .NET types
3. **Reflection Engine** - Dynamically loads and introspects .NET assemblies
4. **Method Invocation Layer** - Handles .NET method calls and property access
5. **Error Handling System** - Manages .NET exceptions and error reporting

### Technology Stack

- **Language**: C# (.NET 8.0+)
- **Framework**: .NET Console Application
- **Communication**: JSON over stdin/stdout (nushell plugin protocol)
- **Serialization**: System.Text.Json
- **Reflection**: System.Reflection
- **Assembly Loading**: System.Runtime.Loader.AssemblyLoadContext

## 📋 Detailed Implementation Plan

### Phase 1: Foundation Setup (Week 1-2)

#### 1.1 Project Structure
```
nu-plugin-dotnet/
├── nu-plugin-dotnet.csproj
├── Program.cs              # Entry point and plugin protocol handler
├── src/
│   ├── Plugin/
│   │   ├── PluginHost.cs       # Main plugin implementation
│   │   ├── ProtocolHandler.cs  # JSON protocol communication
│   │   └── CommandRegistry.cs  # Command registration and routing
│   ├── DotNet/
│   │   ├── AssemblyManager.cs  # Assembly loading and management
│   │   ├── TypeResolver.cs     # Type resolution and caching
│   │   ├── ObjectManager.cs    # Object lifetime management
│   │   └── ReflectionHelper.cs # Reflection utilities
│   ├── Commands/
│   │   ├── BaseCommand.cs      # Base class for all commands
│   │   ├── DotNetNewCommand.cs # Create .NET objects
│   │   ├── DotNetCallCommand.cs# Call .NET methods
│   │   ├── DotNetGetCommand.cs # Get .NET properties
│   │   └── DotNetSetCommand.cs # Set .NET properties
│   ├── Types/
│   │   ├── ValueConverter.cs   # Nushell ↔ .NET type conversion
│   │   ├── PluginValue.cs      # Nushell value representation
│   │   └── DotNetObject.cs     # Wrapper for .NET objects
│   └── Utilities/
│       ├── JsonHelper.cs       # JSON utilities
│       └── ErrorHandler.cs     # Error handling utilities
├── tests/
│   ├── Integration/
│   └── Unit/
├── examples/
│   ├── sample-scripts/
│   └── test-assemblies/
└── README.md
```

#### 1.2 Dependencies Setup
```xml
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <OutputType>Exe</OutputType>
    <TargetFramework>net8.0</TargetFramework>
    <PublishSingleFile>true</PublishSingleFile>
    <SelfContained>true</SelfContained>
  </PropertyGroup>
  
  <ItemGroup>
    <PackageReference Include="System.Text.Json" Version="8.0.0" />
    <PackageReference Include="Microsoft.Extensions.Logging" Version="8.0.0" />
    <PackageReference Include="Microsoft.Extensions.Logging.Console" Version="8.0.0" />
    <PackageReference Include="NuGet.Packaging" Version="6.8.0" />
    <PackageReference Include="NuGet.Protocol" Version="6.8.0" />
  </ItemGroup>
</Project>
```

#### 1.3 Basic Plugin Structure
- Implement nushell plugin JSON protocol handler
- Set up assembly loading infrastructure
- Create basic error types and handling
- Implement object lifetime management system

### Phase 2: Core .NET Integration (Week 3-4)

#### 2.1 Assembly Management System
```csharp
public class AssemblyManager
{
    // Responsibilities:
    // - Load assemblies from various sources (file, GAC, NuGet)
    // - Manage AssemblyLoadContext for isolation
    // - Handle assembly resolution and dependencies
    // - Cache loaded assemblies for performance
}
```

**Key Features:**
- Support for .NET Core/.NET 5+ and .NET Framework assemblies
- Dynamic assembly loading from file paths
- NuGet package resolution and loading
- Assembly dependency resolution
- Isolated loading contexts to prevent conflicts

#### 2.2 Type System Bridge
```csharp
public class ValueConverter
{
    // Bidirectional conversion between:
    // PluginValue (Nushell) ↔ object (.NET)
    
    public object ConvertToClr(PluginValue nushellValue, Type targetType);
    public PluginValue ConvertFromClr(object clrObject);
}
```

**Supported Type Mappings:**
- **Primitives**: `long` ↔ `long`, `double` ↔ `double`, `string` ↔ `string`, `bool` ↔ `bool`
- **Collections**: `List<PluginValue>` ↔ `Array/List<T>`, `Dictionary<string, PluginValue>` ↔ `Dictionary<K,V>`
- **Complex Types**: `Record` ↔ `Custom Objects`, `Table` ↔ `DataTable/IEnumerable<T>`
- **Special Types**: `DateTime`, `Guid`, `Nullable<T>`, `Task<T>`

#### 2.3 Reflection Engine
```csharp
public class ReflectionHelper
{
    // Dynamic type operations:
    // - Type discovery and method enumeration
    // - Generic type construction and handling
    // - Method overload resolution
    // - Property and field access
    // - Constructor resolution
}
```

### Phase 3: Command Implementation (Week 5-6)

#### 3.1 `dotnet new` Command
**Purpose**: Create instances of .NET classes

**Implementation**:
```csharp
public class DotNetNewCommand : BaseCommand
{
    public override async Task<PluginValue> ExecuteAsync(CommandArgs args)
    {
        var typeName = args.GetString("type");
        var constructorArgs = args.GetList("args");
        var assemblyPath = args.GetOptionalString("assembly");
        
        // Load assembly if specified
        if (assemblyPath != null)
            await assemblyManager.LoadAssemblyAsync(assemblyPath);
            
        // Resolve type
        var type = typeResolver.ResolveType(typeName);
        
        // Find matching constructor
        var constructor = ResolveConstructor(type, constructorArgs);
        
        // Convert arguments and create instance
        var convertedArgs = ConvertArguments(constructorArgs, constructor);
        var instance = Activator.CreateInstance(type, convertedArgs);
        
        // Register object for lifetime management
        var objectId = objectManager.RegisterObject(instance);
        
        return new PluginValue { ObjectId = objectId, Type = type.FullName };
    }
}
```

**Syntax Examples:**
```nushell
# Create simple objects
dotnet new "System.DateTime" --args [2023, 12, 25]
dotnet new "System.Guid"

# Create with named parameters
dotnet new "System.Net.Http.HttpClient" --timeout 30

# Create from loaded assembly
dotnet new "MyLibrary.CustomClass" --assembly "path/to/library.dll"
```

#### 3.2 `dotnet call` Command
**Purpose**: Invoke methods on .NET objects

**Implementation**:
```csharp
public class DotNetCallCommand : BaseCommand
{
    public override async Task<PluginValue> ExecuteAsync(CommandArgs args)
    {
        var target = args.GetTarget(); // Object or type name for static calls
        var methodName = args.GetString("method");
        var methodArgs = args.GetList("args");
        
        Type type;
        object instance = null;
        
        if (target.IsObjectReference)
        {
            instance = objectManager.GetObject(target.ObjectId);
            type = instance.GetType();
        }
        else
        {
            type = typeResolver.ResolveType(target.TypeName);
        }
        
        // Resolve method with overload resolution
        var method = ResolveMethod(type, methodName, methodArgs, instance == null);
        
        // Handle generic methods
        if (method.IsGenericMethodDefinition)
            method = ConstructGenericMethod(method, args.GetGenericTypes());
        
        // Convert arguments
        var convertedArgs = ConvertArguments(methodArgs, method.GetParameters());
        
        // Invoke method
        var result = method.Invoke(instance, convertedArgs);
        
        // Handle async methods (Task<T> or ValueTask<T>)
        if (IsAsyncMethod(method))
            result = await UnwrapAsyncResult(result);
        
        return ConvertResult(result);
    }
}
```

**Syntax Examples:**
```nushell
# Instance method calls
$datetime | dotnet call "AddDays" 7
$httpClient | dotnet call "GetStringAsync" "https://api.example.com"

# Static method calls
dotnet call "System.IO.File" "ReadAllText" "config.json"
dotnet call "System.Math" "Max" 10 20

# Generic method calls
$list | dotnet call "ConvertAll" [int] { |s| $s | into int }
```

#### 3.3 `dotnet get` Command
**Purpose**: Access properties and fields

**Implementation**:
```csharp
public class DotNetGetCommand : BaseCommand
{
    public override Task<PluginValue> ExecuteAsync(CommandArgs args)
    {
        var target = args.GetTarget();
        var memberName = args.GetString("member");
        var indexArgs = args.GetOptionalList("index");
        
        // Resolve target type and instance
        (var type, var instance) = ResolveTarget(target);
        
        // Handle indexed properties (e.g., List[0])
        if (indexArgs != null)
        {
            var indexer = type.GetProperties()
                .FirstOrDefault(p => p.GetIndexParameters().Length > 0);
            var convertedIndexes = ConvertArguments(indexArgs, indexer.GetIndexParameters());
            var result = indexer.GetValue(instance, convertedIndexes);
            return Task.FromResult(ConvertResult(result));
        }
        
        // Try property first, then field
        var property = type.GetProperty(memberName);
        if (property != null)
        {
            var result = property.GetValue(instance);
            return Task.FromResult(ConvertResult(result));
        }
        
        var field = type.GetField(memberName);
        if (field != null)
        {
            var result = field.GetValue(instance);
            return Task.FromResult(ConvertResult(result));
        }
        
        throw new InvalidOperationException($"Member '{memberName}' not found on type '{type.FullName}'");
    }
}
```

#### 3.4 `dotnet set` Command
**Purpose**: Set properties and fields

**Implementation**: Similar to `get` but using `SetValue` methods.

### Phase 4: Advanced Features (Week 7-8)

#### 4.1 Assembly Management Commands
```csharp
public class AssemblyCommands
{
    // dotnet load-assembly
    // dotnet assemblies  
    // dotnet assembly-info
    // dotnet load-nuget
}
```

**Features:**
- Load assemblies from file paths
- NuGet package downloading and loading
- Assembly information display
- Dependency resolution

#### 4.2 Type Exploration Commands
```csharp
public class TypeExplorationCommands
{
    // dotnet types
    // dotnet type-info
    // dotnet members
}
```

**Features:**
- List all types in loaded assemblies
- Detailed type information (inheritance, interfaces, etc.)
- Member enumeration with filtering

#### 4.3 Event Handling
```csharp
public class EventHandler
{
    // Challenge: Bridge .NET events to nushell callbacks
    // Possible approach: Event subscription with callback IDs
}
```

#### 4.4 Generic Type Support
```csharp
public class GenericTypeHelper
{
    public Type ConstructGenericType(Type genericType, Type[] typeArguments);
    public MethodInfo ConstructGenericMethod(MethodInfo genericMethod, Type[] typeArguments);
}
```

### Phase 5: Error Handling & Robustness (Week 9)

#### 5.1 Exception Handling
```csharp
public class ErrorHandler
{
    public PluginError ConvertException(Exception ex)
    {
        return new PluginError
        {
            Message = ex.Message,
            StackTrace = ex.StackTrace,
            Type = ex.GetType().FullName,
            InnerException = ex.InnerException != null ? ConvertException(ex.InnerException) : null
        };
    }
}
```

#### 5.2 Memory Management
```csharp
public class ObjectManager
{
    private readonly ConcurrentDictionary<string, WeakReference> _objects = new();
    
    public string RegisterObject(object obj);
    public object GetObject(string id);
    public void DisposeObject(string id);
    public void CollectGarbage();
}
```

#### 5.3 Async Operation Support
```csharp
public static class AsyncHelper
{
    public static async Task<object> UnwrapTask(object taskObject)
    {
        if (taskObject is Task task)
        {
            await task;
            // Handle Task<T> vs Task
            var taskType = task.GetType();
            if (taskType.IsGenericType)
            {
                var resultProperty = taskType.GetProperty("Result");
                return resultProperty.GetValue(task);
            }
            return null; // Task (non-generic)
        }
        return taskObject;
    }
}
```

### Phase 6: Testing & Documentation (Week 10)

#### 6.1 Test Suite Structure
```
tests/
├── Integration/
│   ├── BasicTypesTests.cs
│   ├── CollectionsTests.cs
│   ├── AsyncMethodsTests.cs
│   └── ErrorHandlingTests.cs
├── Unit/
│   ├── ValueConversionTests.cs
│   ├── ReflectionHelperTests.cs
│   └── AssemblyLoadingTests.cs
└── TestFixtures/
    ├── TestLibrary/  (C# project for testing)
    └── SampleData/
```

#### 6.2 Documentation
- Comprehensive README with installation instructions
- Command reference documentation
- Type conversion guide
- Performance optimization tips
- Security considerations

## 🚀 Usage Examples

### Basic Object Creation and Method Calls
```nushell
# Working with DateTime
let $now = dotnet new "System.DateTime" --args [2023, 12, 25, 14, 30, 0]
let $tomorrow = $now | dotnet call "AddDays" 1
$tomorrow | dotnet get "DayOfWeek"  # Output: Tuesday
```

### File Operations
```nushell
# Using .NET File I/O
let $content = dotnet call "System.IO.File" "ReadAllText" "config.json"
let $json = dotnet new "System.Text.Json.JsonDocument" --parse $content
$json | dotnet call "RootElement" | dotnet call "GetProperty" "database"
```

### HTTP Operations
```nushell
# HTTP client usage
let $client = dotnet new "System.Net.Http.HttpClient"
let $response = $client | dotnet call "GetStringAsync" "https://api.github.com/users/octocat"
$response | from json | select login name public_repos
$client | dotnet call "Dispose"  # Cleanup
```

### LINQ Operations
```nushell
# Working with LINQ
let $numbers = dotnet new "System.Collections.Generic.List[int]" --args [[1, 2, 3, 4, 5]]
let $evens = $numbers | dotnet call "Where" { |x| ($x | dotnet call "%" 2) == 0 }
let $doubled = $evens | dotnet call "Select" { |x| $x | dotnet call "*" 2 }
$doubled | dotnet call "ToArray"
```

## 🔧 Technical Challenges & Solutions

### Challenge 1: Nushell Plugin Protocol
**Problem**: Implementing JSON-based communication protocol correctly
**Solution**: 
- Study existing plugin implementations
- Create robust JSON serialization/deserialization
- Handle streaming input/output properly
- Implement proper error reporting format

### Challenge 2: Object Lifetime Management
**Problem**: Managing .NET object lifetimes across plugin calls
**Solution**:
- Object registry with unique IDs
- Weak references to allow garbage collection
- Automatic disposal for IDisposable objects
- Cleanup commands for manual management

### Challenge 3: Type Conversion Complexity
**Problem**: Converting between nushell's dynamic values and .NET's static types
**Solution**:
- Comprehensive type mapping system
- Runtime type inference and coercion
- Custom converters for complex types
- Clear error messages for conversion failures

### Challenge 4: Async Method Handling
**Problem**: .NET async methods and Task unwrapping
**Solution**:
- Automatic Task/ValueTask detection and awaiting
- Proper async context handling
- Cancellation token support
- Progress reporting for long operations

## 📊 Success Metrics

1. **Functionality**: Successfully create objects, call methods, access properties
2. **Performance**: < 50ms startup time, < 5ms per operation overhead
3. **Stability**: Handle errors gracefully without crashing
4. **Usability**: Intuitive syntax that feels natural in nushell
5. **Coverage**: Support for 90% of common .NET scenarios

## 🛡️ Security Considerations

1. **Assembly Loading**: Configurable restrictions on assembly sources
2. **Reflection**: Limit access to sensitive APIs and types
3. **Code Execution**: Sandbox for dynamic code execution
4. **Resource Limits**: Memory and CPU usage monitoring
5. **Permission Model**: Integration with .NET's Code Access Security

## 📈 Future Enhancements

### Version 2.0 Features
- **Visual Studio Integration**: Debugging support with breakpoints
- **Code Generation**: Generate strongly-typed nushell wrappers
- **Package Management**: Integrated NuGet package browser and installer
- **Performance Optimization**: AOT compilation for faster startup
- **IDE Support**: Language server for nushell with .NET IntelliSense

### Community Features
- **Library Templates**: Pre-built wrappers for popular libraries
- **Plugin Ecosystem**: Registry of specialized .NET integration plugins  
- **Sharing Platform**: Community scripts and examples
- **Documentation Generator**: Auto-generate docs from .NET XML docs

## 🎯 Delivery Timeline

| Week | Milestone | Deliverables |
|------|-----------|--------------|
| 1-2  | Foundation | Project setup, plugin protocol, basic structure |
| 3-4  | Core Integration | Assembly loading, type conversion, reflection |
| 5-6  | Commands | Implement all basic commands (new, call, get, set) |
| 7-8  | Advanced Features | Assembly management, generics, exploration tools |
| 9    | Robustness | Error handling, memory management, async support |
| 10   | Polish | Testing, documentation, packaging, examples |

## 📚 Resources & References

1. [Nushell Plugin Development Guide](https://www.nushell.sh/book/plugins.html)
2. [.NET Reflection Documentation](https://docs.microsoft.com/en-us/dotnet/api/system.reflection)
3. [System.Text.Json Documentation](https://docs.microsoft.com/en-us/dotnet/api/system.text.json)
4. [AssemblyLoadContext Documentation](https://docs.microsoft.com/en-us/dotnet/api/system.runtime.loader.assemblyloadcontext)
5. [NuGet API Documentation](https://docs.microsoft.com/en-us/nuget/api/overview)

---

*This plan provides a roadmap for creating a native .NET plugin that bridges nushell and the .NET ecosystem, enabling users to leverage the vast .NET library ecosystem directly in their shell scripts with full type safety and performance.* 