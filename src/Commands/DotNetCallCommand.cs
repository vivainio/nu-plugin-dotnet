using System.Reflection;

using NuPluginDotNet.DotNet;
using NuPluginDotNet.Types;

namespace NuPluginDotNet.Commands;

public class DotNetCallCommand : BaseCommand
{
    public DotNetCallCommand(
        ObjectManager objectManager,
        AssemblyManager assemblyManager,
        ValueConverter valueConverter) : base(objectManager, assemblyManager, valueConverter)
    {
    }

    public override async Task<PluginValue> ExecuteAsync(CommandArgs args)
    {
        try
        {
            // Method name from first positional argument
            var methodName = args.GetPositionalString(0);
            
            // Method arguments from remaining positional parameters
            var methodArgs = args.Positional.Skip(1).ToList();
            
            // Determine target (object or type for static calls)
            object? target = null;
            Type targetType;
            bool isStatic = false;

            if (args.Input?.IsCustom == true)
            {
                // Instance method call
                var objectId = args.Input.GetObjectId();
                Console.Error.WriteLine($"[DEBUG] Custom object - ObjectId: {objectId}");
                target = ObjectManager.GetObject(objectId);
                Console.Error.WriteLine($"[DEBUG] Retrieved target object: {target?.GetType()?.Name ?? "null"}");
                if (target == null)
                {
                    return CreateError($"Object with ID '{objectId}' not found or has been garbage collected.");
                }
                targetType = target.GetType();
            }
            else if (args.Input?.IsString == true)
            {
                var inputString = args.Input.AsString();
                
                // First try to treat it as a type name for static calls
                targetType = AssemblyManager.FindType(inputString);
                if (targetType != null)
                {
                    // It's a valid type name, use for static calls
                    isStatic = true;
                }
                else
                {
                    // Not a type name, treat as string instance for instance method calls
                    target = inputString;
                    targetType = typeof(string);
                    isStatic = false;
                }
            }
            else
            {
                return CreateError("Invalid target. Provide an object instance or type name for static calls.");
            }

            // Find matching method
            var methods = targetType.GetMethods(BindingFlags.Public | (isStatic ? BindingFlags.Static : BindingFlags.Instance));
            var candidateMethods = methods.Where(m => m.Name.Equals(methodName, StringComparison.OrdinalIgnoreCase)).ToArray();
            
            if (candidateMethods.Length == 0)
            {
                return CreateError($"Method '{methodName}' not found on type '{targetType.Name}'");
            }

            // Try to find matching method by parameter count and types
            MethodInfo? matchingMethod = null;
            object?[]? convertedArgs = null;

            foreach (var method in candidateMethods)
            {
                var parameters = method.GetParameters();
                
                if (parameters.Length != methodArgs.Count)
                    continue;

                try
                {
                    // Try to convert arguments
                    convertedArgs = new object?[parameters.Length];
                    for (int i = 0; i < parameters.Length; i++)
                    {
                        convertedArgs[i] = ValueConverter.ConvertToClr(methodArgs[i], parameters[i].ParameterType);
                    }
                    
                    matchingMethod = method;
                    break;
                }
                catch
                {
                    continue;
                }
            }

            if (matchingMethod == null)
            {
                // Try with no parameters if no args provided
                if (methodArgs.Count == 0)
                {
                    matchingMethod = candidateMethods.FirstOrDefault(m => m.GetParameters().Length == 0);
                    convertedArgs = Array.Empty<object>();
                }
                
                if (matchingMethod == null)
                {
                    var availableMethods = string.Join(", ", candidateMethods.Select(m => 
                        $"{m.Name}({string.Join(", ", m.GetParameters().Select(p => p.ParameterType.Name))})"));
                    return CreateError($"No matching overload found for {methodName}. Available overloads: {availableMethods}");
                }
            }

            // Special handling for Console.WriteLine to avoid stdout interference
            if (targetType == typeof(Console) && methodName.Equals("WriteLine", StringComparison.OrdinalIgnoreCase))
            {
                // Redirect Console.WriteLine to stderr to avoid interfering with plugin protocol
                var message = convertedArgs?.Length > 0 ? convertedArgs[0]?.ToString() ?? "" : "";
                Console.Error.WriteLine($"[Console.WriteLine]: {message}");
                return PluginValue.Null(); // Return void/null for Console.WriteLine
            }
            
            // Invoke the method
            var result = matchingMethod.Invoke(target, convertedArgs);
            
            // Handle async methods
            if (IsAsyncMethod(matchingMethod))
            {
                result = await UnwrapAsyncResult(result);
            }

            // Logger.LogInformation("Called method {MethodName} on {TypeName}", methodName, targetType.Name);
            
            // Convert result back to PluginValue
            if (result == null)
            {
                return PluginValue.Null();
            }

            // If the result is a complex object, register it
            var resultType = result.GetType();
            if (IsComplexType(resultType))
            {
                var objectId = ObjectManager.RegisterObject(result);
                return PluginValue.Custom(objectId, resultType.FullName ?? resultType.Name);
            }

            // Convert simple types directly
            return ValueConverter.ConvertFromClr(result);
        }
        catch (Exception ex)
        {
            return CreateError($"Failed to call method: {ex.Message}", ex);
        }
    }

    private static bool IsComplexType(Type type)
    {
        return !type.IsPrimitive && 
               type != typeof(string) && 
               type != typeof(decimal) &&
               !type.IsEnum;
    }
} 