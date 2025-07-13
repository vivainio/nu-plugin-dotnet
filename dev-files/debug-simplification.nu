#!/usr/bin/env nu

# Debug script to understand type name formats
print "=== Testing Type Name Simplification ==="
print ""

print "Testing what type names look like..."
print ""

print "1. Simple non-generic type:"
let obj = (dn new "System.Object")
print $obj

print ""
print "2. StringBuilder (non-generic):"  
let sb = (dn new "System.Text.StringBuilder")
print $sb

print ""
print "3. Generic List:"
let list = (dn new "System.Collections.Generic.List`1[System.String]")
print $list

print ""
print "4. Generic Dictionary:"
let dict = (dn new "System.Collections.Generic.Dictionary`2[System.String,System.Int32]")
print $dict

print ""
print "=== Analysis ==="
print "We need to understand what's causing the double brackets and assembly info" 