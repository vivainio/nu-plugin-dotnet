#!/usr/bin/env nu

# Very basic test for dn new command
print "🧪 Basic dn new command test"
print "============================"
print ""

print "1. Testing StringBuilder (should be available)"
print "---------------------------------------------"
try {
    let $sb = dn new "System.Text.StringBuilder"
    print $"✅ StringBuilder created: ($sb)"
    
    $sb | dn call "Append" "Hello"
    $sb | dn call "Append" " World"
    let $result = $sb | dn call "ToString"
    print $"✅ StringBuilder result: ($result)"
} catch { |err|
    print $"❌ StringBuilder failed: ($err.msg)"
}
print ""

print "2. Testing System.Object"
print "-----------------------"
try {
    let $obj = dn new "System.Object"
    print $"✅ Object created: ($obj)"
    let $str = $obj | dn call "ToString"
    print $"✅ Object.ToString(): ($str)"
} catch { |err|
    print $"❌ Object failed: ($err.msg)"
}
print ""

print "3. Testing known working commands"
print "-------------------------------"
try {
    let $max = "System.Math" | dn call "Max" 42 17
    print $"✅ Math.Max(42, 17) = ($max)"
    
    let $pi = "System.Math" | dn get "PI"
    print $"✅ Math.PI = ($pi)"
} catch { |err|
    print $"❌ Math operations failed: ($err.msg)"
}
print ""

print "4. Checking available assemblies"
print "-------------------------------"
try {
    let $assemblies = dn assemblies
    let $count = $assemblies | length
    print $"✅ Found ($count) loaded assemblies"
    
    # Show first few assemblies
    $assemblies | first 5 | each { |asm| 
        let $name = $asm | get name
        print $"  - ($name)"
    }
} catch { |err|
    print $"❌ Assembly listing failed: ($err.msg)"
}
print ""

print "✅ Basic functionality test completed!" 