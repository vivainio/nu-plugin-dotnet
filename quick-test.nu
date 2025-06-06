#!/usr/bin/env nu
# Quick test of nu-plugin-dotnet

print "🔧 Testing nu-plugin-dotnet..."

# Check if plugin is already loaded
let plugins = (plugin list | where name == "dotnet")
if ($plugins | length) == 0 {
    print "📦 Registering plugin..."
    plugin add ./bin/Release/net8.0/win-x64/nu_plugin_dotnet.exe
} else {
    print "📦 Plugin already registered"
}

print "🧪 Testing basic functionality:"

# Test 1: Math PI (static property)
print "1. Math PI test:"
let $pi = "System.Math" | dn get "PI"
print $"   PI: ($pi)"

# Test 2: Math Max (static method)
print "2. Math Max test:"
let $max = "System.Math" | dn call "Max" 5 10
print $"   Max result: ($max)"

# Test 3: Environment MachineName (static property)
print "3. Environment test:"
let $machine = "System.Environment" | dn get "MachineName"
print $"   Machine: ($machine)"

# Test 4: String instance property
print "4. String test:"
let $length = "Hello World" | dn get "Length"
print $"   Length: ($length)"

# Test 5: Assemblies listing
print "5. Assemblies test:"
let $assemblies = dn assemblies
let $count = ($assemblies | length)
print $"   Assembly count: ($count)"

# Test 6: Console.WriteLine (void method)
print "6. Console.WriteLine test:"
let $result = "System.Console" | dn call "WriteLine" "Test message from quick-test!"
if ($result == null) or ($result == "") {
    print "   ✅ Console.WriteLine executed (void method)"
} else {
    print $"   Console.WriteLine returned: ($result)"
}

print "✅ All tests completed!" 