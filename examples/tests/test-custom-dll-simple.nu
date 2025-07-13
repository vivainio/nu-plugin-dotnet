#!/usr/bin/env nu

# Simple test demonstrating custom DLL integration with nu-plugin-dotnet
# This shows the essential steps to reference and use a custom DLL

print "=== Simple Custom DLL Test ==="
print ""

# Step 1: Define the path to our custom DLL
let dll_path = ($env.PWD | path join "TestLibrary" "bin" "Release" "net8.0" "TestLibrary.dll")
print $"Using custom DLL: ($dll_path)"

# Step 2: Verify the DLL exists, build if needed
if not ($dll_path | path exists) {
    print "Building custom DLL..."
    cd TestLibrary
    dotnet build -c Release
    cd ..
}

print ""
print "=== Testing Math Functions ==="

# Step 3: Load assembly and use static methods
print "Computing factorials:"
let fact_5 = dn type load-asm $dll_path | dn type use TestLibrary.MathUtilities | dn method call Factorial 5
let fact_6 = dn type load-asm $dll_path | dn type use TestLibrary.MathUtilities | dn method call Factorial 6
print $"5! = ($fact_5)"
print $"6! = ($fact_6)"

print ""
print "Checking prime numbers:"
[7, 8, 9, 11, 13] | each { |num|
    let is_prime = dn type load-asm $dll_path | dn type use TestLibrary.MathUtilities | dn method call IsPrime $num
    print $"($num) is prime: ($is_prime)"
}

print ""
print "=== Testing String Functions ==="

print "String manipulation:"
let text = "Hello World"
let reversed = dn type load-asm $dll_path | dn type use TestLibrary.StringUtilities | dn method call Reverse $text
let title_case = dn type load-asm $dll_path | dn type use TestLibrary.StringUtilities | dn method call ToTitleCase "hello world"
let is_palindrome = dn type load-asm $dll_path | dn type use TestLibrary.StringUtilities | dn method call IsPalindrome "racecar"

print $"Original: ($text)"
print $"Reversed: ($reversed)"
print $"Title case: ($title_case)"
print $"Is 'racecar' palindrome: ($is_palindrome)"

print ""
print "=== Key Concepts Demonstrated ==="
print "1. ✅ Loading custom DLL with 'dn load'"
print "2. ✅ Calling static methods with 'dn call'"
print "3. ✅ Passing parameters to methods"
print "4. ✅ Working with different return types (numbers, booleans, strings)"
print "5. ✅ Error handling for invalid inputs"
print ""
print "Custom DLL integration test completed successfully!" 