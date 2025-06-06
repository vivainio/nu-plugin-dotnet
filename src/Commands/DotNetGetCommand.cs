using System.Reflection;

using NuPluginDotNet.DotNet;
using NuPluginDotNet.Types;

namespace NuPluginDotNet.Commands;

public class DotNetGetCommand : BaseCommand
{
    public DotNetGetCommand(
        ObjectManager objectManager,
        AssemblyManager assemblyManager,
        ValueConverter valueConverter) : base(objectManager, assemblyManager, valueConverter)
    {
    }

    public override Task<PluginValue> ExecuteAsync(CommandArgs args)
    {
        try
        {
            // Property/field name from first positional argument
            var memberName = args.GetPositionalString(0);
            
            // Optional index arguments for indexed properties
            var indexArgs = args.Positional.Skip(1).ToList();

            // Determine target (object or type for static members)
            object? target = null;
            Type targetType;
            bool isStatic = false;

            if (args.Input?.IsCustom == true)
            {
                // Instance member access
                var objectId = args.Input.GetObjectId();
                target = ObjectManager.GetObject(objectId);
                targetType = target.GetType();
            }
            else if (args.Input?.IsString == true)
            {
                var inputString = args.Input.AsString();
                
                // First try to treat it as a type name for static access
                var foundType = AssemblyManager.FindType(inputString);
                if (foundType != null)
                {
                    // It's a valid type name, use for static access
                    targetType = foundType;
                    isStatic = true;
                }
                else
                {
                    // Not a type name, treat as string instance for instance member access
                    target = inputString;
                    targetType = typeof(string);
                    isStatic = false;
                }
            }
            else
            {
                return Task.FromResult(CreateError("Invalid target. Provide an object instance or type name for static members."));
            }

            object? result = null;

            // Handle indexed properties first
            if (indexArgs.Count > 0)
            {
                var indexers = targetType.GetProperties(BindingFlags.Public | (isStatic ? BindingFlags.Static : BindingFlags.Instance))
                    .Where(p => p.GetIndexParameters().Length > 0).ToArray();

                PropertyInfo? matchingIndexer = null;
                object?[]? convertedIndexes = null;

                foreach (var indexer in indexers)
                {
                    var parameters = indexer.GetIndexParameters();
                    if (parameters.Length != indexArgs.Count)
                        continue;

                    try
                    {
                        convertedIndexes = new object?[parameters.Length];
                        for (int i = 0; i < parameters.Length; i++)
                        {
                            convertedIndexes[i] = ValueConverter.ConvertToClr(indexArgs[i], parameters[i].ParameterType);
                        }
                        matchingIndexer = indexer;
                        break;
                    }
                    catch
                    {
                        continue;
                    }
                }

                if (matchingIndexer != null)
                {
                    result = matchingIndexer.GetValue(target, convertedIndexes);
                }
                else
                {
                    return Task.FromResult(CreateError($"No matching indexed property found for the provided index arguments"));
                }
            }
            else
            {
                // Try property first
                var property = targetType.GetProperty(memberName, BindingFlags.Public | (isStatic ? BindingFlags.Static : BindingFlags.Instance) | BindingFlags.IgnoreCase);
                if (property != null && property.CanRead)
                {
                    result = property.GetValue(target);
                }
                else
                {
                    // Try field
                    var field = targetType.GetField(memberName, BindingFlags.Public | (isStatic ? BindingFlags.Static : BindingFlags.Instance) | BindingFlags.IgnoreCase);
                    if (field != null)
                    {
                        result = field.GetValue(target);
                    }
                    else
                    {
                        return Task.FromResult(CreateError($"Property or field '{memberName}' not found on type '{targetType.Name}'"));
                    }
                }
            }

            // Logger.LogInformation("Got member {MemberName} from {TypeName}", memberName, targetType.Name);

            // Convert result back to PluginValue
            if (result == null)
            {
                return Task.FromResult(PluginValue.Null());
            }

            // If the result is a complex object, register it
            var resultType = result.GetType();
            if (IsComplexType(resultType))
            {
                var objectId = ObjectManager.RegisterObject(result);
                return Task.FromResult(PluginValue.Custom(objectId, resultType.FullName ?? resultType.Name));
            }

            // Convert simple types directly
            return Task.FromResult(ValueConverter.ConvertFromClr(result));
        }
        catch (Exception ex)
        {
            return Task.FromResult(CreateError($"Failed to get member: {ex.Message}", ex));
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