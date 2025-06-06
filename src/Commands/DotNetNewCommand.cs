using System.Reflection;
using NuPluginDotNet.DotNet;
using NuPluginDotNet.Types;

namespace NuPluginDotNet.Commands;

public class DotNetNewCommand : BaseCommand
{
    public DotNetNewCommand(
        ObjectManager objectManager,
        AssemblyManager assemblyManager,
        ValueConverter valueConverter) : base(objectManager, assemblyManager, valueConverter)
    {
    }

    public override async Task<PluginValue> ExecuteAsync(CommandArgs args)
    {
        try
        {
            // Get type name from first positional argument
            var typeName = args.GetPositionalString(0);
            
            // Optional assembly parameter
            var assemblyPath = args.GetOptionalString("assembly");
            
            // Constructor arguments
            var constructorArgs = args.GetOptionalList("args") ?? new List<PluginValue>();
            
            // Load assembly if specified
            if (!string.IsNullOrEmpty(assemblyPath))
            {
                AssemblyManager.LoadAssembly(assemblyPath);
            }

            // Resolve the type
            var type = AssemblyManager.FindType(typeName);
            if (type == null)
            {
                return CreateError($"Type '{typeName}' not found. Make sure the assembly is loaded.");
            }

            // Find matching constructor
            var constructors = type.GetConstructors();
            ConstructorInfo? matchingConstructor = null;
            object?[]? convertedArgs = null;

            // Try to find a matching constructor
            foreach (var constructor in constructors)
            {
                var parameters = constructor.GetParameters();
                
                // Check if parameter count matches
                if (parameters.Length != constructorArgs.Count)
                    continue;

                try
                {
                    // Try to convert arguments
                    convertedArgs = new object?[parameters.Length];
                    for (int i = 0; i < parameters.Length; i++)
                    {
                        convertedArgs[i] = ValueConverter.ConvertToClr(constructorArgs[i], parameters[i].ParameterType);
                    }
                    
                    matchingConstructor = constructor;
                    break;
                }
                catch
                {
                    // Continue to next constructor
                    continue;
                }
            }

            if (matchingConstructor == null)
            {
                // Try parameterless constructor if no args provided
                if (constructorArgs.Count == 0)
                {
                    var parameterlessConstructor = type.GetConstructor(Type.EmptyTypes);
                    if (parameterlessConstructor != null)
                    {
                        matchingConstructor = parameterlessConstructor;
                        convertedArgs = Array.Empty<object>();
                    }
                }
                
                if (matchingConstructor == null)
                {
                    var availableConstructors = string.Join(", ", constructors.Select(c => 
                        $"({string.Join(", ", c.GetParameters().Select(p => p.ParameterType.Name))})"));
                    return CreateError($"No matching constructor found for {typeName}. Available constructors: {availableConstructors}");
                }
            }

            // Create the instance
            var instance = matchingConstructor.Invoke(convertedArgs);
            
            // Register the object for lifetime management
            var objectId = ObjectManager.RegisterObject(instance!);
            
            // Return custom object reference
            return PluginValue.Custom(objectId, type.FullName ?? type.Name);
        }
        catch (Exception ex)
        {
            return CreateError($"Failed to create object: {ex.Message}", ex);
        }
    }
} 