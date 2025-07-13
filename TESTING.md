# Testing Guide for Nu-Plugin-DotNet

## Quick Start

```bash
# Run all tests
nu run-tests.nu

# Quick validation  
nu run-tests.nu --suite smoke

# Help
nu run-tests.nu --suite help
```

## Test Suites Available

| Command | Description | Use Case |
|---------|-------------|----------|
| `nu run-tests.nu` | All tests | Complete validation |
| `nu run-tests.nu --suite smoke` | Essential checks | CI/CD quick validation |
| `nu run-tests.nu --suite unit` | Unit tests only | Core functionality |
| `nu run-tests.nu --suite integration` | Integration tests | End-to-end scenarios |
| `nu run-tests.nu --suite performance` | Speed tests | Performance validation |

## Individual Categories

| Command | Description | Tests |
|---------|-------------|--------|
| `nu run-tests.nu --suite basic` | Basic functionality | Object creation, method calls, properties |
| `nu run-tests.nu --suite assembly` | Assembly operations | Assembly discovery, type listing |  
| `nu run-tests.nu --suite error` | Error handling | Invalid inputs, edge cases |
| `nu run-tests.nu --suite dll` | Custom DLL integration | TestLibrary loading and usage |

## Test Structure

```
tests/
├── mod.nu                          # Main test module & runners
├── unit/                           # Unit tests
│   ├── basic-functionality.nu      # Core plugin operations
│   ├── assembly-operations.nu      # Assembly/type discovery
│   └── error-handling.nu          # Error cases & validation
├── integration/                    # Integration tests
│   └── custom-dll.nu              # End-to-end DLL scenarios
└── run-tests.nu                    # Test runner script
```

## Modern Testing Features

- ✅ **`std assert`** - Official Nushell assertion library
- ✅ **AAA Pattern** - Arrange, Act, Assert structure  
- ✅ **Descriptive Tests** - Clear naming and descriptions
- ✅ **Error Validation** - Comprehensive error testing
- ✅ **Conditional Testing** - Skip when dependencies missing
- ✅ **Modular Organization** - Logical test grouping
- ✅ **CI/CD Ready** - Proper exit codes and automation

## Example Test Output

```
🧪 Nu Plugin .NET - Comprehensive Test Suite
=============================================

✅ Plugin verified and available

🎯 Running Basic Functionality Tests
====================================
🧪 Running 18 basic functionality tests...

  ✅ test dn-new creates StringBuilder
  ✅ test dn-new creates ArrayList  
  ✅ test dn-call static Math.Max
  ✅ test dn-get string Length
  ...

📊 Basic Tests: 18 passed, 0 failed
✅ All basic functionality tests passed!

📊 FINAL TEST SUMMARY
=====================
🎉 ALL TEST SUITES PASSED!

✅ Plugin Status: PRODUCTION READY
```

## Writing New Tests

Follow the modern Nushell pattern:

```nu
use std assert

def "test my new feature" [] {
    # Arrange - Set up test data
    let input_data = "test value"
    
    # Act - Execute the code being tested
    let result = (dn new "System.Text.StringBuilder")
    
    # Assert - Verify the results
    assert ($result | str contains "StringBuilder")
    assert (($result | describe) == "string")
}
```

## Migration from Legacy Tests

The project has migrated from manual test validation to modern `std assert` patterns:

### Before (Legacy)
```nu
try {
    let result = (dn new "Type")
    if ($result | str contains "expected") {
        print "✅ Test passed"
    } else {
        print "❌ Test failed"
        exit 1
    }
} catch {
    print "❌ Error occurred"
    exit 1
}
```

### After (Modern)
```nu
use std assert

def "test type creation" [] {
    # Arrange
    let type_name = "System.Text.StringBuilder"
    
    # Act
    let result = (dn new $type_name)
    
    # Assert
    assert ($result | str contains "StringBuilder")
}
```

## Benefits of Modern Approach

1. **Better Error Reporting** - Automatic assertion failure details
2. **Cleaner Code** - AAA pattern with clear structure
3. **Easier Maintenance** - Standard library integration
4. **More Reliable** - Consistent behavior across tests
5. **CI/CD Friendly** - Proper exit codes and structured output

## Requirements

- Nushell with `std assert` support (Nushell 0.95+)
- Nu-plugin-dotnet registered with nushell
- TestLibrary built for custom DLL tests (optional)

## Troubleshooting

### Plugin Not Found
```bash
❌ nu-plugin-dotnet not found. Please install and register the plugin:
   1. Build the plugin: dotnet build
   2. Register with nushell: plugin add target/debug/nu_plugin_dotnet.exe
```

### TestLibrary Missing
```
⏭️ TestLibrary.dll not found - building...
```
This is normal - the test suite will attempt to build TestLibrary automatically.

### Test Failures
Individual test failures include detailed error messages for debugging:
```
❌ test dn-new creates StringBuilder: Type 'System.Text.StringBuilder' not found
```

## For Developers

See `docs/testing-best-practices.md` for comprehensive testing documentation and patterns.