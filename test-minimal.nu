#!/usr/bin/env nu

# Simple test script for nu-plugin-dotnet
print "🚀 Testing nu-plugin-dotnet"

# Build the project
print "Building..."
dotnet build NuPluginDotNet.sln

# Clean up old log files
print "Cleaning up old log files..."
try {
    glob $"($env.TEMP)/nu-plugin-dotnet-debug-*.log" | each { |file| rm -f $file }
    glob $"($env.TEMP)/nu-plugin-protocol-debug.log" | each { |file| rm -f $file }
} catch {
    print "No old log files found to clean up"
}

# Enable debugging
print "Enabling debug logging..."
$env.NU_PLUGIN_DOTNET_DEBUG = "true"

# Load the plugin
print "Loading plugin..."
plugin add ./bin/Debug/net8.0/win-x64/nu_plugin_dotnet.exe

# Test the command
print "Testing dn new System.Object..."
let obj = (dn new "System.Object")
print $"✅ Result: ($obj)"

print "Done!" 