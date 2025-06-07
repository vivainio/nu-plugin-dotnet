#!/usr/bin/env nu

# Working List and Collection Examples with dn new
print "🎯 Working List and Collection Examples"
print "========================================"
print ""

print "✅ 1. System.Collections.ArrayList (Dynamic Array)"
print "===================================================="
let $arrayList = dn new "System.Collections.ArrayList"
print $"ArrayList created: ($arrayList)"

# Add different types of items
$arrayList | dn call "Add" "String item"
$arrayList | dn call "Add" 42
$arrayList | dn call "Add" true
$arrayList | dn call "Add" 3.14

let $count = $arrayList | dn get "Count"
print $"Items added: ($count)"

# Access items by index
let $first = $arrayList | dn call "get_Item" 0
let $second = $arrayList | dn call "get_Item" 1
print $"First item: ($first)"
print $"Second item: ($second)"

# Check if contains an item
let $contains = $arrayList | dn call "Contains" 42
print $"Contains 42: ($contains)"

# Remove an item
$arrayList | dn call "Remove" 42
let $newCount = $arrayList | dn get "Count"
print $"Count after removal: ($newCount)"
print ""

print "✅ 2. System.Collections.Hashtable (Key-Value Pairs)"
print "====================================================="
let $hashtable = dn new "System.Collections.Hashtable"
print $"Hashtable created: ($hashtable)"

# Add key-value pairs
$hashtable | dn call "Add" "name" "John Doe"
$hashtable | dn call "Add" "age" 30
$hashtable | dn call "Add" "city" "New York"
$hashtable | dn call "Add" "score" 95.5

let $htCount = $hashtable | dn get "Count"
print $"Key-value pairs: ($htCount)"

# Get values by key
let $name = $hashtable | dn call "get_Item" "name"
let $age = $hashtable | dn call "get_Item" "age"
print $"Name: ($name)"
print $"Age: ($age)"

# Check if contains key
let $hasCity = $hashtable | dn call "ContainsKey" "city"
print $"Has 'city' key: ($hasCity)"
print ""

print "✅ 3. System.Collections.Queue (FIFO - First In, First Out)"
print "============================================================"
try {
    let $queue = dn new "System.Collections.Queue"
    print $"Queue created: ($queue)"
    
    # Enqueue items
    $queue | dn call "Enqueue" "Task 1"
    $queue | dn call "Enqueue" "Task 2"
    $queue | dn call "Enqueue" "Task 3"
    
    let $qCount = $queue | dn get "Count"
    print $"Tasks in queue: ($qCount)"
    
    # Peek at front item without removing
    let $front = $queue | dn call "Peek"
    print $"Next task: ($front)"
    
    # Dequeue items
    let $task1 = $queue | dn call "Dequeue"
    let $task2 = $queue | dn call "Dequeue"
    print $"Completed: ($task1), ($task2)"
    
    let $remaining = $queue | dn get "Count"
    print $"Remaining tasks: ($remaining)"
    
} catch { |err|
    print $"❌ Queue not available: ($err.msg)"
}
print ""

print "✅ 4. System.Collections.Stack (LIFO - Last In, First Out)"
print "==========================================================="
try {
    let $stack = dn new "System.Collections.Stack"
    print $"Stack created: ($stack)"
    
    # Push items
    $stack | dn call "Push" "Layer 1"
    $stack | dn call "Push" "Layer 2"
    $stack | dn call "Push" "Layer 3"
    
    let $sCount = $stack | dn get "Count"
    print $"Layers in stack: ($sCount)"
    
    # Peek at top item without removing
    let $top = $stack | dn call "Peek"
    print $"Top layer: ($top)"
    
    # Pop items
    let $layer3 = $stack | dn call "Pop"
    let $layer2 = $stack | dn call "Pop"
    print $"Removed: ($layer3), ($layer2)"
    
    let $remaining = $stack | dn get "Count"
    print $"Remaining layers: ($remaining)"
    
} catch { |err|
    print $"❌ Stack not available: ($err.msg)"
}
print ""

print "✅ 5. Generic Collections (Advanced Syntax)"
print "============================================"

print "System.Collections.Generic.List`1[System.String] (String List):"
try {
    let $stringList = dn new "System.Collections.Generic.List`1[System.String]"
    print $"✅ Generic string list created: ($stringList)"
    
    $stringList | dn call "Add" "Hello"
    $stringList | dn call "Add" "World"
    $stringList | dn call "Add" "from"
    $stringList | dn call "Add" "Generic List"
    
    let $slCount = $stringList | dn get "Count"
    print $"String items: ($slCount)"
    
    # Access by index
    let $firstStr = $stringList | dn call "get_Item" 0
    print $"First string: ($firstStr)"
    
} catch { |err|
    print $"❌ Generic string list failed: ($err.msg)"
}

print "System.Collections.Generic.List`1[System.Int32] (Integer List):"
try {
    let $intList = dn new "System.Collections.Generic.List`1[System.Int32]"
    print $"✅ Generic integer list created: ($intList)"
    
    $intList | dn call "Add" 10
    $intList | dn call "Add" 20
    $intList | dn call "Add" 30
    
    let $ilCount = $intList | dn get "Count"
    print $"Integer items: ($ilCount)"
    
    let $firstInt = $intList | dn call "get_Item" 0
    print $"First integer: ($firstInt)"
    
} catch { |err|
    print $"❌ Generic integer list failed: ($err.msg)"
}

print "System.Collections.Generic.Dictionary`2[System.String,System.Int32]:"
try {
    let $genericDict = dn new "System.Collections.Generic.Dictionary`2[System.String,System.Int32]"
    print $"✅ Generic dictionary created: ($genericDict)"
    
    $genericDict | dn call "Add" "apples" 5
    $genericDict | dn call "Add" "bananas" 12
    $genericDict | dn call "Add" "oranges" 8
    
    let $gdCount = $genericDict | dn get "Count"
    print $"Dictionary entries: ($gdCount)"
    
    let $apples = $genericDict | dn call "get_Item" "apples"
    print $"Apples count: ($apples)"
    
} catch { |err|
    print $"❌ Generic dictionary failed: ($err.msg)"
}
print ""

print "🎯 Practical Usage Patterns"
print "============================"
print ""

print "📝 Building a to-do list with ArrayList:"
let $todoList = dn new "System.Collections.ArrayList"
$todoList | dn call "Add" "Buy groceries"
$todoList | dn call "Add" "Write documentation"
$todoList | dn call "Add" "Review code"
let $todoCount = $todoList | dn get "Count"
print $"To-do items: ($todoCount)"
print ""

print "👥 User profiles with Hashtable:"
let $userProfiles = dn new "System.Collections.Hashtable"
$userProfiles | dn call "Add" "user123" "Alice Johnson"
$userProfiles | dn call "Add" "user456" "Bob Smith"
$userProfiles | dn call "Add" "user789" "Carol Wilson"
let $userCount = $userProfiles | dn get "Count"
print $"User profiles: ($userCount)"
let $user = $userProfiles | dn call "get_Item" "user123"
print $"User 123: ($user)"
print ""

print "📊 Summary of Working Collection Types"
print "======================================"
print "✅ System.Collections.ArrayList - Dynamic array, mixed types"
print "✅ System.Collections.Hashtable - Key-value pairs, mixed types"
print "✅ System.Collections.Queue - FIFO queue (if assembly loaded)"
print "✅ System.Collections.Stack - LIFO stack (if assembly loaded)"
print "✅ System.Collections.Generic.List`1[Type] - Typed list (advanced syntax)"
print "✅ System.Collections.Generic.Dictionary`2[K,V] - Typed dictionary"
print ""
print "💡 Key Syntax Rules:"
print "• Non-generic: Use simple names (ArrayList, Hashtable)"
print "• Generic: Use backtick notation (List`1[Type], Dictionary`2[K,V])"
print "• Full type names required for generics (System.String, System.Int32)"
print ""
print "🎉 List creation examples completed successfully!" 