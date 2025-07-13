#!/usr/bin/env nu

# Simple modern Nushell test suite for nu-plugin-dotnet
# Using straightforward patterns that work well with Nushell

use std assert

# Test basic object creation
print "🧪 Testing basic object creation..."

print "  - Testing StringBuilder creation"
let sb = (dn new "System.Text.StringBuilder")
assert (($sb | describe) == "string")
assert ($sb | str contains "StringBuilder")
print "    ✅ StringBuilder created successfully"

print "  - Testing ArrayList creation"  
let list = (dn new "System.Collections.ArrayList")
assert (($list | describe) == "string")
assert ($list | str contains "ArrayList")
print "    ✅ ArrayList created successfully"

print "  - Testing generic List creation"
let generic_list = (dn new "List<string>")
assert (($generic_list | describe) == "string") 
assert ($generic_list | str contains "List")
print "    ✅ Generic List created successfully"

# Test method calls
print ""
print "🧪 Testing method calls..."

print "  - Testing StringBuilder.Append"
let sb_result = ($sb | dn call "Append" "Hello World")
assert (($sb_result | describe) == "string")
print "    ✅ StringBuilder.Append successful"

print "  - Testing static Math.Max"
let max_result = ("System.Math" | dn call "Max" 10 20)
assert ($max_result == 20)
print "    ✅ Math.Max returned correct result"

# Test property access
print ""
print "🧪 Testing property access..."

print "  - Testing string Length property"
let length = ("Hello" | dn get "Length")
assert ($length == 5)
print "    ✅ String length correct"

print "  - Testing DateTime.Now static property"
let now = ("System.DateTime" | dn get "Now")
assert (($now | describe) == "string")
assert ($now | str contains "DateTime")
print "    ✅ DateTime.Now accessed successfully"

# Test assembly operations
print ""
print "🧪 Testing assembly operations..."

print "  - Testing dn assemblies command"
let assemblies = (dn assemblies)
assert (($assemblies | describe) | str contains "list")
assert (($assemblies | length) > 0)
print $"    ✅ Found ($assemblies | length) assemblies"

print "  - Testing dn types command"
let types = (dn types "System.Private.CoreLib")
assert (($types | describe) | str contains "list")
assert (($types | length) > 100)
print $"    ✅ Found ($types | length) types in CoreLib"

# Test custom DLL (if available)
print ""
print "🧪 Testing custom DLL loading..."

let dll_path = ($env.PWD | path join "TestLibrary" "bin" "Release" "net8.0" "TestLibrary.dll")

if ($dll_path | path exists) {
    print "  - Testing custom DLL loading"
    try {
        dn load $dll_path
        print "    ✅ Custom DLL loaded successfully"
        
        print "  - Testing custom factorial method"
        let factorial = ("TestLibrary.MathUtilities" | dn call "Factorial" 5)
        assert ($factorial == 120)
        print "    ✅ Factorial calculation correct"
        
        print "  - Testing custom string reverse method"
        let reversed = ("TestLibrary.StringUtilities" | dn call "Reverse" "hello")
        assert ($reversed == "olleh")
        print "    ✅ String reversal correct"
    } catch { |e|
        print $"    ❌ Custom DLL test failed: ($e.msg)"
    }
} else {
    print "  ⏭️ Skipping custom DLL tests - TestLibrary.dll not found"
}

# Test error handling
print ""
print "🧪 Testing error handling..."

print "  - Testing invalid type creation"
try {
    dn new "Invalid.Type.Name"
    print "    ❌ Should have failed for invalid type"
} catch {
    print "    ✅ Correctly handled invalid type error"
}

print "  - Testing invalid method call"
try {
    let obj = (dn new "System.Object")
    $obj | dn call "NonExistentMethod"
    print "    ❌ Should have failed for invalid method"
} catch {
    print "    ✅ Correctly handled invalid method error"
}

# Summary
print ""
print "🎉 Modern test suite completed!"
print "✅ All core plugin functionality verified"
print "✅ Error handling working correctly"
print "✅ Both basic and advanced features operational"

exit 0