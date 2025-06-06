# Nu Plugin DotNet

A powerful nushell plugin that brings the full .NET ecosystem to your nushell environment. Create objects, call methods, access properties, and explore the vast .NET type system directly from nushell.

## Features

- **Object Creation**: Instantiate any .NET class with constructor arguments
- **Method Invocation**: Call instance and static methods with full type conversion
- **Property Access**: Get and set properties and fields on .NET objects
- **Assembly Loading**: Load and explore .NET assemblies at runtime
- **Type System**: Browse types, methods, properties, and other members
- **Automatic Type Conversion**: Seamless conversion between nushell and .NET types
- **Object Lifetime Management**: Automatic cleanup of .NET objects

## Installation

1. Build the plugin:
```bash
dotnet build -c Release
```

2. Register with nushell:
```nushell
plugin add ./bin/Release/net8.0/win-x64/nu_plugin_dotnet.exe
```

## Commands

### `dn new` - Create .NET Objects

Create instances of .NET classes with constructor parameters.

```nushell
# Create a DateTime
let $now = dn new "System.DateTime" --args [2023, 12, 25]

# Create a List<string>
let $list = dn new "System.Collections.Generic.List[string]"

# Create a Dictionary<string, int>
let $dict = dn new "System.Collections.Generic.Dictionary[string, int]"
```

### `dn call` - Call Methods

Call instance methods on objects or static methods on types.

```nushell
# Call instance method
let $tomorrow = $now | dn call "AddDays" 1

# Call static method
let $max = "System.Math" | dn call "Max" 10 20

# Call method with multiple parameters
$list | dn call "AddRange" ["Hello", "World", "!"]
```

### `dn get` - Get Properties/Fields

Access properties and fields from .NET objects or types.

```nushell
# Get instance property
let $year = $now | dn get "Year"

# Get static property
let $pi = "System.Math" | dn get "PI"

# Get collection count
let $count = $list | dn get "Count"
```

### `dn set` - Set Properties/Fields

Modify properties and fields on .NET objects.

```nushell
# Set instance property (on mutable objects)
$obj | dn set "Name" "New Value"

# Set static field
"MyClass" | dn set "StaticField" 42
```

### `dn load-assembly` - Load Assemblies

Load .NET assemblies from files or GAC.

```nushell
# Load assembly from file
dn load-assembly "MyLibrary.dll"

# Load from GAC
dn load-assembly "System.Text.Json"
```

### `dn assemblies` - List Assemblies

List all currently loaded assemblies.

```nushell
# List all assemblies
dn assemblies

# Filter assemblies
dn assemblies | where name =~ "System"
```

### `dn types` - List Types

List types within an assembly.

```nushell
# List types in core library
dn types "System.Private.CoreLib"

# List types in specific assembly
dn types "MyLibrary"
```

### `dn members` - List Type Members

Explore the members (methods, properties, fields) of a type.

```nushell
# List String members
dn members "System.String"

# List DateTime members
dn members "System.DateTime"
```

## Type Conversion

The plugin automatically converts between nushell and .NET types:

| Nushell Type | .NET Type |
|--------------|-----------|
| `int` | `int`, `long`, `double` |
| `float` | `float`, `double`, `decimal` |
| `string` | `string` |
| `bool` | `bool` |
| `list` | `Array`, `List<T>`, `IEnumerable<T>` |
| `record` | `Dictionary<string, object>` |
| Complex objects | Managed object references |

## Examples

### Working with DateTime

```nushell
# Create a specific date
let $christmas = dn new "System.DateTime" --args [2023, 12, 25]

# Get components
let $year = $christmas | dn get "Year"
let $month = $christmas | dn get "Month"
let $dayOfWeek = $christmas | dn get "DayOfWeek"

# Add time
let $newYear = $christmas | dn call "AddDays" 7
let $nextMonth = $christmas | dn call "AddMonths" 1

# Format date
let $formatted = $christmas | dn call "ToString" "yyyy-MM-dd"
```

### Working with Collections

```nushell
# Create and populate a list
let $numbers = dn new "System.Collections.Generic.List[int]"
$numbers | dn call "Add" 1
$numbers | dn call "Add" 2
$numbers | dn call "Add" 3

# Work with the list
let $count = $numbers | dn get "Count"
let $first = $numbers | dn call "get_Item" 0
let $contains = $numbers | dn call "Contains" 2

# Convert to array
let $array = $numbers | dn call "ToArray"
```

### Math Operations

```nushell
# Static math methods
let $max = "System.Math" | dn call "Max" 10 20
let $min = "System.Math" | dn call "Min" 5.5 3.2
let $sqrt = "System.Math" | dn call "Sqrt" 16
let $pow = "System.Math" | dn call "Pow" 2 8

# Math constants
let $pi = "System.Math" | dn get "PI"
let $e = "System.Math" | dn get "E"
```

### File Operations

```nushell
# Check if file exists
let $exists = "System.IO.File" | dn call "Exists" "myfile.txt"

# Read file content
let $content = "System.IO.File" | dn call "ReadAllText" "myfile.txt"

# Get file info
let $info = dn new "System.IO.FileInfo" --args ["myfile.txt"]
let $size = $info | dn get "Length"
let $created = $info | dn get "CreationTime"
```

### Working with JSON

```nushell
# Parse JSON
let $json = '{"name": "John", "age": 30}'
let $doc = "System.Text.Json.JsonDocument" | dn call "Parse" $json
let $root = $doc | dn get "RootElement"

# Access JSON properties
let $name = $root | dn call "GetProperty" "name" | dn call "GetString"
let $age = $root | dn call "GetProperty" "age" | dn call "GetInt32"
```

## Error Handling

The plugin provides detailed error messages for common issues:

- **Type not found**: Lists similar type names
- **Method not found**: Shows available methods with signatures
- **Constructor mismatch**: Lists available constructors
- **Type conversion errors**: Explains expected vs actual types

## Object Lifetime

- Objects are automatically managed with weak references
- Garbage collection cleans up unused objects
- Large objects are handled efficiently
- No manual cleanup required

## Requirements

- .NET 8.0 or later
- Nushell 0.80+
- Windows, macOS, or Linux

## Building from Source

```bash
git clone <repository-url>
cd nu-plugin-dotnet
dotnet restore
dotnet build -c Release
```

## Contributing

Contributions are welcome! Please feel free to submit issues and pull requests.

## License

This project is licensed under the MIT License. 