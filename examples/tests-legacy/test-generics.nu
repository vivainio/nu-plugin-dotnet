#!/usr/bin/env nu

print "🧬 Testing Generic Type Creation"
print "================================"

# Test 1: Basic generic List with backtick syntax
print "1. Testing List`1[System.String]..."
try {
    let list = dn new "System.Collections.Generic.List`1[System.String]"
    print $"✅ Created: ($list)"
} catch { |e|
    print $"❌ Failed: ($e.msg)"
}

# Test 2: Generic Dictionary
print ""
print "2. Testing Dictionary`2[System.String,System.Int32]..."
try {
    let dict = dn new "System.Collections.Generic.Dictionary`2[System.String,System.Int32]"
    print $"✅ Created: ($dict)"
} catch { |e|
    print $"❌ Failed: ($e.msg)"
}

# Test 3: User-friendly syntax (if implemented)
print ""
print "3. Testing user-friendly List<string> syntax..."
try {
    let list = dn new "List<string>"
    print $"✅ Created: ($list)"
} catch { |e|
    print $"❌ Failed: ($e.msg)"
}

# Test 4: Check what types are available
print ""
print "4. Checking available generic types in System.Private.CoreLib..."
try {
    let types = dn types "System.Private.CoreLib" | where name =~ "List"
    print $"Found List types: ($types)"
} catch { |e|
    print $"❌ Failed to list types: ($e.msg)"
}

print ""
print "Generic testing completed."