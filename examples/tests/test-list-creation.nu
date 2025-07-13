#!/usr/bin/env nu

# Test List Creation with dn new command
print "🧪 Testing List Creation with dn new"
print "====================================="
print ""

print "1. Testing System.Collections.ArrayList (non-generic)"
print "----------------------------------------------------"
try {
    let $arrayList = dn new "System.Collections.ArrayList"
    print $"✅ ArrayList created: ($arrayList)"
    
    # Test adding items
    $arrayList | dn call "Add" "Apple"
    $arrayList | dn call "Add" "Banana"
    $arrayList | dn call "Add" 42
    $arrayList | dn call "Add" true
    
    let $count = $arrayList | dn get "Count"
    print $"✅ ArrayList count: ($count)"
    
    # Test accessing items
    let $first = $arrayList | dn call "get_Item" 0
    print $"✅ First item: ($first)"
    
    let $second = $arrayList | dn call "get_Item" 1
    print $"✅ Second item: ($second)"
    
} catch { |err|
    print $"❌ ArrayList failed: ($err.msg)"
}
print ""

print "2. Testing System.Collections.Generic.List[string]"
print "------------------------------------------------"
try {
    let $stringList = dn new "System.Collections.Generic.List[string]"
    print $"✅ List[string] created: ($stringList)"
    
    $stringList | dn call "Add" "Hello"
    $stringList | dn call "Add" "World"
    
    let $count = $stringList | dn get "Count"
    print $"✅ List[string] count: ($count)"
    
} catch { |err|
    print $"❌ List[string] failed: ($err.msg)"
}
print ""

print "3. Testing System.Collections.Generic.List[int]"
print "---------------------------------------------"
try {
    let $intList = dn new "System.Collections.Generic.List[int]"
    print $"✅ List[int] created: ($intList)"
    
    $intList | dn call "Add" 1
    $intList | dn call "Add" 2
    $intList | dn call "Add" 3
    
    let $count = $intList | dn get "Count"
    print $"✅ List[int] count: ($count)"
    
} catch { |err|
    print $"❌ List[int] failed: ($err.msg)"
}
print ""

print "4. Testing other collection types"
print "--------------------------------"

# Test HashSet
try {
    let $hashSet = dn new "System.Collections.Generic.HashSet[string]"
    print $"✅ HashSet[string] created: ($hashSet)"
} catch { |err|
    print $"❌ HashSet[string] failed: ($err.msg)"
}

# Test Dictionary
try {
    let $dict = dn new "System.Collections.Generic.Dictionary[string, int]"
    print $"✅ Dictionary[string, int] created: ($dict)"
} catch { |err|
    print $"❌ Dictionary[string, int] failed: ($err.msg)"
}

# Test Queue (generic)
try {
    let $queue = dn new "System.Collections.Generic.Queue[string]"
    print $"✅ Queue[string] created: ($queue)"
} catch { |err|
    print $"❌ Queue[string] failed: ($err.msg)"
}

# Test Stack (generic)
try {
    let $stack = dn new "System.Collections.Generic.Stack[string]"
    print $"✅ Stack[string] created: ($stack)"
} catch { |err|
    print $"❌ Stack[string] failed: ($err.msg)"
}
print ""

print "5. Testing non-generic collections (should work)"
print "-----------------------------------------------"

# Test Hashtable (non-generic)
try {
    let $hashtable = dn new "System.Collections.Hashtable"
    print $"✅ Hashtable created: ($hashtable)"
    
    $hashtable | dn call "Add" "key1" "value1"
    $hashtable | dn call "Add" "key2" 42
    
    let $count = $hashtable | dn get "Count"
    print $"✅ Hashtable count: ($count)"
    
} catch { |err|
    print $"❌ Hashtable failed: ($err.msg)"
}

# Test Queue (non-generic)
try {
    let $queue = dn new "System.Collections.Queue"
    print $"✅ Queue created: ($queue)"
    
    $queue | dn call "Enqueue" "First"
    $queue | dn call "Enqueue" "Second"
    
    let $count = $queue | dn get "Count"
    print $"✅ Queue count: ($count)"
    
} catch { |err|
    print $"❌ Queue failed: ($err.msg)"
}

# Test Stack (non-generic)
try {
    let $stack = dn new "System.Collections.Stack"
    print $"✅ Stack created: ($stack)"
    
    $stack | dn call "Push" "Bottom"
    $stack | dn call "Push" "Top"
    
    let $count = $stack | dn get "Count"
    print $"✅ Stack count: ($count)"
    
} catch { |err|
    print $"❌ Stack failed: ($err.msg)"
}
print ""

print "6. Checking loaded assemblies for collection types"
print "================================================="
let $assemblies = dn assemblies
print "Loaded assemblies:"
$assemblies | each { |asm| 
    let $name = $asm | get name
    if ($name | str contains "Collection") {
        print $"  • ($name)"
    }
} | ignore
print ""

print "7. Testing assembly loading for generic collections"
print "=================================================="
print "Loading System.Collections assembly..."
try {
    dn load-assembly "System.Collections"
    print "✅ System.Collections loaded"
} catch { |err|
    print $"❌ Failed to load System.Collections: ($err.msg)"
}

print "Loading System.Collections.Generic assembly..."
try {
    dn load-assembly "System.Collections.Generic"  
    print "✅ System.Collections.Generic loaded"
} catch { |err|
    print $"❌ Failed to load System.Collections.Generic: ($err.msg)"
}
print ""

print "8. Re-testing generic collections after assembly loading"
print "======================================================="
try {
    let $stringList2 = dn new "System.Collections.Generic.List[string]"
    print $"✅ List[string] created after assembly loading: ($stringList2)"
    
    $stringList2 | dn call "Add" "Post-load test"
    let $count = $stringList2 | dn get "Count"
    print $"✅ Count: ($count)"
    
} catch { |err|
    print $"❌ List[string] still failed: ($err.msg)"
}
print ""

print "📊 Summary"
print "=========="
print "• ArrayList (non-generic): Should work"
print "• Generic collections: May require proper assembly loading"
print "• Non-generic collections: Generally work if assembly is loaded"
print "• Some collection types may not be available in current runtime"
print ""
print "�� Test completed!" 