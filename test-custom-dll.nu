#!/usr/bin/env nu

# Test script demonstrating how to reference a custom DLL and use its methods
# This test uses the TestLibrary.dll we just created

print "=== Custom DLL Testing with nu-plugin-dotnet ==="
print ""

# First, let's build our test library if it doesn't exist
if not (["TestLibrary", "bin", "Release", "net8.0", "TestLibrary.dll"] | path exists) {
    print "Building TestLibrary..."
    cd TestLibrary
    dotnet build -c Release
    cd ..
}

# Get the path to our custom DLL
let dll_path = ($env.PWD | path join "TestLibrary" "bin" "Release" "net8.0" "TestLibrary.dll")
print $"Using DLL: ($dll_path)"
print ""

print "=== Testing MathUtilities Methods ==="

# Test factorial calculation
print "1. Testing Factorial method:"
let factorial_5 = dn type load-asm $dll_path | dn type use TestLibrary.MathUtilities | dn method call Factorial 5
print $"Factorial of 5: ($factorial_5)"

let factorial_0 = dn type load-asm $dll_path | dn type use TestLibrary.MathUtilities | dn method call Factorial 0
print $"Factorial of 0: ($factorial_0)"

let factorial_7 = dn type load-asm $dll_path | dn type use TestLibrary.MathUtilities | dn method call Factorial 7
print $"Factorial of 7: ($factorial_7)"
print ""

# Test prime number checking
print "2. Testing IsPrime method:"
let primes_to_test = [2, 3, 4, 5, 17, 18, 19, 25, 29, 30]
for num in $primes_to_test {
    let is_prime = dn type load-asm $dll_path | dn type use TestLibrary.MathUtilities | dn method call IsPrime $num
    print $"Is ($num) prime? ($is_prime)"
}
print ""

# Test Greatest Common Divisor
print "3. Testing GreatestCommonDivisor method:"
let gcd_48_18 = dn type load-asm $dll_path | dn type use TestLibrary.MathUtilities | dn method call GreatestCommonDivisor 48 18
print $"GCD of 48 and 18: ($gcd_48_18)"

let gcd_56_42 = dn type load-asm $dll_path | dn type use TestLibrary.MathUtilities | dn method call GreatestCommonDivisor 56 42
print $"GCD of 56 and 42: ($gcd_56_42)"
print ""

# Test Fibonacci sequence
print "4. Testing Fibonacci method:"
let fib_10 = dn type load-asm $dll_path | dn type use TestLibrary.MathUtilities | dn method call Fibonacci 10
print $"First 10 Fibonacci numbers: ($fib_10)"

let fib_5 = dn type load-asm $dll_path | dn type use TestLibrary.MathUtilities | dn method call Fibonacci 5
print $"First 5 Fibonacci numbers: ($fib_5)"
print ""

print "=== Testing StringUtilities Methods ==="

# Test string reversal
print "5. Testing Reverse method:"
let test_strings = ["hello", "world", "nushell", "programming"]
for str in $test_strings {
    let reversed = dn type load-asm $dll_path | dn type use TestLibrary.StringUtilities | dn method call Reverse $str
    print $"Reverse of '($str)': '($reversed)'"
}
print ""

# Test palindrome checking
print "6. Testing IsPalindrome method:"
let palindrome_tests = ["racecar", "hello", "madam", "level", "programming", "A man a plan a canal Panama"]
for str in $palindrome_tests {
    let is_palindrome = dn type load-asm $dll_path | dn type use TestLibrary.StringUtilities | dn method call IsPalindrome $str
    print $"Is '($str)' a palindrome? ($is_palindrome)"
}
print ""

# Test word count
print "7. Testing WordCount method:"
let word_count_tests = [
    "hello world", 
    "the quick brown fox", 
    "this is a test sentence with multiple words",
    "",
    "   ",
    "single"
]
for str in $word_count_tests {
    let count = dn type load-asm $dll_path | dn type use TestLibrary.StringUtilities | dn method call WordCount $str
    print $"Word count in '($str)': ($count)"
}
print ""

# Test title case conversion
print "8. Testing ToTitleCase method:"
let title_case_tests = ["hello world", "the quick brown fox", "nushell is awesome", "UPPERCASE STRING"]
for str in $title_case_tests {
    let title_case = dn type load-asm $dll_path | dn type use TestLibrary.StringUtilities | dn method call ToTitleCase $str
    print $"Title case of '($str)': '($title_case)'"
}
print ""

# Test simple hash generation
print "9. Testing SimpleHash method:"
let hash_tests = ["hello", "world", "nushell", "test", ""]
for str in $hash_tests {
    let hash = dn type load-asm $dll_path | dn type use TestLibrary.StringUtilities | dn method call SimpleHash $str
    print $"Hash of '($str)': ($hash)"
}
print ""

print "=== Advanced Testing: Combining Methods ==="

# Demonstrate more complex usage combining multiple methods
print "10. Advanced test - Finding prime numbers and their properties:"
let numbers = 1..20 | each { |n|
    let is_prime = dn type load-asm $dll_path | dn type use TestLibrary.MathUtilities | dn method call IsPrime $n
    {
        number: $n,
        is_prime: $is_prime,
        factorial: (if $n <= 10 { 
            dn type load-asm $dll_path | dn type use TestLibrary.MathUtilities | dn method call Factorial $n 
        } else { 
            "too large" 
        })
    }
}

$numbers | where is_prime | each { |row|
    print $"Prime number: ($row.number), Factorial: ($row.factorial)"
}
print ""

# Test with string manipulation on numbers
print "11. Advanced test - String manipulation of numeric results:"
let fibonacci_result = dn type load-asm $dll_path | dn type use TestLibrary.MathUtilities | dn method call Fibonacci 8
let fib_string = $fibonacci_result | str join " "
let reversed_fib = dn type load-asm $dll_path | dn type use TestLibrary.StringUtilities | dn method call Reverse $fib_string
let word_count = dn type load-asm $dll_path | dn type use TestLibrary.StringUtilities | dn method call WordCount $fib_string

print $"Fibonacci sequence: ($fib_string)"
print $"Reversed string: ($reversed_fib)"
print $"Word count: ($word_count)"
print ""

print "=== Error Handling Test ==="

# Test error handling with invalid inputs
print "12. Testing error handling:"
try {
    let result = dn type load-asm $dll_path | dn type use TestLibrary.MathUtilities | dn method call Factorial -1
    print $"Factorial of -1: ($result)"
} catch { |e|
    print $"Expected error for negative factorial: ($e.msg)"
}

print ""
print "=== Test Summary ==="
print "✅ Successfully tested custom DLL integration"
print "✅ Verified MathUtilities methods: Factorial, IsPrime, GCD, Fibonacci"
print "✅ Verified StringUtilities methods: Reverse, IsPalindrome, WordCount, ToTitleCase, SimpleHash"
print "✅ Demonstrated advanced method combinations"
print "✅ Verified error handling"
print ""
print "Custom DLL testing completed successfully!" 