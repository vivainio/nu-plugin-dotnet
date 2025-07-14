#!/usr/bin/env nu

# Simple test script for simple-plugin
print "🚀 Testing simple-plugin"

# Get the current working directory as base path
let base_path = (pwd)
let plugin_path = $base_path | path join "examples" "simple-plugin"
let plugin_exe_path = $plugin_path | path join "bin" "Debug" "net8.0" "nu_plugin_simple.exe"

print $"Base path: ($base_path)"
print $"Plugin path: ($plugin_path)"
print $"Plugin exe path: ($plugin_exe_path)"

# Build the simple plugin project
print "Building simple plugin..."
dotnet build ($plugin_path | path join "SimplePluginTyped.csproj")

# Copy to correct plugin name
print "Copying to correct plugin name..."
let source_exe = $plugin_path | path join "bin" "Debug" "net8.0" "SimplePluginTyped.exe"
cp $source_exe $plugin_exe_path

# Show debug log file paths
let debug_log = $"($env.TEMP)/nu-plugin-protocol-debug.log"
print $"Debug log file will be: ($debug_log)"

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

# Load the simple plugin
print $"Loading simple plugin from: ($plugin_exe_path)"
plugin add $plugin_exe_path

# Test the hello command
print "Testing hello command..."
let result = (hello)
print $"✅ Hello result: ($result)"

# Test the add command
print "Testing add command..."
let add_result = (add 5 3)
print $"✅ Add result: ($add_result)"

# Test the greet command
print "Testing greet command..."
let greet_result = (greet "World")
print $"✅ Greet result: ($greet_result)"

# Show debug log file location again
print $"Debug log file location: ($debug_log)"
if ($debug_log | path exists) {
    print $"Debug log file size: ((ls $debug_log).0.size)"
} else {
    print "Debug log file was not created"
}

print "Done!" 