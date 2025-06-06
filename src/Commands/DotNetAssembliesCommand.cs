using Microsoft.Extensions.Logging;
using NuPluginDotNet.DotNet;
using NuPluginDotNet.Types;

namespace NuPluginDotNet.Commands;

public class DotNetAssembliesCommand : BaseCommand
{
    public DotNetAssembliesCommand(
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
            var assemblies = AssemblyManager.GetLoadedAssemblies();
            var assemblyList = new List<PluginValue>();

            foreach (var assembly in assemblies)
            {
                var assemblyInfo = AssemblyManager.GetAssemblyInfo(assembly);
                
                var assemblyRecord = new Dictionary<string, PluginValue>
                {
                    ["name"] = PluginValue.String(assemblyInfo.Name),
                    ["version"] = PluginValue.String(assemblyInfo.Version),
                    ["location"] = PluginValue.String(assemblyInfo.Location),
                    ["fullName"] = PluginValue.String(assemblyInfo.FullName),
                    ["isGAC"] = PluginValue.Bool(assemblyInfo.IsGAC),
                    ["isFullyTrusted"] = PluginValue.Bool(assemblyInfo.IsFullyTrusted),
                    ["typeCount"] = PluginValue.Int(assemblyInfo.TypeCount)
                };

                if (!string.IsNullOrEmpty(assemblyInfo.EntryPoint))
                {
                    assemblyRecord["entryPoint"] = PluginValue.String(assemblyInfo.EntryPoint);
                }

                assemblyList.Add(PluginValue.Record(assemblyRecord));
            }

            Logger.LogInformation("Listed {Count} assemblies", assemblies.Length);
            
            return Task.FromResult(PluginValue.List(assemblyList));
        }
        catch (Exception ex)
        {
            return Task.FromResult(CreateError($"Failed to list assemblies: {ex.Message}", ex));
        }
    }
} 