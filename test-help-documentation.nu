#!/usr/bin/env nu

# Test script to validate all help documentation examples
# This tests every command and example from PLUGIN_COMMANDS_HELP.md

print "=== Testing Nu Plugin .NET Help Documentation ==="
print ""

# Helper function to test and report results
def test_command [description: string, command: closure] {
    print $"Testing: ($description)"
    try {
        let result = (do $command)
        print $"  ✅ SUCCESS: ($result | describe)"
        $result
    } catch { |e|
        print $"  ❌ FAILED: ($e.msg)"
        null
    }
}

print "=== Testing dn new command ==="

# Test basic object creation
test_command "Basic System.Object creation" { dn new "System.Object" }
test_command "StringBuilder creation" { dn new "System.Text.StringBuilder" }
test_command "ArrayList creation" { dn new "System.Collections.ArrayList" }

# Test objects with constructor arguments
test_command "StringBuilder with initial text" { dn new "System.Text.StringBuilder" "Initial text" }

# Test generic collections (from help documentation)
test_command "Generic List of strings" { dn new "System.Collections.Generic.List`1[System.String]" }
test_command "Generic Dictionary" { dn new "System.Collections.Generic.Dictionary`2[System.String,System.Int32]" }

print ""
print "=== Testing dn call command ==="

# Test instance method calls
test_command "StringBuilder Append method" { 
    dn new "System.Text.StringBuilder" | dn call "Append" "Hello"
}

test_command "ArrayList Add method" { 
    dn new "System.Collections.ArrayList" | dn call "Add" "item1"
}

# Test static method calls
test_command "System.Guid NewGuid static method" { 
    "System.Guid" | dn call "NewGuid"
}

test_command "System.DateTime Now static property via call" { 
    "System.DateTime" | dn call "get_Now"
}

test_command "Environment GetEnvironmentVariable" { 
    "System.Environment" | dn call "GetEnvironmentVariable" "PATH"
}

# Test method chaining
test_command "Method chaining example" {
    dn new "System.Text.StringBuilder" 
    | dn call "Append" "Hello " 
    | dn call "Append" "World" 
    | dn call "ToString"
}

print ""
print "=== Testing dn get command ==="

# Test instance property access
test_command "StringBuilder Length property" { 
    dn new "System.Text.StringBuilder" "Hello" | dn get "Length"
}

test_command "ArrayList Count property" { 
    dn new "System.Collections.ArrayList" | dn get "Count"
}

# Test static property access
test_command "DateTime Now static property" { 
    "System.DateTime" | dn get "Now"
}

test_command "Environment MachineName" { 
    "System.Environment" | dn get "MachineName"
}

test_command "Environment ProcessorCount" { 
    "System.Environment" | dn get "ProcessorCount"
}

# Test indexed property access
test_command "String indexer access" { 
    "Hello World" | dn get "Item" 0
}

# Test field access
test_command "String Empty field" { 
    "System.String" | dn get "Empty"
}

print ""
print "=== Testing dn set command ==="

# Test setting properties (create object first, then set)
test_command "Create StringBuilder and set capacity" {
    let sb = (dn new "System.Text.StringBuilder")
    $sb | dn set "Capacity" 100
    $sb | dn get "Capacity"
}

print ""
print "=== Testing dn load-assembly command ==="

# Test loading system assemblies by name
test_command "Load System.Xml assembly" { 
    dn load-assembly "System.Xml"
}

print ""
print "=== Testing dn assemblies command ==="

# Test listing loaded assemblies
test_command "List all loaded assemblies" { 
    dn assemblies | length
}

test_command "Filter assemblies by name" { 
    dn assemblies | where name =~ "System" | length
}

test_command "Show assembly names and versions" { 
    dn assemblies | select name version | first 3
}

print ""
print "=== Testing dn types command ==="

# Test listing types in assemblies
test_command "List types in mscorlib" { 
    dn types "mscorlib" | length
}

test_command "Filter types by name" { 
    dn types "mscorlib" | where name =~ "String" | length
}

test_command "Show interface types only" { 
    dn types "mscorlib" | where isInterface == true | length
}

print ""
print "=== Testing dn members command ==="

# Test listing members of types
test_command "List all String members" { 
    dn members "System.String" | length
}

test_command "List only String methods" { 
    dn members "System.String" --type methods | length
}

test_command "List only DateTime properties" { 
    dn members "System.DateTime" --type properties | length
}

print ""
print "=== Testing dn obj command ==="

# Test object conversion
test_command "Convert DateTime to nushell record" { 
    dn new "System.DateTime" | dn obj | get __type__
}

test_command "Type inspection" { 
    "System.String" | dn obj | get name
}

test_command "Convert ArrayList to nushell" { 
    dn new "System.Collections.ArrayList" | dn obj | get __type__
}

test_command "Convert after method calls" { 
    dn new "System.Text.StringBuilder" "Hello" 
    | dn call "Append" " World" 
    | dn obj 
    | get __type__
}

print ""
print "=== Testing Common Patterns from Help ==="

# Test working with collections pattern
test_command "Create and populate generic list" {
    let list = (dn new "System.Collections.Generic.List`1[System.String]")
    $list | dn call "Add" "item1"
    $list | dn call "Add" "item2"
    $list | dn call "get_Count"
}

test_command "Create and use dictionary" {
    let dict = (dn new "System.Collections.Generic.Dictionary`2[System.String,System.Int32]")
    $dict | dn call "Add" "key1" 42
    $dict | dn call "Add" "key2" 84
    $dict | dn call "get_Count"
}

# Test static method calls pattern
test_command "File operations pattern" { 
    "System.IO.Directory" | dn call "GetCurrentDirectory"
}

test_command "GUID generation pattern" { 
    "System.Guid" | dn call "NewGuid" | dn call "ToString"
}

# Test type discovery pattern
test_command "Assembly exploration" { 
    dn assemblies | select name version | length
}

test_command "Type filtering" { 
    dn types "mscorlib" | where name =~ "String" | length
}

test_command "Member exploration" { 
    dn members "System.String" --type methods | where name =~ "Sub" | length
}

# Test object lifecycle pattern
test_command "Complete object lifecycle" {
    let sb = (dn new "System.Text.StringBuilder")
    $sb | dn call "Append" "Hello"
    $sb | dn call "Append" " "
    $sb | dn call "Append" "World"
    let result = ($sb | dn call "ToString")
    $result
}

print ""
print "=== Testing Error Scenarios ==="

# Test error handling as documented
test_command "Type not found error" { 
    try { dn new "NonExistentType" } catch { |e| $"Error caught: ($e.msg)" }
}

test_command "Method not found error" { 
    try { dn new "System.String" | dn call "NonExistentMethod" } catch { |e| $"Error caught: ($e.msg)" }
}

print ""
print "=== Advanced Generic Collections Tests ==="

# Test all the generic types from our previous work
test_command "Generic List with various types" {
    let stringList = (dn new "System.Collections.Generic.List`1[System.String]")
    $stringList | dn call "Add" "test"
    $stringList | dn call "get_Count"
}

test_command "Generic Dictionary operations" {
    let dict = (dn new "System.Collections.Generic.Dictionary`2[System.String,System.Int32]")
    $dict | dn call "Add" "count" 5
    $dict | dn call "ContainsKey" "count"
}

test_command "Generic Queue operations" {
    let queue = (dn new "System.Collections.Generic.Queue`1[System.String]")
    $queue | dn call "Enqueue" "first"
    $queue | dn call "Enqueue" "second"
    $queue | dn call "get_Count"
}

print ""
print "=== Testing Parameter Documentation Accuracy ==="

# Verify that parameter descriptions match actual behavior

# dn new: type (required), args (optional), --assembly (optional)
test_command "dn new with all parameters" {
    # This should work as documented
    dn new "System.Text.StringBuilder" "test" 
}

# dn call: method (required), args (optional)
test_command "dn call with method and args" {
    dn new "System.Text.StringBuilder" | dn call "Append" "test"
}

# dn get: property (required), index (optional for indexed properties)
test_command "dn get with property name" {
    dn new "System.Text.StringBuilder" "test" | dn get "Length"
}

print ""
print "=== Final Summary ==="
print "Help documentation testing completed!"
print "All examples from PLUGIN_COMMANDS_HELP.md have been tested."
print "Check the results above for any failures that need documentation updates." 