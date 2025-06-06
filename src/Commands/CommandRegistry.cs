using Microsoft.Extensions.Logging;
using NuPluginDotNet.DotNet;
using NuPluginDotNet.Plugin;
using NuPluginDotNet.Types;

namespace NuPluginDotNet.Commands;

public class CommandRegistry
{
    private readonly Dictionary<string, BaseCommand> _commands = new();
    private readonly ObjectManager _objectManager;
    private readonly AssemblyManager _assemblyManager;
    private readonly ValueConverter _valueConverter;
    private readonly ILogger _logger;

    public CommandRegistry(
        ObjectManager objectManager, 
        AssemblyManager assemblyManager, 
        ValueConverter valueConverter,
        ILogger logger)
    {
        _objectManager = objectManager;
        _assemblyManager = assemblyManager;
        _valueConverter = valueConverter;
        _logger = logger;

        RegisterCommands();
    }

    private void RegisterCommands()
    {
        _commands["dotnet new"] = new DotNetNewCommand(_objectManager, _assemblyManager, _valueConverter, _logger);
        _commands["dotnet call"] = new DotNetCallCommand(_objectManager, _assemblyManager, _valueConverter, _logger);
        _commands["dotnet get"] = new DotNetGetCommand(_objectManager, _assemblyManager, _valueConverter, _logger);
        _commands["dotnet set"] = new DotNetSetCommand(_objectManager, _assemblyManager, _valueConverter, _logger);
        _commands["dotnet load-assembly"] = new DotNetLoadAssemblyCommand(_objectManager, _assemblyManager, _valueConverter, _logger);
        _commands["dotnet assemblies"] = new DotNetAssembliesCommand(_objectManager, _assemblyManager, _valueConverter, _logger);
        _commands["dotnet types"] = new DotNetTypesCommand(_objectManager, _assemblyManager, _valueConverter, _logger);
        _commands["dotnet members"] = new DotNetMembersCommand(_objectManager, _assemblyManager, _valueConverter, _logger);
    }

    public async Task<PluginValue> ExecuteAsync(string commandName, PluginCall call)
    {
        if (!_commands.TryGetValue(commandName, out var command))
            throw new InvalidOperationException($"Unknown command: {commandName}");

        var args = new CommandArgs(call, _valueConverter);
        return await command.ExecuteAsync(args);
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