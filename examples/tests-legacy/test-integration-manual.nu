#!/usr/bin/env nu

# Nu Plugin DotNet - Manual Integration Test
# Direct testing using echo and pipe commands

print "🧪 Nu Plugin DotNet - Manual Integration Test"
print "============================================="

let $plugin = "../bin/Release/net8.0/win-x64/nu_plugin_dotnet.exe"

print "\n1. Testing Plugin Signature..."
try {
    let $result = (echo '{"Type":"Signature"}' | $plugin)
    print "✅ Signature test PASSED"
    print $"   Result: ($result | str substring 0..100)..."
} catch {
    print "❌ Signature test FAILED"
}

print "\n2. Testing Math.Max(10, 20)..."
try {
    let $result = (echo '{"Type":"Run","Call":{"Head":{"Name":"dn call"},"Positional":[{"type":"String","val":"Max"},{"type":"Int","val":10},{"type":"Int","val":20}],"Named":{},"Input":{"type":"String","val":"System.Math"}}}' | $plugin)
    if ($result | str contains '"val":20') {
        print "✅ Math.Max test PASSED - returned 20"
    } else {
        print $"❌ Math.Max test FAILED - result: ($result)"
    }
} catch {
    print "❌ Math.Max test FAILED with error"
}

print "\n3. Testing Math.PI property..."
try {
    let $result = (echo '{"Type":"Run","Call":{"Head":{"Name":"dn get"},"Positional":[{"type":"String","val":"PI"}],"Named":{},"Input":{"type":"String","val":"System.Math"}}}' | $plugin)
    if ($result | str contains '3.14') {
        print "✅ Math.PI test PASSED - returned PI value"
    } else {
        print $"❌ Math.PI test FAILED - result: ($result)"
    }
} catch {
    print "❌ Math.PI test FAILED with error"
}

print "\n4. Testing String Length..."
try {
    let $result = (echo '{"Type":"Run","Call":{"Head":{"Name":"dn get"},"Positional":[{"type":"String","val":"Length"}],"Named":{},"Input":{"type":"String","val":"Hello World"}}}' | $plugin)
    if ($result | str contains '"val":11') {
        print "✅ String Length test PASSED - returned 11"
    } else {
        print $"❌ String Length test FAILED - result: ($result)"
    }
} catch {
    print "❌ String Length test FAILED with error"
}

print "\n5. Testing List Assemblies..."
try {
    let $result = (echo '{"Type":"Run","Call":{"Head":{"Name":"dn assemblies"},"Positional":[],"Named":{},"Input":null}}' | $plugin)
    if ($result | str contains 'List') {
        print "✅ List Assemblies test PASSED"
    } else {
        print $"❌ List Assemblies test FAILED - result: ($result | str substring 0..100)..."
    }
} catch {
    print "❌ List Assemblies test FAILED with error"
}

print "\n6. Testing Error Handling (Invalid operation)..."
try {
    let $result = (echo '{"Type":"Run","Call":{"Head":{"Name":"dn call"},"Positional":[{"type":"String","val":"NonExistentMethod"}],"Named":{},"Input":{"type":"String","val":"System.Math"}}}' | $plugin)
    if ($result | str contains 'Error') {
        print "✅ Error Handling test PASSED - correctly returned error"
    } else {
        print $"❌ Error Handling test FAILED - should have errored: ($result)"
    }
} catch {
    print "❌ Error Handling test FAILED with exception"
}

print "\n📊 Manual Integration Test Complete"
print "==================================="
print "🎯 All critical plugin functions tested via direct protocol communication" 