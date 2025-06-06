# Nu Plugin DotNet - System.Management (Traditional WMI) Example
# This example demonstrates how to use the traditional System.Management namespace
# for WMI operations through the nu-plugin-dotnet plugin.
#
# Prerequisites:
# 1. Register the plugin: plugin add ./bin/Debug/net8.0/win-x64/nu_plugin_dotnet.exe
# 2. Windows system with WMI support
# 3. System.Management assembly (usually available on Windows)

print "=== System.Management (Traditional WMI) Example ==="

# Check currently loaded assemblies
print "\n=== Currently Loaded Assemblies ==="
dn assemblies | select name version | first 5

# Try to load System.Management assembly
print "\n=== Loading System.Management Assembly ==="
try {
    dn load-assembly "System.Management"
    print "✅ System.Management loaded successfully!"
    
    # Show available types in System.Management
    print "\n=== Available System.Management Types ==="
    dn types "System.Management" | select name fullName isClass | first 10
    
    # Explore ManagementObjectSearcher - key class for WMI queries
    print "\n=== ManagementObjectSearcher Members ==="
    dn members "System.Management.ManagementObjectSearcher" | select name memberType | first 10
    
    # Explore ManagementObject - represents WMI objects
    print "\n=== ManagementObject Members ==="
    dn members "System.Management.ManagementObject" | select name memberType | first 10
    
    # Show ManagementScope members - for connecting to WMI namespaces
    print "\n=== ManagementScope Members ==="
    dn members "System.Management.ManagementScope" | select name memberType | first 8
    
    print "\n=== Traditional WMI Classes Available ==="
    print "With System.Management loaded, you can query these common WMI classes:"
    print "• Win32_OperatingSystem - OS information"
    print "• Win32_ComputerSystem - Computer details"
    print "• Win32_Processor - CPU information"
    print "• Win32_LogicalDisk - Disk drives"
    print "• Win32_NetworkAdapterConfiguration - Network settings"
    print "• Win32_Service - Windows services"
    print "• Win32_Process - Running processes"
    print "• Win32_BIOS - BIOS information"
    print "• Win32_PhysicalMemory - Memory modules"
    print "• Win32_VideoController - Graphics cards"
    
    print "\n=== Example WMI Query Patterns ==="
    print "Once object creation works, you could use patterns like:"
    print "1. Create ManagementObjectSearcher with WQL query"
    print "2. Call Get() to execute the query"
    print "3. Iterate through ManagementObjectCollection results"
    print "4. Access properties of each ManagementObject"
    
    print "\n=== Sample WQL Queries ==="
    print "• SELECT * FROM Win32_OperatingSystem"
    print "• SELECT Name, Version FROM Win32_OperatingSystem"
    print "• SELECT * FROM Win32_LogicalDisk WHERE DriveType = 3"
    print "• SELECT * FROM Win32_Service WHERE State = 'Running'"
    print "• SELECT Name, ProcessId FROM Win32_Process"
    
} catch {
    print "❌ System.Management not available in this environment"
    print $"Error: ($in)"
    print "\nThis could mean:"
    print "• Running on a non-Windows system"
    print "• System.Management assembly not installed"
    print "• Insufficient permissions for WMI access"
    
    print "\n=== Alternative Approaches ==="
    print "If System.Management isn't available, consider:"
    print "• PowerShell Get-WmiObject commands"
    print "• PowerShell Get-CimInstance commands"
    print "• Direct command-line tools (wmic, systeminfo)"
    print "• Other .NET assemblies for system information"
}

# Show what system-related assemblies are available
print "\n=== Available System-Related Assemblies ==="
try {
    dn assemblies | where name =~ System | where name =~ "Diagnostics|Environment|Runtime|IO|Net" | select name version
} catch {
    print "Could not list system assemblies"
}

# Demonstrate working with built-in system information
print "\n=== Working with Available System Types ==="

# Environment information
print "\n--- System.Environment Properties ---"
try {
    dn members "System.Environment" | where memberType == Property | where name =~ "Machine|OS|User|Version|Platform" | select name
} catch {
    print "Could not access Environment properties"
}

# DateTime for timestamps
print "\n--- System.DateTime Methods ---" 
try {
    dn members "System.DateTime" | where memberType == Method | where name =~ "Now|Today|Parse" | select name | first 5
} catch {
    print "Could not access DateTime methods"
}

print "\n=== WMI Connection Patterns ==="
print "Traditional System.Management follows these patterns:"
print ""
print "1. **Basic Query:**"
print "   - Create ManagementObjectSearcher with WQL"
print "   - Execute Get() to retrieve results"
print "   - Iterate through collection"
print ""
print "2. **Scoped Query:**"
print "   - Create ManagementScope for specific namespace"
print "   - Connect to scope"
print "   - Create searcher with scope and query"
print ""
print "3. **Property Access:**"
print "   - Get ManagementObject from results"
print "   - Access properties by name using indexer"
print "   - Convert values to appropriate types"

print "\n=== Common WMI Namespaces ==="
print "• root/cimv2 - Most common WMI classes"
print "• root/wmi - Hardware and driver information"
print "• root/default - Registry and other system info"
print "• root/microsoft/windows - Modern Windows features"

print "\n=== Security Considerations ==="
print "• WMI queries require appropriate permissions"
print "• Some classes need administrative privileges"
print "• Remote WMI connections need authentication"
print "• Consider using impersonation for specific contexts"

print "\n=== Performance Tips ==="
print "• Use specific property lists instead of SELECT *"
print "• Add WHERE clauses to filter results"
print "• Dispose of ManagementObject instances"
print "• Use ManagementObjectSearcher.Options for timeouts"

print "\n=== Error Handling Patterns ==="
print "• ManagementException for WMI-specific errors"
print "• UnauthorizedAccessException for permission issues"
print "• TimeoutException for slow queries"
print "• COMException for low-level WMI errors"

print "\n=== Next Steps ==="
if (try { dn load-assembly "System.Management"; true } catch { false }) {
    print "✅ System.Management is available - you can proceed with WMI operations"
    print "• Try creating ManagementObjectSearcher instances"
    print "• Execute simple WQL queries"
    print "• Access WMI object properties"
} else {
    print "❌ System.Management not available - consider alternatives:"
    print "• Use PowerShell for WMI operations"
    print "• Explore other system information sources"
    print "• Use command-line tools for specific data"
}

print "\n=== System.Management Demo Complete ==="
print "This example shows how to work with traditional WMI through .NET!" 