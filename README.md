# Nu Plugin DotNet

A nushell plugin that enables seamless integration with .NET classes and libraries, allowing you to create objects, call methods, and access properties directly from nushell.

## Features

- 🔧 **Create .NET Objects**: Instantiate any .NET class with constructor parameters
- 🚀 **Method Invocation**: Call both instance and static methods with automatic type conversion
- 📊 **Property Access**: Get and set properties and fields on .NET objects
- 🔍 **Type Discovery**: Explore assemblies, types, and their members
- ⚡ **Async Support**: Automatic handling of Task and ValueTask return values
- 🧠 **Smart Type Conversion**: Bidirectional conversion between nushell and .NET types
- 📦 **Assembly Management**: Load assemblies from file paths

## Installation

### Prerequisites

- .NET 8.0 or later
- Nushell 0.80 or later

### Build from Source

```bash
git clone https://github.com/yourusername/nu-plugin-dotnet
cd nu-plugin-dotnet
dotnet build -c Release
```

### Register with Nushell

```bash
# Register the plugin
register ./bin/Release/net8.0/nu_plugin_dotnet.exe

# Or with full path
register "C:\path\to\nu_plugin_dotnet.exe"
```

## Quick Start

```nushell
# Create a DateTime object
let $now = dotnet new "System.DateTime" --args [2023, 12, 25, 14, 30, 0]

# Call methods on the object
let $tomorrow = $now | dotnet call "AddDays" 1
$tomorrow | dotnet get "DayOfWeek"  # Output: Tuesday

# Static method calls
let $max = dotnet call "System.Math" "Max" 10 20  # Output: 20

# Working with collections
let $list = dotnet new "System.Collections.Generic.List[string]"
$list | dotnet call "Add" "Hello"
$list | dotnet call "Add" "World"
$list | dotnet get "Count"  # Output: 2
```

## Commands

### `dotnet new`

Create instances of .NET classes.

**Syntax:**
```nushell
dotnet new <type-name> [--args <constructor-args>] [--assembly <assembly-path>]
```

**Examples:**
```nushell
# Simple object creation
dotnet new "System.Guid"
dotnet new "System.DateTime" --args [2023, 12, 25]

# Create with named constructor
dotnet new "System.Text.StringBuilder" --args ["Hello World"]

# Load assembly and create object
dotnet new "MyLibrary.CustomClass" --assembly "path/to/library.dll"
```

### `dotnet call`

Invoke methods on .NET objects or types.

**Syntax:**
```nushell
<object> | dotnet call <method-name> [args...]
<type-name> | dotnet call <method-name> [args...]  # Static methods
```

**Examples:**
```nushell
# Instance method
$datetime | dotnet call "AddDays" 7
$stringBuilder | dotnet call "Append" " - Added text"

# Static method
"System.IO.File" | dotnet call "ReadAllText" "config.json"
"System.Math" | dotnet call "Pow" 2 3  # 2^3 = 8

# Async methods (automatically awaited)
$httpClient | dotnet call "GetStringAsync" "https://api.github.com"
```

### `dotnet get`

Access properties and fields from .NET objects.

**Syntax:**
```nushell
<object> | dotnet get <member-name> [index-args...]
<type-name> | dotnet get <member-name>  # Static members
```

**Examples:**
```nushell
# Get properties
$datetime | dotnet get "Year"
$fileInfo | dotnet get "Length"

# Get static properties
"System.DateTime" | dotnet get "Now"
"System.Environment" | dotnet get "MachineName"

# Indexed properties
$list | dotnet get "Item" 0  # Get first element
$dict | dotnet get "Item" "key"
```

### `dotnet set`

Set properties and fields on .NET objects.

**Syntax:**
```nushell
<object> | dotnet set <member-name> <value>
<type-name> | dotnet set <member-name> <value>  # Static members
```

**Examples:**
```nushell
# Set properties
$stringBuilder | dotnet set "Capacity" 1000
$fileInfo | dotnet set "Attributes" "ReadOnly"

# Set static properties
"System.Environment" | dotnet set "CurrentDirectory" "/new/path"
```

### `dotnet load-assembly`

Load .NET assemblies from file paths.

**Syntax:**
```nushell
dotnet load-assembly <assembly-path>
```

**Examples:**
```nushell
# Load a custom library
dotnet load-assembly "MyLibrary.dll"
dotnet load-assembly "C:\libs\ThirdParty.dll"

# Load and get info
let $info = dotnet load-assembly "SomeLibrary.dll"
$info | select name version typeCount
```

### `dotnet assemblies`

List all loaded assemblies.

**Examples:**
```nushell
# List all assemblies
dotnet assemblies

# Filter by name
dotnet assemblies | where name =~ "System"

# Show only custom assemblies
dotnet assemblies | where isGAC == false
```

### `dotnet types`

List types in an assembly.

**Syntax:**
```nushell
dotnet types <assembly-name>
```

**Examples:**
```nushell
# List types in System.Core
dotnet types "System.Core"

# Filter to classes only
dotnet types "MyLibrary" | where isClass == true

# Find generic types
dotnet types "System.Core" | where isGeneric == true
```

### `dotnet members`

List members (methods, properties, fields) of a type.

**Syntax:**
```nushell
dotnet members <type-name> [--type <member-type>] [--static] [--instance]
```

**Examples:**
```nushell
# List all members
dotnet members "System.String"

# Only methods
dotnet members "System.String" --type methods

# Only static members
dotnet members "System.Math" --static true --instance false

# Only properties
dotnet members "System.IO.FileInfo" --type properties
```

## Type Conversion

The plugin automatically converts between nushell and .NET types:

| Nushell Type | .NET Type | Notes |
|--------------|-----------|-------|
| `int` | `long`, `int`, `short`, etc. | Automatic numeric conversion |
| `float` | `double`, `float`, `decimal` | Precision preserved |
| `string` | `string` | Direct mapping |
| `bool` | `bool` | Direct mapping |
| `list` | `Array`, `List<T>`, `IEnumerable<T>` | Element type conversion |
| `record` | Custom objects, `Dictionary<K,V>` | Property mapping |
| `date` | `DateTime` | Direct mapping |
| `duration` | `TimeSpan` | Direct mapping |

## Real-World Examples

### Working with Files

```nushell
# Read a JSON file using .NET
let $json = "System.IO.File" | dotnet call "ReadAllText" "config.json"
let $doc = dotnet new "System.Text.Json.JsonDocument" --parse $json
$doc | dotnet call "RootElement" | dotnet call "GetProperty" "database"
```

### HTTP Client Usage

```nushell
# Make HTTP requests
let $client = dotnet new "System.Net.Http.HttpClient"
let $response = $client | dotnet call "GetStringAsync" "https://api.github.com/users/octocat"
$response | from json | select login name public_repos

# Don't forget to dispose
$client | dotnet call "Dispose"
```

### Working with Collections

```nushell
# Create and manipulate a list
let $list = dotnet new "System.Collections.Generic.List[int]"
[1, 2, 3, 4, 5] | each { |x| $list | dotnet call "Add" $x }

# Use LINQ-like operations
let $evens = $list | dotnet call "Where" { |x| ($x % 2) == 0 }
let $doubled = $evens | dotnet call "Select" { |x| $x * 2 }
$doubled | dotnet call "ToArray"
```

### Regular Expressions

```nushell
# Create and use regex
let $regex = dotnet new "System.Text.RegularExpressions.Regex" --args ["[a-z]+@[a-z]+\\.[a-z]+"]
let $text = "Contact us at john@example.com or jane@test.org"
let $matches = $regex | dotnet call "Matches" $text

# Extract email addresses
$matches | dotnet call "Cast" | each { |match| $match | dotnet get "Value" }
```

## Error Handling

The plugin provides detailed error messages for common issues:

- **Type not found**: Make sure the assembly is loaded
- **Method not found**: Check method name and parameter count
- **Type conversion errors**: Verify argument types match method signatures
- **Assembly loading errors**: Check file path and permissions

## Performance Considerations

- **Object Lifetime**: Objects are managed with weak references and automatic cleanup
- **Assembly Loading**: Assemblies are cached after first load
- **Type Resolution**: Types are cached for better performance
- **Async Operations**: Properly awaited to avoid blocking

## Security Notes

- The plugin can load and execute code from any .NET assembly
- Only load assemblies from trusted sources
- Consider running in isolated environments for untrusted code

## Contributing

Contributions are welcome! Please feel free to submit issues and pull requests.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Roadmap

- [ ] NuGet package loading support
- [ ] Generic type construction syntax
- [ ] Event subscription and handling
- [ ] Performance optimizations
- [ ] Visual Studio debugger integration
- [ ] Code generation for common libraries

---

*Bring the power of the entire .NET ecosystem to your nushell scripts!* 