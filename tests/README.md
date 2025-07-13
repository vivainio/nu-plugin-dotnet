# Modern Test Suite for Nu-Plugin-DotNet

This directory contains the modern Nushell test suite using `std assert` and best practices.

## Structure

```
tests/
├── mod.nu                          # Main test module & runners  
├── unit/                           # Unit tests
│   ├── basic-functionality.nu      # Core plugin operations (18 tests)
│   ├── assembly-operations.nu      # Assembly/type discovery (16 tests)
│   └── error-handling.nu          # Error cases & validation (13 tests)
├── integration/                    # Integration tests
│   └── custom-dll.nu              # End-to-end DLL scenarios (10 tests)
└── examples/                       # Example test implementations
    ├── simple-modern-tests.nu      # Simple modern test example
    ├── nutest-style-tests.nu       # Advanced nutest framework example
    └── modern-plugin-tests.nu      # Alternative test runner example
```

## Quick Start

```bash
# From project root
nu run-tests.nu                    # All tests
nu run-tests.nu --suite smoke      # Quick validation
nu run-tests.nu --suite unit       # Unit tests only
```

## Test Categories

| Category | Tests | Description |
|----------|-------|-------------|
| **Basic Functionality** | 18 | Object creation, method calls, properties |
| **Assembly Operations** | 16 | Assembly discovery, type listing, members |
| **Error Handling** | 13 | Invalid inputs, edge cases, error validation |
| **Custom DLL Integration** | 10 | End-to-end scenarios with TestLibrary |

## Modern Features

- ✅ **`std assert`** - Official Nushell assertion library
- ✅ **AAA Pattern** - Arrange, Act, Assert structure
- ✅ **Modular Organization** - Tests grouped by functionality
- ✅ **Error Testing** - Comprehensive edge case validation
- ✅ **Conditional Testing** - Skip when dependencies unavailable
- ✅ **CI/CD Ready** - Proper exit codes and automation

## Example Test

```nu
use std assert

def "test dn-new creates StringBuilder" [] {
    # Arrange
    let type_name = "System.Text.StringBuilder"
    
    # Act
    let result = (dn new $type_name)
    
    # Assert
    assert (($result | describe) == "string")
    assert ($result | str contains "StringBuilder")
}
```

## Legacy Tests

Old test files have been moved to `examples/tests-legacy/` for reference.

## Documentation

- **Main Guide**: `/TESTING.md`
- **Best Practices**: `/docs/testing-best-practices.md`
- **README**: `/README.md` (Testing section)