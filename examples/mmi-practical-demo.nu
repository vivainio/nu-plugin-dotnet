# Microsoft.Management.Infrastructure - Practical WMI Operations
# Demonstrates real-world usage of MMI for system management

print "🔧 Microsoft.Management.Infrastructure - Practical Demo"
print "========================================================"

# Load MMI
print "📦 Loading Microsoft.Management.Infrastructure..."
dn load-assembly Microsoft.Management.Infrastructure

# Create session
print "🔗 Creating CimSession to localhost..."
let session = ('Microsoft.Management.Infrastructure.CimSession' | dn call 'Create' 'localhost')
print $"✅ Session created: ($session)"

print "\n📊 Assembly Information:"
dn assemblies | where name =~ 'Infrastructure' | select name version typeCount

print "\n🏗️  Key MMI Classes Available:"
let key_classes = [
    "CimSession"
    "CimInstance" 
    "CimClass"
    "CimException"
    "CimMethodResult"
]

$key_classes | each { |class|
    let full_name = $"Microsoft.Management.Infrastructure.($class)"
    print $"  ✓ ($class)"
    dn members $full_name | where memberType == 'Method' | where isPublic == true | length | each { |count|
        print $"    └─ ($count) public methods"
    }
}

print "\n🔍 CimSession Query Methods:"
dn members 'Microsoft.Management.Infrastructure.CimSession' 
| where memberType == 'Method' 
| where name =~ '(Query|Get|Enumerate)' 
| where isPublic == true
| select name returnType
| first 5

print "\n💡 Usage Notes:"
print "• CimSession.Create() - Connect to CIM server"
print "• GetInstance() - Query single WMI instance"  
print "• QueryInstances() - Query multiple instances"
print "• EnumerateInstances() - Enumerate class instances"
print "• InvokeMethod() - Call WMI methods"

print "\n🎯 Next Steps:"
print "Use the session object to:"
print "1. Query Win32_OperatingSystem for OS info"
print "2. Enumerate Win32_Process for running processes"
print "3. Get Win32_LogicalDisk for disk information"
print "4. Query Win32_Service for system services"

print "\n✨ Microsoft.Management.Infrastructure is ready for use!" 