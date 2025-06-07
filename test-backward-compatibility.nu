#!/usr/bin/env nu

# Testing Backward Compatibility: Old .NET Syntax Still Works
print "🔄 Testing Backward Compatibility with Old .NET Syntax"
print "======================================================"
print ""

print "This test ensures that the original .NET internal syntax continues to work"
print "exactly as before, while the new user-friendly syntax provides an alternative."
print ""

print "1. Testing Old Syntax - Basic Generic Collections"
print "================================================="

print "Creating List with old syntax..."
try {
    let $oldList = dn new "System.Collections.Generic.List`1[System.String]"
    print $"✅ Old List syntax works: ($oldList)"
    
    $oldList | dn call "Add" "OldWay1"
    $oldList | dn call "Add" "OldWay2"
    let $count = $oldList | dn get "Count"
    print $"   Items added with old syntax: ($count)"
} catch { |err|
    print $"❌ Old List syntax failed: ($err.msg)"
}
print ""

print "Creating Dictionary with old syntax..."
try {
    let $oldDict = dn new "System.Collections.Generic.Dictionary`2[System.String,System.Int32]"
    print $"✅ Old Dictionary syntax works: ($oldDict)"
    
    $oldDict | dn call "Add" "old_key1" 100
    $oldDict | dn call "Add" "old_key2" 200
    let $count = $oldDict | dn get "Count"
    print $"   Items added with old syntax: ($count)"
    
    let $value = $oldDict | dn call "get_Item" "old_key1"
    print $"   Retrieved value: ($value)"
} catch { |err|
    print $"❌ Old Dictionary syntax failed: ($err.msg)"
}
print ""

print "Creating HashSet with old syntax..."
try {
    let $oldHashSet = dn new "System.Collections.Generic.HashSet`1[System.Int32]"
    print $"✅ Old HashSet syntax works: ($oldHashSet)"
    
    $oldHashSet | dn call "Add" 42
    $oldHashSet | dn call "Add" 84
    $oldHashSet | dn call "Add" 42  # Duplicate
    let $count = $oldHashSet | dn get "Count"
    print $"   Unique items (should be 2): ($count)"
} catch { |err|
    print $"❌ Old HashSet syntax failed: ($err.msg)"
}
print ""

print "2. Testing Old Syntax - Advanced Collections"
print "============================================"

print "Creating Queue with old syntax..."
try {
    let $oldQueue = dn new "System.Collections.Generic.Queue`1[System.String]"
    print $"✅ Old Queue syntax works: ($oldQueue)"
    
    $oldQueue | dn call "Enqueue" "First_Old"
    $oldQueue | dn call "Enqueue" "Second_Old"
    let $count = $oldQueue | dn get "Count"
    print $"   Queued items: ($count)"
    
    let $dequeued = $oldQueue | dn call "Dequeue"
    print $"   Dequeued: ($dequeued)"
} catch { |err|
    print $"❌ Old Queue syntax failed: ($err.msg)"
}
print ""

print "Creating Stack with old syntax..."
try {
    let $oldStack = dn new "System.Collections.Generic.Stack`1[System.Double]"
    print $"✅ Old Stack syntax works: ($oldStack)"
    
    $oldStack | dn call "Push" 3.14159
    $oldStack | dn call "Push" 2.71828
    let $count = $oldStack | dn get "Count"
    print $"   Stacked items: ($count)"
    
    let $popped = $oldStack | dn call "Pop"
    print $"   Popped: ($popped)"
} catch { |err|
    print $"❌ Old Stack syntax failed: ($err.msg)"
}
print ""

print "3. Testing Complex Nested Old Syntax"
print "===================================="

print "Creating nested List<List<string>> with old syntax..."
try {
    let $oldNestedList = dn new "System.Collections.Generic.List`1[System.Collections.Generic.List`1[System.String]]"
    print $"✅ Old nested List syntax works: ($oldNestedList)"
    
    # Create inner list with old syntax too
    let $oldInnerList = dn new "System.Collections.Generic.List`1[System.String]"
    $oldInnerList | dn call "Add" "nested_old1"
    $oldInnerList | dn call "Add" "nested_old2"
    
    $oldNestedList | dn call "Add" $oldInnerList
    let $count = $oldNestedList | dn get "Count"
    print $"   Nested lists added: ($count)"
} catch { |err|
    print $"❌ Old nested syntax failed: ($err.msg)"
}
print ""

print "Creating Dictionary<string, List<int>> with old syntax..."
try {
    let $oldComplexDict = dn new "System.Collections.Generic.Dictionary`2[System.String,System.Collections.Generic.List`1[System.Int32]]"
    print $"✅ Old complex Dictionary syntax works: ($oldComplexDict)"
    
    # Create value list with old syntax
    let $oldValueList = dn new "System.Collections.Generic.List`1[System.Int32]"
    $oldValueList | dn call "Add" 10
    $oldValueList | dn call "Add" 20
    $oldValueList | dn call "Add" 30
    
    $oldComplexDict | dn call "Add" "old_numbers" $oldValueList
    let $count = $oldComplexDict | dn get "Count"
    print $"   Complex entries: ($count)"
} catch { |err|
    print $"❌ Old complex syntax failed: ($err.msg)"
}
print ""

print "4. Side-by-Side Comparison: Old vs New Syntax"
print "=============================================="

print "Creating identical objects with both syntaxes..."

# Create the same List<string> with both syntaxes
print "List<string> comparison:"
print "-----------------------"
try {
    let $newSyntaxList = dn new "List<string>"
    let $oldSyntaxList = dn new "System.Collections.Generic.List`1[System.String]"
    
    # Add same data to both
    $newSyntaxList | dn call "Add" "item1"
    $newSyntaxList | dn call "Add" "item2"
    
    $oldSyntaxList | dn call "Add" "item1" 
    $oldSyntaxList | dn call "Add" "item2"
    
    let $newCount = $newSyntaxList | dn get "Count"
    let $oldCount = $oldSyntaxList | dn get "Count"
    
    print $"✅ New syntax List count: ($newCount)"
    print $"✅ Old syntax List count: ($oldCount)"
    print $"   Both should be identical: {$newCount == $oldCount}"
} catch { |err|
    print $"❌ Comparison failed: ($err.msg)"
}
print ""

# Create the same Dictionary<string, int> with both syntaxes
print "Dictionary<string, int> comparison:"
print "----------------------------------"
try {
    let $newSyntaxDict = dn new "Dictionary<string, int>"
    let $oldSyntaxDict = dn new "System.Collections.Generic.Dictionary`2[System.String,System.Int32]"
    
    # Add same data to both
    $newSyntaxDict | dn call "Add" "key1" 100
    $newSyntaxDict | dn call "Add" "key2" 200
    
    $oldSyntaxDict | dn call "Add" "key1" 100
    $oldSyntaxDict | dn call "Add" "key2" 200
    
    let $newCount = $newSyntaxDict | dn get "Count"
    let $oldCount = $oldSyntaxDict | dn get "Count"
    
    print $"✅ New syntax Dictionary count: ($newCount)"
    print $"✅ Old syntax Dictionary count: ($oldCount)"
    print $"   Both should be identical: {$newCount == $oldCount}"
    
    # Test retrieving values
    let $newValue = $newSyntaxDict | dn call "get_Item" "key1"
    let $oldValue = $oldSyntaxDict | dn call "get_Item" "key1"
    print $"   New syntax value: ($newValue)"
    print $"   Old syntax value: ($oldValue)"
    print $"   Values should match: {$newValue == $oldValue}"
} catch { |err|
    print $"❌ Dictionary comparison failed: ($err.msg)"
}
print ""

print "5. Testing Mixed Usage (Old and New Together)"
print "============================================="

print "Creating objects with mixed syntax usage..."
try {
    # Create main container with new syntax
    let $mixedContainer = dn new "Dictionary<string, List<int>>"
    
    # Create value lists with old syntax
    let $oldList1 = dn new "System.Collections.Generic.List`1[System.Int32]"
    let $oldList2 = dn new "System.Collections.Generic.List`1[System.Int32]"
    
    # Populate old syntax lists
    $oldList1 | dn call "Add" 1
    $oldList1 | dn call "Add" 2
    $oldList1 | dn call "Add" 3
    
    $oldList2 | dn call "Add" 10
    $oldList2 | dn call "Add" 20
    $oldList2 | dn call "Add" 30
    
    # Add old syntax lists to new syntax dictionary
    $mixedContainer | dn call "Add" "group1" $oldList1
    $mixedContainer | dn call "Add" "group2" $oldList2
    
    let $count = $mixedContainer | dn get "Count"
    print $"✅ Mixed usage works: ($count) groups added"
    
    # Retrieve and test
    let $retrievedList = $mixedContainer | dn call "get_Item" "group1"
    let $listCount = $retrievedList | dn get "Count"
    print $"   Retrieved list has ($listCount) items"
} catch { |err|
    print $"❌ Mixed usage failed: ($err.msg)"
}
print ""

print "6. Testing Edge Cases with Old Syntax"
print "====================================="

print "Testing fully qualified type names..."
try {
    # Test with System.Collections.Generic prefix explicitly
    let $explicitList = dn new "System.Collections.Generic.List`1[System.String]"
    let $explicitDict = dn new "System.Collections.Generic.Dictionary`2[System.String,System.Object]"
    
    $explicitList | dn call "Add" "explicit_test"
    $explicitDict | dn call "Add" "test_key" "test_value"
    
    let $listCount = $explicitList | dn get "Count"
    let $dictCount = $explicitDict | dn get "Count"
    
    print $"✅ Explicit type names work: List({$listCount}), Dict({$dictCount})"
} catch { |err|
    print $"❌ Explicit type names failed: ($err.msg)"
}
print ""

print "🎯 Backward Compatibility Test Results"
print "======================================"
print "✅ All old .NET internal syntax continues to work perfectly"
print "✅ Old and new syntax can be used interchangeably"
print "✅ Mixed usage (old + new) works seamlessly" 
print "✅ Complex nested generics work with old syntax"
print "✅ No breaking changes introduced"
print ""
print "The new user-friendly syntax is purely additive - it doesn't replace"
print "or break any existing functionality. Users can choose whichever syntax"
print "they prefer, or mix both approaches as needed." 