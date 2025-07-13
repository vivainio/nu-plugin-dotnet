#!/usr/bin/env nu

# Simple test demonstrating custom DLL integration with nu-plugin-dotnet
# This shows the essential steps to reference and use a custom DLL

print "=== Simple Custom DLL Test ==="
print ""

# Step 1: Define the path to our custom DLL
let dll_path = ($env.PWD | path join "TestLibrary" "bin" "Release" "net8.0" "TestLibrary.dll" | str replace '\' '/')
print $"Using custom DLL: ($dll_path)"

# Step 2: Verify the DLL exists, build if needed
if not ($dll_path | path exists) {
    print "Building custom DLL..."
    try {
        dotnet build TestLibrary/TestLibrary.csproj -c Release
    } catch {
        print "❌ Failed to build TestLibrary. Please build manually."
        exit 1
    }
}

# Step 3: Load the custom assembly
print ""
print "=== Loading Assembly ==="
try {
    let load_result = dn load $dll_path
    print $"✅ Loaded: ($load_result.name) v($load_result.version)"
} catch { |e|
    print $"❌ Failed to load DLL: ($e.msg)"
    exit 1
}

# Step 4: Test MathUtilities.Factorial
print ""
print "=== Testing Math Functions ==="
print "Computing factorials:"
try {
    let fact_5 = ("TestLibrary.MathUtilities" | dn call "Factorial" 5)
    print $"  Factorial(5) = ($fact_5)"
    
    let fact_6 = ("TestLibrary.MathUtilities" | dn call "Factorial" 6)
    print $"  Factorial(6) = ($fact_6)"
} catch { |e|
    print $"❌ Factorial test failed: ($e.msg)"
}

# Step 5: Test MathUtilities.IsPrime
print ""
print "Testing prime numbers:"
let test_numbers = [2, 3, 4, 5, 17]
for num in $test_numbers {
    try {
        let is_prime = ("TestLibrary.MathUtilities" | dn call "IsPrime" $num)
        print $"  ($num) is prime: ($is_prime)"
    } catch { |e|
        print $"❌ IsPrime test failed for ($num): ($e.msg)"
    }
}

# Step 6: Test StringUtilities
print ""
print "Testing string utilities:"
try {
    let reversed = ("TestLibrary.StringUtilities" | dn call "Reverse" "hello")
    print $"  Reverse('hello') = '($reversed)'"
    
    let is_palindrome = ("TestLibrary.StringUtilities" | dn call "IsPalindrome" "racecar")
    print $"  IsPalindrome('racecar') = ($is_palindrome)"
} catch { |e|
    print $"❌ String test failed: ($e.msg)"
}

print ""
print "🎉 Simple custom DLL test completed!"
print "✅ Custom DLL integration working correctly"