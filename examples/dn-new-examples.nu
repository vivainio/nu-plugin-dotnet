#!/usr/bin/env nu

# dn new Command Examples - Comprehensive Collection
# ================================================

print "🏗️  dn new Command Examples - Comprehensive Collection"
print "====================================================="
print ""

print "📚 Basic Object Creation"
print "========================"

print "\n1. DateTime Objects"
print "-------------------"

# Create specific date
let $christmas = dn new "System.DateTime" --args [2023, 12, 25]
print $"Christmas 2023: ($christmas | dn get 'Year')-($christmas | dn get 'Month')-($christmas | dn get 'Day')"

# Create date with time
let $newYear = dn new "System.DateTime" --args [2024, 1, 1, 0, 0, 0]
print $"New Year: ($newYear | dn call 'ToString' 'yyyy-MM-dd HH:mm:ss')"

# Create with specific timezone info
let $utcTime = dn new "System.DateTime" --args [2023, 6, 15, 14, 30, 0, "Utc"]
print $"UTC Time: ($utcTime | dn call 'ToString' 'yyyy-MM-dd HH:mm:ss')"

print "\n2. GUID Objects"
print "---------------"

# Create empty GUID (all zeros)
let $emptyGuid = dn new "System.Guid" --args [([] | str join)]
print $"Empty GUID: ($emptyGuid | dn call "ToString")"

# Create GUID from string
let $knownGuid = dn new "System.Guid" --args ["550e8400-e29b-41d4-a716-446655440000"]
print $"Known GUID: ($knownGuid | dn call "ToString")"

# Create GUID from byte array
let $guidBytes = [0x00, 0xe8, 0x50, 0x55, 0x29, 0xe4, 0xd4, 0x41, 0xa7, 0x16, 0x44, 0x66, 0x55, 0x44, 0x00, 0x00]
let $guidFromBytes = dn new "System.Guid" --args [$guidBytes]
print $"GUID from bytes: ($guidFromBytes | dn call "ToString")"

print "\n3. String and Text Objects"
print "--------------------------"

# StringBuilder with initial capacity
let $sb1 = dn new "System.Text.StringBuilder"
let $sb2 = dn new "System.Text.StringBuilder" --args [100]
let $sb3 = dn new "System.Text.StringBuilder" --args ["Initial Text"]
let $sb4 = dn new "System.Text.StringBuilder" --args ["Initial Text", 200]

print $"StringBuilder1 capacity: ($sb1 | dn get "Capacity")"
print $"StringBuilder2 capacity: ($sb2 | dn get "Capacity")"
print $"StringBuilder3 text: ($sb3 | dn call "ToString")"
print $"StringBuilder4 capacity: ($sb4 | dn get "Capacity")"

# String with specific encoding
let $encoding = dn new "System.Text.UTF8Encoding"
print $"UTF8 Encoding: ($encoding | dn get "EncodingName")"

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

print $"String list capacity: ($stringList | dn get "Capacity")"
print $"Big string list capacity: ($bigStringList | dn get "Capacity")"

# Add some items to demonstrate
$stringList | dn call "Add" "Apple"
$stringList | dn call "Add" "Banana"
$intList | dn call "Add" 42
$intList | dn call "Add" 17

print $"String list count: ($stringList | dn get "Count")"
print $"Int list count: ($intList | dn get "Count")"

print "\n5. Dictionaries"
print "---------------"

# Create typed dictionaries
let $stringDict = dn new "System.Collections.Generic.Dictionary[string, string]"
let $intDict = dn new "System.Collections.Generic.Dictionary[string, int]"
let $objDict = dn new "System.Collections.Generic.Dictionary[string, object]"

# Dictionary with initial capacity
let $bigDict = dn new "System.Collections.Generic.Dictionary[string, string]" --args [100]

# Add items to demonstrate
$stringDict | dn call "Add" "name" "John"
$stringDict | dn call "Add" "city" "New York"
$intDict | dn call "Add" "age" 30
$intDict | dn call "Add" "score" 95

print $"String dict count: ($stringDict | dn get "Count")"
print $"Int dict count: ($intDict | dn get "Count")"

print "\n6. Sets and HashSets"
print "--------------------"

# Create HashSets
let $stringSet = dn new "System.Collections.Generic.HashSet[string]"
let $intSet = dn new "System.Collections.Generic.HashSet[int]"

# HashSet with comparer (case-insensitive for strings)
let $caseInsensitiveSet = dn new "System.Collections.Generic.HashSet[string]" --args [("System.StringComparer" | dn get "OrdinalIgnoreCase")]

# Add items
$stringSet | dn call "Add" "apple"
$stringSet | dn call "Add" "banana"
$stringSet | dn call "Add" "apple"  # Duplicate, won't be added

print $"String set count: ($stringSet | dn get "Count")"  # Should be 2

print "\n7. Queues and Stacks"
print "--------------------"

# Create Queue
let $stringQueue = dn new "System.Collections.Generic.Queue[string]"
let $intQueue = dn new "System.Collections.Generic.Queue[int]"

# Create Stack
let $stringStack = dn new "System.Collections.Generic.Stack[string]"
let $intStack = dn new "System.Collections.Generic.Stack[int]"

# Add items to demonstrate
$stringQueue | dn call "Enqueue" "First"
$stringQueue | dn call "Enqueue" "Second"
$stringStack | dn call "Push" "Bottom"
$stringStack | dn call "Push" "Top"

print $"Queue count: ($stringQueue | dn get "Count")"
print $"Stack count: ($stringStack | dn get "Count")"

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

print $"HTTP Client timeout: ($httpClientWithTimeout | dn get "Timeout" | dn get "TotalSeconds") seconds"

print "\n9. Network Credentials"
print "----------------------"

# Network credentials
let $credentials = dn new "System.Net.NetworkCredential" --args ["username", "password"]
let $domainCredentials = dn new "System.Net.NetworkCredential" --args ["username", "password", "domain"]

print $"Credentials username: ($credentials | dn get "UserName")"
print $"Domain credentials domain: ($domainCredentials | dn get "Domain")"

print "\n🗂️  File System Objects"
print "========================"

print "\n10. File and Directory Info"
print "---------------------------"

# File info objects
let $fileInfo = dn new "System.IO.FileInfo" --args ["example.txt"]
let $dirInfo = dn new "System.IO.DirectoryInfo" --args ["C:\\temp"]

print $"File info name: ($fileInfo | dn get "Name")"
print $"Directory info name: ($dirInfo | dn get "Name")"

print "\n11. Memory and Streams"
print "----------------------"

# Memory stream
let $memoryStream = dn new "System.IO.MemoryStream"
let $memoryStreamWithCapacity = dn new "System.IO.MemoryStream" --args [1024]

print $"Memory stream capacity: ($memoryStream | dn get "Capacity")"
print $"Memory stream with capacity: ($memoryStreamWithCapacity | dn get "Capacity")"

# String reader/writer
let $stringReader = dn new "System.IO.StringReader" --args ["Sample text to read"]
let $stringWriter = dn new "System.IO.StringWriter"

print $"String reader ready: ($stringReader | dn call "Peek") != -1"

print "\n🔢 Mathematical Objects"
print "======================="

print "\n12. BigInteger"
print "--------------"

# BigInteger objects
let $bigInt1 = dn new "System.Numerics.BigInteger" --args [12345678901234567890]
let $bigInt2 = dn new "System.Numerics.BigInteger" --args ["999999999999999999999999999999"]

print $"BigInteger 1: ($bigInt1 | dn call "ToString")"
print $"BigInteger 2: ($bigInt2 | dn call "ToString")"

print "\n13. Decimal and Numeric Types"
print "-----------------------------"

# Decimal with high precision
let $decimal1 = dn new "System.Decimal" --args [123.456789]
let $decimal2 = dn new "System.Decimal" --args [1, 0, 0, false, 2]  # Scale of 2

print $"Decimal 1: ($decimal1 | dn call "ToString")"

print "\n🕰️  Time and TimeSpan Objects"
print "=============================="

print "\n14. TimeSpan Objects"
print "--------------------"

# Various TimeSpan constructors
let $timespan1 = dn new "System.TimeSpan" --args [1, 2, 3]  # 1 hour, 2 minutes, 3 seconds
let $timespan2 = dn new "System.TimeSpan" --args [1, 2, 3, 4]  # 1 day, 2 hours, 3 minutes, 4 seconds
let $timespan3 = dn new "System.TimeSpan" --args [1, 2, 3, 4, 5]  # + milliseconds

print $"TimeSpan 1: ($timespan1 | dn get "TotalMinutes") minutes"
print $"TimeSpan 2: ($timespan2 | dn get "TotalHours") hours"
print $"TimeSpan 3: ($timespan3 | dn get "TotalMilliseconds") milliseconds"

print "\n15. DateTimeOffset"
print "-------------------"

# DateTimeOffset with timezone
let $offset = dn new "System.TimeSpan" --args [5, 0, 0]  # +5 hours
let $dateTimeOffset = dn new "System.DateTimeOffset" --args [2023, 12, 25, 14, 30, 0, $offset]

print $"DateTimeOffset: ($dateTimeOffset | dn call 'ToString' 'yyyy-MM-dd HH:mm:ss zzz')"

print "\n🔐 Security and Cryptography Objects"
print "===================================="

print "\n16. Cryptographic Objects"
print "-------------------------"

# Load crypto assembly first
dn load-assembly "System.Security.Cryptography"

# Random number generator
let $rng = "System.Security.Cryptography.RandomNumberGenerator" | dn call "Create"

# Generate some random bytes
let $randomBytes = [0, 0, 0, 0]  # Will be filled with random data
$rng | dn call "GetBytes" $randomBytes

print "Random number generator created successfully"

# Hash algorithms
let $sha256 = "System.Security.Cryptography.SHA256" | dn call "Create"
let $md5 = "System.Security.Cryptography.MD5" | dn call "Create"

print $"SHA256 hash size: ($sha256 | dn get "HashSize") bits"
print $"MD5 hash size: ($md5 | dn get "HashSize") bits"

# Cleanup
$sha256 | dn call "Dispose"
$md5 | dn call "Dispose"
$rng | dn call "Dispose"

print "\n🎨 Specialized Objects"
print "======================"

print "\n17. Regular Expressions"
print "-----------------------"

# Regex objects
let $regex1 = dn new "System.Text.RegularExpressions.Regex" --args ["\\d+"]  # Match digits
let $regex2 = dn new "System.Text.RegularExpressions.Regex" --args ["[a-zA-Z]+", ("System.Text.RegularExpressions.RegexOptions" | dn get "IgnoreCase")]

print $"Regex 1 pattern: ($regex1 | dn get "ToString")"
print $"Regex 2 is case insensitive: ($regex2 | dn get "Options")"

# Test the regex
let $match = $regex1 | dn call "Match" "The answer is 42"
print $"Regex match found: ($match | dn get "Success")"
if ($match | dn get "Success") {
    print $"Matched value: ($match | dn get "Value")"
}

print "\n18. Threading Objects"
print "---------------------"

# CancellationToken and related objects
let $cancellationTokenSource = dn new "System.Threading.CancellationTokenSource"
let $cancellationTokenWithTimeout = dn new "System.Threading.CancellationTokenSource" --args [5000]  # 5 second timeout

print $"Cancellation token created: ($cancellationTokenSource | dn get "Token" | dn get "CanBeCanceled")"

# Cleanup
$cancellationTokenSource | dn call "Dispose"
$cancellationTokenWithTimeout | dn call "Dispose"

print "\n19. Culture and Localization"
print "----------------------------"

# Culture info objects
let $usCulture = dn new "System.Globalization.CultureInfo" --args ["en-US"]
let $frCulture = dn new "System.Globalization.CultureInfo" --args ["fr-FR"]
let $invariantCulture = "System.Globalization.CultureInfo" | dn get "InvariantCulture"

print $"US Culture: ($usCulture | dn get "DisplayName")"
print $"French Culture: ($frCulture | dn get "DisplayName")"
print $"Invariant Culture: ($invariantCulture | dn get "Name")"

print "\n20. Uri Objects"
print "---------------"

# URI objects 
let $uri1 = dn new "System.Uri" --args ["https://www.example.com/path?query=value"]
let $uri2 = dn new "System.Uri" --args ["https://www.example.com", "relative/path"]

print $"URI 1 host: ($uri1 | dn get "Host")"
print $"URI 1 path: ($uri1 | dn get "AbsolutePath")"
print $"URI 1 query: ($uri1 | dn get "Query")"
print $"URI 2 absolute: ($uri2 | dn get "AbsoluteUri")"

print "\n🎯 Advanced Patterns"
print "===================="

print "\n21. Nullable Types"
print "------------------"

# Nullable DateTime
let $nullableDate = dn new "System.Nullable[System.DateTime]" --args [$christmas]
print $"Nullable date has value: ($nullableDate | dn get "HasValue")"
print $"Nullable date value: ($nullableDate | dn get "Value" | dn call "ToString" "yyyy-MM-dd")"

print "\n22. Tuple Objects"
print "-----------------"

# Create tuples
let $tuple2 = dn new "System.Tuple[string, int]" --args ["Hello", 42]
let $tuple3 = dn new "System.Tuple[string, int, bool]" --args ["Hello", 42, true]

print $"Tuple2 Item1: ($tuple2 | dn get "Item1")"
print $"Tuple2 Item2: ($tuple2 | dn get "Item2")"
print $"Tuple3 Item3: ($tuple3 | dn get "Item3")"

print "\n23. KeyValuePair Objects"
print "------------------------"

# KeyValuePair objects
let $kvp1 = dn new "System.Collections.Generic.KeyValuePair[string, int]" --args ["score", 95]
let $kvp2 = dn new "System.Collections.Generic.KeyValuePair[string, string]" --args ["name", "John"]

print $"KVP1 Key: ($kvp1 | dn get "Key"), Value: ($kvp1 | dn get "Value")"
print $"KVP2 Key: ($kvp2 | dn get "Key"), Value: ($kvp2 | dn get "Value")"

print "\n🔬 JSON and Serialization Objects"
print "=================================="

print "\n24. JSON Objects"
print "----------------"

# JSON serializer options
let $jsonOptions = dn new "System.Text.Json.JsonSerializerOptions"
$jsonOptions | dn set "WriteIndented" true
$jsonOptions | dn set "PropertyNamingPolicy" ("System.Text.Json.JsonNamingPolicy" | dn get "CamelCase")

print $"JSON Options WriteIndented: ($jsonOptions | dn get "WriteIndented")"

print "\n25. Version Objects"
print "-------------------"

# Version objects
let $version1 = dn new "System.Version" --args [1, 2, 3, 4]
let $version2 = dn new "System.Version" --args ["2.1.0"]

print $"Version 1: ($version1 | dn call "ToString")"
print $"Version 2: ($version2 | dn call "ToString")"
print $"Version 1 Major: ($version1 | dn get "Major")"
print $"Version 2 Minor: ($version2 | dn get "Minor")"

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

dn new "System.Collections.ArrayList"
dn new "System.Collections.Hashtable" 