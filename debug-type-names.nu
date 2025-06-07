#!/usr/bin/env nu

# Debug script to examine exact type name formats
print "=== Debugging Type Name Formats ==="
print ""

print "Creating generic list and examining its type name format:"
let list = (dn new "System.Collections.Generic.List`1[System.String]")
print $"Raw output: ($list)"
print ""

print "Creating generic dictionary:"
let dict = (dn new "System.Collections.Generic.Dictionary`2[System.String,System.Int32]")
print $"Raw output: ($dict)"
print ""

print "Let's examine the exact characters in the type name..."
print "This will help us understand the pattern to match for simplification." 