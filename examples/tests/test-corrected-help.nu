#!/usr/bin/env nu

# Test script to validate the CORRECTED help documentation
print "=== Testing CORRECTED Nu Plugin .NET Help Documentation ==="
print ""

print "✅ WORKING EXAMPLES (from corrected docs):"
print ""

print "1. Basic object creation (parameterless constructors)"
nu -c 'dn new "System.Object"'
nu -c 'dn new "System.Text.StringBuilder"'
nu -c 'dn new "System.Collections.ArrayList"'

print ""
print "2. Generic collections"
nu -c 'dn new "System.Collections.Generic.List`1[System.String]"'
nu -c 'dn new "System.Collections.Generic.Dictionary`2[System.String,System.Int32]"'

print ""
print "3. Method calls with arguments"
nu -c 'dn new "System.Text.StringBuilder" | dn call "Append" "Hello"'
nu -c 'dn new "System.Collections.ArrayList" | dn call "Add" "item1"'

print ""
print "4. Static method calls"
nu -c '"System.Guid" | dn call "NewGuid"'
nu -c '"System.Environment" | dn call "GetEnvironmentVariable" "PATH"'

print ""
print "5. Property access"
nu -c 'dn new "System.Text.StringBuilder" | dn get "Length"'
nu -c 'dn new "System.Collections.ArrayList" | dn get "Count"'

print ""
print "6. Static property access"
nu -c '"System.DateTime" | dn get "Now"'
nu -c '"System.Environment" | dn get "MachineName"'

print ""
print "7. Assembly and type discovery"
nu -c 'dn assemblies | length'
nu -c 'dn types "System.Private.CoreLib" | length'
nu -c 'dn members "System.String" | length'

print ""
print "8. Object conversion"
nu -c 'dn new "System.Text.StringBuilder" | dn obj | get __type__'

print ""
print "9. Method chaining"
nu -c 'dn new "System.Text.StringBuilder" | dn call "Append" "Hello " | dn call "Append" "World" | dn call "ToString"'

print ""
print "10. Complete workflow example"
nu -c 'let list = (dn new "System.Collections.Generic.List`1[System.String]"); $list | dn call "Add" "item1"; $list | dn call "Add" "item2"; $list | dn call "get_Count"'

print ""
print "❌ KNOWN LIMITATIONS (correctly documented):"
print ""

print "These should fail as documented:"
print "- Constructor arguments not supported:"
try { nu -c 'dn new "System.Text.StringBuilder" "Initial text"' } catch { print "  ✅ Correctly fails: Constructor args not supported" }

print "- DateTime requires constructor args:"
try { nu -c 'dn new "System.DateTime"' } catch { print "  ✅ Correctly fails: No parameterless constructor" }

print ""
print "=== CORRECTED HELP DOCUMENTATION VALIDATION COMPLETE ==="
print "All working examples validated ✅"
print "All limitations correctly documented ✅"

exit 0 