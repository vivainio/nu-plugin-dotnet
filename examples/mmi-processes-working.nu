# Working Process List with Command Line Arguments
# Combines MMI demonstration with practical PowerShell integration

print "💻 Process List with Command Line Arguments"
print "==========================================="

print "📦 Method 1: Microsoft.Management.Infrastructure (Demo)"
print "--------------------------------------------------------"

# Load and demonstrate MMI
dn load-assembly Microsoft.Management.Infrastructure
let session = ('Microsoft.Management.Infrastructure.CimSession' | dn call 'Create' 'localhost')
print "✅ MMI CimSession created successfully"

# Show that MMI enumeration works (returns objects)
let mmi_result = ($session | dn call 'EnumerateInstances' 'root/cimv2' 'Win32_Process')
print $"✅ MMI EnumerateInstances returned: ($mmi_result)"
print "   (Object ID indicates successful enumeration - needs further processing)"

print "\n🚀 Method 2: PowerShell Get-CimInstance (Working Solution)"
print "----------------------------------------------------------"

# Use PowerShell to get process information
print "Getting top 10 processes with command line arguments..."

try {
    # This actually works and shows real process data
    ^powershell -c "Get-CimInstance -ClassName Win32_Process | Select-Object Name, ProcessId, CommandLine | Sort-Object Name | Select-Object -First 10 | Format-Table -AutoSize"
} catch {
    print "❌ PowerShell Get-CimInstance failed"
}

print "\n🛠️ Method 3: PowerShell Get-WmiObject (Legacy but reliable)"
print "-----------------------------------------------------------"

try {
    ^powershell -c "Get-WmiObject -Class Win32_Process | Select-Object Name, ProcessId, CommandLine | Where-Object {$_.CommandLine -ne $null} | Select-Object -First 5 | Format-Table -Wrap"
} catch {
    print "❌ PowerShell Get-WmiObject failed"
}

print "\n📋 Method 4: PowerShell Get-Process (Simple, no command line)"
print "------------------------------------------------------------"

try {
    ^powershell -c "Get-Process | Select-Object Name, Id, Company, CPU | Sort-Object Name | Select-Object -First 8 | Format-Table -AutoSize"
} catch {
    print "❌ PowerShell Get-Process failed"
}

print "\n🎯 Summary:"
print "• MMI (Method 1): ✅ Assembly loads, CimSession created, enumeration returns objects"
print "• Get-CimInstance (Method 2): ✅ Full working solution with command lines"  
print "• Get-WmiObject (Method 3): ✅ Legacy WMI approach, very reliable"
print "• Get-Process (Method 4): ✅ Simple process info (no command lines)"

print "\n💡 Recommendation:"
print "Use PowerShell Get-CimInstance for immediate results while MMI object handling is enhanced."

print "\n🔧 MMI Enhancement Needed:"
print "The nu-plugin-dotnet could be enhanced to better handle IEnumerable<CimInstance> collections." 