#!/usr/bin/env nu

# Direct plugin test without registration
print "🔧 Testing plugin directly without nushell registration"

let plugin_path = "./bin/Release/net8.0/win-x64/nu_plugin_dotnet.exe"

print $"Plugin path: ($plugin_path)"

# Test if plugin executable exists
if not ($plugin_path | path exists) {
    print "❌ Plugin executable not found!"
    exit 1
}

# Test plugin responds to Hello
print "Testing plugin Hello response..."
let hello_input = '{"Hello": {"protocol": "nu-plugin", "version": "0.105.2", "features": []}}'
let hello_result = ($hello_input | ^$plugin_path)
print $"Hello response: ($hello_result)"

print "✅ Direct plugin test completed"