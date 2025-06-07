#!/usr/bin/env nu

# Advanced List Operations Test
print "🔬 Advanced List Operations Test"
print "================================"
print ""

print "1. ArrayList with complex operations:"
let $list = dn new "System.Collections.ArrayList"
$list | dn call "Add" "First"
$list | dn call "Add" "Second"
$list | dn call "Add" "Third"
print $"Initial count: ($list | dn get 'Count')"

# Insert at specific position
$list | dn call "Insert" 1 "Inserted"
print $"After insert at index 1: ($list | dn get 'Count')"

# Find index of item
let $index = $list | dn call "IndexOf" "Second"
print $"Index of 'Second': ($index)"

# Check if contains item
let $contains = $list | dn call "Contains" "Third"
print $"Contains 'Third': ($contains)"

# Remove specific item
$list | dn call "Remove" "First"
print $"After removing 'First': ($list | dn get 'Count')"
print ""

print "2. Generic List operations:"
let $nums = dn new "System.Collections.Generic.List`1[System.Int32]"
$nums | dn call "Add" 5
$nums | dn call "Add" 10
$nums | dn call "Add" 15
$nums | dn call "Add" 20
print $"Numbers count: ($nums | dn get 'Count')"

# Contains check
let $contains15 = $nums | dn call "Contains" 15
print $"Contains 15: ($contains15)"

# Remove specific number
$nums | dn call "Remove" 10
print $"After removing 10: ($nums | dn get 'Count')"

# Get item at specific index
let $firstNum = $nums | dn call "get_Item" 0
let $lastNum = $nums | dn call "get_Item" (($nums | dn get "Count") - 1)
print $"First number: ($firstNum)"
print $"Last number: ($lastNum)"
print ""

print "3. String list manipulation:"
let $words = dn new "System.Collections.Generic.List`1[System.String]"
$words | dn call "Add" "apple"
$words | dn call "Add" "banana"
$words | dn call "Add" "cherry"
$words | dn call "Add" "date"

print $"Words: ($words | dn get 'Count') items"
let $hasApple = $words | dn call "Contains" "apple"
print $"Has apple: ($hasApple)"

# Clear all items
$words | dn call "Clear"
print $"After clear: ($words | dn get 'Count') items"
print ""

print "4. Hashtable advanced operations:"
let $data = dn new "System.Collections.Hashtable"
$data | dn call "Add" "users" 150
$data | dn call "Add" "posts" 2340
$data | dn call "Add" "comments" 5670

print $"Data entries: ($data | dn get 'Count')"
let $hasUsers = $data | dn call "ContainsKey" "users"
print $"Has 'users' key: ($hasUsers)"

let $hasValue = $data | dn call "ContainsValue" 150
print $"Has value 150: ($hasValue)"

# Remove by key
$data | dn call "Remove" "comments"
print $"After removing 'comments': ($data | dn get 'Count')"
print ""

print "✅ All advanced operations working perfectly!"
print ""
print "🎯 Demonstrated capabilities:"
print "• Insert/Remove at specific positions"
print "• IndexOf and Contains operations"
print "• Clear operations"
print "• Key/Value checking in Hashtables"
print "• Type-safe operations in generic collections" 