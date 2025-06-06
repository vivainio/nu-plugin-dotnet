# Microsoft.Management.Infrastructure Test Script
# This script demonstrates using Microsoft.Management.Infrastructure with nu-plugin-dotnet

print "Loading Microsoft.Management.Infrastructure..."
dn load-assembly Microsoft.Management.Infrastructure

print "Creating CimSession..."
let session = ('Microsoft.Management.Infrastructure.CimSession' | dn call 'Create' 'localhost')

print "Session created successfully!"
print $"Session object: ($session)"

print "\nTesting CimSession members..."
dn members 'Microsoft.Management.Infrastructure.CimSession' | where memberType == 'Method' | where name =~ 'GetInstance' | first 5

print "\nSuccess! Microsoft.Management.Infrastructure is working with nu-plugin-dotnet!" 