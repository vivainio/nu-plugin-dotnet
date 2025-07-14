using NuPluginDotNet.DotNet;
using NuPluginDotNet.Plugin;
using NuPluginDotNet.Types;
using NuPluginDotNet.Protocol;
using static NuPluginDotNet.Protocol.CommandHelpers;


namespace NuPluginDotNet.Commands;

public class CommandRegistry
{
    private readonly Dictionary<string, BaseCommand> _commands;
    private readonly ObjectManager _objectManager;
    private readonly AssemblyManager _assemblyManager;
    private readonly ValueConverter _valueConverter;

    public CommandRegistry(
        ObjectManager objectManager, 
        AssemblyManager assemblyManager, 
        ValueConverter valueConverter)
    {
        _objectManager = objectManager;
        _assemblyManager = assemblyManager;
        _valueConverter = valueConverter;

        _commands = new Dictionary<string, BaseCommand>
        {
            ["dn new"] = new DotNetNewCommand(_objectManager, _assemblyManager, _valueConverter),
            ["dn call"] = new DotNetCallCommand(_objectManager, _assemblyManager, _valueConverter),
            ["dn get"] = new DotNetGetCommand(_objectManager, _assemblyManager, _valueConverter),
            ["dn set"] = new DotNetSetCommand(_objectManager, _assemblyManager, _valueConverter),
            ["dn load"] = new DotNetLoadAssemblyCommand(_objectManager, _assemblyManager, _valueConverter),
            ["dn assemblies"] = new DotNetAssembliesCommand(_objectManager, _assemblyManager, _valueConverter),
            ["dn types"] = new DotNetTypesCommand(_objectManager, _assemblyManager, _valueConverter),
            ["dn members"] = new DotNetMembersCommand(_objectManager, _assemblyManager, _valueConverter),
            ["dn obj"] = new DotNetObjCommand(_objectManager, _assemblyManager, _valueConverter)
        };
    }

    public async Task<PluginValue> ExecuteAsync(string commandName, PluginCall call)
    {
                    var debugLogFile = Path.Combine(Path.GetTempPath(), $"nu-plugin-dotnet-debug-{Environment.ProcessId}-{Thread.CurrentThread.ManagedThreadId}.log");
        File.AppendAllText(debugLogFile, $"[{DateTime.Now:HH:mm:ss.fff}] [COMMAND_REGISTRY] Executing command: {commandName}\n");
        
        if (!_commands.TryGetValue(commandName, out var command))
            throw new InvalidOperationException($"Unknown command: {commandName}");

        var args = new CommandArgs(call, _valueConverter);
        var result = await command.ExecuteAsync(args);
        
        File.AppendAllText(debugLogFile, $"[{DateTime.Now:HH:mm:ss.fff}] [COMMAND_REGISTRY] Command result type: {result.Type}\n");
        File.AppendAllText(debugLogFile, $"[{DateTime.Now:HH:mm:ss.fff}] [COMMAND_REGISTRY] Command result IsCustom: {result.IsCustom}\n");
        File.AppendAllText(debugLogFile, $"[{DateTime.Now:HH:mm:ss.fff}] [COMMAND_REGISTRY] Command result Value type: {result.Value?.GetType()}\n");
        File.AppendAllText(debugLogFile, $"[{DateTime.Now:HH:mm:ss.fff}] [COMMAND_REGISTRY] Command result Value: {result.Value}\n");
        
        if (result.IsCustom)
        {
            File.AppendAllText(debugLogFile, $"[{DateTime.Now:HH:mm:ss.fff}] [COMMAND_REGISTRY] Custom object - ObjectId: {result.GetObjectId()}\n");
            File.AppendAllText(debugLogFile, $"[{DateTime.Now:HH:mm:ss.fff}] [COMMAND_REGISTRY] Custom object - TypeName: {result.GetTypeName()}\n");
        }
        
        return result;
    }

    public object[] GetSignatures()
    {
        return _commands.Keys.Select(commandName => 
            Command(
                name: commandName,
                description: GetCommandDescription(commandName),
                requiredPositional: GetRequiredPositionalTyped(commandName),
                optionalPositional: GetOptionalPositionalTyped(commandName),
                restPositional: GetRestPositionalTyped(commandName),
                named: GetNamedParametersTyped(commandName),
                inputType: GetInputType(commandName),
                outputType: GetOutputType(commandName),
                category: GetCommandCategory(commandName)
            )
        ).ToArray();
    }

    private PositionalArg[] GetRequiredPositionalTyped(string commandName)
    {
        return commandName switch
        {
            "dn new" => new[]
            {
                Positional("type", "The .NET type name to create", NuTypes.String)
            },
            "dn call" => new[]
            {
                Positional("method", "The method name to call", NuTypes.String)
            },
            "dn get" => new[]
            {
                Positional("property", "The property or field name to get", NuTypes.String)
            },
            "dn set" => new[]
            {
                Positional("property", "The property or field name to set", NuTypes.String),
                Positional("value", "The value to set", NuTypes.Any)
            },
            "dn types" => new[]
            {
                Positional("assembly", "The assembly name to list types from", NuTypes.String)
            },
            "dn members" => new[]
            {
                Positional("type", "The type name to list members from", NuTypes.String)
            },
            _ => Array.Empty<PositionalArg>()
        };
    }

    private PositionalArg[] GetOptionalPositionalTyped(string commandName)
    {
        return commandName switch
        {
            "dn load" => new[]
            {
                Positional("assembly", "The assembly name or path to load", NuTypes.String)
            },
            _ => Array.Empty<PositionalArg>()
        };
    }

    private PositionalArg? GetRestPositionalTyped(string commandName)
    {
        return commandName switch
        {
            "dn call" => Positional("args", "Arguments to pass to the method", NuTypes.Any),
            _ => null
        };
    }

    private NamedArg[] GetNamedParametersTyped(string commandName)
    {
        return commandName switch
        {
            "dn members" => new[]
            {
                Named("type", "Filter by member type (methods, properties, fields)", "t", NuTypes.String),
                Named("static", "Include static members", "s"),
                Named("instance", "Include instance members", "i")
            },
            "dn load" => new[]
            {
                Named("path", "The assembly file path to load", "p", NuTypes.String)
            },
            _ => Array.Empty<NamedArg>()
        };
    }

    private string GetCommandDescription(string commandName)
    {
        return commandName switch
        {
            "dn new" => "Create a new .NET object",
            "dn call" => "Call a method on a .NET object",
            "dn get" => "Get a property or field from a .NET object",
            "dn set" => "Set a property or field on a .NET object",
            "dn load" => "Load a .NET assembly",
            "dn assemblies" => "List loaded assemblies",
            "dn types" => "List types in an assembly",
            "dn members" => "List members of a type",
            "dn obj" => "Convert .NET objects to nushell native data structures",
            _ => "Unknown command"
        };
    }

    private string GetCommandCategory(string commandName)
    {
        return commandName switch
        {
            "dn new" or "dn call" or "dn get" or "dn set" => "Custom",
            "dn load" or "dn assemblies" => "System", 
            "dn types" or "dn members" => "System",
            "dn obj" => "Conversions",
            _ => "Default"
        };
    }

    private string GetInputType(string commandName)
    {
        return commandName switch
        {
            "dn new" => "Nothing",
            "dn call" => "Any",
            "dn get" => "Any",
            "dn set" => "Any",
            "dn load" => "Nothing",
            "dn assemblies" => "Nothing",
            "dn types" => "Nothing",
            "dn members" => "Nothing",
            "dn obj" => "Any",
            _ => "Any"
        };
    }

    private string GetOutputType(string commandName)
    {
        return commandName switch
        {
            "dn new" => "Any",
            "dn call" => "Any",
            "dn get" => "Any",
            "dn set" => "Any",
            "dn load" => "String",
            "dn assemblies" => "List",
            "dn types" => "List",
            "dn members" => "List",
            "dn obj" => "Any",
            _ => "Any"
        };
    }
}

public class CommandArgs
{
    private readonly PluginCall _call;
    private readonly ValueConverter _valueConverter;

    public CommandArgs(PluginCall call, ValueConverter valueConverter)
    {
        _call = call;
        _valueConverter = valueConverter;
    }

    public PluginValue? Input => _call.Input;
    public List<PluginValue> Positional => _call.Positional;
    public Dictionary<string, PluginValue> Named => _call.Named;

    public string GetString(string name)
    {
        if (Named.TryGetValue(name, out var value))
            return value.AsString();
        throw new ArgumentException($"Required parameter '{name}' not found");
    }

    public string? GetOptionalString(string name)
    {
        return Named.TryGetValue(name, out var value) ? value.AsString() : null;
    }

    public long GetInt(string name)
    {
        if (Named.TryGetValue(name, out var value))
            return value.AsInt();
        throw new ArgumentException($"Required parameter '{name}' not found");
    }

    public long? GetOptionalInt(string name)
    {
        return Named.TryGetValue(name, out var value) ? value.AsInt() : null;
    }

    public bool GetBool(string name, bool defaultValue = false)
    {
        return Named.TryGetValue(name, out var value) ? value.AsBool() : defaultValue;
    }

    public List<PluginValue> GetList(string name)
    {
        if (Named.TryGetValue(name, out var value))
            return value.AsList();
        throw new ArgumentException($"Required parameter '{name}' not found");
    }

    public List<PluginValue>? GetOptionalList(string name)
    {
        return Named.TryGetValue(name, out var value) ? value.AsList() : null;
    }

    public string GetPositionalString(int index)
    {
        if (index < Positional.Count)
            return Positional[index].AsString();
        throw new ArgumentException($"Required positional parameter at index {index} not found");
    }

    public string? GetOptionalPositionalString(int index)
    {
        return index < Positional.Count ? Positional[index].AsString() : null;
    }

    public PluginValue GetPositional(int index)
    {
        if (index < Positional.Count)
            return Positional[index];
        throw new ArgumentException($"Required positional parameter at index {index} not found");
    }

    public PluginValue? GetOptionalPositional(int index)
    {
        return index < Positional.Count ? Positional[index] : null;
    }

    public T ConvertInput<T>()
    {
        if (Input == null)
            throw new InvalidOperationException("No input provided");
        return (T)_valueConverter.ConvertToClr(Input, typeof(T))!;
    }

    public T? TryConvertInput<T>() where T : class
    {
        if (Input == null)
            return null;
        try
        {
            return (T?)_valueConverter.ConvertToClr(Input, typeof(T));
        }
        catch
        {
            return null;
        }
    }
} 