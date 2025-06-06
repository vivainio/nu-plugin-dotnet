using System.Collections.Concurrent;
using System.Reflection;
using System.Runtime.Loader;

namespace NuPluginDotNet.DotNet;

public class AssemblyManager
{
    private readonly ConcurrentDictionary<string, Assembly> _loadedAssemblies = new();
    private readonly AssemblyLoadContext _loadContext;

    public AssemblyManager()
    {
        _loadContext = new AssemblyLoadContext("PluginContext", isCollectible: true);
        _loadContext.Resolving += OnAssemblyResolving;
    }

    public Assembly LoadAssembly(string assemblyPath)
    {
        var fullPath = Path.GetFullPath(assemblyPath);
        
        if (_loadedAssemblies.TryGetValue(fullPath, out var existingAssembly))
            return existingAssembly;

        if (!File.Exists(fullPath))
            throw new FileNotFoundException($"Assembly not found: {fullPath}");

        try
        {
            var assembly = _loadContext.LoadFromAssemblyPath(fullPath);
            _loadedAssemblies[fullPath] = assembly;
            return assembly;
        }
        catch (Exception ex)
        {
            throw new InvalidOperationException($"Failed to load assembly from {fullPath}: {ex.Message}", ex);
        }
    }

    public Assembly LoadAssemblyByName(string assemblyName)
    {
        if (_loadedAssemblies.Values.FirstOrDefault(a => a.GetName().Name == assemblyName) is Assembly existing)
            return existing;

        try
        {
            var assembly = _loadContext.LoadFromAssemblyName(new AssemblyName(assemblyName));
            _loadedAssemblies[assembly.Location] = assembly;
            return assembly;
        }
        catch (Exception ex)
        {
            throw new InvalidOperationException($"Failed to load assembly {assemblyName}: {ex.Message}", ex);
        }
    }

    public Assembly[] GetLoadedAssemblies()
    {
        // Include both our loaded assemblies and runtime assemblies
        var runtimeAssemblies = AppDomain.CurrentDomain.GetAssemblies();
        var pluginAssemblies = _loadedAssemblies.Values.ToArray();
        
        return runtimeAssemblies.Concat(pluginAssemblies).Distinct().ToArray();
    }

    public Type? FindType(string typeName)
    {
        // First check if it's a built-in type
        var builtInType = Type.GetType(typeName);
        if (builtInType != null)
            return builtInType;

        // Search in all loaded assemblies
        foreach (var assembly in GetLoadedAssemblies())
        {
            try
            {
                var type = assembly.GetType(typeName);
                if (type != null)
                    return type;

                // Also try exported types for cases where the type is forwarded
                var exportedType = assembly.GetExportedTypes().FirstOrDefault(t => t.FullName == typeName || t.Name == typeName);
                if (exportedType != null)
                    return exportedType;
            }
            catch (Exception)
            {
                // Ignore exceptions when searching for types
                continue;
            }
        }

        return null;
    }

    public Type[] GetTypesInAssembly(string assemblyName)
    {
        var assembly = GetLoadedAssemblies().FirstOrDefault(a => 
            a.GetName().Name?.Equals(assemblyName, StringComparison.OrdinalIgnoreCase) == true);
        
        if (assembly == null)
            throw new InvalidOperationException($"Assembly {assemblyName} not found");

        try
        {
            return assembly.GetExportedTypes();
        }
        catch (Exception ex)
        {
            throw new InvalidOperationException($"Failed to get types from assembly {assemblyName}: {ex.Message}", ex);
        }
    }

    public Type[] GetTypesInNamespace(string namespaceName)
    {
        var types = new List<Type>();
        
        foreach (var assembly in GetLoadedAssemblies())
        {
            try
            {
                var namespaceTypes = assembly.GetExportedTypes()
                    .Where(t => t.Namespace?.Equals(namespaceName, StringComparison.OrdinalIgnoreCase) == true);
                types.AddRange(namespaceTypes);
            }
            catch (Exception)
            {
                // Ignore exceptions when searching
                continue;
            }
        }

        return types.ToArray();
    }

    public Assembly[] SearchAssemblies(string searchTerm)
    {
        return GetLoadedAssemblies()
            .Where(a => a.GetName().Name?.Contains(searchTerm, StringComparison.OrdinalIgnoreCase) == true)
            .ToArray();
    }

    public AssemblyInfo GetAssemblyInfo(Assembly assembly)
    {
        var name = assembly.GetName();
        
        return new AssemblyInfo
        {
            Name = name.Name ?? "Unknown",
            Version = name.Version?.ToString() ?? "Unknown",
            Location = assembly.Location,
            FullName = assembly.FullName ?? "Unknown",
            IsGAC = assembly.GlobalAssemblyCache,
            IsFullyTrusted = assembly.IsFullyTrusted,
            TypeCount = GetSafeTypeCount(assembly),
            EntryPoint = assembly.EntryPoint?.DeclaringType?.FullName
        };
    }

    private int GetSafeTypeCount(Assembly assembly)
    {
        try
        {
            return assembly.GetTypes().Length;
        }
        catch
        {
            try
            {
                return assembly.GetExportedTypes().Length;
            }
            catch
            {
                return 0;
            }
        }
    }

    private Assembly? OnAssemblyResolving(AssemblyLoadContext context, AssemblyName assemblyName)
    {
        // Try to resolve from already loaded assemblies
        var loaded = _loadedAssemblies.Values.FirstOrDefault(a => 
            a.GetName().Name?.Equals(assemblyName.Name, StringComparison.OrdinalIgnoreCase) == true);
        
        if (loaded != null)
            return loaded;

        // Try to load from the runtime
        try
        {
            return context.LoadFromAssemblyName(assemblyName);
        }
        catch
        {
            return null;
        }
    }

    public void Dispose()
    {
        _loadContext.Unload();
    }
}

public class AssemblyInfo
{
    public string Name { get; set; } = "";
    public string Version { get; set; } = "";
    public string Location { get; set; } = "";
    public string FullName { get; set; } = "";
    public bool IsGAC { get; set; }
    public bool IsFullyTrusted { get; set; }
    public int TypeCount { get; set; }
    public string? EntryPoint { get; set; }
} 