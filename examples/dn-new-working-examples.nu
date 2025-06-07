#!/usr/bin/env nu

# dn new Command - Working Examples Collection
# ============================================

print "🏗️  dn new Command - Working Examples Collection"
print "================================================="
print ""

print "📚 Basic Object Creation (Default Constructors)"
print "==============================================="
print ""

print "1️⃣  System.Object - The base of all .NET objects"
print "------------------------------------------------"
let $obj = dn new "System.Object"
print $"Object created: ($obj)"
let $objStr = $obj | dn call "ToString"
print $"Object.ToString(): ($objStr)"
print ""

print "2️⃣  System.Text.StringBuilder - Text manipulation"
print "-------------------------------------------------"
let $sb = dn new "System.Text.StringBuilder"
print $"StringBuilder created: ($sb)"

# Build a string step by step
$sb | dn call "Append" "Hello"
$sb | dn call "Append" " "
$sb | dn call "Append" "from"
$sb | dn call "Append" " "
$sb | dn call "Append" "Nushell!"

let $result = $sb | dn call "ToString"
print $"Built string: ($result)"

let $length = $sb | dn get "Length"
print $"String length: ($length)"
print ""

print "3️⃣  System.Collections.ArrayList - Dynamic array"
print "------------------------------------------------"
try {
    let $arrayList = dn new "System.Collections.ArrayList"
    print $"ArrayList created: ($arrayList)"
    
    # Add various items
    $arrayList | dn call "Add" "Apple"
    $arrayList | dn call "Add" "Banana"
    $arrayList | dn call "Add" "Cherry"
    $arrayList | dn call "Add" 42
    $arrayList | dn call "Add" true
    
    let $count = $arrayList | dn get "Count"
    print $"ArrayList count: ($count)"
    
    # Access items by index
    let $first = $arrayList | dn call "get_Item" 0
    print $"First item: ($first)"
    
} catch { |err|
    print $"ArrayList not available: ($err.msg)"
}
print ""

print "4️⃣  System.Collections.Hashtable - Key-value pairs"
print "--------------------------------------------------"
try {
    let $hashtable = dn new "System.Collections.Hashtable"
    print $"Hashtable created: ($hashtable)"
    
    # Add key-value pairs
    $hashtable | dn call "Add" "name" "John"
    $hashtable | dn call "Add" "age" 30
    $hashtable | dn call "Add" "city" "New York"
    
    let $count = $hashtable | dn get "Count"
    print $"Hashtable count: ($count)"
    
    # Get a value by key
    let $name = $hashtable | dn call "get_Item" "name"
    print $"Name: ($name)"
    
} catch { |err|
    print $"Hashtable not available: ($err.msg)"
}
print ""

print "5️⃣  System.Collections.Queue - FIFO collection"
print "----------------------------------------------"
try {
    let $queue = dn new "System.Collections.Queue"
    print $"Queue created: ($queue)"
    
    # Enqueue items
    $queue | dn call "Enqueue" "First"
    $queue | dn call "Enqueue" "Second"
    $queue | dn call "Enqueue" "Third"
    
    let $count = $queue | dn get "Count"
    print $"Queue count: ($count)"
    
    # Peek at the front item
    let $front = $queue | dn call "Peek"
    print $"Front item: ($front)"
    
    # Dequeue an item
    let $dequeued = $queue | dn call "Dequeue"
    print $"Dequeued: ($dequeued)"
    
    let $newCount = $queue | dn get "Count"
    print $"Queue count after dequeue: ($newCount)"
    
} catch { |err|
    print $"Queue not available: ($err.msg)"
}
print ""

print "6️⃣  System.Collections.Stack - LIFO collection"
print "----------------------------------------------"
try {
    let $stack = dn new "System.Collections.Stack"
    print $"Stack created: ($stack)"
    
    # Push items
    $stack | dn call "Push" "Bottom"
    $stack | dn call "Push" "Middle"
    $stack | dn call "Push" "Top"
    
    let $count = $stack | dn get "Count"
    print $"Stack count: ($count)"
    
    # Peek at the top item
    let $top = $stack | dn call "Peek"
    print $"Top item: ($top)"
    
    # Pop an item
    let $popped = $stack | dn call "Pop"
    print $"Popped: ($popped)"
    
    let $newCount = $stack | dn get "Count"
    print $"Stack count after pop: ($newCount)"
    
} catch { |err|
    print $"Stack not available: ($err.msg)"
}
print ""

print "7️⃣  System.Text.Encoding - Text encoding utilities"
print "--------------------------------------------------"
try {
    # Get UTF8 encoding
    let $utf8 = "System.Text.Encoding" | dn get "UTF8"
    print $"UTF8 encoding: ($utf8)"
    
    # Encode a string to bytes
    let $bytes = $utf8 | dn call "GetBytes" "Hello World"
    print $"Encoded bytes: ($bytes)"
    
    # Get byte count
    let $byteCount = $utf8 | dn call "GetByteCount" "Hello World"
    print $"Byte count: ($byteCount)"
    
} catch { |err|
    print $"Encoding operations failed: ($err.msg)"
}
print ""

print "8️⃣  System.Environment - System information"
print "-------------------------------------------"
try {
    let $machineName = "System.Environment" | dn get "MachineName"
    print $"Machine name: ($machineName)"
    
    let $osVersion = "System.Environment" | dn get "OSVersion"
    print $"OS Version: ($osVersion)"
    
    let $currentDir = "System.Environment" | dn get "CurrentDirectory"
    print $"Current directory: ($currentDir)"
    
    let $tickCount = "System.Environment" | dn get "TickCount"
    print $"Tick count: ($tickCount)"
    
} catch { |err|
    print $"Environment operations failed: ($err.msg)"
}
print ""

print "9️⃣  System.DateTime - Date and time (static properties)"
print "-------------------------------------------------------"
try {
    let $now = "System.DateTime" | dn get "Now"
    print $"Current time: ($now)"
    
    let $today = "System.DateTime" | dn get "Today"
    print $"Today: ($today)"
    
    let $utcNow = "System.DateTime" | dn get "UtcNow"
    print $"UTC Now: ($utcNow)"
    
} catch { |err|
    print $"DateTime operations failed: ($err.msg)"
}
print ""

print "🔟  System.Guid - Static methods"
print "--------------------------------"
try {
    let $newGuid = "System.Guid" | dn call "NewGuid"
    print $"New GUID: ($newGuid)"
    
    let $guidStr = $newGuid | dn call "ToString"
    print $"GUID as string: ($guidStr)"
    
} catch { |err|
    print $"GUID operations failed: ($err.msg)"
}
print ""

print "📊 Assembly Information"
print "======================"
let $assemblies = dn assemblies
let $count = $assemblies | length
print $"Total loaded assemblies: ($count)"
print ""
print "Available assemblies:"
$assemblies | each { |asm| 
    let $name = $asm | get name
    print $"  • ($name)"
} | ignore
print ""

print "🎯 Usage Patterns Summary"
print "========================="
print "✅ dn new \"TypeName\" - Creates objects with default constructors"
print "✅ object | dn call \"MethodName\" [args...] - Call instance methods"
print "✅ \"TypeName\" | dn call \"StaticMethod\" [args...] - Call static methods"
print "✅ object | dn get \"PropertyName\" - Get instance properties"
print "✅ \"TypeName\" | dn get \"StaticProperty\" - Get static properties"
print "✅ dn assemblies - List loaded assemblies"
print ""
print "📝 Notes:"
print "• Constructor arguments (--args) need to be implemented in the command signature"
print "• Generic types may require assembly loading"
print "• Some types may not have parameterless constructors"
print ""
print "🎉 Examples completed successfully!" 