#!/usr/bin/env nu

# Nu Plugin DotNet - Direct Test Runner
# Tests the plugin using JSON protocol without requiring registration

print "🧪 Nu Plugin DotNet - Direct Test Runner"
print "========================================"

let $plugin_path = "./bin/Release-new/nu_plugin_dotnet.exe"

# Helper function to test plugin commands via JSON
def test_plugin_command [test_name: string, json_input: string] {
    print $"\n🔍 Testing: ($test_name)"
    try {
        let $result = ($json_input | $plugin_path)
        let $parsed = ($result | from json)
        
        if $parsed.Type == "Value" {
            print $"✅ PASS: ($test_name)"
            { name: $test_name, status: "PASS", result: $parsed.Value, error: null }
        } else if $parsed.Type == "Error" {
            print $"❌ FAIL: ($test_name) - ($parsed.Value.Message)"
            { name: $test_name, status: "FAIL", result: null, error: $parsed.Value.Message }
        } else {
            print $"✅ PASS: ($test_name) - Non-value response"
            { name: $test_name, status: "PASS", result: $parsed, error: null }
        }
    } catch { |e|
        print $"❌ FAIL: ($test_name) - ($e.msg)"
        { name: $test_name, status: "FAIL", result: null, error: $e.msg }
    }
}

print "\n📋 Running Tests:"

let $tests = [

# Test 1: Plugin Signature
(test_plugin_command "Plugin Signature" '{"Type":"Signature"}'),

# Test 2: Math.Max Static Method
(test_plugin_command "Math.Max(10, 20)" '{"Type":"Run","Call":{"Head":{"Name":"dn call"},"Positional":[{"type":"String","val":"Max"},{"type":"Int","val":10},{"type":"Int","val":20}],"Named":{},"Input":{"type":"String","val":"System.Math"}}}'),

# Test 3: Math.PI Property
(test_plugin_command "Math.PI Property" '{"Type":"Run","Call":{"Head":{"Name":"dn get"},"Positional":[{"type":"String","val":"PI"}],"Named":{},"Input":{"type":"String","val":"System.Math"}}}'),

# Test 4: DateTime Creation
(test_plugin_command "DateTime Creation" '{"Type":"Run","Call":{"Head":{"Name":"dn new"},"Positional":[{"type":"String","val":"System.DateTime"}],"Named":{"args":{"type":"List","val":[{"type":"Int","val":2023},{"type":"Int","val":12},{"type":"Int","val":25}]}},"Input":null}}'),

# Test 5: Math.Sqrt
(test_plugin_command "Math.Sqrt(16)" '{"Type":"Run","Call":{"Head":{"Name":"dn call"},"Positional":[{"type":"String","val":"Sqrt"},{"type":"Int","val":16}],"Named":{},"Input":{"type":"String","val":"System.Math"}}}'),

# Test 6: Math.Min
(test_plugin_command "Math.Min(5, 3)" '{"Type":"Run","Call":{"Head":{"Name":"dn call"},"Positional":[{"type":"String","val":"Min"},{"type":"Int","val":5},{"type":"Int","val":3}],"Named":{},"Input":{"type":"String","val":"System.Math"}}}'),

# Test 7: GUID NewGuid
(test_plugin_command "GUID.NewGuid()" '{"Type":"Run","Call":{"Head":{"Name":"dn call"},"Positional":[{"type":"String","val":"NewGuid"}],"Named":{},"Input":{"type":"String","val":"System.Guid"}}}'),

# Test 8: String Length
(test_plugin_command "String Length" '{"Type":"Run","Call":{"Head":{"Name":"dn get"},"Positional":[{"type":"String","val":"Length"}],"Named":{},"Input":{"type":"String","val":"Hello World"}}}'),

# Test 9: List Assemblies
(test_plugin_command "List Assemblies" '{"Type":"Run","Call":{"Head":{"Name":"dn assemblies"},"Positional":[],"Named":{},"Input":null}}'),

# Test 10: List Types in Core Library
(test_plugin_command "List Types in CoreLib" '{"Type":"Run","Call":{"Head":{"Name":"dn types"},"Positional":[{"type":"String","val":"System.Private.CoreLib"}],"Named":{},"Input":null}}'),

# Test 11: List String Members
(test_plugin_command "List String Members" '{"Type":"Run","Call":{"Head":{"Name":"dn members"},"Positional":[{"type":"String","val":"System.String"}],"Named":{},"Input":null}}'),

# Test 12: Environment MachineName
(test_plugin_command "Environment.MachineName" '{"Type":"Run","Call":{"Head":{"Name":"dn get"},"Positional":[{"type":"String","val":"MachineName"}],"Named":{},"Input":{"type":"String","val":"System.Environment"}}}'),

# Test 13: DateTime Now
(test_plugin_command "DateTime.Now" '{"Type":"Run","Call":{"Head":{"Name":"dn get"},"Positional":[{"type":"String","val":"Now"}],"Named":{},"Input":{"type":"String","val":"System.DateTime"}}}'),

# Test 14: Path.Combine
(test_plugin_command "Path.Combine" '{"Type":"Run","Call":{"Head":{"Name":"dn call"},"Positional":[{"type":"String","val":"Combine"},{"type":"String","val":"C:"},{"type":"String","val":"temp"},{"type":"String","val":"file.txt"}],"Named":{},"Input":{"type":"String","val":"System.IO.Path"}}}'),

# Test 15: Math.Pow
(test_plugin_command "Math.Pow(2, 3)" '{"Type":"Run","Call":{"Head":{"Name":"dn call"},"Positional":[{"type":"String","val":"Pow"},{"type":"Int","val":2},{"type":"Int","val":3}],"Named":{},"Input":{"type":"String","val":"System.Math"}}}'),

# Test 16: List Creation
(test_plugin_command "List Creation" '{"Type":"Run","Call":{"Head":{"Name":"dn new"},"Positional":[{"type":"String","val":"System.Collections.Generic.List[string]"}],"Named":{},"Input":null}}'),

# Test 17: StringBuilder Creation
(test_plugin_command "StringBuilder Creation" '{"Type":"Run","Call":{"Head":{"Name":"dn new"},"Positional":[{"type":"String","val":"System.Text.StringBuilder"}],"Named":{},"Input":null}}'),

# Test 18: Error Test - Invalid Constructor
(test_plugin_command "Error: Invalid GUID Constructor" '{"Type":"Run","Call":{"Head":{"Name":"dn new"},"Positional":[{"type":"String","val":"System.Guid"}],"Named":{},"Input":null}}'),

# Test 19: Error Test - Invalid Method
(test_plugin_command "Error: Invalid Method" '{"Type":"Run","Call":{"Head":{"Name":"dn call"},"Positional":[{"type":"String","val":"NonExistentMethod"}],"Named":{},"Input":{"type":"String","val":"System.Math"}}}'),

# Test 20: Math.E Constant
(test_plugin_command "Math.E Constant" '{"Type":"Run","Call":{"Head":{"Name":"dn get"},"Positional":[{"type":"String","val":"E"}],"Named":{},"Input":{"type":"String","val":"System.Math"}}}')

]

print "\n📊 Test Summary"
print "==============="

let $passed = $tests | where status == "PASS" | length
let $failed = $tests | where status == "FAIL" | length
let $total = $tests | length

print $"Total Tests: ($total)"
print $"✅ Passed: ($passed)"
print $"❌ Failed: ($failed)"
print $"Success Rate: (($passed * 100) / $total | math round --precision 1)%"

if $failed > 0 {
    print "\n❌ Failed Tests:"
    $tests | where status == "FAIL" | each { |test|
        print $"  - ($test.name): ($test.error)"
    } | ignore
}

print "\n🎯 Detailed Results:"
$tests | each { |test|
    let $icon = if $test.status == "PASS" { "✅" } else { "❌" }
    print $"($icon) ($test.name) - ($test.status)"
} | ignore

# Validate specific test results
print "\n🔍 Result Validation:"

let $math_max = $tests | where name == "Math.Max(10, 20)" | first
if $math_max.status == "PASS" and $math_max.result.val == 20 {
    print "✅ Math.Max correctly returned 20"
} else {
    print $"❌ Math.Max failed - expected 20, got ($math_max.result)"
}

let $sqrt_test = $tests | where name == "Math.Sqrt(16)" | first
if $sqrt_test.status == "PASS" and $sqrt_test.result.val == 4 {
    print "✅ Math.Sqrt correctly returned 4"
} else {
    print $"❌ Math.Sqrt failed - expected 4, got ($sqrt_test.result)"
}

let $pi_test = $tests | where name == "Math.PI Property" | first
if $pi_test.status == "PASS" and ($pi_test.result.val > 3.14) {
    print $"✅ Math.PI correctly returned (~($pi_test.result.val))"
} else {
    print $"❌ Math.PI failed - got ($pi_test.result)"
}

let $signature_test = $tests | where name == "Plugin Signature" | first
if $signature_test.status == "PASS" {
    let $commands = $signature_test.result.Value | length
    print $"✅ Plugin signature returned ($commands) commands"
} else {
    print "❌ Plugin signature test failed"
}

print "\n⚡ Performance Test"
print "=================="

print "Running 5 consecutive Math.Max operations..."
let $start_time = date now

for $i in 1..5 {
    let $result = ('{"Type":"Run","Call":{"Head":{"Name":"dn call"},"Positional":[{"type":"String","val":"Max"},{"type":"Int","val":' + ($i | into string) + '},{"type":"Int","val":' + (($i + 1) | into string) + '}],"Named":{},"Input":{"type":"String","val":"System.Math"}}}' | $plugin_path)
}

let $end_time = date now
let $duration = $end_time - $start_time
print $"Completed 5 operations in ($duration)"

print "\n🎉 Test Runner Complete!"

if $failed == 0 {
    print "🏆 All tests passed! Plugin is fully functional with 'dn' commands."
} else {
    print $"⚠️  ($failed) test(s) failed. Plugin may have issues."
}

# Return results
{
    total: $total,
    passed: $passed,
    failed: $failed,
    success_rate: (($passed * 100) / $total),
    tests: $tests
} 