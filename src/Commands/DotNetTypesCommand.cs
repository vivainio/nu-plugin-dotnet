using Microsoft.Extensions.Logging;
using NuPluginDotNet.DotNet;
using NuPluginDotNet.Types;

namespace NuPluginDotNet.Commands;

public class DotNetTypesCommand : BaseCommand
{
    public DotNetTypesCommand(
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
            // Assembly name from first positional argument
            var assemblyName = args.GetPositionalString(0);
            
            var types = AssemblyManager.GetTypesInAssembly(assemblyName);
            var typeList = new List<PluginValue>();

            foreach (var type in types.OrderBy(t => t.FullName))
            {
                var typeRecord = new Dictionary<string, PluginValue>
                {
                    ["name"] = PluginValue.String(type.Name),
                    ["fullName"] = PluginValue.String(type.FullName ?? type.Name),
                    ["namespace"] = PluginValue.String(type.Namespace ?? ""),
                    ["isClass"] = PluginValue.Bool(type.IsClass),
                    ["isInterface"] = PluginValue.Bool(type.IsInterface),
                    ["isEnum"] = PluginValue.Bool(type.IsEnum),
                    ["isValueType"] = PluginValue.Bool(type.IsValueType),
                    ["isAbstract"] = PluginValue.Bool(type.IsAbstract),
                    ["isSealed"] = PluginValue.Bool(type.IsSealed),
                    ["isGeneric"] = PluginValue.Bool(type.IsGenericType),
                    ["isPublic"] = PluginValue.Bool(type.IsPublic)
                };

                if (type.BaseType != null)
                {
                    typeRecord["baseType"] = PluginValue.String(type.BaseType.FullName ?? type.BaseType.Name);
                }

                var interfaces = type.GetInterfaces().Select(i => PluginValue.String(i.FullName ?? i.Name)).ToList();
                if (interfaces.Count > 0)
                {
                    typeRecord["interfaces"] = PluginValue.List(interfaces);
                }

                typeList.Add(PluginValue.Record(typeRecord));
            }

            Logger.LogInformation("Listed {Count} types from assembly {AssemblyName}", types.Length, assemblyName);
            
            return Task.FromResult(PluginValue.List(typeList));
        }
        catch (Exception ex)
        {
            return Task.FromResult(CreateError($"Failed to list types: {ex.Message}", ex));
        }
    }
} 