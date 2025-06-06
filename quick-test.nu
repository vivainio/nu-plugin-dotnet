#!/usr/bin/env nu
# Quick test of nu-plugin-dotnet

print "🔧 Testing nu-plugin-dotnet..."

# Register plugin with the new command
plugin add ./bin/Release/net8.0/win-x64/nu_plugin_dotnet.exe

print "📦 Plugin registered. Testing basic functionality:"

# Test 1: DateTime
print "1. DateTime test:"
let $now = dotnet new "System.DateTime" --args [2023, 12, 25]
print $"   Created: ($now)"
let $year = $now | dotnet get "Year"
print $"   Year: ($year)"

# Test 2: Math
print "2. Math test:"
let $max = "System.Math" | dotnet call "Max" 5 10
print $"   Max(5,10): ($max)"

# Test 3: List
print "3. List test:"
let $list = dotnet new "System.Collections.Generic.List[string]"
$list | dotnet call "Add" "Hello"
let $count = $list | dotnet get "Count"
print $"   List count: ($count)"

# Test 4: GUID
print "4. GUID test:"
let $guid = dotnet new "System.Guid"
print $"   New GUID: ($guid)"

print "✅ All tests completed!" 