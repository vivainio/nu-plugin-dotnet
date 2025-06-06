using NuPluginDotNet.DotNet;
using NuPluginDotNet.Plugin;
using NuPluginDotNet.Types;

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
            ["dn load-assembly"] = new DotNetLoadAssemblyCommand(_objectManager, _assemblyManager, _valueConverter),
            ["dn assemblies"] = new DotNetAssembliesCommand(_objectManager, _assemblyManager, _valueConverter),
            ["dn types"] = new DotNetTypesCommand(_objectManager, _assemblyManager, _valueConverter),
            ["dn members"] = new DotNetMembersCommand(_objectManager, _assemblyManager, _valueConverter),
            ["dn obj"] = new DotNetObjCommand(_objectManager, _assemblyManager, _valueConverter)
        };
    }

    public async Task<PluginValue> ExecuteAsync(string commandName, PluginCall call)
    {
        if (!_commands.TryGetValue(commandName, out var command))
            throw new InvalidOperationException($"Unknown command: {commandName}");

        var args = new CommandArgs(call, _valueConverter);
        return await command.ExecuteAsync(args);
    }

    public List<object> GetSignatures()
    {
        return new List<object>
        {
            new
            {
                Signature = _commands.Keys.Select(commandName => new
                {
                    sig = new
                    {
                        name = commandName,
                        description = GetCommandDescription(commandName),
                        extra_description = "",
                        search_terms = new string[0],
                        required_positional = GetRequiredPositional(commandName),
                        optional_positional = GetOptionalPositional(commandName),
                        rest_positional = GetRestPositional(commandName),
                        vectorizes_over_list = false,
                        named = GetNamedParameters(commandName),
                        input_output_types = new object[][] { new object[] { "Any", "Any" } },
                        allow_variants_without_examples = true,
                        is_filter = false,
                        creates_scope = false,
                        allows_unknown_args = false,
                        category = "Default"
                    },
                    examples = new object[0]
                }).ToArray()
            }
        };
    }

    private object[] GetRequiredPositional(string commandName)
    {
        return commandName switch
        {
            "dn call" => new object[]
            {
                new
                {
                    name = "method",
                    desc = "The method name to call",
                    shape = "String"
                }
            },
            "dn get" => new object[]
            {
                new
                {
                    name = "property",
                    desc = "The property or field name to get",
                    shape = "String"
                }
            },
            "dn set" => new object[]
            {
                new
                {
                    name = "property",
                    desc = "The property or field name to set",
                    shape = "String"
                },
                new
                {
                    name = "value",
                    desc = "The value to set",
                    shape = "Any"
                }
            },
            "dn types" => new object[]
            {
                new
                {
                    name = "assembly",
                    desc = "The assembly name to list types from",
                    shape = "String"
                }
            },
            "dn members" => new object[]
            {
                new
                {
                    name = "type",
                    desc = "The type name to list members from",
                    shape = "String"
                }
            },

            _ => new object[0]
        };
    }

    private object[] GetOptionalPositional(string commandName)
    {
        return commandName switch
        {
            "dn load-assembly" => new object[]
            {
                new
                {
                    name = "assembly",
                    desc = "The assembly name or path to load",
                    shape = "String"
                }
            },
            _ => new object[0]
        };
    }

    private object? GetRestPositional(string commandName)
    {
        return commandName switch
        {
            "dn call" => new
            {
                name = "args",
                desc = "Arguments to pass to the method",
                shape = "Any"
            },
            _ => null
        };
    }

    private object[] GetNamedParameters(string commandName)
    {
        return commandName switch
        {
            "dn load-assembly" => new object[]
            {
                new
                {
                    @long = "path",
                    @short = "p",
                    arg = "String",
                    required = false,
                    desc = "The assembly file path to load"
                }
            },
            _ => new object[0]
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
            "dn load-assembly" => "Load a .NET assembly",
            "dn assemblies" => "List loaded assemblies",
            "dn types" => "List types in an assembly",
            "dn members" => "List members of a type",
            "dn obj" => "Convert .NET objects to nushell native data structures",
            _ => "Unknown command"
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