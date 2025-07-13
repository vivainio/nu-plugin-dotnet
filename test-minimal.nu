#!/usr/bin/env nu

# Simple test script for nu-plugin-dotnet
print "🚀 Testing nu-plugin-dotnet"

# Build the project
print "Building..."
dotnet build NuPluginDotNet.sln

# Load the plugin
print "Loading plugin..."
plugin add ./bin/Debug/net8.0/win-x64/nu_plugin_dotnet.exe

# Test the command
print "Testing dn new System.Object..."
let obj = (dn new "System.Object")
print $"✅ Result: ($obj)"

print "Done!" 