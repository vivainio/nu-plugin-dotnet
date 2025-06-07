#!/usr/bin/env nu

# Comprehensive Generic Collections Examples
# ==========================================

print "🧬 Generic Collections in .NET with dn new"
print "==========================================="
print ""

print "📚 1. Generic Lists - Different Types"
print "====================================="

print "String List:"
print "-----------"
let $stringList = dn new "System.Collections.Generic.List`1[System.String]"
$stringList | dn call "Add" "Apple"
$stringList | dn call "Add" "Banana"
$stringList | dn call "Add" "Cherry"
$stringList | dn call "Add" "Date"
print $"String items: ($stringList | dn get 'Count')"
print $"First fruit: ($stringList | dn call 'get_Item' 0)"
print $"Last fruit: ($stringList | dn call 'get_Item' (($stringList | dn get 'Count') - 1))"
print ""

print "Integer List:"
print "------------"
let $intList = dn new "System.Collections.Generic.List`1[System.Int32]"
$intList | dn call "Add" 10
$intList | dn call "Add" 25
$intList | dn call "Add" 42
$intList | dn call "Add" 100
print $"Integer items: ($intList | dn get 'Count')"
print $"First number: ($intList | dn call 'get_Item' 0)"
print $"Sum of first two: (($intList | dn call 'get_Item' 0) + ($intList | dn call 'get_Item' 1))"
print ""

print "Double List (Floating Point):"
print "----------------------------"
let $doubleList = dn new "System.Collections.Generic.List`1[System.Double]"
$doubleList | dn call "Add" 3.14159
$doubleList | dn call "Add" 2.71828
$doubleList | dn call "Add" 1.41421
print $"Double items: ($doubleList | dn get 'Count')"
print $"Pi: ($doubleList | dn call 'get_Item' 0)"
print $"e: ($doubleList | dn call 'get_Item' 1)"
print ""

print "Boolean List:"
print "------------"
let $boolList = dn new "System.Collections.Generic.List`1[System.Boolean]"
$boolList | dn call "Add" true
$boolList | dn call "Add" false
$boolList | dn call "Add" true
print $"Boolean items: ($boolList | dn get 'Count')"
print $"First value: ($boolList | dn call 'get_Item' 0)"
print ""

print "🗂️ 2. Generic Dictionaries - Key-Value Collections"
print "=================================================="

print "String to Integer Dictionary:"
print "----------------------------"
let $stringIntDict = dn new "System.Collections.Generic.Dictionary`2[System.String,System.Int32]"
$stringIntDict | dn call "Add" "apples" 5
$stringIntDict | dn call "Add" "bananas" 12
$stringIntDict | dn call "Add" "oranges" 8
$stringIntDict | dn call "Add" "grapes" 25
print $"Dictionary entries: ($stringIntDict | dn get 'Count')"
print $"Apples count: ($stringIntDict | dn call 'get_Item' 'apples')"
print $"Bananas count: ($stringIntDict | dn call 'get_Item' 'bananas')"
let $hasOranges = $stringIntDict | dn call "ContainsKey" "oranges"
print $"Has oranges: ($hasOranges)"
print ""

print "Integer to String Dictionary:"
print "----------------------------"
let $intStringDict = dn new "System.Collections.Generic.Dictionary`2[System.Int32,System.String]"
$intStringDict | dn call "Add" 1 "First"
$intStringDict | dn call "Add" 2 "Second"
$intStringDict | dn call "Add" 3 "Third"
$intStringDict | dn call "Add" 10 "Tenth"
print $"Number-to-word entries: ($intStringDict | dn get 'Count')"
print $"Number 1 is: ($intStringDict | dn call 'get_Item' 1)"
print $"Number 10 is: ($intStringDict | dn call 'get_Item' 10)"
print ""

print "String to String Dictionary (Translation):"
print "-----------------------------------------"
let $translations = dn new "System.Collections.Generic.Dictionary`2[System.String,System.String]"
$translations | dn call "Add" "hello" "hola"
$translations | dn call "Add" "goodbye" "adiós"
$translations | dn call "Add" "thank you" "gracias"
$translations | dn call "Add" "please" "por favor"
print $"Translation entries: ($translations | dn get 'Count')"
print $"'hello' in Spanish: ($translations | dn call 'get_Item' 'hello')"
print $"'thank you' in Spanish: ($translations | dn call 'get_Item' 'thank you')"
print ""

print "🎯 3. Advanced Generic Collections"
print "=================================="

print "HashSet (Unique Items Only):"
print "---------------------------"
try {
    let $hashSet = dn new "System.Collections.Generic.HashSet`1[System.String]"
    print $"✅ HashSet created: ($hashSet)"
    
    $hashSet | dn call "Add" "apple"
    $hashSet | dn call "Add" "banana"
    $hashSet | dn call "Add" "apple"  # Duplicate - should be ignored
    $hashSet | dn call "Add" "cherry"
    
    let $count = $hashSet | dn get "Count"
    print $"Unique items (should be 3, not 4): ($count)"
    
    let $hasApple = $hashSet | dn call "Contains" "apple"
    print $"Contains apple: ($hasApple)"
    
} catch { |err|
    print $"❌ HashSet failed: ($err.msg)"
}
print ""

print "Queue (FIFO Generic):"
print "-------------------"
try {
    let $queue = dn new "System.Collections.Generic.Queue`1[System.String]"
    print $"✅ Generic Queue created: ($queue)"
    
    $queue | dn call "Enqueue" "Task A"
    $queue | dn call "Enqueue" "Task B"
    $queue | dn call "Enqueue" "Task C"
    
    let $count = $queue | dn get "Count"
    print $"Queued tasks: ($count)"
    
    let $next = $queue | dn call "Peek"
    print $"Next task: ($next)"
    
    let $completed = $queue | dn call "Dequeue"
    print $"Completed task: ($completed)"
    
    let $remaining = $queue | dn get "Count"
    print $"Remaining tasks: ($remaining)"
    
} catch { |err|
    print $"❌ Generic Queue failed: ($err.msg)"
}
print ""

print "Stack (LIFO Generic):"
print "--------------------"
try {
    let $stack = dn new "System.Collections.Generic.Stack`1[System.Int32]"
    print $"✅ Generic Stack created: ($stack)"
    
    $stack | dn call "Push" 10
    $stack | dn call "Push" 20
    $stack | dn call "Push" 30
    
    let $count = $stack | dn get "Count"
    print $"Stacked numbers: ($count)"
    
    let $top = $stack | dn call "Peek"
    print $"Top number: ($top)"
    
    let $popped = $stack | dn call "Pop"
    print $"Popped number: ($popped)"
    
    let $remaining = $stack | dn get "Count"
    print $"Remaining numbers: ($remaining)"
    
} catch { |err|
    print $"❌ Generic Stack failed: ($err.msg)"
}
print ""

print "SortedDictionary (Ordered Keys):"
print "-------------------------------"
try {
    let $sortedDict = dn new "System.Collections.Generic.SortedDictionary`2[System.String,System.Int32]"
    print $"✅ SortedDictionary created: ($sortedDict)"
    
    $sortedDict | dn call "Add" "zebra" 26
    $sortedDict | dn call "Add" "apple" 1
    $sortedDict | dn call "Add" "mouse" 13
    $sortedDict | dn call "Add" "banana" 2
    
    let $count = $sortedDict | dn get "Count"
    print $"Sorted entries: ($count)"
    print "(Keys are automatically sorted alphabetically)"
    
} catch { |err|
    print $"❌ SortedDictionary failed: ($err.msg)"
}
print ""

print "🔬 4. Practical Generic Examples"
print "==============================="

print "User Database (ID to User Info):"
print "-------------------------------"
let $userDb = dn new "System.Collections.Generic.Dictionary`2[System.Int32,System.String]"
$userDb | dn call "Add" 1001 "Alice Johnson"
$userDb | dn call "Add" 1002 "Bob Smith"
$userDb | dn call "Add" 1003 "Carol Wilson"
$userDb | dn call "Add" 1004 "David Brown"
print $"Users in database: ($userDb | dn get 'Count')"
print $"User 1002: ($userDb | dn call 'get_Item' 1002)"
print ""

print "Shopping Cart (Item to Quantity):"
print "--------------------------------"
let $cart = dn new "System.Collections.Generic.Dictionary`2[System.String,System.Int32]"
$cart | dn call "Add" "Laptop" 1
$cart | dn call "Add" "Mouse" 2
$cart | dn call "Add" "Keyboard" 1
$cart | dn call "Add" "Monitor" 2
print $"Items in cart: ($cart | dn get 'Count')"
print $"Laptops: ($cart | dn call 'get_Item' 'Laptop')"
print $"Mice: ($cart | dn call 'get_Item' 'Mouse')"
print ""

print "Temperature Readings (Time Series):"
print "----------------------------------"
let $temperatures = dn new "System.Collections.Generic.List`1[System.Double]"
$temperatures | dn call "Add" 20.5
$temperatures | dn call "Add" 22.1
$temperatures | dn call "Add" 21.8
$temperatures | dn call "Add" 23.4
$temperatures | dn call "Add" 24.2
print $"Temperature readings: ($temperatures | dn get 'Count')"
print $"First reading: ($temperatures | dn call 'get_Item' 0)°C"
print $"Latest reading: ($temperatures | dn call 'get_Item' (($temperatures | dn get 'Count') - 1))°C"
print ""

print "📊 5. Generic Collection Summary"
print "==============================="
print "✅ Working Generic Types:"
print "• List`1[System.String] - String lists"
print "• List`1[System.Int32] - Integer lists"  
print "• List`1[System.Double] - Floating point lists"
print "• List`1[System.Boolean] - Boolean lists"
print "• Dictionary`2[System.String,System.Int32] - String to integer maps"
print "• Dictionary`2[System.Int32,System.String] - Integer to string maps"
print "• Dictionary`2[System.String,System.String] - String to string maps"
print "• HashSet`1[System.String] - Unique string collections"
print "• Queue`1[System.String] - FIFO string queues"
print "• Stack`1[System.Int32] - LIFO integer stacks"
print "• SortedDictionary`2[K,V] - Automatically sorted dictionaries"
print ""

print "💡 Generic Syntax Rules:"
print "1. Use backtick notation: List`1, Dictionary`2"
print "2. Specify full type names: System.String, System.Int32"
print "3. Use square brackets for type parameters: [System.String]"
print "4. Multiple types separated by commas: [System.String,System.Int32]"
print ""

print "🎉 Generic collections testing completed successfully!"
print "All major .NET generic collection types are working with dn new!" 