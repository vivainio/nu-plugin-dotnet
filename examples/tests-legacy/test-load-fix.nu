#!/usr/bin/env nu

print "🔧 Testing dn load command fix"
print "==============================="

# Test 1: Load TestLibrary
print "1. Loading TestLibrary.dll..."
let load_result = try {
    dn load "C:/r/nu-plugin-dotnet/TestLibrary/bin/Release/net8.0/TestLibrary.dll"
} catch { |e|
    print $"❌ Load failed: ($e.msg)"
    exit 1
}

print $"✅ Library loaded: ($load_result.name) v($load_result.version)"

# Test 2: Check if types are available
print ""
print "2. Checking TestLibrary.MathUtilities members..."
let members = try {
    dn members "TestLibrary.MathUtilities"
} catch { |e|
    print $"❌ Members failed: ($e.msg)"
    exit 1
}

print $"✅ Found ($members | length) members"

# Test 3: Try static method call
print ""
print "3. Testing static method call..."
let factorial_result = try {
    "TestLibrary.MathUtilities" | dn call "Factorial" 5
} catch { |e|
    print $"❌ Method call failed: ($e.msg)"
    exit 1
}

print $"✅ Factorial(5) = ($factorial_result)"

# Test 4: Test multiple methods
print ""
print "4. Testing multiple methods..."
let is_prime = try {
    "TestLibrary.MathUtilities" | dn call "IsPrime" 17
} catch { |e|
    print $"❌ IsPrime failed: ($e.msg)"
    exit 1
}

print $"✅ IsPrime(17) = ($is_prime)"

let gcd = try {
    "TestLibrary.MathUtilities" | dn call "GreatestCommonDivisor" 48 18
} catch { |e|
    print $"❌ GCD failed: ($e.msg)"
    exit 1
}

print $"✅ GCD of 48 and 18 = ($gcd)"

print ""
print "🎉 All TestLibrary tests passed!"
print "The dn load command is working correctly."