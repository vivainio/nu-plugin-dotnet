# Nu Plugin DotNet - System.Management Practical Example
# Demonstrates traditional WMI usage through System.Management
# Shows both success scenarios and practical alternatives
#
# Prerequisites: plugin add ./bin/Debug/net8.0/win-x64/nu_plugin_dotnet.exe

print "=== System.Management (Traditional WMI) - Practical Guide ==="

# Show what we can actually work with
print "\n=== Available .NET Assemblies ==="
let $assemblies = dn assemblies
print $"Found ($assemblies | length) loaded assemblies"
$assemblies | select name version | first 8

# Test System.Management availability
print "\n=== Testing System.Management Availability ==="
let $sysManagementAvailable = try { 
    dn load-assembly "System.Management"
    true 
} catch { 
    false 
}

if $sysManagementAvailable {
    print "✅ System.Management is available!"
    
    print "\n=== System.Management Types ==="
    dn types "System.Management" | select name fullName isClass | first 12
    
    print "\n=== Key WMI Classes ==="
    let $wmiClasses = [
        "ManagementObjectSearcher",
        "ManagementObject", 
        "ManagementScope",
        "ManagementClass",
        "ManagementException",
        "ObjectQuery",
        "SelectQuery"
    ]
    
    for $class in $wmiClasses {
        print $"\n--- ($class) Members ---"
        try {
            dn members $"System.Management.($class)" | select name memberType | first 5
        } catch {
            print $"Could not load ($class)"
        }
    }
    
    print "\n=== WMI Query Example Structure ==="
    print "With System.Management available, you can perform WMI queries like:"
    print ""
    print "```nushell"
    print "# Create a WQL query for operating system info"
    print "let $query = 'SELECT * FROM Win32_OperatingSystem'"
    print "let $searcher = dn new 'System.Management.ManagementObjectSearcher' --args [$query]"
    print "let $results = $searcher | dn call 'Get'"
    print "# Process the ManagementObjectCollection results"
    print "```"
    
    print "\n=== Common WMI Classes Available ==="
    let $wmiQueryClasses = [
        "Win32_OperatingSystem",
        "Win32_ComputerSystem", 
        "Win32_Processor",
        "Win32_LogicalDisk",
        "Win32_Service",
        "Win32_Process",
        "Win32_NetworkAdapterConfiguration",
        "Win32_BIOS",
        "Win32_PhysicalMemory"
    ]
    
    for $wmiClass in $wmiQueryClasses {
        print $"• ($wmiClass) - Query with: SELECT * FROM ($wmiClass)"
    }
    
} else {
    print "❌ System.Management not available in this environment"
    print "This is common when:"
    print "• Running on non-Windows systems"
    print "• In containerized environments"
    print "• When WMI components aren't installed"
    print "• In restricted execution contexts"
}

print "\n=== Alternative System Information Sources ==="

# Try to find available system-related types
print "\n--- Available System Types ---"
try {
    let $systemAssemblies = $assemblies | where name =~ "System"
    for $assembly in $systemAssemblies {
        print $"📦 ($assembly.name) v($assembly.version)"
    }
    
    # Check Environment class
    print "\n--- System.Environment Properties ---"
    let $envProps = dn members "System.Environment" | where memberType == Property | where name =~ "Machine|OS|User|Platform|Version"
    $envProps | select name | first 8
    
    print "\n--- System.Diagnostics.Process Methods ---"
    try {
        dn members "System.Diagnostics.Process" | where memberType == Method | where name =~ "GetCurrent|GetProcesses|Start" | select name | first 5
    } catch {
        print "Process class not accessible"
    }
    
} catch {
    print "Could not enumerate system types"
}

print "\n=== WMI Alternative Strategies ==="

print "\n🔧 **Strategy 1: PowerShell Integration**"
print "Use PowerShell commands directly in Nushell:"
print "```nushell"
print "# Get OS information"
print "powershell 'Get-WmiObject Win32_OperatingSystem | Select-Object Caption, Version'"
print ""
print "# Get running services"
print "powershell 'Get-Service | Where-Object {$_.Status -eq \"Running\"} | Select-Object Name, Status'"
print "```"

print "\n🔧 **Strategy 2: Command-line Tools**"
print "Use traditional Windows tools:"
print "```nushell"
print "# System information"
print "systeminfo | lines | where $it =~ 'OS Name|Total Physical Memory'"
print ""
print "# Process list"
print "tasklist /fo csv | from csv | select 'Image Name', 'PID', 'Mem Usage'"
print ""
print "# Service list"
print "sc query | lines | where $it =~ 'SERVICE_NAME|STATE'"
print "```"

print "\n🔧 **Strategy 3: Registry Access**"
print "Access system info through registry (if available):"
print "```nushell"
print "# Get OS version from registry"
print "reg query 'HKLM\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion' /v ProductName"
print "```"

print "\n🔧 **Strategy 4: File System Information**"
print "Get hardware/system info from special files:"
print "```nushell"
print "# CPU information (on Linux)"
print "open /proc/cpuinfo | lines | where $it =~ 'model name'"
print ""
print "# Memory information (on Linux)"  
print "open /proc/meminfo | lines | where $it =~ 'MemTotal|MemFree'"
print "```"

print "\n=== When System.Management IS Available ==="
print "If you're on a full Windows system with System.Management:"

print "\n**Basic WMI Query Pattern:**"
print "1. Create ManagementObjectSearcher with WQL query"
print "2. Call Get() to execute query"
print "3. Iterate through ManagementObjectCollection"
print "4. Access properties via ManagementObject indexer"

print "\n**Sample Implementation:**"
print "```nushell"
print "# Load the assembly"
print "dn load-assembly 'System.Management'"
print ""
print "# Create and execute query"
print "let $query = 'SELECT Caption, TotalVisibleMemorySize FROM Win32_OperatingSystem'"
print "let $searcher = dn new 'System.Management.ManagementObjectSearcher' --args [$query]"
print "let $collection = $searcher | dn call 'Get'"
print ""
print "# Process results (pseudo-code, actual iteration may vary)"
print "let $enumerator = $collection | dn call 'GetEnumerator'"
print "while ($enumerator | dn call 'MoveNext') {"
print "    let $obj = $enumerator | dn get 'Current'"
print "    let $caption = $obj | dn get 'Item' 'Caption'"
print "    let $memory = $obj | dn get 'Item' 'TotalVisibleMemorySize'"
print "    print $'OS: ($caption), Memory: ($memory) KB'"
print "}"
print "```"

print "\n=== Error Handling for WMI ==="
print "When working with System.Management, watch for:"
print "• ManagementException - WMI-specific errors"
print "• UnauthorizedAccessException - Permission issues"
print "• TimeoutException - Slow or hanging queries"
print "• COMException - Low-level WMI COM errors"

print "\n=== Performance Considerations ==="
print "• Use SELECT with specific properties instead of *"
print "• Add WHERE clauses to filter at WMI level"
print "• Set reasonable timeouts on queries"
print "• Dispose of ManagementObject instances"
print "• Consider async patterns for long-running queries"

print "\n=== Security Notes ==="
print "• Many WMI classes require administrative privileges"
print "• Remote WMI connections need proper authentication"
print "• Some queries can be resource-intensive"
print "• Consider using impersonation for specific security contexts"

print "\n=== Summary ==="
if $sysManagementAvailable {
    print "✅ System.Management is available - you can use traditional WMI!"
    print "✅ Full WMI query capabilities are accessible"
    print "✅ Access to comprehensive Windows system information"
} else {
    print "❌ System.Management not available - use alternative strategies"
    print "💡 PowerShell integration often provides the best alternative"
    print "💡 Command-line tools can provide specific system information"
    print "💡 Registry access can supplement missing WMI functionality"
}

print "\n=== System.Management Demo Complete ==="
print "This guide shows both the ideal scenario and practical alternatives!" 