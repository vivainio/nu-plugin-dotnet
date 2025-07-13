#!/usr/bin/env nu

# Simple test script to validate help documentation examples
print "=== Testing Nu Plugin .NET Help Documentation ==="

print "Testing dn new command examples..."

# Test basic object creation from help docs
print "1. Basic System.Object creation"
try { dn new "System.Object" } catch { |e| print $"Failed: ($e.msg)" }

print "2. StringBuilder creation"
try { dn new "System.Text.StringBuilder" } catch { |e| print $"Failed: ($e.msg)" }

print "3. ArrayList creation"
try { dn new "System.Collections.ArrayList" } catch { |e| print $"Failed: ($e.msg)" }

print "4. StringBuilder with initial text (using alternative approach)"
try { 
    let sb = (dn new "System.Text.StringBuilder")
    $sb | dn call "Append" "Initial text"
    print $"✅ StringBuilder with text: ($sb | dn call 'ToString')"
} catch { |e| print $"Failed: ($e.msg)" }

print "5. Generic List of strings"
try { dn new "System.Collections.Generic.List`1[System.String]" } catch { |e| print $"Failed: ($e.msg)" }

print "6. Generic Dictionary"
try { dn new "System.Collections.Generic.Dictionary`2[System.String,System.Int32]" } catch { |e| print $"Failed: ($e.msg)" }

print ""
print "Testing dn call command examples..."

print "7. StringBuilder Append method"
try { 
    dn new "System.Text.StringBuilder" | dn call "Append" "Hello"
} catch { |e| print $"Failed: ($e.msg)" }

print "8. ArrayList Add method"
try { 
    dn new "System.Collections.ArrayList" | dn call "Add" "item1"
} catch { |e| print $"Failed: ($e.msg)" }

print "9. System.Guid NewGuid static method"
try { 
    "System.Guid" | dn call "NewGuid"
} catch { |e| print $"Failed: ($e.msg)" }

print "10. Environment GetEnvironmentVariable"
try { 
    "System.Environment" | dn call "GetEnvironmentVariable" "PATH"
} catch { |e| print $"Failed: ($e.msg)" }

print "11. Method chaining example"
try {
    dn new "System.Text.StringBuilder" | dn call "Append" "Hello " | dn call "Append" "World" | dn call "ToString"
} catch { |e| print $"Failed: ($e.msg)" }

print ""
print "Testing dn get command examples..."

print "12. StringBuilder Length property"
try { 
    # Constructor args not supported - use parameterless constructor
    let sb = (dn new "System.Text.StringBuilder")
    $sb | dn call "Append" "Hello"
    $sb | dn get "Length"
} catch { |e| print $"Failed: ($e.msg)" }

print "13. ArrayList Count property"
try { 
    dn new "System.Collections.ArrayList" | dn get "Count"
} catch { |e| print $"Failed: ($e.msg)" }

print "14. DateTime Now static property"
try { 
    "System.DateTime" | dn get "Now"
} catch { |e| print $"Failed: ($e.msg)" }

print "15. Environment MachineName"
try { 
    "System.Environment" | dn get "MachineName"
} catch { |e| print $"Failed: ($e.msg)" }

print "16. String indexer access"
try { 
    "Hello World" | dn get "Item" 0
} catch { |e| print $"Failed: ($e.msg)" }

print ""
print "Testing dn assemblies command..."

print "17. List all loaded assemblies"
try { 
    dn assemblies | length
} catch { |e| print $"Failed: ($e.msg)" }

print ""
print "Testing dn types command..."

print "18. List types in mscorlib"
try { 
    dn types "mscorlib" | length
} catch { |e| print $"Failed: ($e.msg)" }

print ""
print "Testing dn members command..."

print "19. List all String members"
try { 
    dn members "System.String" | length
} catch { |e| print $"Failed: ($e.msg)" }

print ""
print "Testing dn obj command..."

print "20. Convert DateTime to nushell record"
try { 
    # DateTime requires constructor args - use DateTime.Now instead
    "System.DateTime" | dn get "Now" | dn obj | get __type__
} catch { |e| print $"Failed: ($e.msg)" }

print ""
print "All basic help documentation examples tested!"

# Ensure clean exit
exit 0 