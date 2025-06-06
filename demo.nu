#!/usr/bin/env nu

# Nu Plugin DotNet - Demonstration Script
# Shows practical usage examples of the plugin

print "🎯 Nu Plugin DotNet - Demonstration"
print "===================================="
print ""

# Check if plugin is available
let plugin_commands = (help commands | where name =~ "^dn " | get name)
if ($plugin_commands | length) == 0 {
    print "❌ Plugin not found. Please register it first:"
    print "   plugin add ./bin/Release/net8.0/win-x64/nu_plugin_dotnet.exe"
    exit 1
}

print "🔧 Available Commands:"
$plugin_commands | each { |cmd| print $"  - ($cmd)" }
print ""

print "📚 Demonstration Examples"
print "========================="

print ""
print "🧮 Example 1: Math Operations"
print "------------------------------"
print "Calculate maximum of two numbers:"
let max_result = ("System.Math" | dn call "Max" 42 17)
print $"Math.Max(42, 17) = ($max_result)"

print "Get mathematical constants:"
let pi = ("System.Math" | dn get "PI")
let e = ("System.Math" | dn get "E")
print $"PI = ($pi)"
print $"E = ($e)"

print "Calculate square root:"
let sqrt_result = ("System.Math" | dn call "Sqrt" 64)
print $"Math.Sqrt(64) = ($sqrt_result)"

print ""
print "📅 Example 2: Date and Time Operations"
print "---------------------------------------"
print "Create specific dates:"
let christmas = (dn new "System.DateTime" --args [2023, 12, 25])
let newyear = (dn new "System.DateTime" --args [2024, 1, 1])

print "Access date properties:"
let xmas_year = ($christmas | dn get "Year")
let xmas_month = ($christmas | dn get "Month")
let xmas_day = ($christmas | dn get "Day")
let day_of_week = ($christmas | dn get "DayOfWeek")
print $"Christmas 2023: ($xmas_year)-($xmas_month)-($xmas_day) (($day_of_week))"

print "Date arithmetic:"
let tomorrow = ($christmas | dn call "AddDays" 1)
let next_week = ($christmas | dn call "AddDays" 7)
let tomorrow_day = ($tomorrow | dn get "Day")
print $"Day after Christmas: ($tomorrow_day)"

print "Date formatting:"
let formatted = ($christmas | dn call "ToString" "yyyy-MM-dd")
print $"Formatted date: ($formatted)"

print ""
print "📦 Example 3: Collections"
print "--------------------------"
print "Create and use a List<string>:"
let fruits = (dn new "System.Collections.Generic.List[string]")
$fruits | dn call "Add" "Apple"
$fruits | dn call "Add" "Banana"
$fruits | dn call "Add" "Cherry"

let fruit_count = ($fruits | dn get "Count")
print $"Added 3 fruits, count = ($fruit_count)"

print "Check if list contains an item:"
let has_apple = ($fruits | dn call "Contains" "Apple")
print $"Contains 'Apple': ($has_apple)"

print "Create and use a Dictionary:"
let ages = (dn new "System.Collections.Generic.Dictionary[string, int]")
$ages | dn call "Add" "Alice" 30
$ages | dn call "Add" "Bob" 25

let alice_age = ($ages | dn call "get_Item" "Alice")
print $"Alice's age: ($alice_age)"

print ""
print "📝 Example 4: String Operations"
print "--------------------------------"
print "String properties and methods:"
let text = "Hello, Nushell World!"
let length = ($text | dn get "Length")
let upper = ($text | dn call "ToUpper")
let contains_nu = ($text | dn call "Contains" "Nushell")

print $"Text: '($text)'"
print $"Length: ($length)"
print $"Uppercase: ($upper)"
print $"Contains 'Nushell': ($contains_nu)"

print "String manipulation:"
let substring = ($text | dn call "Substring" 7 8)  # "Nushell "
let replaced = ($text | dn call "Replace" "World" "Universe")
print $"Substring (7, 8): '($substring)'"
print $"Replaced 'World' with 'Universe': '($replaced)'"

print "StringBuilder for efficient string building:"
let sb = (dn new "System.Text.StringBuilder")
$sb | dn call "Append" "Building"
$sb | dn call "Append" " strings"
$sb | dn call "Append" " efficiently"
let built_string = ($sb | dn call "ToString")
print $"StringBuilder result: '($built_string)'"

print ""
print "🔧 Example 5: File and Path Operations"
print "---------------------------------------"
print "Path operations:"
let combined_path = ("System.IO.Path" | dn call "Combine" "C:" "Users" "Documents" "myfile.txt")
let filename = ("System.IO.Path" | dn call "GetFileName" $combined_path)
let directory = ("System.IO.Path" | dn call "GetDirectoryName" $combined_path)
let extension = ("System.IO.Path" | dn call "GetExtension" $combined_path)

print $"Combined path: ($combined_path)"
print $"Filename: ($filename)"
print $"Directory: ($directory)"
print $"Extension: ($extension)"

print "Get system paths:"
let temp_path = ("System.IO.Path" | dn call "GetTempPath")
print $"Temp directory: ($temp_path)"

print ""
print "🆔 Example 6: GUID Operations"
print "------------------------------"
print "Generate unique identifiers:"
let guid1 = ("System.Guid" | dn call "NewGuid")
let guid2 = ("System.Guid" | dn call "NewGuid")

let guid1_str = ($guid1 | dn call "ToString")
let guid2_str = ($guid2 | dn call "ToString")

print $"GUID 1: ($guid1_str)"
print $"GUID 2: ($guid2_str)"
print $"Are they equal? (($guid1_str) == ($guid2_str))"

print ""
print "🔍 Example 7: System Information"
print "---------------------------------"
print "Environment information:"
let machine_name = ("System.Environment" | dn get "MachineName")
let user_name = ("System.Environment" | dn get "UserName")
let current_dir = ("System.Environment" | dn get "CurrentDirectory")

print $"Machine name: ($machine_name)"
print $"User name: ($user_name)"
print $"Current directory: ($current_dir)"

print ""
print "📚 Example 8: Assembly and Type Exploration"
print "--------------------------------------------"
print "List loaded assemblies:"
let assemblies = (dn assemblies)
let assembly_count = ($assemblies | length)
print $"Total assemblies loaded: ($assembly_count)"

print "Show first few assemblies:"
$assemblies | first 5 | each { |asm| print $"  - ($asm.name)" }

print "Explore types in System.Private.CoreLib:"
let core_types = (dn types "System.Private.CoreLib")
let type_count = ($core_types | length)
print $"Types in System.Private.CoreLib: ($type_count)"

print "Find DateTime-related types:"
let datetime_types = ($core_types | where name =~ "DateTime")
print "DateTime-related types:"
$datetime_types | each { |type| print $"  - ($type.name)" }

print "Explore String members:"
let string_members = (dn members "System.String")
let method_count = ($string_members | where member_type == "Method" | length)
let property_count = ($string_members | where member_type == "Property" | length)
print $"String has ($method_count) methods and ($property_count) properties"

print ""
print "🎉 Demonstration Complete!"
print "=========================="
print ""
print "The nu-plugin-dotnet brings the full power of .NET to your nushell scripts!"
print "You can now use any .NET class, method, or property directly from nushell."
print ""
print "Key capabilities demonstrated:"
print "✅ Math operations and constants"
print "✅ Date/time creation and manipulation" 
print "✅ Collection operations (List, Dictionary)"
print "✅ String processing and StringBuilder"
print "✅ File and path operations"
print "✅ GUID generation"
print "✅ System information access"
print "✅ Assembly and type exploration"
print ""
print "Happy scripting with .NET and Nushell! 🚀" 