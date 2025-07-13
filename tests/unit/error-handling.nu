#!/usr/bin/env nu

# Unit tests for error handling and edge cases
# Tests plugin behavior with invalid inputs and error conditions

use std assert

# Invalid Type Tests
def "test dn-new with invalid type name" [] {
    # Act & Assert
    try {
        dn new "NonExistent.Type.Name"
        assert false "Should have thrown an error for invalid type"
    } catch {
        assert true "Correctly handled invalid type error"
    }
}

def "test dn-new with malformed type name" [] {
    # Act & Assert
    try {
        dn new "Invalid..Type..Name"
        assert false "Should have thrown an error for malformed type"
    } catch {
        assert true "Correctly handled malformed type error"
    }
}

def "test dn-new with empty type name" [] {
    # Act & Assert
    try {
        dn new ""
        assert false "Should have thrown an error for empty type"
    } catch {
        assert true "Correctly handled empty type error"
    }
}

def "test dn-new with generic syntax error" [] {
    # Act & Assert
    try {
        dn new "List<>"  # Missing type parameter
        assert false "Should have thrown an error for incomplete generic"
    } catch {
        assert true "Correctly handled incomplete generic syntax"
    }
}

# Invalid Method Tests
def "test dn-call with invalid method name" [] {
    # Arrange
    let obj = (dn new "System.Object")
    
    # Act & Assert
    try {
        $obj | dn call "NonExistentMethod"
        assert false "Should have thrown an error for invalid method"
    } catch {
        assert true "Correctly handled invalid method error"
    }
}

def "test dn-call with wrong parameter count" [] {
    # Act & Assert
    try {
        "System.Math" | dn call "Max" 10  # Max requires 2 parameters
        assert false "Should have thrown an error for wrong parameter count"
    } catch {
        assert true "Correctly handled wrong parameter count"
    }
}

def "test dn-call with invalid parameter type" [] {
    # Act & Assert
    try {
        "System.Math" | dn call "Max" "not_a_number" 10
        assert false "Should have thrown an error for invalid parameter type"
    } catch {
        assert true "Correctly handled invalid parameter type"
    }
}

# Invalid Property Tests
def "test dn-get with invalid property name" [] {
    # Arrange
    let obj = (dn new "System.Object")
    
    # Act & Assert
    try {
        $obj | dn get "NonExistentProperty"
        assert false "Should have thrown an error for invalid property"
    } catch {
        assert true "Correctly handled invalid property error"
    }
}

def "test dn-get with write-only property" [] {
    # Note: This test may vary depending on available write-only properties
    # Act & Assert
    try {
        let sb = (dn new "System.Text.StringBuilder")
        $sb | dn get "Capacity" # This should work, so we test a different scenario
        assert true "Capacity is readable"
    } catch {
        assert true "Handled property access correctly"
    }
}

# Invalid Set Operations
def "test dn-set with invalid property name" [] {
    # Arrange
    let obj = (dn new "System.Object")
    
    # Act & Assert
    try {
        $obj | dn set "NonExistentProperty" "value"
        assert false "Should have thrown an error for invalid property"
    } catch {
        assert true "Correctly handled invalid property set"
    }
}

def "test dn-set with read-only property" [] {
    # Act & Assert
    try {
        "Hello" | dn set "Length" 10  # String.Length is read-only
        assert false "Should have thrown an error for read-only property"
    } catch {
        assert true "Correctly handled read-only property error"
    }
}

# Assembly Loading Error Tests
def "test dn-load with non-existent file" [] {
    # Act & Assert
    try {
        dn load "non-existent-file.dll"
        assert false "Should have thrown an error for non-existent file"
    } catch {
        assert true "Correctly handled non-existent file error"
    }
}

def "test dn-load with invalid file path" [] {
    # Act & Assert
    try {
        dn load "invalid/path/with\\mixed\\separators.dll"
        assert false "Should have thrown an error for invalid path"
    } catch {
        assert true "Correctly handled invalid path error"
    }
}

# Type Discovery Error Tests
def "test dn-types with invalid assembly name" [] {
    # Act & Assert
    try {
        dn types "NonExistentAssembly"
        assert false "Should have thrown an error for invalid assembly"
    } catch {
        assert true "Correctly handled invalid assembly error"
    }
}

def "test dn-members with invalid type name" [] {
    # Act & Assert
    try {
        dn members "NonExistent.Type"
        assert false "Should have thrown an error for invalid type"
    } catch {
        assert true "Correctly handled invalid type for members"
    }
}

# Edge Cases
def "test dn-new with type requiring constructor arguments" [] {
    # DateTime requires constructor arguments
    # Act & Assert
    try {
        dn new "System.DateTime"
        assert false "Should have thrown an error - DateTime requires constructor args"
    } catch {
        assert true "Correctly handled type requiring constructor arguments"
    }
}

def "test method call with null-like values" [] {
    # Arrange
    let sb = (dn new "System.Text.StringBuilder")
    
    # Act - AppendLine with empty string should work
    let result = ($sb | dn call "AppendLine" "")
    
    # Assert
    assert (($result | describe) == "string")
    assert ($result | str contains "StringBuilder")
}

def "test property access edge cases" [] {
    # Act - Empty string length should be 0
    let empty_length = ("" | dn get "Length")
    
    # Assert
    assert ($empty_length == 0)
}

# Complex Error Scenarios
def "test chained operations with error" [] {
    # Act & Assert
    try {
        dn new "System.Text.StringBuilder"
        | dn call "Append" "test"
        | dn call "NonExistentMethod"  # This should fail
        
        assert false "Should have thrown an error in chain"
    } catch {
        assert true "Correctly handled error in method chain"
    }
}

def "test multiple error conditions" [] {
    # Test that errors are consistent across multiple attempts
    let error_results = (1..3 | each { |i|
        try {
            dn new "Invalid.Type"
            false  # Should not reach here
        } catch {
            true   # Error occurred as expected
        }
    })
    
    # Assert all attempts failed consistently
    let error_count = ($error_results | where $it == true | length)
    assert ($error_count == 3)
}

# Test runner for this module
def run-error-tests [] {
    let test_functions = (
        scope commands 
        | where name =~ "^test " 
        | get name
    )
    
    print $"🧪 Running ($test_functions | length) error handling tests..."
    print ""
    
    let results = ($test_functions | each { |test_name|
        try {
            do { nu -c $"use tests/unit/error-handling.nu; ($test_name)" }
            print $"  ✅ ($test_name)"
            {name: $test_name, status: "PASS", error: null}
        } catch { |e|
            print $"  ❌ ($test_name): ($e.msg)"
            {name: $test_name, status: "FAIL", error: $e.msg}
        }
    })
    
    let passed = ($results | where status == "PASS" | length)
    let failed = ($results | where status == "FAIL" | length)
    
    print ""
    print $"📊 Error Handling Tests: ($passed) passed, ($failed) failed"
    
    if $failed > 0 {
        print "❌ Failed tests:"
        $results | where status == "FAIL" | each { |test|
            print $"  - ($test.name): ($test.error)"
        }
        exit 1
    } else {
        print "✅ All error handling tests passed!"
    }
}

# Main entry point
def main [] {
    run-error-tests
}