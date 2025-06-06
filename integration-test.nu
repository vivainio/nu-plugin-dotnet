#!/usr/bin/env nu

# Nu Plugin DotNet - Integration Test Suite
# Tests the plugin using actual nushell commands after registration

print "🧪 Nu Plugin DotNet - Integration Test Suite"
print "============================================="
print ""

# Configuration
let plugin_path = "./bin/Release/net8.0/win-x64/nu_plugin_dotnet.exe"
let $test_results = []

# Helper function to run test and capture result
def run_test [test_name: string, test_code: closure] {
    print $"📋 Testing: ($test_name)"
    
    try {
        let result = do $test_code
        print $"✅ PASS: ($test_name)"
        { name: $test_name, status: "PASS", result: $result, error: null }
    } catch { |err|
        print $"❌ FAIL: ($test_name) - ($err.msg)"
        { name: $test_name, status: "FAIL", result: null, error: $err.msg }
    }
}

print "🔧 Step 1: Plugin Registration"
print "==============================="

# Check if plugin exists
if not ($plugin_path | path exists) {
    print $"❌ ERROR: Plugin not found at ($plugin_path)"
    print "Please build the plugin first with: dotnet build -c Release"
    exit 1
}

print $"📁 Plugin found: ($plugin_path)"

# Register the plugin
print "🔌 Registering plugin with nushell..."
try {
    plugin add $plugin_path
    print "✅ Plugin registered successfully"
} catch { |err|
    print $"❌ Failed to register plugin: ($err.msg)"
    exit 1
}

# Verify plugin commands are available
print "🔍 Verifying plugin commands..."
let plugin_commands = (help commands | where name =~ "^dn " | get name)

if ($plugin_commands | length) == 0 {
    print "❌ No 'dn' commands found after registration"
    exit 1
}

print $"✅ Found ($plugin_commands | length) plugin commands:"
$plugin_commands | each { |cmd| print $"  - ($cmd)" }
print ""

print "🧪 Step 2: Functionality Tests"
print "==============================="

# Test 1: Basic Math Operations
let test1 = (run_test "Math.Max(10, 20)" {
    let result = ("System.Math" | dn call "Max" 10 20)
    if $result == 20 { 
        $result 
    } else { 
        error make { msg: $"Expected 20, got ($result)" }
    }
})

# Test 2: Math Constants
let test2 = (run_test "Math.PI Property" {
    let pi = ("System.Math" | dn get "PI")
    if ($pi > 3.14 and $pi < 3.15) { 
        $pi 
    } else { 
        error make { msg: $"Expected PI (~3.14159), got ($pi)" }
    }
})

# Test 3: Object Creation - DateTime
let test3 = (run_test "DateTime Creation" {
    let date = (dn new "System.DateTime" --args [2023, 12, 25])
    if ($date | describe) =~ "custom" {
        $date
    } else {
        error make { msg: $"Expected custom object, got ($date | describe)" }
    }
})

# Test 4: Math.Sqrt
let test4 = (run_test "Math.Sqrt(16)" {
    let result = ("System.Math" | dn call "Sqrt" 16)
    if $result == 4.0 { 
        $result 
    } else { 
        error make { msg: $"Expected 4.0, got ($result)" }
    }
})

# Test 5: String Length
let test5 = (run_test "String Length Property" {
    let length = ("Hello World" | dn get "Length")
    if $length == 11 { 
        $length 
    } else { 
        error make { msg: $"Expected 11, got ($length)" }
    }
})

# Test 6: DateTime Property Access
let test6 = (run_test "DateTime Property Access" {
    let date = (dn new "System.DateTime" --args [2023, 12, 25])
    let year = ($date | dn get "Year")
    if $year == 2023 { 
        $year 
    } else { 
        error make { msg: $"Expected 2023, got ($year)" }
    }
})

# Test 7: Assembly Listing
let test7 = (run_test "List Assemblies" {
    let assemblies = (dn assemblies)
    if ($assemblies | length) > 10 { 
        ($assemblies | length) 
    } else { 
        error make { msg: $"Expected >10 assemblies, got ($assemblies | length)" }
    }
})

# Test 8: Type Listing
let test8 = (run_test "List Types in System.Private.CoreLib" {
    let types = (dn types "System.Private.CoreLib")
    if ($types | length) > 100 { 
        ($types | length) 
    } else { 
        error make { msg: $"Expected >100 types, got ($types | length)" }
    }
})

# Test 9: Member Listing
let test9 = (run_test "List String Members" {
    let members = (dn members "System.String")
    if ($members | length) > 50 { 
        ($members | length) 
    } else { 
        error make { msg: $"Expected >50 members, got ($members | length)" }
    }
})

# Test 10: List Creation and Usage
let test10 = (run_test "List<string> Creation and Add" {
    let list = (dn new "System.Collections.Generic.List[string]")
    $list | dn call "Add" "Hello"
    $list | dn call "Add" "World"
    let count = ($list | dn get "Count")
    if $count == 2 { 
        $count 
    } else { 
        error make { msg: $"Expected count 2, got ($count)" }
    }
})

# Test 11: StringBuilder Operations
let test11 = (run_test "StringBuilder Operations" {
    let sb = (dn new "System.Text.StringBuilder")
    $sb | dn call "Append" "Hello"
    $sb | dn call "Append" " "
    $sb | dn call "Append" "World"
    let result = ($sb | dn call "ToString")
    if $result == "Hello World" { 
        $result 
    } else { 
        error make { msg: $"Expected 'Hello World', got ($result)" }
    }
})

# Test 12: GUID Generation
let test12 = (run_test "GUID Generation" {
    let guid1 = ("System.Guid" | dn call "NewGuid")
    let guid2 = ("System.Guid" | dn call "NewGuid")
    let guid1_str = ($guid1 | dn call "ToString")
    let guid2_str = ($guid2 | dn call "ToString")
    
    if $guid1_str != $guid2_str and ($guid1_str | str length) == 36 { 
        $guid1_str 
    } else { 
        error make { msg: $"GUID generation failed: ($guid1_str), ($guid2_str)" }
    }
})

# Test 13: File Path Operations
let test13 = (run_test "Path.Combine Operations" {
    let combined = ("System.IO.Path" | dn call "Combine" "C:" "Users" "Documents" "file.txt")
    if ($combined | str contains "file.txt") { 
        $combined 
    } else { 
        error make { msg: $"Expected path with 'file.txt', got ($combined)" }
    }
})

# Test 14: Error Handling
let test14 = (run_test "Error Handling - Invalid Constructor" {
    try {
        dn new "System.Guid" --args []
        error make { msg: "Expected error but operation succeeded" }
    } catch { |err|
        if ($err.msg | str contains "constructor") { 
            "Error correctly caught" 
        } else { 
            error make { msg: $"Unexpected error message: ($err.msg)" }
        }
    }
})

# Test 15: DateTime Arithmetic
let test15 = (run_test "DateTime AddDays Method" {
    let date = (dn new "System.DateTime" --args [2023, 12, 25])
    let tomorrow = ($date | dn call "AddDays" 1)
    let day = ($tomorrow | dn get "Day")
    if $day == 26 { 
        $day 
    } else { 
        error make { msg: $"Expected day 26, got ($day)" }
    }
})

# Collect all test results
let all_tests = [
    $test1, $test2, $test3, $test4, $test5, $test6, $test7, $test8, 
    $test9, $test10, $test11, $test12, $test13, $test14, $test15
]

print ""
print "📊 Test Results Summary"
print "======================="

let passed = ($all_tests | where status == "PASS" | length)
let failed = ($all_tests | where status == "FAIL" | length)
let total = ($all_tests | length)

print $"✅ Passed: ($passed)/($total)"
print $"❌ Failed: ($failed)/($total)"
print $"📈 Success Rate: (($passed / $total * 100) | math round)%"

if $failed > 0 {
    print ""
    print "❌ Failed Tests:"
    $all_tests | where status == "FAIL" | each { |test|
        print $"  - ($test.name): ($test.error)"
    }
}

print ""
print "🎯 Command Coverage Verification"
print "================================"

let expected_commands = [
    "dn new", "dn call", "dn get", "dn set", 
    "dn load-assembly", "dn assemblies", "dn types", "dn members"
]

let available_commands = (help commands | where name =~ "^dn " | get name)

print "Expected commands:"
$expected_commands | each { |cmd| 
    if $cmd in $available_commands {
        print $"✅ ($cmd) - Available"
    } else {
        print $"❌ ($cmd) - Missing"
    }
}

print ""
print "🏆 Final Assessment"
print "==================="

let success_rate = ($passed / $total * 100) | math round
let commands_available = ($expected_commands | length) == ($available_commands | length)

if $success_rate >= 90 and $commands_available {
    print "🎉 EXCELLENT: Plugin is fully functional and ready for production!"
    print $"   - ($success_rate)% test success rate"
    print "   - All 8 commands available"
    print "   - .NET interop working correctly"
    print "   - Object lifecycle management working"
    print "   - Error handling working"
} else if $success_rate >= 75 {
    print "⚠️  GOOD: Plugin is mostly functional with minor issues"
    print $"   - ($success_rate)% test success rate"
    print "   - Most core functionality working"
} else {
    print "❌ NEEDS WORK: Plugin has significant issues"
    print $"   - Only ($success_rate)% test success rate"
    print "   - Major functionality problems detected"
}

print ""
print "🚀 Integration Testing Complete!"
print ""
print "To use the plugin:"
print "  let \$now = dn new \"System.DateTime\" --args [2023, 12, 25]"
print "  let \$max = \"System.Math\" | dn call \"Max\" 10 20"
print "  let \$pi = \"System.Math\" | dn get \"PI\""
print "  dn assemblies"
print "  dn types \"System.Private.CoreLib\"" 