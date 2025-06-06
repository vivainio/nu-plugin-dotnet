#!/usr/bin/env nu
# Simple binary test

print "Simple Binary Test"
print "=================="

# Load crypto assembly
dn load-assembly "System.Security.Cryptography"

# Create hasher
let $hasher = "System.Security.Cryptography.SHA256" | dn call "Create"
print $"Hasher: ($hasher)"

# Test with a very simple binary value
print "Creating simple binary data..."
let $simple_binary = [72, 101, 108, 108, 111] # "Hello" as bytes
print $"Binary data: ($simple_binary)"
print $"Type: ($simple_binary | describe)"

# Try calling ComputeHash - this should work now
print "Attempting hash computation..."
try {
    let $result = $hasher | dn call "ComputeHash" $simple_binary  
    print $"Success! Hash computed: ($result)"
} catch { |e|
    print $"Failed: ($e.msg)"
}

# Cleanup
$hasher | dn call "Dispose"
print "Done" 