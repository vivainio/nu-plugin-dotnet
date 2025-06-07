# Nu Plugin .NET - Command Reference

A comprehensive help guide for all nushell commands provided by the nu-plugin-dotnet plugin.

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

Creates an instance of a .NET type using its constructor.

### Syntax
```nushell
dn new <type> [...args] [--assembly <path>]
```

### Parameters
- **`type`** (required): The .NET type name to create (e.g., "System.String", "System.Collections.ArrayList")
- **`args`** (optional): Constructor arguments
- **`--assembly`** (optional): Assembly name or path to load before creating the object

### Generic Types Syntax
For generic types, use backtick notation:
- `List`1[System.String]` - Generic List of strings
- `Dictionary`2[System.String,System.Int32]` - Generic Dictionary with string keys and integer values

### Examples
```nushell
# Create basic objects
dn new "System.Object"
dn new "System.Text.StringBuilder"
dn new "System.Collections.ArrayList"

# Create objects with constructor arguments
dn new "System.String" "Hello World"
dn new "System.Text.StringBuilder" "Initial text"

# Create generic collections
dn new "System.Collections.Generic.List`1[System.String]"
dn new "System.Collections.Generic.Dictionary`2[System.String,System.Int32]"

# Load assembly and create object
dn new "MyCustomType" --assembly "./MyLibrary.dll"
```

### Return Value
Returns a custom object reference that can be used with other `dn` commands.

---

## dn call

**Call a method on a .NET object**

Invokes a method on a .NET object instance or calls a static method on a type.

### Syntax
```nushell
<object> | dn call <method> [...args]
<type_name> | dn call <method> [...args]  # For static methods
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
"System.DateTime" | dn call "Now"
"System.Environment" | dn call "GetEnvironmentVariable" "PATH"

# Method chaining
dn new "System.Text.StringBuilder" 
| dn call "Append" "Hello " 
| dn call "Append" "World" 
| dn call "ToString"
```

### Return Value
Returns the method result. Complex objects are returned as custom object references, simple types are converted to nushell native types.

### Special Handling
- `Console.WriteLine` is redirected to stderr to avoid interfering with the plugin protocol
- Async methods are automatically awaited
- Method overloading is supported through automatic parameter matching

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
dn new "System.Text.StringBuilder" "Hello" | dn get "Length"
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
let obj = (dn new "MyClass")
$obj | dn set "Name" "John Doe"
$obj | dn set "Age" 30

# Set static properties (if writable)
"MyStaticClass" | dn set "GlobalSetting" "value"
```

### Return Value
Returns null on success.

### Notes
- Only works with writable properties and non-readonly fields
- Automatic type conversion is performed for the value

---

## dn load-assembly

**Load a .NET assembly**

Loads a .NET assembly from file path or by name, making its types available for use.

### Syntax
```nushell
dn load-assembly [<assembly>] [--path <path>]
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
dn load-assembly "Newtonsoft.Json"

# Load system assemblies
dn load-assembly "System.Xml"
dn load-assembly "System.Data"
```

### Return Value
Returns an assembly information record containing:
- `name`: Assembly name
- `version`: Assembly version
- `location`: File path location
- `fullName`: Full assembly name
- `isGAC`: Whether it's in the Global Assembly Cache
- `isFullyTrusted`: Trust level
- `typeCount`: Number of types in the assembly
- `entryPoint`: Entry point method (if applicable)

---

## dn assemblies

**List loaded assemblies**

Lists all currently loaded assemblies in the .NET plugin.

### Syntax
```nushell
dn assemblies
```

### Parameters
None.

### Examples
```nushell
# List all loaded assemblies
dn assemblies

# Filter assemblies by name
dn assemblies | where name =~ "System"

# Show assembly versions
dn assemblies | select name version | sort-by name
```

### Return Value
Returns a list of assembly information records, each containing the same fields as `dn load-assembly`.

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
# List types in mscorlib
dn types "mscorlib"

# List types in System.Collections
dn types "System.Collections"

# Filter for specific types
dn types "mscorlib" | where name =~ "String"

# Show interface types only
dn types "mscorlib" | where isInterface == true
```

### Return Value
Returns a list of type information records containing:
- `name`: Type name
- `fullName`: Full type name including namespace
- `namespace`: Type namespace
- `isClass`: Whether it's a class
- `isInterface`: Whether it's an interface
- `isEnum`: Whether it's an enumeration
- `isValueType`: Whether it's a value type
- `isAbstract`: Whether it's abstract
- `isSealed`: Whether it's sealed
- `isGeneric`: Whether it's a generic type
- `isPublic`: Whether it's publicly accessible
- `baseType`: Base type (if applicable)
- `interfaces`: Implemented interfaces

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

# List only static members
dn members "System.Math" --static --no-instance

# List only instance members
dn members "System.Collections.ArrayList" --instance --no-static
```

### Return Value
Returns a list of member information records. The structure varies by member type:

**Method records:**
- `memberType`: "Method"
- `name`: Method name
- `returnType`: Return type name
- `isStatic`: Whether it's static
- `isPublic`: Whether it's public
- `isVirtual`: Whether it's virtual
- `isAbstract`: Whether it's abstract
- `isGeneric`: Whether it's generic
- `parameters`: List of parameter descriptions

**Property records:**
- `memberType`: "Property"
- `name`: Property name
- `propertyType`: Property type name
- `canRead`: Whether property is readable
- `canWrite`: Whether property is writable
- `isStatic`: Whether it's static
- `indexParameters`: Index parameters (for indexed properties)

**Field records:**
- `memberType`: "Field"
- `name`: Field name
- `fieldType`: Field type name
- `isStatic`: Whether it's static
- `isPublic`: Whether it's public
- `isReadOnly`: Whether it's readonly
- `isLiteral`: Whether it's a literal (const)

---

## dn obj

**Convert .NET objects to nushell native data structures**

Converts .NET objects to nushell-friendly data structures for inspection and manipulation.

### Syntax
```nushell
<object> | dn obj
<type_name> | dn obj  # For type inspection
```

### Parameters
Input can be:
- A .NET object (custom object reference)
- A type name string (for static type inspection)
- Any other value (for basic conversion)

### Examples
```nushell
# Convert object to nushell record
dn new "System.DateTime" | dn obj

# Inspect type information
"System.String" | dn obj

# Convert collections
dn new "System.Collections.ArrayList" | dn obj

# Convert after method calls
dn new "System.Text.StringBuilder" "Hello" 
| dn call "Append" " World" 
| dn obj
```

### Return Value
Returns nushell-native data structures:
- **Objects**: Converted to records with properties as fields
- **Collections**: Converted to nushell lists
- **Basic types**: Converted to appropriate nushell types
- **Type inspection**: Returns type metadata record

### Object Conversion Features
- Automatic circular reference detection
- Property and field extraction
- Type information metadata (`__type__`, `__full_type__`)
- Nested object conversion
- Collection enumeration
- Error handling for inaccessible members

---

## Common Patterns

### Working with Collections
```nushell
# Create and populate a list
let list = (dn new "System.Collections.Generic.List`1[System.String]")
$list | dn call "Add" "item1"
$list | dn call "Add" "item2"
$list | dn obj

# Create and use a dictionary
let dict = (dn new "System.Collections.Generic.Dictionary`2[System.String,System.Int32]")
$dict | dn call "Add" "key1" 42
$dict | dn call "Add" "key2" 84
$dict | dn obj
```

### Static Method Calls
```nushell
# File operations
"System.IO.File" | dn call "Exists" "myfile.txt"
"System.IO.Directory" | dn call "GetCurrentDirectory"

# Environment access
"System.Environment" | dn get "UserName"
"System.Environment" | dn call "GetEnvironmentVariable" "PATH"

# GUID generation
"System.Guid" | dn call "NewGuid" | dn call "ToString"
```

### Type Discovery
```nushell
# Explore available assemblies
dn assemblies | select name version

# Find types in an assembly
dn types "mscorlib" | where name =~ "String"

# Explore type members
dn members "System.String" --type methods | where name =~ "Sub"
```

### Object Lifecycle
```nushell
# Create, manipulate, and inspect objects
let sb = (dn new "System.Text.StringBuilder")
$sb | dn call "Append" "Hello"
$sb | dn call "Append" " "
$sb | dn call "Append" "World"
let result = ($sb | dn call "ToString")
$sb | dn obj  # Inspect final state
```

---

## Error Handling

All commands return descriptive error messages for common issues:
- Type not found
- Assembly loading failures
- Method/property not found
- Parameter type mismatches
- Access permission issues

Example error scenarios:
```nushell
# Type not found
dn new "NonExistentType"  # Error: Type 'NonExistentType' not found

# Method not found
dn new "System.String" | dn call "NonExistentMethod"  # Error: Method not found

# Wrong parameter count
dn new "System.String" | dn call "Substring"  # Error: No matching overload found
```

---

## Performance Notes

- Objects are managed by the plugin's ObjectManager for memory efficiency
- Circular reference detection prevents infinite recursion in `dn obj`
- Assembly loading is cached for performance
- Type resolution uses efficient lookup mechanisms
- Method overloading resolution minimizes reflection overhead

---

## See Also

- [Working Examples](examples/dn-new-working-examples.nu)
- [Generic Collections Guide](generics.nu)
- [Quick Reference](examples/dn-new-quick-reference.nu)