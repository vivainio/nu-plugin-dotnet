#!/usr/bin/env nu
# Simple test for dn load-assembly with different parameters

print "🧪 Testing dn load-assembly with various methods"
print "================================================"

print "\n=== Testing Positional Arguments (Assembly Names) ==="

print "🔄 Testing System.Security.Cryptography..."
dn load-assembly "System.Security.Cryptography"

print "🔄 Testing System.Text.Json..."
dn load-assembly "System.Text.Json"

print "🔄 Testing System.Net.Http..."
dn load-assembly "System.Net.Http"

print "\n=== Testing --path Parameter ==="

print "🔄 Testing System.Security.Cryptography.dll..."
dn load-assembly --path "System.Security.Cryptography.dll"

print "\n=== Testing More Positional Arguments ==="

print "🔄 Testing System.Collections..."
dn load-assembly "System.Collections"

print "🔄 Testing System.Threading..."
dn load-assembly "System.Threading"

print "\n=== Checking Loaded Assemblies ==="
print "Current assemblies (with 'System' in name):"
dn assemblies | where name =~ "System" | select name | first 10

print "\n✅ Assembly loading tests complete!" 