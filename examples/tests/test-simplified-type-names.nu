#!/usr/bin/env nu

# Test script to demonstrate simplified generic type names
print "=== Testing Simplified Generic Type Names ==="
print ""

print "✅ BEFORE: System.Collections.Generic.List`1[[System.String, System.Private.CoreLib, Version=8.0.0.0, Culture=neutral, PublicKeyToken=7cec85d7bea7798e]]@<guid>"
print "✅ NOW: System.Collections.Generic.List`1[System.String]@<guid>"
print ""

print "1. Generic List with String:"
let list = (dn new "System.Collections.Generic.List`1[System.String]")
print $list

print ""
print "2. Generic Dictionary with String keys and Int32 values:"
let dict = (dn new "System.Collections.Generic.Dictionary`2[System.String,System.Int32]")
print $dict

print ""
print "3. Add items and test operations:"
print "Add item to list:"
let list_with_item = ($list | dn call "Add" "Hello World")
print $list_with_item

print ""
print "Add key-value to dictionary:"
let dict_with_item = ($dict | dn call "Add" "count" 42)
print $dict_with_item

print ""
print "4. Nested generic types (if they work):"
print "List of Lists:"
# This might be complex to create, but let's try
try {
    let nested_list = (dn new "System.Collections.Generic.List`1[System.Collections.Generic.List`1[System.String]]")
    print $nested_list
} catch { |err|
    print $"Could not create nested generic: ($err.msg)"
}

print ""
print "5. Non-generic types remain unchanged:"
print "System.Object:"
let obj = (dn new "System.Object")
print $obj

print ""
print "System.Text.StringBuilder:"
let sb = (dn new "System.Text.StringBuilder")
print $sb

print ""
print "=== COMPARISON ==="
print "BEFORE (noisy): System.Collections.Generic.List`1[[System.String, System.Private.CoreLib, Version=8.0.0.0, Culture=neutral, PublicKeyToken=7cec85d7bea7798e]]@12345678-1234-1234-1234-123456789abc"
print "AFTER (clean):  System.Collections.Generic.List`1[System.String]@12345678-1234-1234-1234-123456789abc"
print ""
print "🎉 Much cleaner and easier to read!"
print ""
print "=== SIMPLIFIED TYPE NAMES TEST COMPLETE ===" 