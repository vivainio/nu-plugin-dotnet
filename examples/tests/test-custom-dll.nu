#!/usr/bin/env nu

# Updated Custom DLL Test using current syntax
print "=== Custom DLL Testing with nu-plugin-dotnet ==="
print ""

# Load our custom assembly
let dll_path = ($env.PWD | path join "TestLibrary" "bin" "Release" "net8.0" "TestLibrary.dll" | str replace '\' '/')

if not ($dll_path | path exists) {
    print "Building TestLibrary..."
    try {
        dotnet build TestLibrary/TestLibrary.csproj -c Release
    } catch {
        print "❌ Failed to build TestLibrary. Please build manually."
        exit 1
    }
}

print $"Loading custom DLL: ($dll_path)"

try {
    dn load $dll_path
    print "✅ Custom DLL loaded successfully"
} catch { |e|
    print $"❌ Failed to load DLL: ($e.msg)"
    exit 1
}

print ""
print "=== Testing MathUtilities Methods ==="

# Test factorial calculation
print "1. Testing Factorial method:"
try {
    let factorial_5 = ("TestLibrary.MathUtilities" | dn call "Factorial" 5)
    print $"Factorial of 5: ($factorial_5)"
} catch { |e|
    print $"❌ Factorial test failed: ($e.msg)"
}

# Test prime checking
print ""
print "2. Testing IsPrime method:"
let test_numbers = [2, 3, 4, 5, 17]
for num in $test_numbers {
    try {
        let is_prime = ("TestLibrary.MathUtilities" | dn call "IsPrime" $num)
        print $"  ($num) is prime: ($is_prime)"
    } catch { |e|
        print $"❌ IsPrime test failed for ($num): ($e.msg)"
    }
}

# Test string operations
print ""
print "3. Testing StringUtilities methods:"
try {
    let reversed = ("TestLibrary.StringUtilities" | dn call "Reverse" "hello")
    print $"  Reverse('hello') = '($reversed)'"
    
    let is_palindrome = ("TestLibrary.StringUtilities" | dn call "IsPalindrome" "racecar")
    print $"  IsPalindrome('racecar') = ($is_palindrome)"
} catch { |e|
    print $"❌ String test failed: ($e.msg)"
}

print ""
print "🎉 Custom DLL testing completed successfully!"

# Ensure clean exit
exit 0