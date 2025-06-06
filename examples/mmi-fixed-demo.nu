# Nu Plugin DotNet - Microsoft.Management.Infrastructure Demo (Fixed)
# This example demonstrates Microsoft.Management.Infrastructure usage after stack overflow fixes
# 
# Prerequisites: plugin add ./bin/Debug/net8.0/win-x64/nu_plugin_dotnet.exe
# Note: This requires Windows with WMI/CIM support and proper assembly installation

print "=== Microsoft.Management.Infrastructure Demo (Stack Overflow Fixed) ==="

# Show current assemblies
print "\n=== Currently Loaded Assemblies ==="
dn assemblies | select name version | first 5

# Try to load Microsoft.Management.Infrastructure
print "\n=== Loading Microsoft.Management.Infrastructure ==="
try {
    dn load-assembly "Microsoft.Management.Infrastructure"
    print "✅ Microsoft.Management.Infrastructure loaded successfully!"
    
    # If successful, show available types
    print "\n=== Available MMI Types ==="
    dn types "Microsoft.Management.Infrastructure" | select name fullName | first 10
    
    # Show CimSession members
    print "\n=== CimSession Members ==="
    dn members "Microsoft.Management.Infrastructure.CimSession" | select name memberType | first 10
    
    print "\n=== Next Steps ==="
    print "Now you can create CIM sessions and perform WMI operations:"
    print "1. Create a CIM session to localhost"
    print "2. Execute WQL queries for system information"
    print "3. Access WMI classes like Win32_OperatingSystem, Win32_ComputerSystem, etc."
    
} catch {
    print "⚠ Microsoft.Management.Infrastructure not available in this environment"
    print $"Error: ($in)"
    print "\nThis is normal if:"
    print "• The assembly is not installed on this system"
    print "• The assembly is in a different location"
    print "• You're not running on Windows with full WMI support"
    
    print "\n=== Alternatives for System Information ==="
    print "Consider these approaches instead:"
    
    # Try System.Management (older WMI API)
    print "\n--- Trying System.Management (Classic WMI) ---"
    try {
        dn load-assembly "System.Management"
        print "✅ System.Management available!"
        dn types "System.Management" | where name =~ Management | select name fullName | first 5
    } catch {
        print "❌ System.Management also not available"
    }
    
    # Show what's available for system operations
    print "\n--- Available System-Related Assemblies ---"
    dn assemblies | where name =~ System | where name =~ "Diagnostics|Environment|Runtime|IO" | select name
}

# Demonstrate working with available system types
print "\n=== Working with Available System Types ==="

# Show Environment information that's always available
print "\n--- Environment Information (via System.Environment) ---"
try {
    let $envType = "System.Environment"
    dn members $envType | where memberType == Property | where name =~ "MachineName|OSVersion|UserName|Version" | select name
    print "You can access these properties to get system information"
} catch {
    print "Could not access Environment type"
}

# Show Process-related information
print "\n--- Process Information (via System.Diagnostics.Process) ---"
try {
    dn members "System.Diagnostics.Process" | where memberType == Method | where name =~ "GetCurrent|GetProcesses" | select name | first 3
    print "These methods can provide process information"
} catch {
    print "Could not access Process type"
}

print "\n=== Stack Overflow Issue Resolution Summary ==="
print "✅ Fixed recursive assembly resolution in OnAssemblyResolving"
print "✅ Added prevention for circular dependency loading"
print "✅ Improved error handling to prevent stack overflow in error reporting"
print "✅ Plugin now provides proper error messages instead of crashing"

print "\n=== Recommended Workflow ==="
print "1. Try loading the specific assembly you need"
print "2. If it fails, you'll get a clear error message"
print "3. Use alternative approaches or assemblies that are available"
print "4. Leverage the plugin's type exploration capabilities"

print "\n=== Command Reference ==="
print "dn assemblies                    - List loaded assemblies"
print "dn load-assembly <name>          - Load assembly (with proper error handling)"
print "dn types <assembly>              - Explore types in assembly"
print "dn members <type>                - Examine type members"
print "dn new <type> [args]             - Create instances (syntax being refined)"

print "\n=== Demo Complete ==="
print "The plugin is now robust against stack overflow and provides clear error reporting!" 