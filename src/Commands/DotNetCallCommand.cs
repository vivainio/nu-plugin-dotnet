using System.Reflection;
using Microsoft.Extensions.Logging;
using NuPluginDotNet.DotNet;
using NuPluginDotNet.Types;

namespace NuPluginDotNet.Commands;

public class DotNetCallCommand : BaseCommand
{
    public DotNetCallCommand(
        ObjectManager objectManager,
        AssemblyManager assemblyManager,
        ValueConverter valueConverter,
        ILogger logger) : base(objectManager, assemblyManager, valueConverter, logger)
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
                target = ObjectManager.GetObject(objectId);
                targetType = target.GetType();
            }
            else if (args.Input?.IsString == true)
            {
                // Static method call with type name
                var typeName = args.Input.AsString();
                targetType = AssemblyManager.FindType(typeName);
                if (targetType == null)
                {
                    return CreateError($"Type '{typeName}' not found");
                }
                isStatic = true;
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

            // Invoke the method
            var result = matchingMethod.Invoke(target, convertedArgs);
            
            // Handle async methods
            if (IsAsyncMethod(matchingMethod))
            {
                result = await UnwrapAsyncResult(result);
            }

            Logger.LogInformation("Called method {MethodName} on {TypeName}", methodName, targetType.Name);
            
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
               type != typeof(DateTime) && 
               type != typeof(TimeSpan) && 
               type != typeof(Guid) && 
               type != typeof(decimal) &&
               !type.IsEnum;
    }
} 