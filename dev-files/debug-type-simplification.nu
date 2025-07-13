#!/usr/bin/env nu

# Debug script to test type name simplification
print "=== Debugging Type Name Simplification ==="
print ""

print "Testing basic types (should remain unchanged):"
print "System.Object:"
nu -c 'dn new "System.Object"'

print ""
print "System.String:"
nu -c 'dn new "System.String"'

print ""
print "Testing generic types (should be simplified):"
print "Generic List[String]:"
nu -c 'dn new "System.Collections.Generic.List`1[System.String]"'

print ""
print "Generic Dictionary[String,Int32]:"
nu -c 'dn new "System.Collections.Generic.Dictionary`2[System.String,System.Int32]"'

print ""
print "=== Analysis ==="
print "If we still see assembly info or double brackets, the simplification isn't working correctly." 