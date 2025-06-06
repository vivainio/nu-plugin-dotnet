# Microsoft.Management.Infrastructure - Process List with Command Lines
# Query Win32_Process to get running processes with command line arguments

print "🔍 Getting Process List with Command Line Arguments"
print "=================================================="

# Load MMI assembly
print "📦 Loading Microsoft.Management.Infrastructure..."
dn load-assembly Microsoft.Management.Infrastructure

# Create CIM session
print "🔗 Creating CimSession..."
let session = ('Microsoft.Management.Infrastructure.CimSession' | dn call 'Create' 'localhost')

print "✅ Session created successfully!"

# Let's explore what methods are available for querying instances
print "\n🔍 Available CimSession query methods:"
dn members 'Microsoft.Management.Infrastructure.CimSession' 
| where memberType == 'Method' 
| where name =~ '(Query|Enumerate|Get)'
| where isPublic == true
| select name returnType
| first 8

print "\n💡 Attempting to enumerate Win32_Process instances..."

# Try to enumerate processes using EnumerateInstances
print "Method 1: Using EnumerateInstances"
try {
    let processes = ($session | dn call 'EnumerateInstances' 'root/cimv2' 'Win32_Process')
    print $"Result: ($processes)"
} catch {
    print "❌ EnumerateInstances method failed"
}

print "\nMethod 2: Check available overloads for EnumerateInstances"
dn members 'Microsoft.Management.Infrastructure.CimSession'
| where name == 'EnumerateInstances'
| where memberType == 'Method'

print "\n🎯 Alternative approach using PowerShell cmdlets:"
print "Since direct CIM instance enumeration may need specific parameters,"
print "here's how you can get process info with command lines:"

print "\nUsing Get-CimInstance (if available):"
print "Get-CimInstance -ClassName Win32_Process | Select-Object Name, ProcessId, CommandLine"

print "\nUsing Get-WmiObject (legacy):"
print "Get-WmiObject -Class Win32_Process | Select-Object Name, ProcessId, CommandLine"

print "\n📝 Key Process Properties Available:"
print "• Name - Process name"
print "• ProcessId - PID"
print "• CommandLine - Full command with arguments"
print "• ExecutablePath - Path to executable"
print "• CreationDate - When process started"
print "• WorkingSetSize - Memory usage"
print "• ParentProcessId - Parent PID"

print "\n✨ MMI Session is ready for advanced CIM operations!" 