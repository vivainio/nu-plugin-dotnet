#!/usr/bin/env nu
# System.Security.Cryptography Demo Script for nu-plugin-dotnet
# 
# This script demonstrates loading and using the System.Security.Cryptography
# assembly to work with cryptographic functions from nushell.
#
# NOTE: The --name parameter was removed from dn load-assembly due to 
# plugin protocol serialization issues. Use positional arguments instead:
# - dn load-assembly "AssemblyName" (loads by name)
# - dn load-assembly --path "path/to/assembly.dll" (loads by path)

print "🔧 Nu Plugin DotNet - Cryptography Test"
print "========================================"

# Check if plugin is already loaded
let plugins = (plugin list | where name == "dotnet")
if ($plugins | length) == 0 {
    print "📦 Registering plugin..."
    plugin add ./bin/Release/net8.0/win-x64/nu_plugin_dotnet.exe
    print "✅ Plugin registered successfully"
} else {
    print "📦 Plugin already registered"
}

print "\n=== Loading Various Assemblies by Name ==="

# Test loading different assemblies by name (positional argument)
print "🔄 Trying to load System.Security.Cryptography..."
try {
    dn load-assembly "System.Security.Cryptography"
    print "✅ System.Security.Cryptography assembly loaded"
} catch {
    print "❌ Failed to load System.Security.Cryptography"
}

print "🔄 Trying to load System.Text.Json..."
try {
    dn load-assembly "System.Text.Json"
    print "✅ System.Text.Json assembly loaded"
} catch {
    print "❌ Failed to load System.Text.Json"
}

print "🔄 Trying to load System.Net.Http..."
try {
    dn load-assembly "System.Net.Http"
    print "✅ System.Net.Http assembly loaded"
} catch {
    print "❌ Failed to load System.Net.Http"
}

print "🔄 Trying to load System.IO.FileSystem..."
try {
    dn load-assembly "System.IO.FileSystem"
    print "✅ System.IO.FileSystem assembly loaded"
} catch {
    print "❌ Failed to load System.IO.FileSystem"
}

print "🔄 Trying to load System.Linq..."
try {
    dn load-assembly "System.Linq"
    print "✅ System.Linq assembly loaded"
} catch {
    print "❌ Failed to load System.Linq"
}

print "🔄 Trying to load Newtonsoft.Json..."
try {
    dn load-assembly "Newtonsoft.Json"
    print "✅ Newtonsoft.Json assembly loaded"
} catch {
    print "❌ Failed to load Newtonsoft.Json"
}

print "🔄 Trying to load System.Drawing..."
try {
    dn load-assembly "System.Drawing"
    print "✅ System.Drawing assembly loaded"
} catch {
    print "❌ Failed to load System.Drawing"
}

print "\n=== Testing --path Parameter with DLL Files ==="

print "🔄 Trying to load System.Security.Cryptography.dll..."
try {
    dn load-assembly --path "System.Security.Cryptography.dll"
    print "✅ System.Security.Cryptography.dll loaded via --path"
} catch {
    print "❌ Failed to load System.Security.Cryptography.dll via --path"
}

print "🔄 Trying to load System.Text.Json.dll..."
try {
    dn load-assembly --path "System.Text.Json.dll"
    print "✅ System.Text.Json.dll loaded via --path"
} catch {
    print "❌ Failed to load System.Text.Json.dll via --path"
}

print "\n=== Testing Positional Arguments (Backward Compatibility) ==="

print "🔄 Trying positional argument with System.Collections..."
try {
    dn load-assembly "System.Collections"
    print "✅ System.Collections loaded via positional argument"
} catch {
    print "❌ Failed to load System.Collections via positional argument"
}

print "🔄 Trying positional argument with System.Threading..."
try {
    dn load-assembly "System.Threading"
    print "✅ System.Threading loaded via positional argument"
} catch {
    print "❌ Failed to load System.Threading via positional argument"
}

print "\n=== Testing System.Security.Cryptography Assembly Access ==="

print "\n=== SHA256 Static Create Method ==="

# Call static Create method on SHA256 class
let $sha256 = "System.Security.Cryptography.SHA256" | dn call "Create"
print "✅ SHA256.Create() called successfully"
print $"SHA256 algorithm type: ($sha256)"

# Test some properties of the created SHA256 instance
let $hashSize = $sha256 | dn get "HashSize"
print $"SHA256 Hash Size: ($hashSize) bits"

# Dispose the hasher
$sha256 | dn call "Dispose"
print "✅ SHA256 hasher disposed"

print "\n=== MD5 Static Create Method ==="

# Call static Create method on MD5 class
let $md5 = "System.Security.Cryptography.MD5" | dn call "Create"
print "✅ MD5.Create() called successfully"
print $"MD5 algorithm type: ($md5)"

# Test properties
let $md5HashSize = $md5 | dn get "HashSize"
print $"MD5 Hash Size: ($md5HashSize) bits"

# Dispose the hasher
$md5 | dn call "Dispose" 
print "✅ MD5 hasher disposed"

print "\n=== AES Static Create Method ==="

# Call static Create method on Aes class
let $aes = "System.Security.Cryptography.Aes" | dn call "Create"
print "✅ Aes.Create() called successfully"
print $"AES algorithm type: ($aes)"

# Test properties
let $keySize = $aes | dn get "KeySize" 
let $blockSize = $aes | dn get "BlockSize"
print $"AES Key Size: ($keySize) bits"
print $"AES Block Size: ($blockSize) bits"

# Dispose AES
$aes | dn call "Dispose"
print "✅ AES algorithm disposed"

print "\n=== RSA Static Create Method ==="

# Call static Create method on RSA class
let $rsa = "System.Security.Cryptography.RSA" | dn call "Create"
print "✅ RSA.Create() called successfully"
print $"RSA algorithm type: ($rsa)"

# Test properties
let $rsaKeySize = $rsa | dn get "KeySize"
print $"RSA Key Size: ($rsaKeySize) bits"

# Dispose RSA
$rsa | dn call "Dispose"
print "✅ RSA algorithm disposed"

print "\n=== RandomNumberGenerator Static Create Method ==="

# Call static Create method on RandomNumberGenerator class
let $rng = "System.Security.Cryptography.RandomNumberGenerator" | dn call "Create"
print "✅ RandomNumberGenerator.Create() called successfully"
print $"RNG type: ($rng)"

# Dispose RNG
$rng | dn call "Dispose"
print "✅ Random number generator disposed"

print "\n=== Additional Hash Algorithm Static Create Methods ==="

# SHA1
let $sha1 = "System.Security.Cryptography.SHA1" | dn call "Create"
print "✅ SHA1.Create() called successfully"
let $sha1HashSize = $sha1 | dn get "HashSize"
print $"SHA1 Hash Size: ($sha1HashSize) bits"
$sha1 | dn call "Dispose"

# SHA384
let $sha384 = "System.Security.Cryptography.SHA384" | dn call "Create"
print "✅ SHA384.Create() called successfully"
let $sha384HashSize = $sha384 | dn get "HashSize"
print $"SHA384 Hash Size: ($sha384HashSize) bits"
$sha384 | dn call "Dispose"

# SHA512
let $sha512 = "System.Security.Cryptography.SHA512" | dn call "Create"
print "✅ SHA512.Create() called successfully"
let $sha512HashSize = $sha512 | dn get "HashSize"
print $"SHA512 Hash Size: ($sha512HashSize) bits"
$sha512 | dn call "Dispose"

print "\n=== Testing Some Hash Computation ==="

# Create test data
let $testData = "Hello, Cryptography!" | encode utf8
let $dataLength = ($testData | length)
print ("Test data: 'Hello, Cryptography!' " + ($dataLength | into string) + " bytes")

# Create SHA256 hasher and compute hash
let $sha256_hasher = "System.Security.Cryptography.SHA256" | dn call "Create"
let $hashResult = $sha256_hasher | dn call "ComputeHash" $testData
print $"SHA256 hash computed: ($hashResult | length) bytes"
print $"First few hash bytes: ($hashResult | first 8)"
$sha256_hasher | dn call "Dispose"

print "\n=== Cryptography Demo Complete ==="
print "✅ Successfully demonstrated System.Security.Cryptography access"
print "✅ Successfully called static Create methods on multiple algorithms:"
print "   - SHA256.Create()"
print "   - MD5.Create()" 
print "   - Aes.Create()"
print "   - RSA.Create()"
print "   - RandomNumberGenerator.Create()"
print "   - SHA1.Create(), SHA384.Create(), SHA512.Create()"
print "✅ Successfully performed hash computation"
print "✅ All cryptographic operations completed successfully!" 