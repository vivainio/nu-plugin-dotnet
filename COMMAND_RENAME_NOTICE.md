# Command Renaming: load-assembly → load

## Notice

The `dn load-assembly` command has been renamed to `dn load` for simplicity and consistency.

### Current Status

- **Current Command:** `dn load-assembly` (still working in existing builds)
- **New Command:** `dn load` (to be implemented in future builds)
- **Documentation Updated:** All documentation now reflects the new `dn load` syntax

### Updated Documentation Files

The following files have been updated to use the new `dn load` syntax:

1. `TestLibrary/README.md` - Updated all examples and command references
2. `CUSTOM_DLL_TEST_SUCCESS.md` - Updated command syntax examples
3. `demo-custom-dll-concept.nu` - Updated demonstration script

### Working Test Files

The actual test files still use the current working command name:

- `test-custom-dll-working.nu` - Uses `dn load-assembly` (current working version)

### Migration Plan

When the plugin is updated to support `dn load`:

1. Update test files to use `dn load` instead of `dn load-assembly`
2. Verify all functionality works with the new command name
3. Remove this notice file

### Example Usage (New Syntax)

```nushell
# Load a custom DLL
let dll_path = "path/to/custom.dll"
dn load $dll_path

# Call methods from the loaded assembly
"MyNamespace.MyClass" | dn call "MyMethod" param1 param2
```

### Example Usage (Current Working Syntax)

```nushell
# Load a custom DLL (current working version)
let dll_path = "path/to/custom.dll"
dn load-assembly $dll_path

# Call methods from the loaded assembly
"MyNamespace.MyClass" | dn call "MyMethod" param1 param2
```

The documentation has been prepared for the future command name while maintaining working functionality with the current command name. 