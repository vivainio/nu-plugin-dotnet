# Nu Plugin DotNet - Basic Usage Examples
# Make sure to register the plugin first: register ./nu_plugin_dotnet.exe

# Basic object creation and method calls
print "=== Basic DateTime Operations ==="
let $now = dn new "System.DateTime" --args [2023, 12, 25, 14, 30, 0]
print $"Created DateTime: ($now)"

let $tomorrow = $now | dn call "AddDays" 1
print $"Tomorrow: ($tomorrow)"

let $dayOfWeek = $tomorrow | dn get "DayOfWeek"
print $"Day of week: ($dayOfWeek)"

# Static method calls
print "\n=== Static Method Calls ==="
let $max = "System.Math" | dn call "Max" 10 20
print $"Max of 10 and 20: ($max)"

let $sqrt = "System.Math" | dn call "Sqrt" 16.0
print $"Square root of 16: ($sqrt)"

# Working with collections
print "\n=== Collections ==="
let $list = dn new "System.Collections.Generic.List[string]"
$list | dn call "Add" "Hello"
$list | dn call "Add" "World"
$list | dn call "Add" "From"
$list | dn call "Add" "DotNet"

let $count = $list | dn get "Count"
print $"List count: ($count)"

let $first = $list | dn get "Item" 0
print $"First item: ($first)"

# String operations
print "\n=== String Operations ==="
let $sb = dn new "System.Text.StringBuilder"
$sb | dn call "Append" "Hello"
$sb | dn call "Append" " "
$sb | dn call "Append" "World"
$sb | dn call "Append" "!"

let $result = $sb | dn call "ToString"
print $"StringBuilder result: ($result)"

# File operations (be careful - this creates a file!)
print "\n=== File Operations ==="
let $tempFile = $"($env.TEMP)/nu-plugin-test.txt"
"System.IO.File" | dn call "WriteAllText" $tempFile "Hello from .NET!"

let $content = "System.IO.File" | dn call "ReadAllText" $tempFile
print $"File content: ($content)"

# Clean up
"System.IO.File" | dn call "Delete" $tempFile

# GUID generation
print "\n=== GUID Operations ==="
let $guid = dn new "System.Guid"
print $"New GUID: ($guid)"

let $guidString = $guid | dn call "ToString"
print $"GUID as string: ($guidString)"

# DateTime formatting
print "\n=== DateTime Formatting ==="
let $now = "System.DateTime" | dn get "Now"
let $formatted = $now | dn call "ToString" "yyyy-MM-dd HH:mm:ss"
print $"Formatted DateTime: ($formatted)"

print "\n=== Plugin Demo Complete ===" 