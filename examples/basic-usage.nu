# Nu Plugin DotNet - Basic Usage Examples
# Make sure to register the plugin first: register ./nu_plugin_dotnet.exe

# Basic object creation and method calls
print "=== Basic DateTime Operations ==="
let $now = dotnet new "System.DateTime" --args [2023, 12, 25, 14, 30, 0]
print $"Created DateTime: ($now)"

let $tomorrow = $now | dotnet call "AddDays" 1
print $"Tomorrow: ($tomorrow)"

let $dayOfWeek = $tomorrow | dotnet get "DayOfWeek"
print $"Day of week: ($dayOfWeek)"

# Static method calls
print "\n=== Static Method Calls ==="
let $max = "System.Math" | dotnet call "Max" 10 20
print $"Max of 10 and 20: ($max)"

let $sqrt = "System.Math" | dotnet call "Sqrt" 16.0
print $"Square root of 16: ($sqrt)"

# Working with collections
print "\n=== Collections ==="
let $list = dotnet new "System.Collections.Generic.List[string]"
$list | dotnet call "Add" "Hello"
$list | dotnet call "Add" "World"
$list | dotnet call "Add" "From"
$list | dotnet call "Add" "DotNet"

let $count = $list | dotnet get "Count"
print $"List count: ($count)"

let $first = $list | dotnet get "Item" 0
print $"First item: ($first)"

# String operations
print "\n=== String Operations ==="
let $sb = dotnet new "System.Text.StringBuilder"
$sb | dotnet call "Append" "Hello"
$sb | dotnet call "Append" " "
$sb | dotnet call "Append" "World"
$sb | dotnet call "Append" "!"

let $result = $sb | dotnet call "ToString"
print $"StringBuilder result: ($result)"

# File operations (be careful - this creates a file!)
print "\n=== File Operations ==="
let $tempFile = $"($env.TEMP)/nu-plugin-test.txt"
"System.IO.File" | dotnet call "WriteAllText" $tempFile "Hello from .NET!"

let $content = "System.IO.File" | dotnet call "ReadAllText" $tempFile
print $"File content: ($content)"

# Clean up
"System.IO.File" | dotnet call "Delete" $tempFile

# GUID generation
print "\n=== GUID Operations ==="
let $guid = dotnet new "System.Guid"
print $"New GUID: ($guid)"

let $guidString = $guid | dotnet call "ToString"
print $"GUID as string: ($guidString)"

# DateTime formatting
print "\n=== DateTime Formatting ==="
let $now = "System.DateTime" | dotnet get "Now"
let $formatted = $now | dotnet call "ToString" "yyyy-MM-dd HH:mm:ss"
print $"Formatted DateTime: ($formatted)"

print "\n=== Plugin Demo Complete ===" 