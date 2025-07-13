#!/usr/bin/env nu

# Simple test for dn new command
print "🧪 Simple dn new command test"
print "=============================="
print ""

print "Loading required assemblies..."
# Note: Basic .NET assemblies are already loaded automatically
# Using built-in assemblies that are already available
print ""

print "1. Testing StringBuilder"
print "-----------------------"
let $sb = dn new "System.Text.StringBuilder"
print $"StringBuilder: ($sb)"

$sb | dn call "Append" "Hello"
$sb | dn call "Append" " World"
let $result = $sb | dn call "ToString"
print $"Result: ($result)"
print ""

print "2. Testing basic types that should work"
print "--------------------------------------"

# Test objects that should have parameterless constructors
print "Testing System.Object..."
let $obj = dn new "System.Object"
print $"Object: ($obj)"

print "Testing System.Collections.ArrayList..."
let $arrayList = dn new "System.Collections.ArrayList"
print $"ArrayList: ($arrayList)"
$arrayList | dn call "Add" "Item1"
$arrayList | dn call "Add" "Item2"
let $count = $arrayList | dn get "Count"
print $"ArrayList count: ($count)"
print ""

print "3. Testing static methods (known to work)"
print "----------------------------------------"
let $max = ("System.Math" | dn call "Max" 42 17)
print $"Math.Max result = ($max)"

let $pi = "System.Math" | dn get "PI"
print $"Math.PI = ($pi)"
print ""

print "✅ Basic tests completed!"

# Ensure clean exit
exit 0 