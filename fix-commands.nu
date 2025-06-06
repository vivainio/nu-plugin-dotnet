#!/usr/bin/env nu

# Fix all command files to remove ILogger dependency

let command_files = [
    "src/Commands/DotNetCallCommand.cs",
    "src/Commands/DotNetGetCommand.cs", 
    "src/Commands/DotNetSetCommand.cs",
    "src/Commands/DotNetLoadAssemblyCommand.cs",
    "src/Commands/DotNetAssembliesCommand.cs",
    "src/Commands/DotNetTypesCommand.cs",
    "src/Commands/DotNetMembersCommand.cs"
]

$command_files | each { |file|
    print $"Fixing ($file)..."
    
    # Read the file
    let content = (open $file)
    
    # Remove ILogger import
    let fixed1 = ($content | str replace "using Microsoft.Extensions.Logging;" "")
    
    # Fix constructor - remove ILogger parameter 
    let fixed2 = ($fixed1 | str replace ", ILogger logger)" ")")
    
    # Fix base constructor call
    let fixed3 = ($fixed2 | str replace ": base(objectManager, assemblyManager, valueConverter, logger)" ": base(objectManager, assemblyManager, valueConverter)")
    
    # Remove Logger calls (simple approach)
    let fixed4 = ($fixed3 | str replace "Logger.LogInformation" "// Logger.LogInformation")
    
    # Save the fixed file
    $fixed4 | save $file --force
    
    print $"Fixed ($file)"
}

print "All command files fixed!" 