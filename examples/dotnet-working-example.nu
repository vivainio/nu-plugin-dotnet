# Nu Plugin DotNet - Practical Working Example
# This demonstrates what actually works with the current plugin
# 
# Prerequisites: plugin add ./bin/Debug/net8.0/win-x64/nu_plugin_dotnet.exe

print "=== Nu Plugin DotNet - Working Example ==="

# Show currently loaded assemblies
print "\n=== Available .NET Assemblies ==="
dn assemblies | select name version | first 10

# Explore System.Console assembly
print "\n=== System.Console Types ==="
dn types "System.Console" | select name fullName isClass

# Show Console class members  
print "\n=== Console Class Members ==="
dn members "System.Console" | select name memberType | first 10

# Explore System.Runtime assembly
print "\n=== System.Runtime Types (first 10) ==="
dn types "System.Runtime" | select name fullName | first 10

# Show DateTime members
print "\n=== DateTime Members (first 10) ==="
dn members "System.DateTime" | select name memberType | first 10

# Explore System.Text.Json assembly
print "\n=== JSON-related Types ==="
dn types "System.Text.Json" | where name =~ Json | select name fullName

# Show what's in System.Collections
print "\n=== Collection Types ==="
dn types "System.Collections" | select name isClass isInterface | first 8

print "\n=== Plugin Capabilities Summary ==="
print "✅ List loaded assemblies with 'dn assemblies'"
print "✅ Explore types in assemblies with 'dn types <assembly>'"
print "✅ Examine class/interface members with 'dn members <type>'"
print "✅ Filter and analyze .NET type information"
print "❌ Creating object instances has syntax issues"
print "❌ Microsoft.Management.Infrastructure causes stack overflow"
print "❌ Some external assemblies may not load properly"

print "\n=== Use Cases This Plugin Enables ==="
print "• .NET Assembly exploration and documentation"
print "• Type discovery and API surface analysis" 
print "• Finding available methods and properties"
print "• Understanding .NET type hierarchies"
print "• Investigating loaded assembly dependencies"

print "\n=== Alternative Approaches for WMI/System Management ==="
print "For Windows system management, consider:"
print "• PowerShell commands: Get-WmiObject, Get-CimInstance"
print "• Direct PowerShell integration in Nushell scripts"
print "• System.Management classes (if loadable)"
print "• Command-line tools: wmic, systeminfo, etc."

print "\n=== Plugin Command Reference ==="
print "dn assemblies          - List all loaded .NET assemblies"
print "dn load-assembly <name> - Load a .NET assembly by name/path"
print "dn types <assembly>    - List types in a specific assembly"
print "dn members <type>      - Show members of a specific type"
print "dn new <type>          - Create instance (currently has issues)"
print "dn call <method>       - Call methods (requires working objects)"
print "dn get <property>      - Get properties (requires working objects)" 
print "dn set <property>      - Set properties (requires working objects)"

print "\n=== Example Workflow: Exploring a .NET Assembly ==="
print "1. dn assemblies | where name =~ YourAssembly"
print "2. dn types 'AssemblyName' | where isClass == true"
print "3. dn members 'Namespace.ClassName' | where memberType == Method"
print "4. Use the discovered information in your applications"

print "\n=== Demo Complete ==="
print "The nu-plugin-dotnet provides excellent .NET type exploration capabilities!" 