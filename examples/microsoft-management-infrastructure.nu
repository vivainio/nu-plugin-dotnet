# Nu Plugin DotNet - Microsoft.Management.Infrastructure Example
# This example demonstrates how to use Microsoft.Management.Infrastructure (MMI) 
# for WMI and CIM operations through the nu-plugin-dotnet plugin.
# 
# Prerequisites:
# 1. Register the plugin: register ./nu_plugin_dotnet.exe
# 2. Microsoft.Management.Infrastructure should be available on Windows systems
#
# Note: This example works best on Windows systems where MMI is natively available

print "=== Microsoft.Management.Infrastructure Example ==="

# Load the Microsoft.Management.Infrastructure assembly
# On Windows, this is typically located in the GAC or system folders
try {
    print "Loading Microsoft.Management.Infrastructure assembly..."
    
    # Try to load from GAC first (most common on Windows)
    dn load-library "Microsoft.Management.Infrastructure"
    print "✓ Successfully loaded Microsoft.Management.Infrastructure"
} catch {
    print "⚠ Could not load Microsoft.Management.Infrastructure from GAC"
    print "  This assembly is typically available on Windows systems."
    print "  You may need to install the Windows Management Framework or"
    print "  ensure the assembly is available in your system."
    exit 1
}

# Create a CIM Session to the local computer
print "\n=== Creating CIM Session ==="
try {
    let $session = dn new "Microsoft.Management.Infrastructure.CimSession" --args ["localhost"]
    print $"✓ Created CIM session to localhost"
    
    # Get operating system information
    print "\n=== Querying Operating System Information ==="
    let $osQuery = "SELECT * FROM Win32_OperatingSystem"
    let $osInstances = $session | dn call "QueryInstances" "root/cimv2" "WQL" $osQuery
    
    # Note: In a real scenario, you'd iterate through the collection
    # For this example, we'll show how to access the first instance
    print "OS Information query executed successfully"
    
    # Get computer system information
    print "\n=== Querying Computer System Information ==="
    let $csQuery = "SELECT * FROM Win32_ComputerSystem"
    let $csInstances = $session | dn call "QueryInstances" "root/cimv2" "WQL" $csQuery
    print "Computer System query executed successfully"
    
    # Get processor information
    print "\n=== Querying Processor Information ==="
    let $cpuQuery = "SELECT * FROM Win32_Processor"
    let $cpuInstances = $session | dn call "QueryInstances" "root/cimv2" "WQL" $cpuQuery
    print "Processor query executed successfully"
    
    # Clean up the session
    print "\n=== Cleaning Up ==="
    $session | dn call "Close"
    print "✓ CIM session closed"
    
} catch {
    print "❌ Error during CIM operations:"
    print $"   ($in)"
    print "   This might be due to insufficient permissions or WMI service issues."
}

# Alternative approach: Using CimSession factory methods
print "\n=== Alternative: Using CimSession Factory Methods ==="
try {
    # Create session using factory method
    let $sessionOptions = dn new "Microsoft.Management.Infrastructure.Options.CimSessionOptions"
    let $session2 = "Microsoft.Management.Infrastructure.CimSession" | dn call "Create" "localhost" $sessionOptions
    print "✓ Created CIM session using factory method"
    
    # Get logical disk information
    print "\n=== Querying Logical Disk Information ==="
    let $diskQuery = "SELECT * FROM Win32_LogicalDisk WHERE DriveType = 3"
    let $diskInstances = $session2 | dn call "QueryInstances" "root/cimv2" "WQL" $diskQuery
    print "Logical disk query executed successfully"
    
    # Clean up
    $session2 | dn call "Close"
    print "✓ Second CIM session closed"
    
} catch {
    print "❌ Error with factory method approach:"
    print $"   ($in)"
}

# Working with CIM Classes directly
print "\n=== Working with CIM Classes ==="
try {
    # Get CIM class information
    let $session3 = dn new "Microsoft.Management.Infrastructure.CimSession" --args ["localhost"]
    
    # Query for a specific CIM class
    let $class = $session3 | dn call "GetClass" "root/cimv2" "Win32_Service"
    print "✓ Retrieved Win32_Service class information"
    
    # You could examine class properties, methods, etc.
    # let $properties = $class | dn get "CimClassProperties"
    
    $session3 | dn call "Close"
    print "✓ Third CIM session closed"
    
} catch {
    print "❌ Error working with CIM classes:"
    print $"   ($in)"
}

# Example: Creating and configuring CIM operation options
print "\n=== CIM Operation Options ==="
try {
    # Create operation options
    let $opOptions = dn new "Microsoft.Management.Infrastructure.Options.CimOperationOptions"
    
    # Set timeout (example: 30 seconds)
    let $timeout = dn new "System.TimeSpan" --args [0, 0, 30]  # hours, minutes, seconds
    $opOptions | dn set "Timeout" $timeout
    print "✓ Created CIM operation options with 30-second timeout"
    
    # Create session with custom options
    let $sessionOptions = dn new "Microsoft.Management.Infrastructure.Options.CimSessionOptions"
    # Set custom timeout for session
    $sessionOptions | dn set "Timeout" $timeout
    
    let $customSession = "Microsoft.Management.Infrastructure.CimSession" | dn call "Create" "localhost" $sessionOptions
    print "✓ Created CIM session with custom options"
    
    # Use the session with operation options for a query
    let $serviceQuery = "SELECT * FROM Win32_Service WHERE State = 'Running'"
    let $runningServices = $customSession | dn call "QueryInstances" "root/cimv2" "WQL" $serviceQuery $opOptions
    print "✓ Queried running services with custom options"
    
    $customSession | dn call "Close"
    print "✓ Custom session closed"
    
} catch {
    print "❌ Error with custom options:"
    print $"   ($in)"
}

print "\n=== Microsoft.Management.Infrastructure Example Complete ==="
print "\nNote: This example demonstrates the basic structure for MMI operations."
print "In practice, you would need to iterate through CimInstance collections"
print "to access actual data from WMI queries. The MMI API provides rich"
print "functionality for system management and monitoring on Windows platforms."

print "\n=== Common MMI Use Cases ==="
print "• System monitoring (CPU, memory, disk usage)"
print "• Service management (start, stop, query services)"  
print "• Process management (list, monitor processes)"
print "• Hardware inventory (system specs, components)"
print "• Network configuration queries"
print "• Event log access and monitoring"
print "• Performance counter access"
print "• Registry operations (with appropriate permissions)" 