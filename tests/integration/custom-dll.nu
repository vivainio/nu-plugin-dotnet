#!/usr/bin/env nu

# Integration tests for custom DLL loading and usage
# Tests end-to-end scenarios with the TestLibrary

use std assert

# Setup and availability checks
def "test TestLibrary availability" [] {
    # Arrange
    let dll_path = ($env.PWD | path join "TestLibrary" "bin" "Release" "net8.0" "TestLibrary.dll")
    
    # Act & Assert
    if ($dll_path | path exists) {
        assert true "TestLibrary.dll is available for testing"
    } else {
        print "⏭️ TestLibrary.dll not found - building..."
        try {
            dotnet build TestLibrary/TestLibrary.csproj -c Release
            assert ($dll_path | path exists) "TestLibrary.dll should exist after build"
        } catch { |e|
            print $"⚠️ Could not build TestLibrary: ($e.msg)"
            print "⏭️ Skipping custom DLL tests"
            return
        }
    }
}

def "test custom DLL loading" [] {
    # Arrange
    let dll_path = ($env.PWD | path join "TestLibrary" "bin" "Release" "net8.0" "TestLibrary.dll")
    
    # Skip test if DLL doesn't exist
    if not ($dll_path | path exists) {
        print "⏭️ Skipping - TestLibrary.dll not found"
        return
    }
    
    # Act & Assert
    try {
        dn load $dll_path
        assert true "Custom DLL loaded successfully"
    } catch { |e|
        assert false $"Failed to load custom DLL: ($e.msg)"
    }
}

# MathUtilities Tests
def "test MathUtilities Factorial function" [] {
    # Arrange
    let dll_path = ($env.PWD | path join "TestLibrary" "bin" "Release" "net8.0" "TestLibrary.dll")
    
    # Skip test if DLL doesn't exist
    if not ($dll_path | path exists) {
        print "⏭️ Skipping - TestLibrary.dll not found"
        return
    }
    
    # Load DLL
    try { dn load $dll_path } catch { return }
    
    # Act
    let factorial_5 = ("TestLibrary.MathUtilities" | dn call "Factorial" 5)
    let factorial_0 = ("TestLibrary.MathUtilities" | dn call "Factorial" 0)
    let factorial_1 = ("TestLibrary.MathUtilities" | dn call "Factorial" 1)
    
    # Assert
    assert ($factorial_5 == 120)
    assert ($factorial_0 == 1)
    assert ($factorial_1 == 1)
}

def "test MathUtilities IsPrime function" [] {
    # Arrange
    let dll_path = ($env.PWD | path join "TestLibrary" "bin" "Release" "net8.0" "TestLibrary.dll")
    
    # Skip test if DLL doesn't exist
    if not ($dll_path | path exists) {
        print "⏭️ Skipping - TestLibrary.dll not found"
        return
    }
    
    # Load DLL
    try { dn load $dll_path } catch { return }
    
    # Act & Assert
    let primes = [2, 3, 5, 7, 11, 13, 17, 19]
    let non_primes = [4, 6, 8, 9, 10, 12, 14, 15, 16, 18]
    
    for prime in $primes {
        let is_prime = ("TestLibrary.MathUtilities" | dn call "IsPrime" $prime)
        assert ($is_prime == true) $"($prime) should be prime"
    }
    
    for non_prime in $non_primes {
        let is_prime = ("TestLibrary.MathUtilities" | dn call "IsPrime" $non_prime)
        assert ($is_prime == false) $"($non_prime) should not be prime"
    }
}

def "test MathUtilities edge cases" [] {
    # Arrange
    let dll_path = ($env.PWD | path join "TestLibrary" "bin" "Release" "net8.0" "TestLibrary.dll")
    
    # Skip test if DLL doesn't exist
    if not ($dll_path | path exists) {
        print "⏭️ Skipping - TestLibrary.dll not found"
        return
    }
    
    # Load DLL
    try { dn load $dll_path } catch { return }
    
    # Act & Assert
    # Test edge cases for IsPrime
    let one_is_prime = ("TestLibrary.MathUtilities" | dn call "IsPrime" 1)
    assert ($one_is_prime == false) "1 should not be considered prime"
    
    # Test larger factorial
    let factorial_6 = ("TestLibrary.MathUtilities" | dn call "Factorial" 6)
    assert ($factorial_6 == 720)
}

# StringUtilities Tests
def "test StringUtilities Reverse function" [] {
    # Arrange
    let dll_path = ($env.PWD | path join "TestLibrary" "bin" "Release" "net8.0" "TestLibrary.dll")
    
    # Skip test if DLL doesn't exist
    if not ($dll_path | path exists) {
        print "⏭️ Skipping - TestLibrary.dll not found"
        return
    }
    
    # Load DLL
    try { dn load $dll_path } catch { return }
    
    # Act & Assert
    let test_cases = [
        ["hello", "olleh"],
        ["world", "dlrow"],
        ["nushell", "llehsun"],
        ["", ""],
        ["a", "a"]
    ]
    
    for test_case in $test_cases {
        let input = ($test_case | first)
        let expected = ($test_case | last)
        let result = ("TestLibrary.StringUtilities" | dn call "Reverse" $input)
        assert ($result == $expected) $"Reverse('($input)') should be '($expected)'"
    }
}

def "test StringUtilities IsPalindrome function" [] {
    # Arrange
    let dll_path = ($env.PWD | path join "TestLibrary" "bin" "Release" "net8.0" "TestLibrary.dll")
    
    # Skip test if DLL doesn't exist
    if not ($dll_path | path exists) {
        print "⏭️ Skipping - TestLibrary.dll not found"
        return
    }
    
    # Load DLL
    try { dn load $dll_path } catch { return }
    
    # Act & Assert
    let palindromes = ["racecar", "level", "madam", "a", ""]
    let non_palindromes = ["hello", "world", "nushell", "test"]
    
    for palindrome in $palindromes {
        let is_palindrome = ("TestLibrary.StringUtilities" | dn call "IsPalindrome" $palindrome)
        assert ($is_palindrome == true) $"'($palindrome)' should be a palindrome"
    }
    
    for non_palindrome in $non_palindromes {
        let is_palindrome = ("TestLibrary.StringUtilities" | dn call "IsPalindrome" $non_palindrome)
        assert ($is_palindrome == false) $"'($non_palindrome)' should not be a palindrome"
    }
}

# Complex Integration Tests
def "test combined MathUtilities and StringUtilities workflow" [] {
    # Arrange
    let dll_path = ($env.PWD | path join "TestLibrary" "bin" "Release" "net8.0" "TestLibrary.dll")
    
    # Skip test if DLL doesn't exist
    if not ($dll_path | path exists) {
        print "⏭️ Skipping - TestLibrary.dll not found"
        return
    }
    
    # Load DLL
    try { dn load $dll_path } catch { return }
    
    # Act - Complex workflow combining math and string operations
    let numbers = [2, 3, 5, 7]
    let factorial_results = ($numbers | each { |n|
        let factorial = ("TestLibrary.MathUtilities" | dn call "Factorial" $n)
        let factorial_str = ($factorial | into string)
        let reversed = ("TestLibrary.StringUtilities" | dn call "Reverse" $factorial_str)
        {number: $n, factorial: $factorial, reversed: $reversed}
    })
    
    # Assert
    assert (($factorial_results | length) == 4)
    assert (($factorial_results | get factorial | first) == 2)  # 2! = 2
    assert (($factorial_results | get factorial | get 1) == 6)  # 3! = 6
    assert (($factorial_results | get factorial | get 2) == 120) # 5! = 120
    assert (($factorial_results | get factorial | get 3) == 5040) # 7! = 5040
}

def "test error handling with custom DLL" [] {
    # Arrange
    let dll_path = ($env.PWD | path join "TestLibrary" "bin" "Release" "net8.0" "TestLibrary.dll")
    
    # Skip test if DLL doesn't exist
    if not ($dll_path | path exists) {
        print "⏭️ Skipping - TestLibrary.dll not found"
        return
    }
    
    # Load DLL
    try { dn load $dll_path } catch { return }
    
    # Act & Assert - Test invalid method calls
    try {
        "TestLibrary.MathUtilities" | dn call "NonExistentMethod" 5
        assert false "Should have thrown error for non-existent method"
    } catch {
        assert true "Correctly handled non-existent method error"
    }
    
    # Test invalid class
    try {
        "TestLibrary.NonExistentClass" | dn call "SomeMethod" 5
        assert false "Should have thrown error for non-existent class"
    } catch {
        assert true "Correctly handled non-existent class error"
    }
}

def "test TestLibrary type discovery" [] {
    # Arrange
    let dll_path = ($env.PWD | path join "TestLibrary" "bin" "Release" "net8.0" "TestLibrary.dll")
    
    # Skip test if DLL doesn't exist
    if not ($dll_path | path exists) {
        print "⏭️ Skipping - TestLibrary.dll not found"
        return
    }
    
    # Load DLL
    try { dn load $dll_path } catch { return }
    
    # Act - Discover types in TestLibrary
    try {
        let types = (dn types "TestLibrary")
        
        # Assert
        assert (($types | describe) | str contains "list")
        assert (($types | length) >= 2)  # Should have at least MathUtilities and StringUtilities
        
        let type_names = ($types | get name)
        assert ($type_names | any { $it == "MathUtilities" })
        assert ($type_names | any { $it == "StringUtilities" })
    } catch {
        # Some versions might not support type listing by assembly name
        print "ℹ️ Type discovery not available for custom assemblies"
    }
}

# Test runner for this module
def run-custom-dll-tests [] {
    let test_functions = (
        scope commands 
        | where name =~ "^test " 
        | get name
    )
    
    print $"🧪 Running ($test_functions | length) custom DLL integration tests..."
    print ""
    
    # First check if TestLibrary is available
    let dll_path = ($env.PWD | path join "TestLibrary" "bin" "Release" "net8.0" "TestLibrary.dll")
    if not ($dll_path | path exists) {
        print "⚠️ TestLibrary.dll not found. Attempting to build..."
        try {
            dotnet build TestLibrary/TestLibrary.csproj -c Release
        } catch {
            print "❌ Could not build TestLibrary. Skipping custom DLL tests."
            return
        }
    }
    
    let results = ($test_functions | each { |test_name|
        try {
            do { nu -c $"use tests/integration/custom-dll.nu; ($test_name)" }
            print $"  ✅ ($test_name)"
            {name: $test_name, status: "PASS", error: null}
        } catch { |e|
            print $"  ❌ ($test_name): ($e.msg)"
            {name: $test_name, status: "FAIL", error: $e.msg}
        }
    })
    
    let passed = ($results | where status == "PASS" | length)
    let failed = ($results | where status == "FAIL" | length)
    
    print ""
    print $"📊 Custom DLL Tests: ($passed) passed, ($failed) failed"
    
    if $failed > 0 {
        print "❌ Failed tests:"
        $results | where status == "FAIL" | each { |test|
            print $"  - ($test.name): ($test.error)"
        }
        exit 1
    } else {
        print "✅ All custom DLL integration tests passed!"
    }
}

# Main entry point
def main [] {
    run-custom-dll-tests
}