# Nu Plugin DotNet - Microsoft.Management.Infrastructure Simple Demo
# A clean, simple example using Microsoft.Management.Infrastructure
# Prerequisites: register ./nu_plugin_dotnet.exe

print "=== Microsoft.Management.Infrastructure Simple Demo ==="

# Load the Microsoft.Management.Infrastructure assembly
print "Loading Microsoft.Management.Infrastructure..."
try {
    dn load-assembly "Microsoft.Management.Infrastructure"
    print "✓ Assembly loaded successfully"
} catch {
    print "❌ Failed to load Microsoft.Management.Infrastructure"
    print "  This example requires Windows with WMI support"
    exit 1
}

# Create CIM session
print "\nCreating CIM session..."
try {
    let $session = dn new "Microsoft.Management.Infrastructure.CimSession" --args ["localhost"]
    print "✓ CIM session created"
    
    # === Basic OS Information ===
    print "\n=== Operating System Information ==="
    try {
        let $osQuery = "SELECT Caption, Version, OSArchitecture FROM Win32_OperatingSystem"
        let $osInstances = $session | dn call "QueryInstances" "root/cimv2" "WQL" $osQuery
        
        let $enumerator = $osInstances | dn call "GetEnumerator"
        let $hasNext = $enumerator | dn call "MoveNext"
        
        if $hasNext {
            let $osInstance = $enumerator | dn get "Current"
            let $properties = $osInstance | dn get "CimInstanceProperties"
            
            let $captionProp = $properties | dn get "Item" "Caption"
            let $versionProp = $properties | dn get "Item" "Version"
            let $archProp = $properties | dn get "Item" "OSArchitecture"
            
            let $caption = $captionProp | dn get "Value"
            let $version = $versionProp | dn get "Value"
            let $arch = $archProp | dn get "Value"
            
            print $"OS Name: ($caption)"
            print $"Version: ($version)"
            print $"Architecture: ($arch)"
        }
    } catch {
        print $"❌ Error querying OS information: ($in)"
    }
    
    # === Computer System Information ===
    print "\n=== Computer System Information ==="
    try {
        let $csQuery = "SELECT Name, Manufacturer, Model FROM Win32_ComputerSystem"
        let $csInstances = $session | dn call "QueryInstances" "root/cimv2" "WQL" $csQuery
        let $csEnum = $csInstances | dn call "GetEnumerator"
        let $csHasNext = $csEnum | dn call "MoveNext"
        
        if $csHasNext {
            let $csInstance = $csEnum | dn get "Current"
            let $csProperties = $csInstance | dn get "CimInstanceProperties"
            
            let $nameProp = $csProperties | dn get "Item" "Name"
            let $mfgProp = $csProperties | dn get "Item" "Manufacturer"
            let $modelProp = $csProperties | dn get "Item" "Model"
            
            let $name = $nameProp | dn get "Value"
            let $manufacturer = $mfgProp | dn get "Value"
            let $model = $modelProp | dn get "Value"
            
            print $"Computer Name: ($name)"
            print $"Manufacturer: ($manufacturer)"
            print $"Model: ($model)"
        }
    } catch {
        print $"❌ Error querying computer system: ($in)"
    }
    
    # === Processor Information ===
    print "\n=== Processor Information ==="
    try {
        let $cpuQuery = "SELECT Name, Manufacturer, NumberOfCores FROM Win32_Processor"
        let $cpuInstances = $session | dn call "QueryInstances" "root/cimv2" "WQL" $cpuQuery
        let $cpuEnum = $cpuInstances | dn call "GetEnumerator"
        let $cpuHasNext = $cpuEnum | dn call "MoveNext"
        
        if $cpuHasNext {
            let $cpuInstance = $cpuEnum | dn get "Current"
            let $cpuProperties = $cpuInstance | dn get "CimInstanceProperties"
            
            let $cpuNameProp = $cpuProperties | dn get "Item" "Name"
            let $cpuMfgProp = $cpuProperties | dn get "Item" "Manufacturer"
            let $coresProp = $cpuProperties | dn get "Item" "NumberOfCores"
            
            let $cpuName = $cpuNameProp | dn get "Value"
            let $cpuMfg = $cpuMfgProp | dn get "Value"
            let $cores = $coresProp | dn get "Value"
            
            print $"CPU Name: ($cpuName)"
            print $"Manufacturer: ($cpuMfg)"
            print $"Number of Cores: ($cores)"
        }
    } catch {
        print $"❌ Error querying processor info: ($in)"
    }
    
    # === List Logical Drives ===
    print "\n=== Logical Drives ==="
    try {
        let $diskQuery = "SELECT DeviceID, VolumeName, FileSystem FROM Win32_LogicalDisk WHERE DriveType = 3"
        let $diskInstances = $session | dn call "QueryInstances" "root/cimv2" "WQL" $diskQuery
        let $diskEnum = $diskInstances | dn call "GetEnumerator"
        
        while ($diskEnum | dn call "MoveNext") {
            let $diskInstance = $diskEnum | dn get "Current"
            let $diskProperties = $diskInstance | dn get "CimInstanceProperties"
            
            let $deviceProp = $diskProperties | dn get "Item" "DeviceID"
            let $labelProp = $diskProperties | dn get "Item" "VolumeName"
            let $fsProp = $diskProperties | dn get "Item" "FileSystem"
            
            let $deviceId = $deviceProp | dn get "Value"
            let $volumeName = $labelProp | dn get "Value"
            let $fileSystem = $fsProp | dn get "Value"
            
            print $"Drive: ($deviceId) - Label: ($volumeName) - FileSystem: ($fileSystem)"
        }
    } catch {
        print $"❌ Error querying disk information: ($in)"
    }
    
    # === Running Services (First 5) ===
    print "\n=== Running Services (First 5) ==="
    try {
        let $serviceQuery = "SELECT Name, DisplayName, State FROM Win32_Service WHERE State = 'Running'"
        let $serviceInstances = $session | dn call "QueryInstances" "root/cimv2" "WQL" $serviceQuery
        let $serviceEnum = $serviceInstances | dn call "GetEnumerator"
        
        let $count = 0
        while ($serviceEnum | dn call "MoveNext") {
            if $count >= 5 {
                break
            }
            
            let $serviceInstance = $serviceEnum | dn get "Current"
            let $serviceProperties = $serviceInstance | dn get "CimInstanceProperties"
            
            let $nameProp = $serviceProperties | dn get "Item" "Name"
            let $displayProp = $serviceProperties | dn get "Item" "DisplayName"
            
            let $serviceName = $nameProp | dn get "Value"
            let $displayName = $displayProp | dn get "Value"
            
            print $"• ($serviceName) - ($displayName)"
            let $count = $count + 1
        }
        print "... and more services running"
    } catch {
        print $"❌ Error querying services: ($in)"
    }
    
    # === Working with CIM Classes ===
    print "\n=== CIM Class Information ==="
    try {
        let $class = $session | dn call "GetClass" "root/cimv2" "Win32_Service"
        let $className = $class | dn get "CimSystemProperties" | dn get "ClassName"
        print $"Retrieved class information for: ($className)"
        
        # Get class properties count
        let $properties = $class | dn get "CimClassProperties"
        let $propCount = $properties | dn get "Count"
        print $"Number of properties in Win32_Service: ($propCount)"
    } catch {
        print $"❌ Error working with CIM classes: ($in)"
    }
    
    # Clean up
    print "\n=== Cleaning Up ==="
    $session | dn call "Close"
    print "✓ CIM session closed"
    
} catch {
    print $"❌ Critical error: ($in)"
}

print "\n=== Demo Complete ==="
print "\nThis example demonstrates:"
print "• Loading Microsoft.Management.Infrastructure with dn load-library"
print "• Creating CIM sessions for local WMI access"
print "• Executing WQL queries to retrieve system information"
print "• Accessing CIM instance properties safely"
print "• Iterating through query result collections"
print "• Working with CIM classes and metadata"
print "• Proper resource cleanup"

print "\n💡 Use Cases:"
print "• System monitoring and inventory"
print "• Service management and monitoring"
print "• Hardware information gathering"
print "• Performance data collection"
print "• System configuration queries" 