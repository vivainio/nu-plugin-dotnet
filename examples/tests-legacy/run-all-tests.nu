#!/usr/bin/env nu

# Nu Plugin DotNet - All Tests Runner
# Executes all test files in examples/tests/ directory

print "🧪 Nu Plugin DotNet - All Tests Runner"
print "======================================"
print ""

# Check if plugin is registered
try {
    (dn assemblies | length) > 0
    print "✅ Plugin is registered and available"
} catch {
    print "❌ Plugin not found. Please register the plugin first:"
    print "   plugin add ./publish/win-x64/nu_plugin_dotnet.exe"
    print "   or"
    print "   plugin add ./bin/Release/net8.0/nu_plugin_dotnet.exe"
    exit 1
}

print ""

# Get all test files in the tests directory
let test_files = (ls examples/tests/*.nu | get name | sort)
let total_tests = ($test_files | length)

print $"Found ($total_tests) test files to run:"
$test_files | each { |file| print $"  - ($file)" }
print ""

# Run each test file and collect results
let results = ($test_files | each { |file|
    let test_name = ($file | path basename)
    print $"🔍 Running: ($test_name)"
    print $"----------------------------------------"
    
    try {
        # Run the test file and capture any output
        let start_time = (date now)
        nu $file
        let end_time = (date now)
        let duration = ($end_time - $start_time)
        
        print $"✅ PASS: ($test_name) (Duration: ($duration))"
        print ""
        {
            name: $test_name,
            status: "PASS",
            file: $file,
            duration: $duration,
            error: null
        }
    } catch { |e|
        print $"❌ FAIL: ($test_name) - ($e.msg)"
        print ""
        {
            name: $test_name,
            status: "FAIL", 
            file: $file,
            duration: null,
            error: $e.msg
        }
    }
})

# Summary
print "📊 Test Summary"
print "==============="

let passed = ($results | where status == "PASS" | length)
let failed = ($results | where status == "FAIL" | length)
let success_rate = if $total_tests > 0 { (($passed * 100) / $total_tests | math round --precision 1) } else { 0 }

print $"Total Tests: ($total_tests)"
print $"✅ Passed: ($passed)"
print $"❌ Failed: ($failed)"
print $"Success Rate: ($success_rate)%"

if $failed > 0 {
    print ""
    print "❌ Failed Tests:"
    $results | where status == "FAIL" | each { |test|
        print $"  - ($test.name): ($test.error)"
    }
}

print ""
print "🎯 Detailed Results:"
$results | each { |test|
    let icon = if $test.status == "PASS" { "✅" } else { "❌" }
    let duration_str = if $test.duration != null { $" (($test.duration))" } else { "" }
    print $"($icon) ($test.name) - ($test.status)($duration_str)"
}

print ""
if $failed == 0 {
    print "🎉 All tests passed! The plugin is working perfectly."
} else {
    print $"⚠️  ($failed) out of ($total_tests) tests failed. Please review the failures above."
}

# Also run the main test suite for comparison
print ""
print "🔗 Running Main Test Suite"
print "=========================="
try {
    nu examples/test-suite.nu
    print "✅ Main test suite completed"
} catch { |e|
    print $"❌ Main test suite failed: ($e.msg)"
}

# Return results for external use
{
    total: $total_tests,
    passed: $passed,
    failed: $failed,
    success_rate: $success_rate,
    test_results: $results
}