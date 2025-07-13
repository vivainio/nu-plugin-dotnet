#!/usr/bin/env nu

# Unit tests for basic nu-plugin-dotnet functionality
# Tests core object creation, method calls, and property access

use std assert

# Object Creation Tests
def "test dn-new creates StringBuilder" [] {
    # Arrange
    let type_name = "System.Text.StringBuilder"
    
    # Act
    let result = (dn new $type_name)
    
    # Assert
    assert (($result | describe) == "string")
    assert ($result | str contains "StringBuilder")
}

def "test dn-new creates ArrayList" [] {
    # Arrange & Act
    let result = (dn new "System.Collections.ArrayList")
    
    # Assert
    assert (($result | describe) == "string")
    assert ($result | str contains "ArrayList")
}

def "test dn-new creates System.Object" [] {
    # Arrange & Act
    let result = (dn new "System.Object")
    
    # Assert
    assert (($result | describe) == "string")
    assert ($result | str contains "System.Object")
}

def "test dn-new creates generic List" [] {
    # Arrange & Act
    let result = (dn new "List<string>")
    
    # Assert
    assert (($result | describe) == "string")
    assert ($result | str contains "List")
}

def "test dn-new creates generic Dictionary" [] {
    # Arrange & Act
    let result = (dn new "Dictionary<string, int>")
    
    # Assert
    assert (($result | describe) == "string")
    assert ($result | str contains "Dictionary")
}

def "test dn-new creates generic HashSet" [] {
    # Arrange & Act
    let result = (dn new "HashSet<string>")
    
    # Assert
    assert (($result | describe) == "string")
    assert ($result | str contains "HashSet")
}

# Method Call Tests
def "test dn-call StringBuilder Append" [] {
    # Arrange
    let sb = (dn new "System.Text.StringBuilder")
    let test_text = "Hello World"
    
    # Act
    let result = ($sb | dn call "Append" $test_text)
    
    # Assert
    assert (($result | describe) == "string")
    assert ($result | str contains "StringBuilder")
}

def "test dn-call static Math.Max" [] {
    # Arrange
    let a = 10
    let b = 20
    
    # Act
    let result = ("System.Math" | dn call "Max" $a $b)
    
    # Assert
    assert ($result == 20)
}

def "test dn-call static Math.Min" [] {
    # Arrange
    let a = 10
    let b = 20
    
    # Act
    let result = ("System.Math" | dn call "Min" $a $b)
    
    # Assert
    assert ($result == 10)
}

def "test dn-call static Guid.NewGuid" [] {
    # Act
    let result = ("System.Guid" | dn call "NewGuid")
    
    # Assert
    assert (($result | describe) == "string")
    assert ($result | str contains "Guid")
}

def "test dn-call method chaining" [] {
    # Arrange & Act
    let result = (
        dn new "System.Text.StringBuilder"
        | dn call "Append" "Hello"
        | dn call "Append" " "
        | dn call "Append" "World"
        | dn call "ToString"
    )
    
    # Assert
    assert ($result == "Hello World")
}

# Property Access Tests
def "test dn-get string Length" [] {
    # Arrange
    let test_string = "Hello World"
    
    # Act
    let length = ($test_string | dn get "Length")
    
    # Assert
    assert ($length == 11)
}

def "test dn-get DateTime Now" [] {
    # Act
    let now = ("System.DateTime" | dn get "Now")
    
    # Assert
    assert (($now | describe) == "string")
    assert ($now | str contains "DateTime")
}

def "test dn-get Environment MachineName" [] {
    # Act
    let machine_name = ("System.Environment" | dn get "MachineName")
    
    # Assert
    assert (($machine_name | describe) == "string")
    assert (($machine_name | str length) > 0)
}

def "test dn-get Math PI" [] {
    # Act
    let pi = ("System.Math" | dn get "PI")
    
    # Assert
    assert ($pi > 3.14)
    assert ($pi < 3.15)
}

# Collection Operations Tests
def "test ArrayList Add and Count" [] {
    # Arrange
    let list = (dn new "System.Collections.ArrayList")
    
    # Act
    $list | dn call "Add" "item1"
    $list | dn call "Add" "item2"
    let count = ($list | dn get "Count")
    
    # Assert
    assert ($count == 2)
}

def "test generic List Add and Count" [] {
    # Arrange
    let list = (dn new "List<string>")
    
    # Act
    $list | dn call "Add" "item1"
    $list | dn call "Add" "item2"
    let count = ($list | dn get "Count")
    
    # Assert
    assert ($count == 2)
}

def "test Dictionary Add and Count" [] {
    # Arrange
    let dict = (dn new "Dictionary<string, int>")
    
    # Act
    $dict | dn call "Add" "key1" 100
    $dict | dn call "Add" "key2" 200
    let count = ($dict | dn get "Count")
    
    # Assert
    assert ($count == 2)
}

# Test runner for this module
def run-basic-tests [] {
    let test_functions = (
        scope commands 
        | where name =~ "^test " 
        | get name
    )
    
    print $"🧪 Running ($test_functions | length) basic functionality tests..."
    print ""
    
    let results = ($test_functions | each { |test_name|
        try {
            do { nu -c $"use tests/unit/basic-functionality.nu; ($test_name)" }
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
    print $"📊 Basic Tests: ($passed) passed, ($failed) failed"
    
    if $failed > 0 {
        print "❌ Failed tests:"
        $results | where status == "FAIL" | each { |test|
            print $"  - ($test.name): ($test.error)"
        }
        exit 1
    } else {
        print "✅ All basic functionality tests passed!"
    }
}

# Main entry point
def main [] {
    run-basic-tests
}