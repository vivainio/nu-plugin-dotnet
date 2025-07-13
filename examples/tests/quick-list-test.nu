#!/usr/bin/env nu

# Quick List Creation Test - Essential Patterns
print "🚀 Quick List Creation Test"
print "==========================="
print ""

print "1. ArrayList (Easy - Mixed Types)"
print "--------------------------------"
let $list = dn new "System.Collections.ArrayList"
$list | dn call "Add" "apple"
$list | dn call "Add" 42
$list | dn call "Add" true
print $"ArrayList items: ($list | dn get 'Count')"
print $"First item: ($list | dn call 'get_Item' 0)"
print ""

print "2. Generic String List (Advanced)"
print "--------------------------------"
let $stringList = dn new "System.Collections.Generic.List`1[System.String]"
$stringList | dn call "Add" "Hello"
$stringList | dn call "Add" "World"
print $"String list items: ($stringList | dn get 'Count')"
print $"First string: ($stringList | dn call 'get_Item' 0)"
print ""

print "3. Generic Integer List (Advanced)"
print "---------------------------------"
let $intList = dn new "System.Collections.Generic.List`1[System.Int32]"
$intList | dn call "Add" 10
$intList | dn call "Add" 20
$intList | dn call "Add" 30
print $"Integer list items: ($intList | dn get 'Count')"
print $"Sum example: ($intList | dn call 'get_Item' 0) + ($intList | dn call 'get_Item' 1) = {($intList | dn call 'get_Item' 0) + ($intList | dn call 'get_Item' 1)}"
print ""

print "4. Hashtable (Key-Value Storage)"
print "------------------------------"
let $dict = dn new "System.Collections.Hashtable"
$dict | dn call "Add" "name" "Alice"
$dict | dn call "Add" "score" 95
print $"Dictionary entries: ($dict | dn get 'Count')"
print $"Name: ($dict | dn call 'get_Item' 'name')"
print $"Score: ($dict | dn call 'get_Item' 'score')"
print ""

print "✅ All list types working perfectly!"
print ""
print "📋 Quick Reference:"
print "• Simple lists: dn new \"System.Collections.ArrayList\""
print "• Typed string lists: dn new \"System.Collections.Generic.List`1[System.String]\""
print "• Typed integer lists: dn new \"System.Collections.Generic.List`1[System.Int32]\""
print "• Key-value storage: dn new \"System.Collections.Hashtable\""

exit 0 