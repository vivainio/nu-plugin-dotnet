#!/usr/bin/env nu

# Test script to demonstrate the new readable custom object format
print "=== Testing Readable Custom Object Names ==="
print ""

print "✅ BEFORE: Objects showed as __CUSTOM_OBJECT__<guid>__"
print "✅ NOW: Objects show as TypeName@<guid>"
print ""

print "1. Basic objects with readable type names:"
print "System.Object:"
nu -c 'dn new "System.Object"'

print ""
print "System.Text.StringBuilder:"
nu -c 'dn new "System.Text.StringBuilder"'

print ""
print "System.Collections.ArrayList:"
nu -c 'dn new "System.Collections.ArrayList"'

print ""
print "2. Generic collections with full type information:"
print "Generic List[String]:"
nu -c 'dn new "System.Collections.Generic.List`1[System.String]"'

print ""
print "Generic Dictionary[String,Int32]:"
nu -c 'dn new "System.Collections.Generic.Dictionary`2[System.String,System.Int32]"'

print ""
print "3. Method calls returning custom objects:"
print "StringBuilder after Append:"
nu -c 'dn new "System.Text.StringBuilder" | dn call "Append" "Hello World"'

print ""
print "Static method calls:"
print "System.Guid.NewGuid():"
nu -c '"System.Guid" | dn call "NewGuid"'

print ""
print "System.DateTime.Now:"
nu -c '"System.DateTime" | dn get "Now"'

print ""
print "4. The format is: TypeName@ObjectId"
print "   - TypeName: Full .NET type name (including generics)"
print "   - @: Separator"  
print "   - ObjectId: Unique GUID for object lifetime management"

print ""
print "=== READABLE OBJECT NAMES TEST COMPLETE ==="
print "Custom objects now show their actual .NET type! 🎉" 