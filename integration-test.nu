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
}),

# Test 12: Test Nested Object Manipulation
(test_command "Nested Object Manipulation" {
    # Create nested structure using working approaches
    # Test 1: Parse multiple DateTime objects to create a date hierarchy
    let $start_date = "System.DateTime" | dn call "Parse" "2024-01-01"
    let $end_date = "System.DateTime" | dn call "Parse" "2024-12-31" 
    let $current_date = "System.DateTime" | dn call "Parse" "2024-06-15"
    
    # Extract components from each date (demonstrating nested access)
    let $start_year = $start_date | dn get "Year"
    let $start_month = $start_date | dn get "Month"
    let $end_year = $end_date | dn get "Year"
    let $end_month = $end_date | dn get "Month"
    let $current_day = $current_date | dn get "Day"
    
    # Test 2: Create TimeSpan objects for date arithmetic (nested operations)
    let $days_diff = $end_date | dn call "Subtract" $start_date
    let $total_days = $days_diff | dn get "TotalDays"
    
    # Test 3: Complex path operations (nested string manipulation)
    let $base_path = "System.IO.Path" | dn call "Combine" "C:" "Projects" "nushell"
    let $sub_path = "System.IO.Path" | dn call "Combine" $base_path "plugins" "dotnet"
    let $file_path = "System.IO.Path" | dn call "Combine" $sub_path "test.dll"
    
    # Test 4: Environment and system info nesting
    let $machine = "System.Environment" | dn get "MachineName"
    let $os_version = "System.Environment" | dn get "OSVersion"
    let $version_string = $os_version | dn call "ToString"
    
    # Test 5: GUID operations for unique identifiers in nested structures
    let $guid1 = "System.Guid" | dn call "NewGuid"
    let $guid2 = "System.Guid" | dn call "NewGuid"
    let $guid1_str = $guid1 | dn call "ToString"
    let $guid2_str = $guid2 | dn call "ToString"
    let $guids_equal = $guid1 | dn call "Equals" $guid2
    
    # Verify nested operations work correctly
    if ($start_year == 2024) and ($end_month == 12) and ($current_day == 15) and ($total_days >= 365) and ($file_path | str contains "test.dll") and ($machine | str length) > 0 and ($guid1_str != $guid2_str) and ($guids_equal == false) {
        $"Nested operations: dates=($start_year)/($end_month), days=($total_days), path_depth=3, guids_unique=true"
    } else {
        error make { msg: $"Nested operations failed: year=($start_year), month=($end_month), days=($total_days), equal=($guids_equal)" }
    }
}),

# Test 13: Test Object to Nushell Conversion
(test_command "Object to Nushell Conversion" {
    # Test converting complex .NET objects to nushell native structures
    
    # Test 1: Convert Version object to nushell record 
    let $version = "System.Version" | dn call "Parse" "1.2.3.4"
    let $version_record = $version | dn obj
    
    # Test 2: Convert GUID object to nushell record
    let $guid = "System.Guid" | dn call "NewGuid"
    let $guid_record = $guid | dn obj
    
    # Test 3: Convert type info to nushell record
    let $version_type_info = "System.Version" | dn obj
    let $guid_type_info = "System.Guid" | dn obj
    
    # Test 4: Convert simple string to demonstrate basic conversion
    let $string_obj = "Hello World" | dn obj
    
    # Verify conversions work and produce records with expected fields
    let $version_has_major = ($version_record | get major) == 1
    let $version_has_minor = ($version_record | get minor) == 2
    let $version_has_type = ($version_record | get __type__) == "Version"
    
    let $guid_has_type = ($guid_record | get __type__) == "Guid"
    
    let $version_type_has_name = ($version_type_info | get name) == "Version"
    let $version_type_has_methods = ($version_type_info | get methods | length) > 5
    let $version_type_has_properties = ($version_type_info | get properties | length) > 3
    
    let $guid_type_has_name = ($guid_type_info | get name) == "Guid"
    let $guid_type_is_struct = ($guid_type_info | get is_struct) == true
    
    let $string_converted = $string_obj == "Hello World"
    
    # Verify all conversions successful
    if $version_has_major and $version_has_minor and $version_has_type and $guid_has_type and $version_type_has_name and $version_type_has_methods and $version_type_has_properties and $guid_type_has_name and $guid_type_is_struct and $string_converted {
        $"Object conversion: Version=✓, GUID=✓, TypeInfo=✓, String=✓"
    } else {
        error make { msg: $"Object conversion failed: some conversions did not produce expected results" }
    }
}),

# Test 14: Test Byte Array Operations
(test_command "Byte Array Operations" {
    # Test working with byte arrays for binary data operations
    
    # Test 1: Create byte array from ASCII string
    let $ascii_bytes = "System.Text.Encoding" | dn get "ASCII" | dn call "GetBytes" "ABC"
    let $ascii_length = $ascii_bytes | dn get "Length"
    
    # Test 2: Inspect byte array with dn obj command (shows as list of integers)
    let $bytes_list = $ascii_bytes | dn obj
    
    # Test 3: Array element access to check specific byte values
    let $first_byte = $ascii_bytes | dn call "GetValue" 0
    let $second_byte = $ascii_bytes | dn call "GetValue" 1
    let $third_byte = $ascii_bytes | dn call "GetValue" 2
    
    # Test 4: Create UTF8 byte array (without decode to avoid .NET 8 issues)
    let $utf8_bytes = "System.Text.Encoding" | dn get "UTF8" | dn call "GetBytes" "Hello"
    let $utf8_length = $utf8_bytes | dn get "Length"
    
    # Test 5: Empty byte array
    let $empty_bytes = "System.Text.Encoding" | dn get "ASCII" | dn call "GetBytes" ""
    let $empty_length = $empty_bytes | dn get "Length"
    
    # Test 6: Byte array properties
    let $utf8_first = $utf8_bytes | dn call "GetValue" 0  # 'H' = 72
    
    # Verify byte array operations work correctly
    let $ascii_created = $ascii_length == 3
    let $bytes_are_list = ($bytes_list | length) == 3
    let $bytes_correct_values = ($bytes_list | get 0) == 65 and ($bytes_list | get 1) == 66 and ($bytes_list | get 2) == 67
    
    # Test ASCII byte values: A=65, B=66, C=67
    let $first_is_65 = $first_byte == 65   # ASCII 'A'
    let $second_is_66 = $second_byte == 66 # ASCII 'B' 
    let $third_is_67 = $third_byte == 67   # ASCII 'C'
    
    let $utf8_created = $utf8_length == 5
    let $utf8_first_correct = $utf8_first == 72  # 'H' = 72
    let $empty_array_works = $empty_length == 0
    
    # Verify all byte array operations successful
    if $ascii_created and $bytes_are_list and $bytes_correct_values and $first_is_65 and $second_is_66 and $third_is_67 and $utf8_created and $utf8_first_correct and $empty_array_works {
        $"Byte arrays: Creation=✓, Lists=✓, Access=✓, Values=✓, UTF8=✓"
    } else {
        error make { msg: $"Byte array operations failed: ascii=($ascii_created), list=($bytes_are_list), values=($bytes_correct_values), access=($first_is_65), utf8=($utf8_created)" }
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