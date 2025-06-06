# Microsoft.Management.Infrastructure - System Information Example
# This demonstrates practical usage of MMI for system information gathering

print "=== Microsoft.Management.Infrastructure Demo ==="
print "Loading MMI assembly..."

# Load the assembly
dn load-assembly Microsoft.Management.Infrastructure

print "Assembly loaded successfully!"
print "Available MMI types:"
dn types 'Microsoft.Management.Infrastructure' | where name =~ 'Session' | select name fullName

print "\n=== Creating CimSession ==="
let session = ('Microsoft.Management.Infrastructure.CimSession' | dn call 'Create' 'localhost')
print $"Session created: ($session)"

print "\n=== Available CimSession Methods ==="
dn members 'Microsoft.Management.Infrastructure.CimSession' 
| where memberType == 'Method' 
| where isPublic == true 
| select name returnType isStatic
| first 10

print "\n=== MMI Assembly Information ==="
dn assemblies | where name =~ 'Infrastructure'

print "\n=== Available CIM Classes (sample) ==="
print "CimClass members:"
dn members 'Microsoft.Management.Infrastructure.CimClass' 
| where memberType == 'Property' 
| select name propertyType
| first 10

print "\n=== Success! ==="
print "Microsoft.Management.Infrastructure is fully functional!"
print "You can now use CIM/WMI operations through the modern MMI API."
print ""
print "Key classes available:"
print "- CimSession: For connecting to CIM servers"
print "- CimInstance: For working with CIM instances"  
print "- CimClass: For working with CIM class definitions"
print "- CimMethodResult: For method invocation results" 