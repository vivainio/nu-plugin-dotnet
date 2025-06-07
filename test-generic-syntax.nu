#!/usr/bin/env nu

# Testing Generic Type Syntax Conversion in dn new
print "🧬 Testing User-Friendly Generic Type Syntax"
print "============================================"
print ""

print "1. Testing basic generic types with user-friendly syntax"
print "========================================================="

print "Creating List<string> (user-friendly syntax)..."
try {
    let $stringList = dn new "List<string>"
    print $"✅ List<string> created: ($stringList)"
    
    # Test functionality
    $stringList | dn call "Add" "Apple"
    $stringList | dn call "Add" "Banana"
    let $count = $stringList | dn get "Count"
    print $"   Items added: ($count)"
} catch { |err|
    print $"❌ List<string> failed: ($err.msg)"
}
print ""

print "Creating Dictionary<string, int> (user-friendly syntax)..."
try {
    let $stringIntDict = dn new "Dictionary<string, int>"
    print $"✅ Dictionary<string, int> created: ($stringIntDict)"
    
    # Test functionality
    $stringIntDict | dn call "Add" "apples" 5
    $stringIntDict | dn call "Add" "bananas" 12
    let $count = $stringIntDict | dn get "Count"
    print $"   Items added: ($count)"
    
    let $apples = $stringIntDict | dn call "get_Item" "apples"
    print $"   Apples count: ($apples)"
} catch { |err|
    print $"❌ Dictionary<string, int> failed: ($err.msg)"
}
print ""

print "Creating HashSet<string> (user-friendly syntax)..."
try {
    let $stringSet = dn new "HashSet<string>"
    print $"✅ HashSet<string> created: ($stringSet)"
    
    # Test functionality
    $stringSet | dn call "Add" "apple"
    $stringSet | dn call "Add" "banana"
    $stringSet | dn call "Add" "apple"  # Duplicate - should be ignored
    let $count = $stringSet | dn get "Count"
    print $"   Unique items (should be 2): ($count)"
} catch { |err|
    print $"❌ HashSet<string> failed: ($err.msg)"
}
print ""

print "2. Testing nested generic types"
print "==============================="

print "Creating List<List<string>> (nested generics)..."
try {
    let $nestedList = dn new "List<List<string>>"
    print $"✅ List<List<string>> created: ($nestedList)"
    
    # Create inner lists to add
    let $innerList1 = dn new "List<string>"
    $innerList1 | dn call "Add" "item1"
    $innerList1 | dn call "Add" "item2"
    
    $nestedList | dn call "Add" $innerList1
    let $count = $nestedList | dn get "Count"
    print $"   Nested lists added: ($count)"
} catch { |err|
    print $"❌ List<List<string>> failed: ($err.msg)"
}
print ""

print "Creating Dictionary<string, List<int>> (complex nested)..."
try {
    let $complexDict = dn new "Dictionary<string, List<int>>"
    print $"✅ Dictionary<string, List<int>> created: ($complexDict)"
    
    # Create a list to add as value
    let $intList = dn new "List<int>"
    $intList | dn call "Add" 1
    $intList | dn call "Add" 2
    $intList | dn call "Add" 3
    
    $complexDict | dn call "Add" "numbers" $intList
    let $count = $complexDict | dn get "Count"
    print $"   Complex entries added: ($count)"
} catch { |err|
    print $"❌ Dictionary<string, List<int>> failed: ($err.msg)"
}
print ""

print "3. Testing type aliases"
print "======================="

print "Creating List<int> (with int alias)..."
try {
    let $intList = dn new "List<int>"
    print $"✅ List<int> created: ($intList)"
    
    $intList | dn call "Add" 42
    $intList | dn call "Add" 100
    let $count = $intList | dn get "Count"
    print $"   Integer items: ($count)"
} catch { |err|
    print $"❌ List<int> failed: ($err.msg)"
}
print ""

print "Creating Dictionary<int, bool> (multiple aliases)..."
try {
    let $intBoolDict = dn new "Dictionary<int, bool>"
    print $"✅ Dictionary<int, bool> created: ($intBoolDict)"
    
    $intBoolDict | dn call "Add" 1 true
    $intBoolDict | dn call "Add" 0 false
    let $count = $intBoolDict | dn get "Count"
    print $"   Boolean mappings: ($count)"
} catch { |err|
    print $"❌ Dictionary<int, bool> failed: ($err.msg)"
}
print ""

print "4. Testing Queue and Stack with user-friendly syntax"
print "===================================================="

print "Creating Queue<string> (user-friendly syntax)..."
try {
    let $queue = dn new "Queue<string>"
    print $"✅ Queue<string> created: ($queue)"
    
    $queue | dn call "Enqueue" "First"
    $queue | dn call "Enqueue" "Second"
    $queue | dn call "Enqueue" "Third"
    
    let $count = $queue | dn get "Count"
    print $"   Queued items: ($count)"
    
    let $first = $queue | dn call "Dequeue"
    print $"   First out: ($first)"
} catch { |err|
    print $"❌ Queue<string> failed: ($err.msg)"
}
print ""

print "Creating Stack<int> (user-friendly syntax)..."
try {
    let $stack = dn new "Stack<int>"
    print $"✅ Stack<int> created: ($stack)"
    
    $stack | dn call "Push" 10
    $stack | dn call "Push" 20
    $stack | dn call "Push" 30
    
    let $count = $stack | dn get "Count"
    print $"   Stacked items: ($count)"
    
    let $top = $stack | dn call "Pop"
    print $"   Last in, first out: ($top)"
} catch { |err|
    print $"❌ Stack<int> failed: ($err.msg)"
}
print ""

print "5. Comparison with old syntax (should still work)"
print "================================================="

print "Creating List with old syntax (for comparison)..."
try {
    let $oldSyntaxList = dn new "System.Collections.Generic.List`1[System.String]"
    print $"✅ Old syntax still works: ($oldSyntaxList)"
    
    $oldSyntaxList | dn call "Add" "OldWay"
    let $count = $oldSyntaxList | dn get "Count"
    print $"   Old syntax count: ($count)"
} catch { |err|
    print $"❌ Old syntax failed: ($err.msg)"
}
print ""

print "Creating Dictionary with old syntax (for comparison)..."
try {
    let $oldSyntaxDict = dn new "System.Collections.Generic.Dictionary`2[System.String,System.Int32]"
    print $"✅ Old Dictionary syntax still works: ($oldSyntaxDict)"
    
    $oldSyntaxDict | dn call "Add" "old_key" 42
    let $count = $oldSyntaxDict | dn get "Count"
    print $"   Old Dictionary count: ($count)"
    
    let $value = $oldSyntaxDict | dn call "get_Item" "old_key"
    print $"   Retrieved value: ($value)"
} catch { |err|
    print $"❌ Old Dictionary syntax failed: ($err.msg)"
}
print ""

print "Direct comparison: New vs Old syntax (same functionality)..."
try {
    # Create identical collections with both syntaxes
    let $newList = dn new "List<string>"
    let $oldList = dn new "System.Collections.Generic.List`1[System.String]"
    
    # Add identical data
    $newList | dn call "Add" "test"
    $oldList | dn call "Add" "test"
    
    let $newCount = $newList | dn get "Count"
    let $oldCount = $oldList | dn get "Count"
    
    print $"✅ New syntax count: ($newCount)"
    print $"✅ Old syntax count: ($oldCount)"
    print $"   Functionality identical: {$newCount == $oldCount}"
} catch { |err|
    print $"❌ Comparison failed: ($err.msg)"
}
print ""

print "6. Testing error cases"
print "======================"

print "Testing invalid generic syntax..."
try {
    let $invalid = dn new "Dictionary<string>"  # Missing second type parameter
    print $"❌ Should have failed: ($invalid)"
} catch { |err|
    print $"✅ Correctly caught error: ($err.msg)"
}
print ""

print "Testing unknown generic type..."
try {
    let $unknown = dn new "UnknownGeneric<string>"
    print $"❌ Should have failed: ($unknown)"
} catch { |err|
    print $"✅ Correctly handled unknown type: ($err.msg)"
}
print ""

print "🎉 Generic syntax conversion testing completed!"
print "==============================================="
print "The new user-friendly syntax should make it much easier to work with generics!" 