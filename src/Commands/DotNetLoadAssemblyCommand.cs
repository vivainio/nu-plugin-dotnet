
using System.Reflection;
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
        // Assembly path from --path parameter or first positional argument
        var assemblyPath = args.GetOptionalString("path");
        
        try
        {
            
            // If no --path parameter, try positional argument
            if (string.IsNullOrWhiteSpace(assemblyPath))
            {
                assemblyPath = args.GetOptionalPositionalString(0);
            }
            
            if (string.IsNullOrWhiteSpace(assemblyPath))
            {
                return Task.FromResult(CreateError("Assembly path or name must be specified"));
            }

            // Load the assembly - try as path first, then as name
            Assembly assembly;
            try
            {
                // First try to load as file path
                assembly = AssemblyManager.LoadAssembly(assemblyPath);
            }
            catch
            {
                // If that fails, try to load by name
                assembly = AssemblyManager.LoadAssemblyByName(assemblyPath);
            }
            
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
            return Task.FromResult(CreateError($"Failed to load assembly '{assemblyPath}': {ex.Message}", ex));
        }
    }
} 