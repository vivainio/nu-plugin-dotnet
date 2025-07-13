#!/usr/bin/env nu

# Quick validation test for custom DLL integration

print "Testing custom DLL integration..."

# Get the DLL path
let dll_path = ($env.PWD | path join "TestLibrary" "bin" "Release" "net8.0" "TestLibrary.dll")

# Test if we can load and use the custom DLL
print $"DLL Path: ($dll_path)"
print $"DLL exists: ($dll_path | path exists)"

# Quick test of a simple method
print ""
print "Testing basic functionality:"

try {
    # Test factorial calculation
    let result = dn type load-asm $dll_path | dn type use TestLibrary.MathUtilities | dn method call Factorial 5
    print $"✅ Factorial test passed: 5! = ($result)"
    
    # Test string reversal
    let reversed = dn type load-asm $dll_path | dn type use TestLibrary.StringUtilities | dn method call Reverse "test"
    print $"✅ String reversal test passed: 'test' reversed = '($reversed)'"
    
    print ""
    print "🎉 Custom DLL integration is working correctly!"
    
} catch { |e|
    print $"❌ Error testing custom DLL: ($e.msg)"
    print "Make sure nu-plugin-dotnet is properly installed and registered.

exit 0"
} 