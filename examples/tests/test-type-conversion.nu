#!/usr/bin/env nu

# Manual test to demonstrate expected type conversions
print "🔧 Generic Type Conversion Examples"
print "==================================="
print ""

print "Expected Conversions:"
print "-------------------"
print "Input: 'string'           -> Output: 'System.String'"
print "Input: 'int'              -> Output: 'System.Int32'"
print "Input: 'List<string>'     -> Output: 'System.Collections.Generic.List`1[System.String]'"
print "Input: 'Dictionary<string, int>' -> Output: 'System.Collections.Generic.Dictionary`2[System.String,System.Int32]'"
print "Input: 'HashSet<int>'     -> Output: 'System.Collections.Generic.HashSet`1[System.Int32]'"
print "Input: 'Queue<bool>'      -> Output: 'System.Collections.Generic.Queue`1[System.Boolean]'"
print "Input: 'Stack<double>'    -> Output: 'System.Collections.Generic.Stack`1[System.Double]'"
print ""

print "Nested Generic Examples:"
print "----------------------"
print "Input: 'List<List<string>>'           -> Output: 'System.Collections.Generic.List`1[System.Collections.Generic.List`1[System.String]]'"
print "Input: 'Dictionary<string, List<int>>' -> Output: 'System.Collections.Generic.Dictionary`2[System.String,System.Collections.Generic.List`1[System.Int32]]'"
print ""

print "Type Alias Examples:"
print "------------------"
print "Input: 'List<long>'       -> Output: 'System.Collections.Generic.List`1[System.Int64]'"
print "Input: 'Dictionary<int, bool>' -> Output: 'System.Collections.Generic.Dictionary`2[System.Int32,System.Boolean]'"
print "Input: 'HashSet<char>'    -> Output: 'System.Collections.Generic.HashSet`1[System.Char]'"
print ""

print "This conversion will be tested when you run the main test: test-generic-syntax.nu" 
exit 0
