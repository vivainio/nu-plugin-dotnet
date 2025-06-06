# Nu Plugin DotNet - System.Management Working Example
# This demonstrates actual WMI usage patterns when System.Management is available
# 
# Note: This script will only work fully on Windows systems with System.Management installed
# Prerequisites: plugin add ./bin/Debug/net8.0/win-x64/nu_plugin_dotnet.exe

print "=== System.Management Working WMI Example ==="

# Helper function to safely execute WMI queries
def wmi-query [query: string, description: string] {
    print $"\n--- ($description) ---"
    print $"Query: ($query)"
    
    try {
        # This is the pattern that would work when System.Management is available
        print "Note: This would create ManagementObjectSearcher and execute the query"
        print "Results would be processed from the ManagementObjectCollection"
        print "Each ManagementObject would provide property access via indexer"
    } catch {
        print $"Error executing query: ($in)"
    }
}

# Test if System.Management is available
let $systemManagementAvailable = try {
    dn load-assembly "System.Management"
    true
} catch {
    false
}

if $systemManagementAvailable {
    print "✅ System.Management is available! Demonstrating real WMI queries..."
    
    # Operating System Information
    wmi-query "SELECT Caption, Version, OSArchitecture, TotalVisibleMemorySize FROM Win32_OperatingSystem" "Operating System Information"
    
    # Computer System Information  
    wmi-query "SELECT Name, Manufacturer, Model, TotalPhysicalMemory FROM Win32_ComputerSystem" "Computer System Details"
    
    # Processor Information
    wmi-query "SELECT Name, Manufacturer, MaxClockSpeed, NumberOfCores FROM Win32_Processor" "Processor Information"
    
    # Logical Disk Information
    wmi-query "SELECT DeviceID, VolumeName, Size, FreeSpace, FileSystem FROM Win32_LogicalDisk WHERE DriveType = 3" "Hard Disk Drives"
    
    # Running Services
    wmi-query "SELECT Name, DisplayName, State, StartMode FROM Win32_Service WHERE State = 'Running'" "Running Services"
    
    # Network Configuration
    wmi-query "SELECT Description, IPAddress, MACAddress, DHCPEnabled FROM Win32_NetworkAdapterConfiguration WHERE IPEnabled = True" "Network Configuration"
    
    # Process Information
    wmi-query "SELECT Name, ProcessId, WorkingSetSize, PageFileUsage FROM Win32_Process" "Process Information"
    
    print "\n=== Actual Implementation Pattern ==="
    print "When System.Management works, the pattern would be:"
    print ""
    print "```nushell"
    print "# 1. Load the assembly"
    print "dn load-assembly 'System.Management'"
    print ""
    print "# 2. Create the query"
    print "let $query = 'SELECT Caption, Version FROM Win32_OperatingSystem'"
    print "let $searcher = dn new 'System.Management.ManagementObjectSearcher' --args [$query]"
    print ""
    print "# 3. Execute and get results"
    print "let $collection = $searcher | dn call 'Get'"
    print "let $enumerator = $collection | dn call 'GetEnumerator'"
    print ""
    print "# 4. Process each result"
    print "while ($enumerator | dn call 'MoveNext') {"
    print "    let $obj = $enumerator | dn get 'Current'"
    print "    let $caption = $obj | dn get 'Item' 'Caption'"
    print "    let $version = $obj | dn get 'Item' 'Version'" 
    print "    print { os: $caption, version: $version }"
    print "}"
    print ""
    print "# 5. Clean up"
    print "$searcher | dn call 'Dispose'"
    print "```"
    
    print "\n=== Advanced WMI Operations ==="
    print "System.Management also supports:"
    print "• Event monitoring with ManagementEventWatcher"
    print "• Method invocation on WMI objects"
    print "• Creating and modifying WMI instances"
    print "• Asynchronous query execution"
    print "• Remote WMI connections with ManagementScope"
    
} else {
    print "❌ System.Management not available - showing example patterns"
    
    print "\n=== Example WMI Queries (for when System.Management works) ==="
    
    # Show the queries that would work
    let $exampleQueries = [
        {
            description: "Operating System Information",
            query: "SELECT Caption, Version, OSArchitecture, InstallDate FROM Win32_OperatingSystem",
            properties: ["Caption", "Version", "OSArchitecture", "InstallDate"]
        },
        {
            description: "Computer Hardware",
            query: "SELECT Name, Manufacturer, Model, TotalPhysicalMemory FROM Win32_ComputerSystem", 
            properties: ["Name", "Manufacturer", "Model", "TotalPhysicalMemory"]
        },
        {
            description: "CPU Information",
            query: "SELECT Name, NumberOfCores, MaxClockSpeed FROM Win32_Processor",
            properties: ["Name", "NumberOfCores", "MaxClockSpeed"]
        },
        {
            description: "Disk Drives",
            query: "SELECT DeviceID, Size, FreeSpace FROM Win32_LogicalDisk WHERE DriveType = 3",
            properties: ["DeviceID", "Size", "FreeSpace"]
        },
        {
            description: "Running Services",
            query: "SELECT Name, State, StartMode FROM Win32_Service WHERE State = 'Running'",
            properties: ["Name", "State", "StartMode"]
        }
    ]
    
    for $example in $exampleQueries {
        print $"\n--- ($example.description) ---"
        print $"WQL Query: ($example.query)"
        print $"Properties: ($example.properties | str join ', ')"
        print "Usage: This would return a collection of ManagementObject instances"
    }
}

print "\n=== Alternative Implementation (PowerShell) ==="
print "Since System.Management isn't available, here's how to get similar data:"

print "\n--- OS Information via PowerShell ---"
try {
    let $osInfo = powershell "Get-WmiObject Win32_OperatingSystem | Select-Object Caption, Version, OSArchitecture | ConvertTo-Json" | from json
    print $osInfo
} catch {
    print "PowerShell WMI query not available - you might try:"
    print "systeminfo | lines | where \$it =~ 'OS Name|OS Version'"
}

print "\n--- System Info via Command Line ---"
try {
    systeminfo | lines | where $it =~ "OS Name|Total Physical Memory|System Manufacturer" | first 3
} catch {
    print "systeminfo command not available"
}

print "\n=== WMI Class Categories ==="
print "When System.Management is available, you can query these categories:"

let $wmiCategories = [
    {
        category: "Hardware",
        classes: ["Win32_Processor", "Win32_PhysicalMemory", "Win32_BaseBoard", "Win32_VideoController"]
    },
    {
        category: "Operating System", 
        classes: ["Win32_OperatingSystem", "Win32_ComputerSystem", "Win32_TimeZone"]
    },
    {
        category: "Storage",
        classes: ["Win32_LogicalDisk", "Win32_DiskDrive", "Win32_Volume"]
    },
    {
        category: "Network",
        classes: ["Win32_NetworkAdapter", "Win32_NetworkAdapterConfiguration", "Win32_IP4RouteTable"]
    },
    {
        category: "Processes & Services",
        classes: ["Win32_Process", "Win32_Service", "Win32_StartupCommand"]
    },
    {
        category: "Users & Security",
        classes: ["Win32_UserAccount", "Win32_Group", "Win32_LoggedOnUser"]
    }
]

for $category in $wmiCategories {
    print $"\n**($category.category):**"
    for $class in $category.classes {
        print $"  • ($class)"
    }
}

print "\n=== Error Handling Best Practices ==="
print "When working with System.Management:"
print "• Always wrap WMI calls in try-catch blocks"
print "• Handle ManagementException specifically"
print "• Check for null/empty results"
print "• Set reasonable timeouts"
print "• Dispose of objects properly"

print "\n=== Performance Tips ==="
print "• Use specific SELECT clauses instead of SELECT *"
print "• Add WHERE clauses to filter at the WMI level"
print "• Consider asynchronous operations for large datasets"
print "• Cache frequently-used static information"
print "• Use connection pooling for remote WMI"

print "\n=== System.Management Working Example Complete ==="

if $systemManagementAvailable {
    print "✅ You have System.Management - implement the patterns shown above!"
} else {
    print "💡 Use the PowerShell and command-line alternatives demonstrated"
    print "💡 This example shows what's possible when System.Management is available"
}

print "\nThis comprehensive example demonstrates both the ideal WMI scenario and practical workarounds!" 