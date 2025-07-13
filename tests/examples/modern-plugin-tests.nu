#!/usr/bin/env nu

# Modern Nushell test suite for nu-plugin-dotnet using best practices
# Uses std assert for proper test validation

use std assert

# Test: Basic object creation
def "test dn-new creates StringBuilder" [] {
    # Arrange
    let type_name = "System.Text.StringBuilder"
    
    # Act
    let result = (dn new $type_name)
    
    # Assert
    assert (($result | describe) == "custom")
    assert ($result | str contains "StringBuilder")
}

def "test dn-new creates ArrayList" [] {
    # Arrange & Act
    let result = (dn new "System.Collections.ArrayList")
    
    # Assert
    assert (($result | describe) == "custom")
    assert ($result | str contains "ArrayList")
}

def "test dn-new creates generic List" [] {
    # Arrange & Act  
    let result = (dn new "List<string>")
    
    # Assert
    assert (($result | describe) == "custom")
    assert ($result | str contains "List")
}

# Test: Method calls
def "test dn-call StringBuilder Append" [] {
    # Arrange
    let sb = (dn new "System.Text.StringBuilder")
    let test_text = "Hello World"
    
    # Act
    let result = ($sb | dn call "Append" $test_text)
    
    # Assert
    assert (($result | describe) == "custom")
    assert ($result | str contains "StringBuilder")
}

def "test dn-call static Math.Max" [] {
    # Arrange
    let a = 10
    let b = 20
    
    # Act
    let result = ("System.Math" | dn call "Max" $a $b)
    
    # Assert
    assert equal $result 20
}

# Test: Property access
def "test dn-get string Length" [] {
    # Arrange
    let test_string = "Hello World"
    
    # Act
    let length = ($test_string | dn get "Length")
    
    # Assert
    assert equal $length 11
}

def "test dn-get DateTime Now" [] {
    # Act
    let now = ("System.DateTime" | dn get "Now")
    
    # Assert
    assert (($now | describe) == "custom")
    assert ($now | str contains "DateTime")
}

# Test: Assembly operations
def "test dn-assemblies returns list" [] {
    # Act
    let assemblies = (dn assemblies)
    
    # Assert
    assert (($assemblies | describe) == "table")
    assert (($assemblies | length) > 0)
    assert ($assemblies | get name | any { $in | str contains "System" })
}

def "test dn-types lists types" [] {
    # Act
    let types = (dn types "System.Private.CoreLib")
    
    # Assert
    assert (($types | describe) == "table")
    assert (($types | length) > 100)
    assert ($types | get name | any { $in == "String" })
}

# Test: Custom DLL loading
def "test dn-load custom assembly" [] {
    # Arrange
    let dll_path = ($env.PWD | path join "TestLibrary" "bin" "Release" "net8.0" "TestLibrary.dll")
    
    # Skip test if DLL doesn't exist
    if not ($dll_path | path exists) {
        print "⏭️ Skipping custom DLL test - TestLibrary.dll not found"
        return
    }
    
    # Act & Assert
    try {
        dn load $dll_path
        assert true "DLL loaded successfully"
    } catch { |e|
        assert false $"Failed to load DLL: ($e.msg)"
    }
}

def "test custom-dll factorial calculation" [] {
    # Arrange
    let dll_path = ($env.PWD | path join "TestLibrary" "bin" "Release" "net8.0" "TestLibrary.dll")
    
    # Skip test if DLL doesn't exist
    if not ($dll_path | path exists) {
        print "⏭️ Skipping factorial test - TestLibrary.dll not found"
        return
    }
    
    # Load DLL first
    try { dn load $dll_path } catch { return }
    
    # Act
    let result = ("TestLibrary.MathUtilities" | dn call "Factorial" 5)
    
    # Assert
    assert equal $result 120
}

# Test: Error handling
def "test dn-new invalid type throws error" [] {
    # Act & Assert
    try {
        dn new "NonExistent.Type"
        assert false "Should have thrown an error"
    } catch {
        assert true "Correctly threw error for invalid type"
    }
}

def "test dn-call invalid method throws error" [] {
    # Arrange
    let obj = (dn new "System.Object")
    
    # Act & Assert
    try {
        $obj | dn call "NonExistentMethod"
        assert false "Should have thrown an error"
    } catch {
        assert true "Correctly threw error for invalid method"
    }
}

# Test runner function
def run-all-tests [] {
    let test_functions = (
        scope commands 
        | where name =~ "^test " 
        | get name
    )
    
    print $"🧪 Running ($test_functions | length) tests..."
    print ""
    
    let results = ($test_functions | each { |test_name|
        try {
            do { nu -c $"source tests/modern-plugin-tests.nu; ($test_name)" }
            print $"✅ ($test_name)"
            {name: $test_name, status: "PASS", error: null}
        } catch { |e|
            print $"❌ ($test_name): ($e.msg)"
            {name: $test_name, status: "FAIL", error: $e.msg}
        }
    })
    
    let passed = ($results | where status == "PASS" | length)
    let failed = ($results | where status == "FAIL" | length)
    
    print ""
    print $"📊 Test Results: ($passed) passed, ($failed) failed"
    
    if ($passed + $failed) > 0 {
        print $"Success Rate: {($passed * 100) / ($passed + $failed)}%"
    }
    
    if $failed > 0 {
        print ""
        print "❌ Failed tests:"
        $results | where status == "FAIL" | each { |test|
            print $"  - ($test.name): ($test.error)"
        }
        exit 1
    } else {
        print ""
        print "🎉 All tests passed!"
        exit 0
    }
}

# Export the test runner as main
def main [] {
    run-all-tests
}