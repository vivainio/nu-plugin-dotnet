
using NuPluginDotNet.DotNet;
using NuPluginDotNet.Types;

namespace NuPluginDotNet.Commands;

public class DotNetLoadAssemblyCommand : BaseCommand
{
    public DotNetLoadAssemblyCommand(
        ObjectManager objectManager,
        AssemblyManager assemblyManager,
        ValueConverter valueConverter) : base(objectManager, assemblyManager, valueConverter)
    {
    }

    public override Task<PluginValue> ExecuteAsync(CommandArgs args)
    {
        try
        {
            // Assembly path from first positional argument
            var assemblyPath = args.GetPositionalString(0);
            
            if (string.IsNullOrWhiteSpace(assemblyPath))
            {
                return Task.FromResult(CreateError("Assembly path cannot be empty"));
            }

            // Load the assembly
            var assembly = AssemblyManager.LoadAssembly(assemblyPath);
            var assemblyInfo = AssemblyManager.GetAssemblyInfo(assembly);
            
            // Logger.LogInformation("Loaded assembly {AssemblyName} from {Path}", assemblyInfo.Name, assemblyPath);
            
            // Return assembly information as a record
            var result = new Dictionary<string, PluginValue>
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
                result["entryPoint"] = PluginValue.String(assemblyInfo.EntryPoint);
            }

            return Task.FromResult(PluginValue.Record(result));
        }
        catch (Exception ex)
        {
            return Task.FromResult(CreateError($"Failed to load assembly: {ex.Message}", ex));
        }
    }
} 