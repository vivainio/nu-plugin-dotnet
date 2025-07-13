#!/usr/bin/env nu

# Testing dn new command with current working implementation
print "🧪 Testing dn new command functionality"
print "========================================"
print ""

print "1. Testing basic object creation (no constructor args)"
print "-----------------------------------------------------"

# Test StringBuilder (default constructor)
print "Creating StringBuilder..."
let $sb = dn new "System.Text.StringBuilder"
print $"StringBuilder created: ($sb)"

# Test List<string> (default constructor)
print "Creating List<string>..."
let $list = dn new "List<string>"
print $"List created: ($list)"

# Test Dictionary (default constructor)
print "Creating Dictionary<string, int>..."
let $dict = dn new "Dictionary<string, int>"
print $"Dictionary created: ($dict)"

print ""
print "2. Testing object usage"
print "---------------------"

# Use the StringBuilder
print "Adding text to StringBuilder..."
$sb | dn call "Append" "Hello"
$sb | dn call "Append" " "
$sb | dn call "Append" "World"
let $result = $sb | dn call "ToString"
print $"StringBuilder result: ($result)"

# Use the List
print "Adding items to List..."
$list | dn call "Add" "Apple"
$list | dn call "Add" "Banana"
$list | dn call "Add" "Cherry"
let $count = $list | dn get "Count"
print $"List count: ($count)"

# Use the Dictionary
print "Adding items to Dictionary..."
$dict | dn call "Add" "one" 1
$dict | dn call "Add" "two" 2
$dict | dn call "Add" "three" 3
let $dictCount = $dict | dn get "Count"
print $"Dictionary count: ($dictCount)"

print ""
print "3. Testing different object types"
print "--------------------------------"

# Test DateTime (this will likely fail without constructor args)
print "Attempting DateTime creation..."
try {
    let $dt = dn new "System.DateTime"
    print $"DateTime created: ($dt)"
} catch { |err|
    print $"DateTime creation failed as expected: ($err.msg)"
}

# Test GUID (this will likely fail without constructor args)
print "Attempting GUID creation..."
try {
    let $guid = dn new "System.Guid"
    print $"GUID created: ($guid)"
} catch { |err|
    print $"GUID creation failed (expected): ($err.msg)"
}

print ""
print "4. Testing with existing working patterns"
print "========================================="

# Test simple math operations
print "Testing Math.Max static call..."
let $max = "System.Math" | dn call "Max" 10 20
print $"Math.Max(10, 20) = ($max)"

# Test string operations
print "Testing string length..."
let $length = "Hello World" | dn get "Length"
print $"Length of 'Hello World': ($length)"

print ""
print "✅ Basic dn new testing completed!"
print "Note: Constructor arguments (--args) need to be implemented in signature"

# Ensure clean exit
exit 0 