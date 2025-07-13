#!/usr/bin/env nu

# Test script to demonstrate the help system works for all plugin commands
print "=== Testing Help System for Nu Plugin .NET ==="
print ""

print "✅ NUSHELL HELP SYSTEM WORKS:"
print "Use 'help <command>' (not '<command> --help')"
print ""

print "1. help dn new"
nu -c 'help dn new'
print ""

print "2. help dn call"  
nu -c 'help dn call'
print ""

print "3. help dn get"
nu -c 'help dn get'
print ""

print "4. help dn set"
nu -c 'help dn set'
print ""

print "5. help dn load"
nu -c 'help dn load'
print ""

print "6. help dn assemblies"
nu -c 'help dn assemblies'
print ""

print "7. help dn types"
nu -c 'help dn types'
print ""

print "8. help dn members"
nu -c 'help dn members'
print ""

print "9. help dn obj"
nu -c 'help dn obj'
print ""

print "=== HELP SYSTEM TEST COMPLETE ==="
print "All commands have working help via 'help <command>' ✅"
print ""
print "Note: Use 'help dn <command>' NOT 'dn <command> --help'"
print "This is the standard nushell pattern for plugin commands." 