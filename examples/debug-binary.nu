#!/usr/bin/env nu
# Debug script to test binary data conversion

print "🔍 Debug Binary Data Conversion"
print "================================="

# Create test data
let $testString = "Hello"
let $testData = $testString | encode utf8
print $"Test string: '($testString)'"
print $"Test data type: ($testData | describe)"
print $"Test data length: ($testData | length)"
print $"Test data: ($testData)"

# Load crypto assembly
print "\n📦 Loading crypto assembly..."
dn load-assembly "System.Security.Cryptography"

# Create SHA256 hasher
print "\n🏗️ Creating SHA256 hasher..."
let $hasher = "System.Security.Cryptography.SHA256" | dn call "Create"
print $"Hasher created: ($hasher)"

# Test the ComputeHash method signature
print "\n🔍 Checking ComputeHash method..."
try {
    # This should fail but give us information about expected parameters
    let $result = $hasher | dn call "ComputeHash" "wrong_type"
    print $"Unexpected success: ($result)"
} catch { |e|
    print $"Expected error with string: ($e.msg)"
}

# Now try with our binary data
print "\n🔄 Trying with binary data..."
try {
    let $result = $hasher | dn call "ComputeHash" $testData
    print $"Success with binary data: ($result)"
} catch { |e|
    print $"Error with binary data: ($e.msg)"
}

# Cleanup
$hasher | dn call "Dispose"
print "\n✅ Cleanup complete" 