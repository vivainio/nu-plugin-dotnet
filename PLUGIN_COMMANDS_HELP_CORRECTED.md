# Nu Plugin .NET - Command Reference (CORRECTED)

A comprehensive help guide for all nushell commands provided by the nu-plugin-dotnet plugin.

**⚠️ This is the CORRECTED version based on actual testing of the plugin.**

## Overview

The nu-plugin-dotnet plugin provides seamless integration between nushell and the .NET ecosystem, allowing you to create, manipulate, and interact with .NET objects directly from nushell scripts.

## Command Summary

| Command | Description |
|---------|-------------|
| [`dn new`](#dn-new) | Create a new .NET object |
| [`dn call`](#dn-call) | Call a method on a .NET object |
| [`dn get`](#dn-get) | Get a property or field from a .NET object |
| [`dn set`](#dn-set) | Set a property or field on a .NET object |
| [`dn load-assembly`](#dn-load-assembly) | Load a .NET assembly |
| [`dn assemblies`](#dn-assemblies) | List loaded assemblies |
| [`dn types`](#dn-types) | List types in an assembly |
| [`dn members`](#dn-members) | List members of a type |
| [`dn obj`](#dn-obj) | Convert .NET objects to nushell native data structures |

---

## dn new

**Create a new .NET object**

Creates an instance of a .NET type using its parameterless constructor.

### Syntax
```nushell
dn new <type>
```

### Parameters
- **`type`** (required): The .NET type name to create

### ⚠️ Current Limitations
- **Only supports parameterless constructors** (constructor arguments not currently supported in command signature)
- **No --assembly flag** (assemblies must be loaded separately with `dn load-assembly`)

### Generic Types Syntax
For generic types, use backtick notation:
- `System.Collections.Generic.List`1[System.String]` - Generic List of strings
- `System.Collections.Generic.Dictionary`2[System.String,System.Int32]` - Generic Dictionary

### Examples
```nushell
# Create basic objects (parameterless constructors only)
dn new "System.Object"
dn new "System.Text.StringBuilder"
dn new "System.Collections.ArrayList"

# Create generic collections
dn new "System.Collections.Generic.List`1[System.String]"
dn new "System.Collections.Generic.Dictionary`2[System.String,System.Int32]"

# ❌ These DON'T work (constructor args not supported in current signature):
# dn new "System.Text.StringBuilder" "Initial text"
# dn new "System.String" "Hello World"
```

### Return Value
Returns a custom object reference that can be used with other `dn` commands.

---

## dn call

**Call a method on a .NET object**

Invokes a method on a .NET object instance or calls a static method on a type.

### Syntax
```nushell
<object> | dn call <method> ...(args)
<type_name> | dn call <method> ...(args)  # For static methods
```

### Parameters
- **`method`** (required): The method name to call
- **`args`** (optional): Arguments to pass to the method

### Examples
```nushell
# Instance method calls
dn new "System.Text.StringBuilder" | dn call "Append" "Hello"
dn new "System.Collections.ArrayList" | dn call "Add" "item1"

# Static method calls
"System.Guid" | dn call "NewGuid"
"System.Environment" | dn call "GetEnvironmentVariable" "PATH"

# Method chaining
dn new "System.Text.StringBuilder" 
| dn call "Append" "Hello " 
| dn call "Append" "World" 
| dn call "ToString"
```

### Return Value
Returns the method result. Complex objects are returned as custom object references, simple types are converted to nushell native types.

---

## dn get

**Get a property or field from a .NET object**

Retrieves the value of a property or field from a .NET object instance or static member from a type.

### Syntax
```nushell
<object> | dn get <property>
<object> | dn get <property> <index>  # For indexed properties
<type_name> | dn get <property>      # For static properties
```

### Parameters
- **`property`** (required): The property or field name to get
- **`index`** (optional): Index arguments for indexed properties

### Examples
```nushell
# Instance property access
dn new "System.Text.StringBuilder" | dn get "Length"
dn new "System.Collections.ArrayList" | dn get "Count"

# Static property access
"System.DateTime" | dn get "Now"
"System.Environment" | dn get "MachineName"
"System.Environment" | dn get "ProcessorCount"

# Indexed property access
"Hello World" | dn get "Item" 0  # Get character at index 0

# Field access
"System.String" | dn get "Empty"
```

### Return Value
Returns the property/field value. Complex objects are returned as custom object references, simple types are converted to nushell native types.

---

## dn set

**Set a property or field on a .NET object**

Sets the value of a writable property or field on a .NET object instance or static member.

### Syntax
```nushell
<object> | dn set <property> <value>
<type_name> | dn set <property> <value>  # For static properties
```

### Parameters
- **`property`** (required): The property or field name to set
- **`value`** (required): The value to set

### Examples
```nushell
# Set instance properties
let sb = (dn new "System.Text.StringBuilder")
$sb | dn set "Capacity" 100

# Note: Many properties are read-only, so setting may fail
```

### Return Value
Returns null on success.

---

## dn load-assembly

**Load a .NET assembly**

Loads a .NET assembly from file path or by name, making its types available for use.

### Syntax
```nushell
dn load-assembly (assembly) [--path <path>]
```

### Parameters
- **`assembly`** (optional): Assembly name or path (positional)
- **`--path`** (optional): Assembly file path to load

### Examples
```nushell
# Load by file path
dn load-assembly --path "./MyLibrary.dll"
dn load-assembly "./MyLibrary.dll"

# Load by name
dn load-assembly "System.Text.Json"
dn load-assembly "System.Xml"
```

### Return Value
Returns an assembly information record containing name, version, location, etc.

---

## dn assemblies

**List loaded assemblies**

Lists all currently loaded assemblies in the .NET plugin.

### Syntax
```nushell
dn assemblies
```

### Examples
```nushell
# List all loaded assemblies
dn assemblies

# Filter assemblies by name
dn assemblies | where name =~ "System"

# Show assembly names and versions
dn assemblies | select name version | sort-by name
```

### Return Value
Returns a list of assembly information records.

---

## dn types

**List types in an assembly**

Lists all public types defined in a specified assembly.

### Syntax
```nushell
dn types <assembly>
```

### Parameters
- **`assembly`** (required): The assembly name to list types from

### Examples
```nushell
# List types in System.Private.CoreLib (not "mscorlib" in .NET Core)
dn types "System.Private.CoreLib"

# List types in System.Collections
dn types "System.Collections"

# Filter for specific types
dn types "System.Private.CoreLib" | where name =~ "String"

# Show interface types only
dn types "System.Private.CoreLib" | where isInterface == true
```

### Return Value
Returns a list of type information records.

---

## dn members

**List members of a type**

Lists all public members (methods, properties, fields) of a specified type.

### Syntax
```nushell
dn members <type> [--type <filter>] [--static] [--instance]
```

### Parameters
- **`type`** (required): The type name to list members from
- **`--type`** (optional): Filter by member type ("methods", "properties", "fields")
- **`--static`** (optional): Include static members (default: true)
- **`--instance`** (optional): Include instance members (default: true)

### Examples
```nushell
# List all members of String
dn members "System.String"

# List only methods
dn members "System.String" --type methods

# List only properties
dn members "System.DateTime" --type properties
```

### Return Value
Returns a list of member information records.

---

## dn obj

**Convert .NET objects to nushell native data structures**

Converts .NET objects to nushell-friendly data structures for inspection and manipulation.

### Syntax
```nushell
<object> | dn obj
<type_name> | dn obj  # For type inspection
```

### Examples
```nushell
# Convert object to nushell record (use objects with parameterless constructors)
dn new "System.Text.StringBuilder" | dn obj

# Inspect type information
"System.String" | dn obj

# Convert collections
dn new "System.Collections.ArrayList" | dn obj

# Convert after method calls
dn new "System.Text.StringBuilder" 
| dn call "Append" "Hello World" 
| dn obj
```

### Return Value
Returns nushell-native data structures with type metadata.

---

## Working Examples (TESTED)

### Basic Object Creation and Manipulation
```nushell
# Create and use StringBuilder
let sb = (dn new "System.Text.StringBuilder")
$sb | dn call "Append" "Hello"
$sb | dn call "Append" " "
$sb | dn call "Append" "World"
$sb | dn call "ToString"  # Returns "Hello World"
```

### Generic Collections
```nushell
# Create and populate a generic list
let list = (dn new "System.Collections.Generic.List`1[System.String]")
$list | dn call "Add" "item1"
$list | dn call "Add" "item2"
$list | dn call "get_Count"  # Returns 2

# Create and use a dictionary
let dict = (dn new "System.Collections.Generic.Dictionary`2[System.String,System.Int32]")
$dict | dn call "Add" "key1" 42
$dict | dn call "Add" "key2" 84
$dict | dn call "get_Count"  # Returns 2
```

### Static Method Calls
```nushell
# Environment access
"System.Environment" | dn get "MachineName"
"System.Environment" | dn get "ProcessorCount"
"System.Environment" | dn call "GetEnvironmentVariable" "PATH"

# GUID generation
"System.Guid" | dn call "NewGuid" | dn call "ToString"
```

### Assembly and Type Discovery
```nushell
# Explore available assemblies
dn assemblies | select name version

# Find types in core library
dn types "System.Private.CoreLib" | where name =~ "String"

# Explore type members
dn members "System.String" --type methods | where name =~ "Sub"
```

---

## Known Issues and Limitations

1. **Constructor Arguments**: The `dn new` command currently only supports parameterless constructors due to command signature limitations.

2. **Assembly Loading**: The `--assembly` flag shown in some examples doesn't exist in the current command signature.

3. **DateTime Creation**: `System.DateTime` requires constructor arguments, so `dn new "System.DateTime"` fails. Use static properties instead: `"System.DateTime" | dn get "Now"`.

4. **Assembly Names**: Use actual .NET Core assembly names like "System.Private.CoreLib" instead of legacy names like "mscorlib".

---

## Error Handling

Common error scenarios:
```nushell
# Type not found
dn new "NonExistentType"  # Error: Type 'NonExistentType' not found

# No parameterless constructor
dn new "System.DateTime"  # Error: No matching constructor found

# Method not found
dn new "System.String" | dn call "NonExistentMethod"  # Error: Method not found
```

---

## Performance Notes

- Objects are managed by the plugin's ObjectManager for memory efficiency
- Assembly loading is cached for performance
- Type resolution uses efficient lookup mechanisms
- Method overloading resolution minimizes reflection overhead 