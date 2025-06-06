#!/usr/bin/env nu

# Nu Plugin DotNet - Integration Test
# Tests the registered plugin functionality

print "🧪 Nu Plugin DotNet - Integration Test"
print "======================================"

def test_command [test_name: string, command: closure] {
    print $"\n🔍 Testing: ($test_name)"
    try {
        let $result = (do $command)
        print $"✅ PASS: ($test_name) - ($result)"
        { name: $test_name, status: "PASS", result: $result, error: null }
    } catch { |e|
        print $"❌ FAIL: ($test_name) - ($e.msg)"
        { name: $test_name, status: "FAIL", result: null, error: $e.msg }
    }
}

print "\n📋 Running Integration Tests:"

let $results = [

# Test 1: Check plugin is loaded
(test_command "Plugin Registration" {
    let $plugins = plugin list
    let $our_plugin = $plugins | where name =~ "dotnet"
    if ($our_plugin | length) > 0 { "Plugin is registered" } else { error make { msg: "Plugin not found" } }
}),

# Test 2: Test assemblies command
(test_command "List Assemblies" {
    let $assemblies = dn assemblies
    let $count = $assemblies | length
    if $count > 5 { $"Found ($count) assemblies" } else { error make { msg: $"Expected more assemblies, got ($count)" } }
}),

# Test 3: Test basic math
(test_command "Math.PI Constant" {
    let $pi = "System.Math" | dn get "PI"
    if ($pi > 3.14) and ($pi < 3.15) { $"PI = ($pi)" } else { error make { msg: $"Expected ~3.14159, got ($pi)" } }
}),

# Test 4: Test static method
(test_command "Math.Max Function" {
    let $max = "System.Math" | dn call "Max" 10 20
    if $max == 20 { "Max of 10 and 20 = " + ($max | into string) } else { error make { msg: $"Expected 20, got ($max)" } }
}),

# Test 5: Test environment
(test_command "Environment.MachineName" {
    let $machine = "System.Environment" | dn get "MachineName"
    if ($machine | str length) > 0 { $"Machine: ($machine)" } else { error make { msg: "MachineName should not be empty" } }
}),

# Test 6: Test DateTime
(test_command "DateTime.Now" {
    let $now = "System.DateTime" | dn get "Now"
    let $year = $now | dn get "Year"
    if $year >= 2024 { $"Current year: ($year)" } else { error make { msg: $"Expected year >= 2024, got ($year)" } }
}),

# Test 7: Test string operations
(test_command "String Length" {
    let $str = "Hello World"
    let $length = $str | dn get "Length"
    if $length == 11 { $"Length of 'Hello World': ($length)" } else { error make { msg: $"Expected 11, got ($length)" } }
}),

# Test 8: Test Path operations
(test_command "Path.Combine" {
    let $path = "System.IO.Path" | dn call "Combine" "C:" "temp" "file.txt"
    if ($path | str contains "file.txt") { $"Combined path: ($path)" } else { error make { msg: $"Expected path to contain 'file.txt', got ($path)" } }
}),

# Test 9: Test GUID generation
(test_command "GUID.NewGuid" {
    let $guid = "System.Guid" | dn call "NewGuid"
    let $str = $guid | dn call "ToString"
    if ($str | str length) > 30 { $"Generated GUID: ($str | str substring 0..8)..." } else { error make { msg: "GUID string too short" } }
}),

# Test 10: Test error handling
(test_command "Error Handling" {
    try {
        "System.Math" | dn call "NonExistentMethod" 1 2
        error make { msg: "Should have failed" }
    } catch {
        "Error handling works correctly"
    }
}),

# Test 11: Test Console.WriteLine
(test_command "Console.WriteLine" {
    # Test Console.WriteLine - should execute without error and return null/void
    let $result = "System.Console" | dn call "WriteLine" "Hello from nu-plugin-dotnet!"
    # Console.WriteLine returns void, so we expect null or empty
    if ($result == null) or ($result == "") { 
        "Console.WriteLine executed successfully" 
    } else { 
        $"Console.WriteLine returned: ($result)" 
    }
})

]

print "\n📊 Test Summary"
print "==============="

let $passed = $results | where status == "PASS" | length
let $failed = $results | where status == "FAIL" | length
let $total = $results | length

print $"Total Tests: ($total)"
print $"✅ Passed: ($passed)"
print $"❌ Failed: ($failed)"
print $"Success Rate: (($passed * 100) / $total | math round --precision 1)%"

if $failed > 0 {
    print "\n❌ Failed Tests:"
    $results | where status == "FAIL" | each { |test|
        print $"  - ($test.name): ($test.error)"
    } | ignore
    exit 1
} else {
    print "\n🎉 All tests passed! Plugin is fully functional."
    exit 0
} 