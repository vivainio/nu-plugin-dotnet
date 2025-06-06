# Nu Plugin DotNet - Microsoft.Management.Infrastructure Working Demo
# This example demonstrates the current capabilities and limitations
# when working with Microsoft.Management.Infrastructure through nu-plugin-dotnet
#
# Prerequisites: nu-plugin-dotnet must be added: plugin add ./bin/Debug/net8.0/win-x64/nu_plugin_dotnet.exe

print "=== Microsoft.Management.Infrastructure Demo ==="

# First, let's see what assemblies are currently loaded
print "\n=== Currently Loaded Assemblies ==="
dn assemblies | select name version | first 5

# Try to load Microsoft.Management.Infrastructure assembly
print "\n=== Loading Microsoft.Management.Infrastructure ==="
try {
    # Note: This may cause stack overflow on some systems
    dn load-assembly "Microsoft.Management.Infrastructure"
    print "✓ Microsoft.Management.Infrastructure loaded successfully"
} catch {
    print "⚠ Could not load Microsoft.Management.Infrastructure"
    print $"  Error: ($in)"
    print "  This is expected on systems where MMI is not readily available"
    print "  or when there are circular dependency issues."
}

# Alternative approach: Check if System.Management.Automation is available
print "\n=== Alternative: Try System.Management.Automation ==="
try {
    dn load-assembly "System.Management.Automation" 
    print "✓ System.Management.Automation loaded"
    
    # List types in the assembly
    print "\n=== Available Types in System.Management.Automation ==="
    dn types "System.Management.Automation" | first 10
    
} catch {
    print "⚠ System.Management.Automation not available"
    print $"  Error: ($in)"
}

# Work with standard .NET types that are always available
print "\n=== Working with Standard .NET Types ==="

# Show available types in System.Diagnostics
print "\n--- System.Diagnostics Types ---"
try {
    dn types "System.Diagnostics" | first 10
} catch {
    print "Could not list System.Diagnostics types"
}

# Show members of a known type
print "\n--- Process Type Members ---"
try {
    dn members "System.Diagnostics.Process" | first 10
} catch {
    print "Could not show Process members"
}

print "\n=== Current Status Summary ==="
print "• The nu-plugin-dotnet is working and can list assemblies"
print "• The plugin can load assemblies and show types/members"
print "• Microsoft.Management.Infrastructure may have loading issues"
print "• This demonstrates the plugin's type exploration capabilities"

print "\n=== For WMI/CIM Operations ==="
print "Consider these alternatives:"
print "• Use PowerShell's Get-WmiObject or Get-CimInstance for WMI queries"
print "• Use System.Management namespace if available"
print "• Use the plugin for other .NET assemblies that load successfully"

print "\n=== Plugin Commands Available ==="
print "• dn assemblies - List loaded assemblies"
print "• dn load-assembly <name> - Load an assembly"
print "• dn types <assembly> - List types in assembly"
print "• dn members <type> - List members of a type"
print "• dn new <type> - Create new instance (syntax issues currently)"
print "• dn call <method> - Call methods (when objects work)"
print "• dn get <property> - Get properties (when objects work)"
print "• dn set <property> - Set properties (when objects work)"

print "\n=== Demo Complete ===" 