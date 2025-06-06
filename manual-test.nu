# Manual test commands for nu-plugin-dotnet
# Run these commands one by one in nushell

# 1. Add the plugin
# plugin add ./bin/Release/net8.0/win-x64/nu_plugin_dotnet.exe

# 2. Test DateTime creation
# let $now = dn new "System.DateTime" --args [2023, 12, 25]
# print $now

# 3. Test method call
# let $tomorrow = $now | dn call "AddDays" 1
# print $tomorrow

# 4. Test property access
# let $year = $now | dn get "Year"
# print $year

# 5. Test static method
# let $max = "System.Math" | dn call "Max" 10 20
# print $max

# 6. Test list creation
# let $list = dn new "System.Collections.Generic.List[string]"
# $list | dn call "Add" "Hello"
# $list | dn call "Add" "World"
# let $count = $list | dn get "Count"
# print $count

# 7. Test assemblies listing
# dn assemblies | first 5

# 8. Test types in assembly
# dn types "System.Private.CoreLib" | first 3

# 9. Test GUID
# let $guid = dn new "System.Guid"
# print $guid 