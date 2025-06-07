#!/usr/bin/env nu

# dn new Command Examples - Comprehensive Collection
# ==================================================

print "🏗️  dn new Command Examples - Comprehensive Collection"
print "====================================================="
print ""

print "📚 Basic Object Creation"
print "========================"

print "\n1. DateTime Objects"
print "-------------------"

# Create specific date
let $christmas = dn new "System.DateTime" --args [2023, 12, 25]
let $year = $christmas | dn get "Year"
let $month = $christmas | dn get "Month" 
let $day = $christmas | dn get "Day"
print $"Christmas 2023: ($year)-($month)-($day)"

# Create date with time
let $newYear = dn new "System.DateTime" --args [2024, 1, 1, 0, 0, 0]
let $formatted = $newYear | dn call "ToString" "yyyy-MM-dd HH:mm:ss"
print $"New Year: ($formatted)"

print "\n2. GUID Objects"
print "---------------"

# Create GUID from string
let $knownGuid = dn new "System.Guid" --args ["550e8400-e29b-41d4-a716-446655440000"]
let $guidStr = $knownGuid | dn call "ToString"
print $"Known GUID: ($guidStr)"

print "\n3. String and Text Objects"
print "--------------------------"

# StringBuilder with different constructors
let $sb1 = dn new "System.Text.StringBuilder"
let $sb2 = dn new "System.Text.StringBuilder" --args [100]
let $sb3 = dn new "System.Text.StringBuilder" --args ["Initial Text"]
let $sb4 = dn new "System.Text.StringBuilder" --args ["Initial Text", 200]

let $cap1 = $sb1 | dn get "Capacity"
let $cap2 = $sb2 | dn get "Capacity" 
let $text3 = $sb3 | dn call "ToString"
let $cap4 = $sb4 | dn get "Capacity"

print $"StringBuilder1 capacity: ($cap1)"
print $"StringBuilder2 capacity: ($cap2)"
print $"StringBuilder3 text: ($text3)"
print $"StringBuilder4 capacity: ($cap4)"

print "\n📦 Collection Objects"
print "====================="

print "\n4. Generic Lists"
print "----------------"

# Create typed lists
let $stringList = dn new "System.Collections.Generic.List[string]"
let $intList = dn new "System.Collections.Generic.List[int]"
let $dateList = dn new "System.Collections.Generic.List[System.DateTime]"

# Lists with initial capacity
let $bigStringList = dn new "System.Collections.Generic.List[string]" --args [1000]
let $bigIntList = dn new "System.Collections.Generic.List[int]" --args [500]

# Add some items
$stringList | dn call "Add" "Apple"
$stringList | dn call "Add" "Banana"
$intList | dn call "Add" 42
$intList | dn call "Add" 17

let $stringCount = $stringList | dn get "Count"
let $intCount = $intList | dn get "Count"
print $"String list count: ($stringCount)"
print $"Int list count: ($intCount)"

print "\n5. Dictionaries"
print "---------------"

# Create typed dictionaries
let $stringDict = dn new "System.Collections.Generic.Dictionary[string, string]"
let $intDict = dn new "System.Collections.Generic.Dictionary[string, int]"
let $objDict = dn new "System.Collections.Generic.Dictionary[string, object]"

# Add items
$stringDict | dn call "Add" "name" "John"
$stringDict | dn call "Add" "city" "New York"
$intDict | dn call "Add" "age" 30
$intDict | dn call "Add" "score" 95

let $dictCount1 = $stringDict | dn get "Count"
let $dictCount2 = $intDict | dn get "Count"
print $"String dict count: ($dictCount1)"
print $"Int dict count: ($dictCount2)"

print "\n6. Sets and HashSets"
print "--------------------"

# Create HashSets
let $stringSet = dn new "System.Collections.Generic.HashSet[string]"
let $intSet = dn new "System.Collections.Generic.HashSet[int]"

# Add items
$stringSet | dn call "Add" "apple"
$stringSet | dn call "Add" "banana"
$stringSet | dn call "Add" "apple"  # Duplicate, won't be added

let $setCount = $stringSet | dn get "Count"
print $"String set count: ($setCount)"  # Should be 2

print "\n7. Queues and Stacks"
print "--------------------"

# Create Queue and Stack
let $stringQueue = dn new "System.Collections.Generic.Queue[string]"
let $stringStack = dn new "System.Collections.Generic.Stack[string]"

# Add items
$stringQueue | dn call "Enqueue" "First"
$stringQueue | dn call "Enqueue" "Second"
$stringStack | dn call "Push" "Bottom"
$stringStack | dn call "Push" "Top"

let $queueCount = $stringQueue | dn get "Count"
let $stackCount = $stringStack | dn get "Count"
print $"Queue count: ($queueCount)"
print $"Stack count: ($stackCount)"

print "\n🌐 Network and HTTP Objects"
print "==========================="

print "\n8. HTTP Client"
print "--------------"

# Basic HTTP client
let $httpClient = dn new "System.Net.Http.HttpClient"

# HTTP client with timeout
let $timespan = dn new "System.TimeSpan" --args [0, 0, 30]  # 30 seconds
let $httpClientWithTimeout = dn new "System.Net.Http.HttpClient"
$httpClientWithTimeout | dn set "Timeout" $timespan

let $timeout = $httpClientWithTimeout | dn get "Timeout" | dn get "TotalSeconds"
print $"HTTP Client timeout: ($timeout) seconds"

print "\n9. Network Credentials"
print "----------------------"

# Network credentials
let $credentials = dn new "System.Net.NetworkCredential" --args ["username", "password"]
let $domainCredentials = dn new "System.Net.NetworkCredential" --args ["username", "password", "domain"]

let $username = $credentials | dn get "UserName"
let $domain = $domainCredentials | dn get "Domain"
print $"Credentials username: ($username)"
print $"Domain credentials domain: ($domain)"

print "\n🗂️  File System Objects"
print "========================"

print "\n10. File and Directory Info"
print "---------------------------"

# File info objects
let $fileInfo = dn new "System.IO.FileInfo" --args ["example.txt"]
let $dirInfo = dn new "System.IO.DirectoryInfo" --args ["C:\\temp"]

let $fileName = $fileInfo | dn get "Name"
let $dirName = $dirInfo | dn get "Name"
print $"File info name: ($fileName)"
print $"Directory info name: ($dirName)"

print "\n11. Memory and Streams"
print "----------------------"

# Memory stream
let $memoryStream = dn new "System.IO.MemoryStream"
let $memoryStreamWithCapacity = dn new "System.IO.MemoryStream" --args [1024]

let $cap1 = $memoryStream | dn get "Capacity"
let $cap2 = $memoryStreamWithCapacity | dn get "Capacity"
print $"Memory stream capacity: ($cap1)"
print $"Memory stream with capacity: ($cap2)"

print "\n🔢 Mathematical Objects"
print "======================="

print "\n12. BigInteger"
print "--------------"

# BigInteger objects
let $bigInt1 = dn new "System.Numerics.BigInteger" --args [12345678901234567890]
let $bigInt2 = dn new "System.Numerics.BigInteger" --args ["999999999999999999999999999999"]

let $bigStr1 = $bigInt1 | dn call "ToString"
let $bigStr2 = $bigInt2 | dn call "ToString"
print $"BigInteger 1: ($bigStr1)"
print $"BigInteger 2: ($bigStr2)"

print "\n13. Decimal and Numeric Types"
print "-----------------------------"

# Decimal with high precision
let $decimal1 = dn new "System.Decimal" --args [123.456789]
let $decStr = $decimal1 | dn call "ToString"
print $"Decimal 1: ($decStr)"

print "\n🕰️  Time and TimeSpan Objects"
print "=============================="

print "\n14. TimeSpan Objects"
print "--------------------"

# Various TimeSpan constructors
let $timespan1 = dn new "System.TimeSpan" --args [1, 2, 3]  # 1 hour, 2 minutes, 3 seconds
let $timespan2 = dn new "System.TimeSpan" --args [1, 2, 3, 4]  # 1 day, 2 hours, 3 minutes, 4 seconds

let $minutes = $timespan1 | dn get "TotalMinutes"
let $hours = $timespan2 | dn get "TotalHours"
print $"TimeSpan 1: ($minutes) minutes"
print $"TimeSpan 2: ($hours) hours"

print "\n15. DateTimeOffset"
print "-------------------"

# DateTimeOffset with timezone
let $offset = dn new "System.TimeSpan" --args [5, 0, 0]  # +5 hours
let $dateTimeOffset = dn new "System.DateTimeOffset" --args [2023, 12, 25, 14, 30, 0, $offset]

let $offsetStr = $dateTimeOffset | dn call "ToString" "yyyy-MM-dd HH:mm:ss zzz"
print $"DateTimeOffset: ($offsetStr)"

print "\n🔐 Security and Cryptography Objects"
print "===================================="

print "\n16. Cryptographic Objects"
print "-------------------------"

# Load crypto assembly first
dn load-assembly "System.Security.Cryptography"

# Hash algorithms using static Create methods
let $sha256 = "System.Security.Cryptography.SHA256" | dn call "Create"
let $md5 = "System.Security.Cryptography.MD5" | dn call "Create"

let $sha256Size = $sha256 | dn get "HashSize"
let $md5Size = $md5 | dn get "HashSize"
print $"SHA256 hash size: ($sha256Size) bits"
print $"MD5 hash size: ($md5Size) bits"

# Cleanup
$sha256 | dn call "Dispose"
$md5 | dn call "Dispose"

print "\n🎨 Specialized Objects"
print "======================"

print "\n17. Regular Expressions"
print "-----------------------"

# Regex objects
let $regex1 = dn new "System.Text.RegularExpressions.Regex" --args ["\\d+"]  # Match digits
let $ignoreCase = "System.Text.RegularExpressions.RegexOptions" | dn get "IgnoreCase"
let $regex2 = dn new "System.Text.RegularExpressions.Regex" --args ["[a-zA-Z]+", $ignoreCase]

# Test the regex
let $match = $regex1 | dn call "Match" "The answer is 42"
let $success = $match | dn get "Success"
print $"Regex match found: ($success)"

if $success {
    let $value = $match | dn get "Value"
    print $"Matched value: ($value)"
}

print "\n18. Threading Objects"
print "---------------------"

# CancellationToken and related objects
let $cancellationTokenSource = dn new "System.Threading.CancellationTokenSource"
let $cancellationTokenWithTimeout = dn new "System.Threading.CancellationTokenSource" --args [5000]  # 5 second timeout

let $token = $cancellationTokenSource | dn get "Token"
let $canBeCanceled = $token | dn get "CanBeCanceled"
print $"Cancellation token created: ($canBeCanceled)"

# Cleanup
$cancellationTokenSource | dn call "Dispose"
$cancellationTokenWithTimeout | dn call "Dispose"

print "\n19. Culture and Localization"
print "----------------------------"

# Culture info objects
let $usCulture = dn new "System.Globalization.CultureInfo" --args ["en-US"]
let $frCulture = dn new "System.Globalization.CultureInfo" --args ["fr-FR"]

let $usName = $usCulture | dn get "DisplayName"
let $frName = $frCulture | dn get "DisplayName"
print $"US Culture: ($usName)"
print $"French Culture: ($frName)"

print "\n20. Uri Objects"
print "---------------"

# URI objects
let $uri1 = dn new "System.Uri" --args ["https://www.example.com/path?query=value"]
let $uri2 = dn new "System.Uri" --args ["https://www.example.com", "relative/path"]

let $host = $uri1 | dn get "Host"
let $path = $uri1 | dn get "AbsolutePath"
let $query = $uri1 | dn get "Query"
let $absolute = $uri2 | dn get "AbsoluteUri"

print $"URI 1 host: ($host)"
print $"URI 1 path: ($path)"
print $"URI 1 query: ($query)"
print $"URI 2 absolute: ($absolute)"

print "\n🎯 Advanced Patterns"
print "===================="

print "\n21. Nullable Types"
print "------------------"

# Nullable DateTime
let $nullableDate = dn new "System.Nullable[System.DateTime]" --args [$christmas]
let $hasValue = $nullableDate | dn get "HasValue"
print $"Nullable date has value: ($hasValue)"

if $hasValue {
    let $value = $nullableDate | dn get "Value"
    let $dateStr = $value | dn call "ToString" "yyyy-MM-dd"
    print $"Nullable date value: ($dateStr)"
}

print "\n22. Tuple Objects"
print "-----------------"

# Create tuples
let $tuple2 = dn new "System.Tuple[string, int]" --args ["Hello", 42]
let $tuple3 = dn new "System.Tuple[string, int, bool]" --args ["Hello", 42, true]

let $item1 = $tuple2 | dn get "Item1"
let $item2 = $tuple2 | dn get "Item2"
let $item3 = $tuple3 | dn get "Item3"
print $"Tuple2 Item1: ($item1)"
print $"Tuple2 Item2: ($item2)"
print $"Tuple3 Item3: ($item3)"

print "\n23. KeyValuePair Objects"
print "------------------------"

# KeyValuePair objects
let $kvp1 = dn new "System.Collections.Generic.KeyValuePair[string, int]" --args ["score", 95]
let $kvp2 = dn new "System.Collections.Generic.KeyValuePair[string, string]" --args ["name", "John"]

let $key1 = $kvp1 | dn get "Key"
let $val1 = $kvp1 | dn get "Value"
let $key2 = $kvp2 | dn get "Key" 
let $val2 = $kvp2 | dn get "Value"
print $"KVP1 Key: ($key1), Value: ($val1)"
print $"KVP2 Key: ($key2), Value: ($val2)"

print "\n🔬 JSON and Serialization Objects"
print "=================================="

print "\n24. JSON Objects"
print "----------------"

# JSON serializer options
let $jsonOptions = dn new "System.Text.Json.JsonSerializerOptions"
$jsonOptions | dn set "WriteIndented" true
let $camelCase = "System.Text.Json.JsonNamingPolicy" | dn get "CamelCase"
$jsonOptions | dn set "PropertyNamingPolicy" $camelCase

let $indented = $jsonOptions | dn get "WriteIndented"
print $"JSON Options WriteIndented: ($indented)"

print "\n25. Version Objects"
print "-------------------"

# Version objects
let $version1 = dn new "System.Version" --args [1, 2, 3, 4]
let $version2 = dn new "System.Version" --args ["2.1.0"]

let $ver1Str = $version1 | dn call "ToString"
let $ver2Str = $version2 | dn call "ToString"
let $major = $version1 | dn get "Major"
let $minor = $version2 | dn get "Minor"

print $"Version 1: ($ver1Str)"
print $"Version 2: ($ver2Str)"
print $"Version 1 Major: ($major)"
print $"Version 2 Minor: ($minor)"

print "\n🎉 Summary"
print "=========="
print ""
print "✅ Successfully demonstrated 25 different categories of dn new usage!"
print "📊 Object types created:"
print "   • DateTime and time-related objects"
print "   • GUID and unique identifier objects" 
print "   • String and text processing objects"
print "   • Generic collections (List, Dictionary, Set, Queue, Stack)"
print "   • Network and HTTP objects"
print "   • File system objects"
print "   • Mathematical and numeric objects"
print "   • Security and cryptography objects"
print "   • Regular expression objects"
print "   • Threading and cancellation objects"
print "   • Culture and localization objects"
print "   • URI and web-related objects"
print "   • Advanced types (Nullable, Tuple, KeyValuePair)"
print "   • JSON and serialization objects"
print "   • Version and metadata objects"
print ""
print "🎯 Key Patterns Demonstrated:"
print "   • Parameterless constructors: dn new \"Type\""
print "   • Single parameter: dn new \"Type\" --args [value]"
print "   • Multiple parameters: dn new \"Type\" --args [val1, val2, val3]"
print "   • Complex parameter types: Using other objects as parameters"
print "   • Generic types: dn new \"Generic[T]\" --args [...]"
print "   • Nested generic types: dn new \"Outer[Inner[T]]\" --args [...]"
print ""
print "📚 For more examples, see:"
print "   • README.md - Basic usage examples"
print "   • examples/demo.nu - Practical demonstrations"
print "   • examples/integration-test.nu - Testing patterns" 