#!/usr/bin/env nu

# Advanced test suite using nutest-style annotations
# This demonstrates the modern approach with @test annotations

# Note: This requires the nutest framework to be installed
# Install with: nupm install nutest

@before-all
def setup-test-environment [] {
    print "🔧 Setting up test environment..."
    
    # Verify plugin is available
    if not (which dn | is-not-empty) {
        error make {msg: "nu-plugin-dotnet not found. Please install and register the plugin."}
    }
    
    print "✅ Plugin verified"
}

@after-all 
def cleanup-test-environment [] {
    print "🧹 Cleaning up test environment..."
}

@before-each
def setup-each-test [] {
    # Setup that runs before each individual test
    # Could clear any global state, reset counters, etc.
}

@test
def "should create basic .NET objects" [] {
    use std assert
    
    # Test multiple object types
    let objects = [
        "System.Object",
        "System.Text.StringBuilder", 
        "System.Collections.ArrayList"
    ]
    
    for obj_type in $objects {
        let result = (dn new $obj_type)
        assert ($result | describe) =~ "custom"
        assert ($result | str contains ($obj_type | split row "." | last))
    }
}

@test
def "should support generic collections with modern syntax" [] {
    use std assert
    
    let generic_types = [
        "List<string>",
        "Dictionary<string, int>",
        "HashSet<string>"
    ]
    
    for type_name in $generic_types {
        let result = (dn new $type_name)
        assert ($result | describe) =~ "custom"
    }
}

@test
def "should perform method calls correctly" [] {
    use std assert
    
    # Instance method test
    let sb = (dn new "System.Text.StringBuilder")
    let result = ($sb | dn call "Append" "Test")
    assert ($result | str contains "StringBuilder")
    
    # Static method test  
    let max_result = ("System.Math" | dn call "Max" 15 25)
    assert equal $max_result 25
}

@test
def "should access properties correctly" [] {
    use std assert
    
    # String length
    let length = ("Hello" | dn get "Length")
    assert equal $length 5
    
    # Static property
    let now = ("System.DateTime" | dn get "Now")
    assert ($now | str contains "DateTime")
}

@test  
def "should list assemblies and types" [] {
    use std assert
    
    # Test assemblies command
    let assemblies = (dn assemblies)
    assert ($assemblies | describe) == "table"
    assert ($assemblies | length) > 0
    
    # Test types command
    let types = (dn types "System.Private.CoreLib" | first 10)
    assert ($types | describe) == "table"
    assert ($types | length) == 10
}

@test
def "should handle custom DLL loading" [] {
    use std assert
    
    let dll_path = ($env.PWD | path join "TestLibrary" "bin" "Release" "net8.0" "TestLibrary.dll")
    
    if ($dll_path | path exists) {
        # Test DLL loading
        dn load $dll_path
        
        # Test custom method call
        let factorial = ("TestLibrary.MathUtilities" | dn call "Factorial" 4)
        assert equal $factorial 24
        
        let reversed = ("TestLibrary.StringUtilities" | dn call "Reverse" "hello")
        assert equal $reversed "olleh"
    } else {
        print "⏭️ Skipping custom DLL test - TestLibrary.dll not found"
    }
}

@test
def "should handle errors gracefully" [] {
    use std assert
    
    # Test invalid type creation
    try {
        dn new "Invalid.Type.Name"
        assert false "Should have failed"
    } catch {
        assert true "Correctly handled invalid type"
    }
    
    # Test invalid method call
    try {
        let obj = (dn new "System.Object")
        $obj | dn call "NonExistentMethod"
        assert false "Should have failed"
    } catch {
        assert true "Correctly handled invalid method"
    }
}

@test
def "should support method chaining" [] {
    use std assert
    
    let result = (
        dn new "System.Text.StringBuilder"
        | dn call "Append" "Hello"
        | dn call "Append" " "  
        | dn call "Append" "World"
        | dn call "ToString"
    )
    
    assert equal $result "Hello World"
}

@test
def "should support both old and new generic syntax" [] {
    use std assert
    
    # New user-friendly syntax
    let new_list = (dn new "List<string>")
    $new_list | dn call "Add" "item1"
    let new_count = ($new_list | dn get "Count")
    
    # Old .NET internal syntax  
    let old_list = (dn new "System.Collections.Generic.List`1[System.String]")
    $old_list | dn call "Add" "item1"
    let old_count = ($old_list | dn get "Count")
    
    # Both should work identically
    assert equal $new_count $old_count
    assert equal $new_count 1
}

# Main entry point for standalone execution
def main [] {
    print "🧪 Nu Plugin .NET Test Suite (Nutest Style)"
    print "This requires the nutest framework to run properly."
    print "Install with: nupm install nutest"
    print "Then run with: nutest run-tests"
    print ""
    print "For standalone execution, use: nu tests/modern-plugin-tests.nu"
}