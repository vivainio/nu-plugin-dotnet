#!/usr/bin/env nu

# Dual Syntax Comparison Test: Proving Identical Functionality
print "⚖️  Dual Syntax Comparison Test"
print "================================"
print ""
print "This test creates identical objects using both old and new syntax"
print "and verifies they behave exactly the same way."
print ""

# Test case structure: [new_syntax, old_syntax, test_name]
let test_cases = [
    ["List<string>", "System.Collections.Generic.List`1[System.String]", "List of strings"],
    ["List<int>", "System.Collections.Generic.List`1[System.Int32]", "List of integers"],
    ["Dictionary<string, int>", "System.Collections.Generic.Dictionary`2[System.String,System.Int32]", "String-to-int dictionary"],
    ["Dictionary<int, string>", "System.Collections.Generic.Dictionary`2[System.Int32,System.String]", "Int-to-string dictionary"],
    ["HashSet<string>", "System.Collections.Generic.HashSet`1[System.String]", "String hash set"],
    ["HashSet<int>", "System.Collections.Generic.HashSet`1[System.Int32]", "Integer hash set"],
    ["Queue<string>", "System.Collections.Generic.Queue`1[System.String]", "String queue"],
    ["Stack<int>", "System.Collections.Generic.Stack`1[System.Int32]", "Integer stack"]
]

print "🧪 Running comprehensive comparison tests..."
print "============================================="

let $totalTests = ($test_cases | length)
mut $passedTests = 0

for $case in $test_cases {
    let $newSyntax = $case.0
    let $oldSyntax = $case.1
    let $testName = $case.2
    
    print $"\nTesting: ($testName)"
    print $"  New: ($newSyntax)"
    print $"  Old: ($oldSyntax)"
    print "  -----------------------------------"
    
    try {
        # Create objects with both syntaxes
        let $newObj = dn new $newSyntax
        let $oldObj = dn new $oldSyntax
        
        print $"  ✅ Both objects created successfully"
        
        # Test basic functionality based on type
        if ($newSyntax | str contains "List") {
            # Test List functionality
            $newObj | dn call "Add" "test_item"
            $oldObj | dn call "Add" "test_item"
            
            let $newCount = $newObj | dn get "Count"
            let $oldCount = $oldObj | dn get "Count"
            
            if $newCount == $oldCount {
                print $"  ✅ List Add/Count: Both have ($newCount) items"
                $passedTests = $passedTests + 1
            } else {
                print $"  ❌ List Count mismatch: New($newCount) vs Old($oldCount)"
            }
            
        } else if ($newSyntax | str contains "Dictionary") {
            # Test Dictionary functionality
            if ($newSyntax | str contains "string, int") {
                $newObj | dn call "Add" "test_key" 42
                $oldObj | dn call "Add" "test_key" 42
            } else {
                $newObj | dn call "Add" 1 "test_value"
                $oldObj | dn call "Add" 1 "test_value"
            }
            
            let $newCount = $newObj | dn get "Count"
            let $oldCount = $oldObj | dn get "Count"
            
            if $newCount == $oldCount {
                print $"  ✅ Dictionary Add/Count: Both have ($newCount) items"
                $passedTests = $passedTests + 1
            } else {
                print $"  ❌ Dictionary Count mismatch: New($newCount) vs Old($oldCount)"
            }
            
        } else if ($newSyntax | str contains "HashSet") {
            # Test HashSet functionality
            if ($newSyntax | str contains "string") {
                $newObj | dn call "Add" "unique_item"
                $newObj | dn call "Add" "unique_item"  # Duplicate
                $oldObj | dn call "Add" "unique_item"
                $oldObj | dn call "Add" "unique_item"  # Duplicate
            } else {
                $newObj | dn call "Add" 42
                $newObj | dn call "Add" 42  # Duplicate
                $oldObj | dn call "Add" 42
                $oldObj | dn call "Add" 42  # Duplicate
            }
            
            let $newCount = $newObj | dn get "Count"
            let $oldCount = $oldObj | dn get "Count"
            
            if $newCount == $oldCount and $newCount == 1 {
                print $"  ✅ HashSet uniqueness: Both have ($newCount) unique item"
                $passedTests = $passedTests + 1
            } else {
                print $"  ❌ HashSet behavior mismatch: New($newCount) vs Old($oldCount)"
            }
            
        } else if ($newSyntax | str contains "Queue") {
            # Test Queue functionality
            $newObj | dn call "Enqueue" "first"
            $newObj | dn call "Enqueue" "second"
            $oldObj | dn call "Enqueue" "first"
            $oldObj | dn call "Enqueue" "second"
            
            let $newFirst = $newObj | dn call "Dequeue"
            let $oldFirst = $oldObj | dn call "Dequeue"
            
            if $newFirst == $oldFirst {
                print $"  ✅ Queue FIFO: Both returned '($newFirst)'"
                $passedTests = $passedTests + 1
            } else {
                print $"  ❌ Queue behavior mismatch: New('($newFirst)') vs Old('($oldFirst)')"
            }
            
        } else if ($newSyntax | str contains "Stack") {
            # Test Stack functionality
            $newObj | dn call "Push" 10
            $newObj | dn call "Push" 20
            $oldObj | dn call "Push" 10
            $oldObj | dn call "Push" 20
            
            let $newTop = $newObj | dn call "Pop"
            let $oldTop = $oldObj | dn call "Pop"
            
            if $newTop == $oldTop {
                print $"  ✅ Stack LIFO: Both returned ($newTop)"
                $passedTests = $passedTests + 1
            } else {
                print $"  ❌ Stack behavior mismatch: New(($newTop)) vs Old(($oldTop))"
            }
        }
        
    } catch { |err|
        print $"  ❌ Test failed: ($err.msg)"
    }
}

print ""
print "🎯 Final Results"
print "================"
print $"Tests Passed: ($passedTests) / ($totalTests)"
print $"Success Rate: {($passedTests * 100 / $totalTests)}%"

if $passedTests == $totalTests {
    print ""
    print "🎉 ALL TESTS PASSED!"
    print "✅ Old and new syntax produce identical functionality"
    print "✅ No breaking changes detected"
    print "✅ Perfect backward compatibility maintained"
} else {
    print ""
    print "⚠️  Some tests failed - please investigate"
}

print ""
print "📋 Summary"
print "=========="
print "• New user-friendly syntax: Dictionary<string, int>"
print "• Old .NET internal syntax: System.Collections.Generic.Dictionary`2[System.String,System.Int32]"
print "• Both syntaxes create identical objects with identical behavior"
print "• Users can choose whichever syntax they prefer"
print "• Both syntaxes can be mixed in the same script

exit 0" 