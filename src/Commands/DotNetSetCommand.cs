using System.Reflection;
using Microsoft.Extensions.Logging;
using NuPluginDotNet.DotNet;
using NuPluginDotNet.Types;

namespace NuPluginDotNet.Commands;

public class DotNetSetCommand : BaseCommand
{
    public DotNetSetCommand(
        ObjectManager objectManager,
        AssemblyManager assemblyManager,
        ValueConverter valueConverter,
        ILogger logger) : base(objectManager, assemblyManager, valueConverter, logger)
    {
    }

    public override Task<PluginValue> ExecuteAsync(CommandArgs args)
    {
        try
        {
            // Property/field name from first positional argument
            var memberName = args.GetPositionalString(0);
            
            // Value to set from second positional argument
            var value = args.GetPositional(1);

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
                // Static member access with type name
                var typeName = args.Input.AsString();
                var foundType = AssemblyManager.FindType(typeName);
                if (foundType == null)
                {
                    return Task.FromResult(CreateError($"Type '{typeName}' not found"));
                }
                targetType = foundType;
                isStatic = true;
            }
            else
            {
                return Task.FromResult(CreateError("Invalid target. Provide an object instance or type name for static members."));
            }

            // Try property first
            var property = targetType.GetProperty(memberName, BindingFlags.Public | (isStatic ? BindingFlags.Static : BindingFlags.Instance) | BindingFlags.IgnoreCase);
            if (property != null && property.CanWrite)
            {
                var convertedValue = ValueConverter.ConvertToClr(value, property.PropertyType);
                property.SetValue(target, convertedValue);
                
                Logger.LogInformation("Set property {PropertyName} on {TypeName}", memberName, targetType.Name);
                return Task.FromResult(PluginValue.Null()); // Success with no return value
            }

            // Try field
            var field = targetType.GetField(memberName, BindingFlags.Public | (isStatic ? BindingFlags.Static : BindingFlags.Instance) | BindingFlags.IgnoreCase);
            if (field != null && !field.IsInitOnly)
            {
                var convertedValue = ValueConverter.ConvertToClr(value, field.FieldType);
                field.SetValue(target, convertedValue);
                
                Logger.LogInformation("Set field {FieldName} on {TypeName}", memberName, targetType.Name);
                return Task.FromResult(PluginValue.Null()); // Success with no return value
            }

            return Task.FromResult(CreateError($"Writable property or field '{memberName}' not found on type '{targetType.Name}'"));
        }
        catch (Exception ex)
        {
            return Task.FromResult(CreateError($"Failed to set member: {ex.Message}", ex));
        }
    }
} 