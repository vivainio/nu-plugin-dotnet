# Nu Plugin .NET Test Module
# Main test module for nu-plugin-dotnet using modern Nushell testing patterns

# Export test runners for different categories
export use unit/basic-functionality.nu run-basic-tests
export use unit/assembly-operations.nu run-assembly-tests  
export use unit/error-handling.nu run-error-tests
export use integration/custom-dll.nu run-custom-dll-tests

# Main test runner that runs all test suites
export def run-all-tests [] {
    print "🧪 Nu Plugin .NET - Comprehensive Test Suite"
    print "============================================="
    print ""
    
    # Verify plugin is available
    if not (which dn | is-not-empty) {
        print "❌ nu-plugin-dotnet not found. Please install and register the plugin."
        print "   Run: plugin add nu_plugin_dotnet.exe"
        exit 1
    }
    
    print "✅ Plugin verified and available"
    print ""
    
    # Run each test suite
    let test_suites = [
        {name: "Basic Functionality", runner: "run-basic-tests"},
        {name: "Assembly Operations", runner: "run-assembly-tests"},
        {name: "Error Handling", runner: "run-error-tests"},
        {name: "Custom DLL Integration", runner: "run-custom-dll-tests"}
    ]
    
    let results = ($test_suites | each { |suite|
        print $"🎯 Running ($suite.name) Tests"
        print ("=" | str repeat ($suite.name | str length + 20))
        
        try {
            match $suite.runner {
                "run-basic-tests" => { use unit/basic-functionality.nu; run-basic-tests },
                "run-assembly-tests" => { use unit/assembly-operations.nu; run-assembly-tests },
                "run-error-tests" => { use unit/error-handling.nu; run-error-tests },
                "run-custom-dll-tests" => { use integration/custom-dll.nu; run-custom-dll-tests }
            }
            print $"✅ ($suite.name) tests completed successfully"
            {suite: $suite.name, status: "PASS", error: null}
        } catch { |e|
            print $"❌ ($suite.name) tests failed: ($e.msg)"
            {suite: $suite.name, status: "FAIL", error: $e.msg}
        }
    })
    
    let failed_count = ($results | where status == "FAIL" | length)
    
    print ""
    
    # Final summary
    print "📊 FINAL TEST SUMMARY"
    print "====================="
    
    if $failed_count == 0 {
        print "🎉 ALL TEST SUITES PASSED!"
        print ""
        print "✅ Plugin Status: PRODUCTION READY"
        print "✅ All core functionality verified"
        print "✅ Error handling robust"
        print "✅ Custom DLL integration working"
        print ""
        exit 0
    } else {
        print $"❌ ($failed_count) test suites failed"
        print ""
        print "Failed suites:"
        $results | where status == "FAIL" | each { |result|
            print $"  - ($result.suite): ($result.error)"
        }
        print ""
        print "Please review the failed tests above"
        exit 1
    }
}

# Run quick smoke tests (essential functionality only)
export def run-smoke-tests [] {
    print "🚀 Nu Plugin .NET - Smoke Tests (Quick Validation)"
    print "=================================================="
    print ""
    
    # Verify plugin is available
    if not (which dn | is-not-empty) {
        print "❌ nu-plugin-dotnet not found"
        exit 1
    }
    
    use std assert
    
    print "Testing core functionality..."
    
    # Basic object creation
    try {
        let sb = (dn new "System.Text.StringBuilder")
        assert ($sb | str contains "StringBuilder")
        print "  ✅ Object creation working"
    } catch { |e|
        print $"  ❌ Object creation failed: ($e.msg)"
        exit 1
    }
    
    # Method calls
    try {
        let result = ("System.Math" | dn call "Max" 10 20)
        assert ($result == 20)
        print "  ✅ Method calls working"
    } catch { |e|
        print $"  ❌ Method calls failed: ($e.msg)"
        exit 1
    }
    
    # Property access
    try {
        let length = ("Hello" | dn get "Length")
        assert ($length == 5)
        print "  ✅ Property access working"
    } catch { |e|
        print $"  ❌ Property access failed: ($e.msg)"
        exit 1
    }
    
    # Assembly operations
    try {
        let assemblies = (dn assemblies)
        assert (($assemblies | length) > 0)
        print "  ✅ Assembly operations working"
    } catch { |e|
        print $"  ❌ Assembly operations failed: ($e.msg)"
        exit 1
    }
    
    print ""
    print "🎉 Smoke tests passed! Plugin is functional."
    exit 0
}

# Run performance tests (measure execution time)
export def run-performance-tests [] {
    print "⚡ Nu Plugin .NET - Performance Tests"
    print "===================================="
    print ""
    
    use std assert
    
    # Test object creation performance
    print "📊 Testing object creation performance..."
    let start_time = (date now)
    
    for i in 1..100 {
        let obj = (dn new "System.Object")
    }
    
    let end_time = (date now)
    let duration = ($end_time - $start_time)
    print $"  100 object creations: ($duration)"
    
    # Test method call performance
    print "📊 Testing method call performance..."
    let start_time = (date now)
    
    for i in 1..100 {
        let result = ("System.Math" | dn call "Max" $i ($i + 1))
    }
    
    let end_time = (date now)
    let duration = ($end_time - $start_time)
    print $"  100 method calls: ($duration)"
    
    print ""
    print "✅ Performance tests completed"
}

# Export individual test categories for selective testing
export def run-unit-tests [] {
    print "🧪 Running Unit Tests Only"
    print "=========================="
    print ""
    
    use unit/basic-functionality.nu; run-basic-tests
    print ""
    use unit/assembly-operations.nu; run-assembly-tests  
    print ""
    use unit/error-handling.nu; run-error-tests
    
    print ""
    print "✅ All unit tests completed"
}

export def run-integration-tests [] {
    print "🔗 Running Integration Tests Only"
    print "================================="
    print ""
    
    use integration/custom-dll.nu; run-custom-dll-tests
    
    print ""
    print "✅ All integration tests completed"
}