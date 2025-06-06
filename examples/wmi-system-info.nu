# Nu Plugin DotNet - WMI System Information Example
# A practical example showing how to extract real system information
# using Microsoft.Management.Infrastructure through nu-plugin-dotnet
#
# Prerequisites:
# 1. Register the plugin: register ./nu_plugin_dotnet.exe  
# 2. Run on Windows (where MMI is available)

print "=== WMI System Information Tool ==="

# Load the Microsoft.Management.Infrastructure assembly
print "Loading Microsoft.Management.Infrastructure..."
try {
    dn load-library "Microsoft.Management.Infrastructure"
    print "✓ Assembly loaded successfully"
} catch {
    print "❌ Failed to load Microsoft.Management.Infrastructure"
    print "  This example requires Windows with WMI support"
    exit 1
}

# Helper function to safely get CIM instance property
def get-cim-property [instance: any, propertyName: string] {
    try {
        let $properties = $instance | dn get "CimInstanceProperties"
        let $property = $properties | dn get "Item" $propertyName
        if ($property != null) {
            $property | dn get "Value"
        } else {
            "N/A"
        }
    } catch {
        "Error reading property"
    }
}

# Create CIM session
print "\nCreating CIM session..."
try {
    let $session = dn new "Microsoft.Management.Infrastructure.CimSession" --args ["localhost"]
    print "✓ CIM session created"
    
    # === Operating System Information ===
    print "\n=== Operating System Information ==="
    try {
        let $osQuery = "SELECT * FROM Win32_OperatingSystem"
        let $osInstances = $session | dn call "QueryInstances" "root/cimv2" "WQL" $osQuery
        
        # Get the enumerator to iterate through results
        let $enumerator = $osInstances | dn call "GetEnumerator"
        let $hasNext = $enumerator | dn call "MoveNext"
        
        if $hasNext {
            let $osInstance = $enumerator | dn get "Current"
            
            print $"OS Name: (get-cim-property $osInstance 'Caption')"
            print $"Version: (get-cim-property $osInstance 'Version')"
            print $"Architecture: (get-cim-property $osInstance 'OSArchitecture')"
            print $"Install Date: (get-cim-property $osInstance 'InstallDate')"
            print $"Last Boot: (get-cim-property $osInstance 'LastBootUpTime')"
            
            # Memory information (convert from KB to GB)
            let $totalMemoryKB = get-cim-property $osInstance "TotalVisibleMemorySize"
            let $freeMemoryKB = get-cim-property $osInstance "FreePhysicalMemory"
            
            if ($totalMemoryKB != "N/A" and $totalMemoryKB != "Error reading property") {
                let $totalMemoryGB = ($totalMemoryKB | into float) / 1024 / 1024
                let $freeMemoryGB = ($freeMemoryKB | into float) / 1024 / 1024
                let $usedMemoryGB = $totalMemoryGB - $freeMemoryGB
                
                print $"Total Memory: ($totalMemoryGB | math round --precision 2) GB"
                print $"Free Memory: ($freeMemoryGB | math round --precision 2) GB"
                print $"Used Memory: ($usedMemoryGB | math round --precision 2) GB"
            }
        }
    } catch {
        print $"❌ Error querying OS information: ($in)"
    }
    
    # === Computer System Information ===
    print "\n=== Computer System Information ==="
    try {
        let $csQuery = "SELECT * FROM Win32_ComputerSystem"
        let $csInstances = $session | dn call "QueryInstances" "root/cimv2" "WQL" $csQuery
        let $csEnum = $csInstances | dn call "GetEnumerator"
        let $csHasNext = $csEnum | dn call "MoveNext"
        
        if $csHasNext {
            let $csInstance = $csEnum | dn get "Current"
            
            print $"Computer Name: (get-cim-property $csInstance 'Name')"
            print $"Manufacturer: (get-cim-property $csInstance 'Manufacturer')"
            print $"Model: (get-cim-property $csInstance 'Model')"
            print $"Domain: (get-cim-property $csInstance 'Domain')"
            print $"Workgroup: (get-cim-property $csInstance 'Workgroup')"
            print $"Username: (get-cim-property $csInstance 'UserName')"
        }
    } catch {
        print $"❌ Error querying computer system: ($in)"
    }
    
    # === Processor Information ===
    print "\n=== Processor Information ==="
    try {
        let $cpuQuery = "SELECT * FROM Win32_Processor"
        let $cpuInstances = $session | dn call "QueryInstances" "root/cimv2" "WQL" $cpuQuery
        let $cpuEnum = $cpuInstances | dn call "GetEnumerator"
        
        let $cpuCount = 0
        while ($cpuEnum | dn call "MoveNext") {
            let $cpuInstance = $cpuEnum | dn get "Current"
            let $cpuCount = $cpuCount + 1
            
            print $"CPU ($cpuCount):"
            print $"  Name: (get-cim-property $cpuInstance 'Name')"
            print $"  Manufacturer: (get-cim-property $cpuInstance 'Manufacturer')"
            print $"  Cores: (get-cim-property $cpuInstance 'NumberOfCores')"
            print $"  Logical Processors: (get-cim-property $cpuInstance 'NumberOfLogicalProcessors')"
            print $"  Max Clock Speed: (get-cim-property $cpuInstance 'MaxClockSpeed') MHz"
            print $"  Current Load: (get-cim-property $cpuInstance 'LoadPercentage')%"
        }
    } catch {
        print $"❌ Error querying processor info: ($in)"
    }
    
    # === Disk Information ===
    print "\n=== Disk Information ==="
    try {
        let $diskQuery = "SELECT * FROM Win32_LogicalDisk WHERE DriveType = 3"
        let $diskInstances = $session | dn call "QueryInstances" "root/cimv2" "WQL" $diskQuery
        let $diskEnum = $diskInstances | dn call "GetEnumerator"
        
        while ($diskEnum | dn call "MoveNext") {
            let $diskInstance = $diskEnum | dn get "Current"
            let $driveLetter = get-cim-property $diskInstance "DeviceID"
            
            print $"Drive ($driveLetter):"
            print $"  Label: (get-cim-property $diskInstance 'VolumeName')"
            print $"  File System: (get-cim-property $diskInstance 'FileSystem')"
            
            # Convert bytes to GB
            let $totalSizeBytes = get-cim-property $diskInstance "Size"
            let $freeSizeBytes = get-cim-property $diskInstance "FreeSpace"
            
            if ($totalSizeBytes != "N/A" and $totalSizeBytes != "Error reading property") {
                let $totalSizeGB = ($totalSizeBytes | into float) / 1024 / 1024 / 1024
                let $freeSizeGB = ($freeSizeBytes | into float) / 1024 / 1024 / 1024
                let $usedSizeGB = $totalSizeGB - $freeSizeGB
                let $usedPercent = ($usedSizeGB / $totalSizeGB) * 100
                
                print $"  Total Size: ($totalSizeGB | math round --precision 2) GB"
                print $"  Free Space: ($freeSizeGB | math round --precision 2) GB"
                let $usedPercentRounded = $usedPercent | math round --precision 1
                print $"  Used Space: ($usedSizeGB | math round --precision 2) GB ($usedPercentRounded%)"
            }
            print ""
        }
    } catch {
        print $"❌ Error querying disk information: ($in)"
    }
    
    # === Network Interface Information ===
    print "\n=== Network Interface Information ==="
    try {
        let $netQuery = "SELECT * FROM Win32_NetworkAdapterConfiguration WHERE IPEnabled = True"
        let $netInstances = $session | dn call "QueryInstances" "root/cimv2" "WQL" $netQuery
        let $netEnum = $netInstances | dn call "GetEnumerator"
        
        let $adapterCount = 0
        while ($netEnum | dn call "MoveNext") {
            let $netInstance = $netEnum | dn get "Current"
            let $adapterCount = $adapterCount + 1
            
            print $"Network Adapter ($adapterCount):"
            print $"  Description: (get-cim-property $netInstance 'Description')"
            print $"  MAC Address: (get-cim-property $netInstance 'MACAddress')"
            print $"  DHCP Enabled: (get-cim-property $netInstance 'DHCPEnabled')"
            
            # IP addresses are arrays, so this is simplified
            let $ipAddresses = get-cim-property $netInstance "IPAddress"
            print $"  IP Addresses: ($ipAddresses)"
            print ""
        }
    } catch {
        print $"❌ Error querying network information: ($in)"
    }
    
    # === Running Services (Top 10) ===
    print "\n=== Running Services (Top 10) ==="
    try {
        let $serviceQuery = "SELECT * FROM Win32_Service WHERE State = 'Running'"
        let $serviceInstances = $session | dn call "QueryInstances" "root/cimv2" "WQL" $serviceQuery
        let $serviceEnum = $serviceInstances | dn call "GetEnumerator"
        
        let $serviceCount = 0
        while ($serviceEnum | dn call "MoveNext") {
            if $serviceCount >= 10 {
                break
            }
            let $serviceInstance = $serviceEnum | dn get "Current"
            let $serviceName = get-cim-property $serviceInstance "Name"
            let $displayName = get-cim-property $serviceInstance "DisplayName"
            let $startMode = get-cim-property $serviceInstance "StartMode"
            
            print $"• ($serviceName) - ($displayName) [($startMode)]"
            let $serviceCount = $serviceCount + 1
        }
        print $"... and more (showing first 10)"
    } catch {
        print $"❌ Error querying services: ($in)"
    }
    
    # Clean up
    print "\n=== Cleaning Up ==="
    $session | dn call "Close"
    print "✓ CIM session closed"
    
} catch {
    print $"❌ Critical error: ($in)"
}

print "\n=== System Information Report Complete ===" 