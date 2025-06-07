# Custom DLL Testing with nu-plugin-dotnet

This directory contains a custom .NET class library (`TestLibrary`) that demonstrates how to create and use custom DLLs with the nu-plugin-dotnet plugin.

## What's Included

### TestLibrary.dll
A custom .NET 8.0 class library with two utility classes:

#### MathUtilities
Static methods for mathematical operations:
- `Factorial(int n)` - Calculates factorial of a number
- `IsPrime(int number)` - Checks if a number is prime
- `GreatestCommonDivisor(int a, int b)` - Calculates GCD of two numbers
- `Fibonacci(int n)` - Generates Fibonacci sequence

#### StringUtilities
Static methods for string operations:
- `Reverse(string input)` - Reverses a string
- `IsPalindrome(string input)` - Checks if a string is a palindrome
- `WordCount(string input)` - Counts words in a string
- `ToTitleCase(string input)` - Converts to title case
- `SimpleHash(string input)` - Generates a simple hash

## How to Use

### 1. Build the Custom DLL
```bash
cd TestLibrary
dotnet build -c Release
```

### 2. Run the Tests
```bash
# Simple test (recommended to start)
nu test-custom-dll-simple.nu

# Comprehensive test
nu test-custom-dll.nu
```

### 3. Key Commands Demonstrated

#### Loading a Custom Assembly
```nushell
dn load "path/to/your/custom.dll"
```

#### Using a Specific Type
```nushell
dn load $dll_path
"TestLibrary.MathUtilities" | dn call "method_name" params
```

#### Calling Static Methods
```nushell
dn load $dll_path
"TestLibrary.MathUtilities" | dn call "Factorial" 5
```

#### Chaining Operations
```nushell
let dll_path = "TestLibrary/bin/Release/net8.0/TestLibrary.dll"
dn load $dll_path
let result = "TestLibrary.StringUtilities" | dn call "Reverse" "hello"
```

## Example Usage

```nushell
# Load the DLL and calculate factorial
let dll_path = ($env.PWD | path join "TestLibrary" "bin" "Release" "net8.0" "TestLibrary.dll")
dn load $dll_path
let factorial_result = "TestLibrary.MathUtilities" | dn call "Factorial" 5
print $"5! = ($factorial_result)"

# Check if a number is prime
let is_prime = "TestLibrary.MathUtilities" | dn call "IsPrime" 17
print $"17 is prime: ($is_prime)"

# Reverse a string
let reversed = "TestLibrary.StringUtilities" | dn call "Reverse" "nushell"
print $"Reversed: ($reversed)"
```

## Benefits of Custom DLLs

1. **Reusability** - Write once, use across multiple scripts
2. **Performance** - Compiled .NET code runs faster than interpreted scripts
3. **Complex Logic** - Implement sophisticated algorithms in C#
4. **Type Safety** - Benefit from .NET's strong typing system
5. **Ecosystem** - Access to the entire .NET ecosystem and NuGet packages

## Next Steps

Try creating your own custom DLL:
1. Create a new class library project
2. Add your custom methods
3. Build the DLL
4. Reference it in your Nushell scripts using nu-plugin-dotnet

This approach allows you to extend Nushell with powerful .NET functionality while maintaining the elegant shell scripting experience. 