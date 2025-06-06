#!/usr/bin/env nu

# Nu Plugin DotNet - Quick Integration Test
# Assumes plugin is already registered

print "⚡ Nu Plugin DotNet - Quick Integration Test"
print "============================================"
print ""

# Verify plugin commands are available
let plugin_commands = (help commands | where name =~ "^dn " | get name)

if ($plugin_commands | length) == 0 {
    print "❌ No 'dn' commands found. Please register the plugin first:"
    print "   plugin add ./bin/Release/net8.0/win-x64/nu_plugin_dotnet.exe"
    exit 1
}

print $"✅ Found ($plugin_commands | length) plugin commands"
print ""

print "🧪 Running Quick Tests..."

# Test 1: Basic Math
print "📋 Testing Math.Max..."
let test1 = try {
    let result = ("System.Math" | dn call "Max" 10 20)
    if $result == 20 {
        print "✅ Math.Max(10, 20) = 20"
        "PASS"
    } else {
        print $"❌ Math.Max failed: expected 20, got ($result)"
        "FAIL"
    }
} catch { |err|
    print $"❌ Math.Max error: ($err.msg)"
    "FAIL"
}

# Test 2: Object Creation
print "📋 Testing DateTime creation..."
let test2 = try {
    let date = (dn new "System.DateTime" --args [2023, 12, 25])
    print "✅ DateTime object created"
    "PASS"
} catch { |err|
    print $"❌ DateTime creation error: ($err.msg)"
    "FAIL"
}

# Test 3: Property Access
print "📋 Testing property access..."
let test3 = try {
    let pi = ("System.Math" | dn get "PI")
    if ($pi > 3.14 and $pi < 3.15) {
        print $"✅ Math.PI = ($pi)"
        "PASS"
    } else {
        print $"❌ Math.PI unexpected value: ($pi)"
        "FAIL"
    }
} catch { |err|
    print $"❌ Property access error: ($err.msg)"
    "FAIL"
}

# Test 4: Collection Operations
print "📋 Testing List operations..."
let test4 = try {
    let list = (dn new "System.Collections.Generic.List[string]")
    $list | dn call "Add" "test"
    let count = ($list | dn get "Count")
    if $count == 1 {
        print "✅ List operations working"
        "PASS"
    } else {
        print $"❌ List count unexpected: ($count)"
        "FAIL"
    }
} catch { |err|
    print $"❌ List operations error: ($err.msg)"
    "FAIL"
}

# Test 5: Assembly Listing
print "📋 Testing assembly listing..."
let test5 = try {
    let assemblies = (dn assemblies)
    if ($assemblies | length) > 5 {
        print $"✅ Found ($assemblies | length) assemblies"
        "PASS"
    } else {
        print $"❌ Too few assemblies: ($assemblies | length)"
        "FAIL"
    }
} catch { |err|
    print $"❌ Assembly listing error: ($err.msg)"
    "FAIL"
}

print ""
print "📊 Results Summary"
print "=================="

let all_tests = [$test1, $test2, $test3, $test4, $test5]
let passed = ($all_tests | where $it == "PASS" | length)
let total = ($all_tests | length)
let success_rate = ($passed / $total * 100) | math round

print $"✅ Passed: ($passed)/($total)"
print $"📈 Success Rate: ($success_rate)%"

if $success_rate >= 80 {
    print "🎉 Plugin is working well!"
} else {
    print "⚠️  Plugin has some issues"
    let failed_count = ($all_tests | where $it == "FAIL" | length)
    print $"Failed: ($failed_count) tests"
}

print ""
print "⚡ Quick test complete!" 