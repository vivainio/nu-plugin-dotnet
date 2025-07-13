#!/usr/bin/env nu

# Unit tests for assembly and type discovery operations
# Tests dn assemblies, dn types, and dn members commands

use std assert

# Assembly Discovery Tests
def "test dn-assemblies returns list" [] {
    # Act
    let assemblies = (dn assemblies)
    
    # Assert
    assert (($assemblies | describe) | str contains "list")
    assert (($assemblies | length) > 0)
}

def "test dn-assemblies contains System assemblies" [] {
    # Act
    let assemblies = (dn assemblies)
    let system_assemblies = ($assemblies | get name | where ($it | str contains "System"))
    
    # Assert
    assert (($system_assemblies | length) > 0)
}

def "test dn-assemblies contains plugin assembly" [] {
    # Act
    let assemblies = (dn assemblies)
    let plugin_assembly = ($assemblies | get name | where ($it | str contains "nu_plugin_dotnet"))
    
    # Assert
    assert (($plugin_assembly | length) > 0)
}

# Type Discovery Tests
def "test dn-types lists CoreLib types" [] {
    # Act
    let types = (dn types "System.Private.CoreLib")
    
    # Assert
    assert (($types | describe) | str contains "list")
    assert (($types | length) > 100)
}

def "test dn-types finds String type" [] {
    # Act
    let types = (dn types "System.Private.CoreLib")
    let string_types = ($types | get name | where $it == "String")
    
    # Assert
    assert (($string_types | length) > 0)
}

def "test dn-types finds DateTime type" [] {
    # Act
    let types = (dn types "System.Private.CoreLib")
    let datetime_types = ($types | get name | where $it == "DateTime")
    
    # Assert
    assert (($datetime_types | length) > 0)
}

def "test dn-types finds Object type" [] {
    # Act
    let types = (dn types "System.Private.CoreLib")
    let object_types = ($types | get name | where $it == "Object")
    
    # Assert
    assert (($object_types | length) > 0)
}

# Member Discovery Tests
def "test dn-members lists String members" [] {
    # Act
    let members = (dn members "System.String")
    
    # Assert
    assert (($members | describe) | str contains "list")
    assert (($members | length) > 10)
}

def "test dn-members finds String Length property" [] {
    # Act
    let members = (dn members "System.String")
    let length_members = ($members | where name == "Length")
    
    # Assert
    assert (($length_members | length) > 0)
    assert (($length_members | first | get memberType) == "Property")
}

def "test dn-members finds String Contains method" [] {
    # Act
    let members = (dn members "System.String")
    let contains_members = ($members | where name == "Contains")
    
    # Assert
    assert (($contains_members | length) > 0)
    assert (($contains_members | get memberType | any { $it == "Method" }))
}

def "test dn-members lists Math members" [] {
    # Act
    let members = (dn members "System.Math")
    
    # Assert
    assert (($members | describe) | str contains "list")
    assert (($members | length) > 20)
}

def "test dn-members finds Math Max method" [] {
    # Act
    let members = (dn members "System.Math")
    let max_members = ($members | where name == "Max")
    
    # Assert
    assert (($max_members | length) > 0)
    assert (($max_members | get memberType | any { $it == "Method" }))
}

def "test dn-members finds Math PI field" [] {
    # Act
    let members = (dn members "System.Math")
    let pi_members = ($members | where name == "PI")
    
    # Assert
    assert (($pi_members | length) > 0)
    assert (($pi_members | first | get memberType) == "Field")
}

# Type Information Tests
def "test assembly type counts are reasonable" [] {
    # Act
    let core_types = (dn types "System.Private.CoreLib" | length)
    let runtime_types = (dn types "System.Runtime" | length)
    
    # Assert - CoreLib should have significantly more types than Runtime
    assert ($core_types > $runtime_types)
    assert ($core_types > 500)  # CoreLib is large
}

def "test member filtering by type" [] {
    # Act
    let string_members = (dn members "System.String")
    let methods = ($string_members | where memberType == "Method")
    let properties = ($string_members | where memberType == "Property")
    
    # Assert
    assert (($methods | length) > 0)
    assert (($properties | length) > 0)
    assert (($methods | length) > ($properties | length))  # String has more methods than properties
}

# Test runner for this module
def run-assembly-tests [] {
    let test_functions = (
        scope commands 
        | where name =~ "^test " 
        | get name
    )
    
    print $"🧪 Running ($test_functions | length) assembly operation tests..."
    print ""
    
    let results = ($test_functions | each { |test_name|
        try {
            do { nu -c $"use tests/unit/assembly-operations.nu; ($test_name)" }
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
    print $"📊 Assembly Tests: ($passed) passed, ($failed) failed"
    
    if $failed > 0 {
        print "❌ Failed tests:"
        $results | where status == "FAIL" | each { |test|
            print $"  - ($test.name): ($test.error)"
        }
        exit 1
    } else {
        print "✅ All assembly operation tests passed!"
    }
}

# Main entry point
def main [] {
    run-assembly-tests
}