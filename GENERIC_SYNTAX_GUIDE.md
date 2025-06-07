# User-Friendly Generic Type Syntax

## Overview

The `dn new` command now supports user-friendly generic type syntax, making it much easier to create generic .NET objects without needing to remember the complex internal type names.

## Syntax Comparison

### Before (Internal .NET Syntax)
```nushell
# Complex and hard to remember
let $list = dn new "System.Collections.Generic.List`1[System.String]"
let $dict = dn new "System.Collections.Generic.Dictionary`2[System.String,System.Int32]"
```

### After (User-Friendly Syntax)
```nushell
# Simple and intuitive
let $list = dn new "List<string>"
let $dict = dn new "Dictionary<string, int>"
```

## Supported Type Aliases

The following type aliases are supported for common .NET types:

| Alias     | Full .NET Type    |
|-----------|-------------------|
| `string`  | `System.String`   |
| `int`     | `System.Int32`    |
| `long`    | `System.Int64`    |
| `short`   | `System.Int16`    |
| `byte`    | `System.Byte`     |
| `bool`    | `System.Boolean`  |
| `double`  | `System.Double`   |
| `float`   | `System.Single`   |
| `decimal` | `System.Decimal`  |
| `char`    | `System.Char`     |
| `object`  | `System.Object`   |

## Supported Generic Types

The following generic type shortcuts are available:

| Shortcut           | Full .NET Type                                    | Parameters |
|--------------------|---------------------------------------------------|------------|
| `List`             | `System.Collections.Generic.List`                | 1          |
| `Dictionary`       | `System.Collections.Generic.Dictionary`          | 2          |
| `HashSet`          | `System.Collections.Generic.HashSet`             | 1          |
| `Queue`            | `System.Collections.Generic.Queue`               | 1          |
| `Stack`            | `System.Collections.Generic.Stack`               | 1          |
| `SortedDictionary` | `System.Collections.Generic.SortedDictionary`    | 2          |
| `SortedSet`        | `System.Collections.Generic.SortedSet`           | 1          |
| `LinkedList`       | `System.Collections.Generic.LinkedList`          | 1          |
| `KeyValuePair`     | `System.Collections.Generic.KeyValuePair`        | 2          |
| `Nullable`         | `System.Nullable`                                 | 1          |
| `IEnumerable`      | `System.Collections.Generic.IEnumerable`         | 1          |
| `ICollection`      | `System.Collections.Generic.ICollection`         | 1          |
| `IList`            | `System.Collections.Generic.IList`               | 1          |
| `IDictionary`      | `System.Collections.Generic.IDictionary`         | 2          |
| `ISet`             | `System.Collections.Generic.ISet`                | 1          |
| `Task`             | `System.Threading.Tasks.Task`                     | 1          |

## Examples

### Basic Generic Types

```nushell
# Create a list of strings
let $fruits = dn new "List<string>"
$fruits | dn call "Add" "Apple"
$fruits | dn call "Add" "Banana"

# Create a dictionary mapping strings to integers
let $inventory = dn new "Dictionary<string, int>"
$inventory | dn call "Add" "apples" 10
$inventory | dn call "Add" "bananas" 5

# Create a set of unique integers
let $numbers = dn new "HashSet<int>"
$numbers | dn call "Add" 1
$numbers | dn call "Add" 2
$numbers | dn call "Add" 1  # Duplicate, will be ignored
```

### Nested Generic Types

```nushell
# Create a list of lists
let $matrix = dn new "List<List<int>>"
let $row1 = dn new "List<int>"
$row1 | dn call "Add" 1
$row1 | dn call "Add" 2
$matrix | dn call "Add" $row1

# Create a dictionary with list values
let $groups = dn new "Dictionary<string, List<string>>"
let $team1 = dn new "List<string>"
$team1 | dn call "Add" "Alice"
$team1 | dn call "Add" "Bob"
$groups | dn call "Add" "developers" $team1
```

### Queue and Stack Examples

```nushell
# FIFO Queue
let $tasks = dn new "Queue<string>"
$tasks | dn call "Enqueue" "Task 1"
$tasks | dn call "Enqueue" "Task 2"
let $next_task = $tasks | dn call "Dequeue"  # Returns "Task 1"

# LIFO Stack
let $history = dn new "Stack<string>"
$history | dn call "Push" "Page 1"
$history | dn call "Push" "Page 2"
let $current = $history | dn call "Pop"  # Returns "Page 2"
```

## Backward Compatibility

**100% Backward Compatible**: The old internal .NET syntax continues to work exactly as before:

```nushell
# Both of these create identical objects with identical behavior
let $list1 = dn new "List<string>"  # New syntax
let $list2 = dn new "System.Collections.Generic.List`1[System.String]"  # Old syntax

# You can even mix both syntaxes in the same script
let $dict_new = dn new "Dictionary<string, List<int>>"  # Container with new syntax
let $list_old = dn new "System.Collections.Generic.List`1[System.Int32]"  # Value with old syntax
$dict_new | dn call "Add" "numbers" $list_old  # Mix them together!
```

### Comprehensive Compatibility Testing

The implementation has been thoroughly tested to ensure:

- ✅ **All existing scripts continue to work unchanged**
- ✅ **Old syntax produces identical objects and behavior**
- ✅ **Mixed usage of old and new syntax works seamlessly**
- ✅ **No performance impact on existing old syntax usage**
- ✅ **All edge cases and complex nested generics work with old syntax**

### How It Works

The conversion logic only activates for user-friendly syntax (containing `<` and `>`). If your type name doesn't contain these characters, it passes through unchanged:

```nushell
# These pass through unchanged (old syntax)
"System.Collections.Generic.List`1[System.String]"
"System.String"
"MyCustomType"

# These get converted (new syntax)  
"List<string>" → "System.Collections.Generic.List`1[System.String]"
"Dictionary<string, int>" → "System.Collections.Generic.Dictionary`2[System.String,System.Int32]"
```

## Error Handling

The system provides helpful error messages:

```nushell
# Wrong number of type parameters
let $invalid = dn new "Dictionary<string>"  # Error: Dictionary expects 2 type parameters

# Unknown generic type
let $unknown = dn new "UnknownGeneric<string>"  # Error: Type not found
```

## Benefits

1. **Easier to read and write**: No need to remember complex internal type names
2. **Less error-prone**: Shorter syntax reduces typos
3. **Familiar syntax**: Uses C#-like generic syntax that .NET developers know
4. **Backward compatible**: Old syntax continues to work
5. **Supports nesting**: Complex nested generics are handled correctly

## Implementation Details

The conversion happens automatically in the `dn new` command:
- User-friendly syntax like `Dictionary<string, int>` is detected
- It's converted to internal .NET syntax: `System.Collections.Generic.Dictionary`2[System.String,System.Int32]`
- The existing type resolution and object creation logic remains unchanged

This feature makes working with .NET generics in Nushell much more pleasant and productive! 