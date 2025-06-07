#!/usr/bin/env nu

# Demo: Custom DLL Integration Concept with nu-plugin-dotnet
# This demonstrates the pattern for using custom DLLs

print "=== Custom DLL Integration Demo ==="
print ""

# Show the DLL we created
let dll_path = ($env.PWD | path join "TestLibrary" "bin" "Release" "net8.0" "TestLibrary.dll")
print $"✅ Custom DLL created: ($dll_path)"
print $"✅ DLL exists: ($dll_path | path exists)"

# Display the DLL file info
let dll_info = ls $dll_path | first
print $"✅ DLL size: ($dll_info.size)"
print ""

print "=== What the Integration Would Look Like ==="
print ""

print "With nu-plugin-dotnet properly configured, you could run:"
print ""

print "# 1. Load assembly and call Factorial method"
print '   dn load $dll_path'
print '   "TestLibrary.MathUtilities" | dn call "Factorial" 5'
print "   Result: 120"
print ""

print "# 2. Test prime number checking"
print '   "TestLibrary.MathUtilities" | dn call "IsPrime" 17'
print "   Result: true"
print ""

print "# 3. String manipulation"
print '   "TestLibrary.StringUtilities" | dn call "Reverse" "hello"'
print "   Result: olleh"
print ""

print "# 4. Complex operations with loops"
print '   for num in [2, 3, 5, 7, 11] {'
print '       let is_prime = "TestLibrary.MathUtilities" | dn call "IsPrime" $num'
print '       print $"($num) is prime: ($is_prime)"'
print '   }'
print ""

print "=== Custom DLL Methods Available ==="
print ""

print "📐 MathUtilities methods:"
print "   • Factorial(int n) - Calculate factorial"
print "   • IsPrime(int number) - Check if number is prime"
print "   • GreatestCommonDivisor(int a, int b) - Calculate GCD" 
print "   • Fibonacci(int n) - Generate Fibonacci sequence"
print ""

print "📝 StringUtilities methods:"
print "   • Reverse(string input) - Reverse a string"
print "   • IsPalindrome(string input) - Check if palindrome"
print "   • WordCount(string input) - Count words"
print "   • ToTitleCase(string input) - Convert to title case"
print "   • SimpleHash(string input) - Generate simple hash"
print ""

print "=== Benefits of Custom DLL Integration ==="
print ""
print "🚀 Performance: Compiled .NET code runs faster"
print "🔧 Reusability: Write once, use in multiple scripts"
print "🧮 Complex Logic: Implement sophisticated algorithms in C#"
print "📚 Ecosystem: Access entire .NET ecosystem and NuGet packages"
print "🛡️ Type Safety: Benefit from .NET's strong typing"
print ""

print "=== Next Steps ==="
print ""
print "1. Ensure nu-plugin-dotnet is properly installed and registered"
print "2. Run: nu plugin add path/to/nu_plugin_dotnet.exe"
print "3. Restart Nushell or start new session"
print "4. Run the actual tests: nu test-custom-dll-working.nu"
print ""

print "The custom DLL is ready and the test patterns are established!"
print "This demonstrates how to extend Nushell with custom .NET functionality." 