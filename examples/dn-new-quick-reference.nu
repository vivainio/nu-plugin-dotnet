#!/usr/bin/env nu

# dn new Command - Quick Reference Guide (Current Working Version)
# ================================================================

print "🚀 dn new Command - Quick Reference Guide"
print "==========================================="
print ""

print "📋 Current Working Syntax"
print "========================="
print ""

print "Basic Syntax:"
print "  dn new \"FullTypeName\""
print ""
print "Note: Constructor arguments (--args) are not yet implemented in the command signature"
print ""

print "Examples by Pattern:"
print ""

print "1️⃣  Parameterless Constructor (Currently Working)"
print "------------------------------------------------"
print "# Creates object using default constructor"
print "let \\$obj = dn new \\\"System.Text.StringBuilder\\\""
print "let \\$list = dn new \\\"System.Collections.ArrayList\\\""
print "let \\$dict = dn new \\\"System.Collections.Hashtable\\\""
print ""

print "2️⃣  Working Object Creation Examples"
print "-----------------------------------"

# Basic objects that work
let $sb = dn new "System.Text.StringBuilder"
print $"StringBuilder: ($sb)"

let $obj = dn new "System.Object"
print $"Object: ($obj)"

let $arrayList = dn new "System.Collections.ArrayList"
print $"ArrayList: ($arrayList)"

let $hashtable = dn new "System.Collections.Hashtable"
print $"Hashtable: ($hashtable)"

# Note: Queue and Stack may require assembly loading
try {
    let $queue = dn new "System.Collections.Queue"
    print $"Queue: ($queue)"
} catch {
    print "Queue: (requires assembly loading)"
}

try {
    let $stack = dn new "System.Collections.Stack"
    print $"Stack: ($stack)"
} catch {
    print "Stack: (requires assembly loading)"
}
print ""

print "3️⃣  Static Method Calls (Working)"
print "--------------------------------"
let $guid = "System.Guid" | dn call "NewGuid"
print $"New GUID: ($guid)"

let $now = "System.DateTime" | dn get "Now"
print $"Current time: ($now)"

let $machineName = "System.Environment" | dn get "MachineName"
print $"Machine name: ($machineName)"
print ""

print "4️⃣  Instance Method Calls (Working)"
print "----------------------------------"
$sb | dn call "Append" "Hello World"
let $result = $sb | dn call "ToString"
print $"StringBuilder result: ($result)"

$arrayList | dn call "Add" "Item1"
$arrayList | dn call "Add" "Item2"
let $count = $arrayList | dn get "Count"
print $"ArrayList count: ($count)"
print ""

print "5️⃣  Property Access (Working)"
print "----------------------------"
let $length = $sb | dn get "Length"
print $"StringBuilder length: ($length)"

let $utf8 = "System.Text.Encoding" | dn get "UTF8"
print $"UTF8 encoding: ($utf8)"
print ""

print "📚 Common Patterns That Work"
print "============================"
print ""
print "✅ Object Creation:"
print "   dn new \\\"System.Text.StringBuilder\\\""
print "   dn new \\\"System.Collections.ArrayList\\\""
print "   dn new \\\"System.Collections.Hashtable\\\""
print ""
print "✅ Method Chaining:"
print "   \\$sb | dn call \\\"Append\\\" \\\"Hello\\\" | dn call \\\"Append\\\" \\\" World\\\""
print ""
print "✅ Static Calls:"
print "   \\\"System.Guid\\\" | dn call \\\"NewGuid\\\""
print "   \\\"System.DateTime\\\" | dn get \\\"Now\\\""
print ""
print "✅ Property Access:"
print "   \\$object | dn get \\\"PropertyName\\\""
print "   \\\"TypeName\\\" | dn get \\\"StaticProperty\\\""
print ""

print "⚠️  Limitations (To Be Implemented)"
print "==================================="
print ""
print "❌ Constructor Arguments:"
print "   # This doesn't work yet:"
print "   # dn new \\\"System.DateTime\\\" --args [2024, 1, 15]"
print ""
print "❌ Generic Type Parameters:"
print "   # May need assembly loading:"
print "   # dn new \\\"System.Collections.Generic.List[string]\\\""
print ""
print "❌ Complex Constructors:"
print "   # Types without parameterless constructors"
print ""

print "🔧 Assembly Management"
print "====================="
print "List loaded assemblies:"
let $assemblies = dn assemblies
print $"Total assemblies: ($assemblies | length)"
print ""

print "🎯 Best Practices"
print "================="
print "1. Start with parameterless constructors"
print "2. Use try-catch for experimental object creation"
print "3. Check dn assemblies to see what's available"
print "4. Use dn members \\\"TypeName\\\" to explore type capabilities"
print ""

print "✅ Quick Reference Complete!" 