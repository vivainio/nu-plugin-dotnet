#!/usr/bin/env nu

# Test different syntax for creating generic lists
print "🧪 Testing Generic List Syntax Variations"
print "=========================================="
print ""

print "1. Testing different syntax approaches for List<T>"
print "------------------------------------------------"

# Try the full name with backtick
print "Trying System.Collections.Generic.List`1..."
try {
    let $list1 = dn new "System.Collections.Generic.List`1"
    print $"✅ List`1 created: ($list1)"
} catch { |err|
    print $"❌ List`1 failed: ($err.msg)"
}

# Try with fully qualified name
print "Trying full type name..."
try {
    let $list2 = dn new "System.Collections.Generic.List`1[System.String]"
    print $"✅ List`1[System.String] created: ($list2)"
} catch { |err|
    print $"❌ List`1[System.String] failed: ($err.msg)"
}

# Try other variations
print "Trying System.Collections.Generic.List[string]..."
try {
    let $list3 = dn new "System.Collections.Generic.List[string]"
    print $"✅ List[string] created: ($list3)"
} catch { |err|
    print $"❌ List[string] failed: ($err.msg)"
}

print "Trying System.Collections.Generic.List[System.String]..."
try {
    let $list4 = dn new "System.Collections.Generic.List[System.String]"
    print $"✅ List[System.String] created: ($list4)"
} catch { |err|
    print $"❌ List[System.String] failed: ($err.msg)"
}
print ""

print "2. Testing Dictionary syntax variations"
print "======================================="

print "Trying Dictionary`2..."
try {
    let $dict1 = dn new "System.Collections.Generic.Dictionary`2"
    print $"✅ Dictionary`2 created: ($dict1)"
} catch { |err|
    print $"❌ Dictionary`2 failed: ($err.msg)"
}

print "Trying Dictionary`2[System.String,System.Int32]..."
try {
    let $dict2 = dn new "System.Collections.Generic.Dictionary`2[System.String,System.Int32]"
    print $"✅ Dictionary`2[System.String,System.Int32] created: ($dict2)"
} catch { |err|
    print $"❌ Dictionary`2[System.String,System.Int32] failed: ($err.msg)"
}

print "Trying Dictionary[string, int]..."
try {
    let $dict3 = dn new "System.Collections.Generic.Dictionary[string, int]"
    print $"✅ Dictionary[string, int] created: ($dict3)"
} catch { |err|
    print $"❌ Dictionary[string, int] failed: ($err.msg)"
}
print ""

print "3. Examining exact type names from assemblies"
print "============================================"
print "Full names from System.Private.CoreLib:"
nu -c "dn types 'System.Private.CoreLib' | where name =~ 'List' | select name fullName"
print ""

print "4. Testing what actually works"
print "============================="

print "✅ ArrayList (confirmed working):"
let $arrayList = dn new "System.Collections.ArrayList"
$arrayList | dn call "Add" "Works!"
let $count = $arrayList | dn get "Count"
print $"ArrayList count: ($count)"

print "✅ Hashtable (confirmed working):"
let $hashtable = dn new "System.Collections.Hashtable"
$hashtable | dn call "Add" "key" "value"
let $dictCount = $hashtable | dn get "Count"
print $"Hashtable count: ($dictCount)"
print ""

print "📋 Conclusions"
print "=============="
print "• Generic types may need specific runtime syntax"
print "• Non-generic collections work reliably"
print "• ArrayList is the best option for dynamic arrays currently"
print "• Hashtable works well for key-value storage"
print ""
print "�� Test completed!" 