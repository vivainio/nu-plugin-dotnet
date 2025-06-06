using System.Text.Json;
using Microsoft.Extensions.Logging;
using NuPluginDotNet.Commands;
using NuPluginDotNet.DotNet;
using NuPluginDotNet.Types;

namespace NuPluginDotNet.Plugin;

public class PluginHost
{
    private readonly ILogger<PluginHost> _logger;
    private readonly CommandRegistry? _commandRegistry;
    private readonly ObjectManager? _objectManager;
    private readonly AssemblyManager? _assemblyManager;
    private readonly ValueConverter? _valueConverter;
    private readonly bool _initializationSucceeded = false;

    public PluginHost(ILogger<PluginHost> logger)
    {
        _logger = logger;
        
        try
        {
            _objectManager = new ObjectManager();
            _assemblyManager = new AssemblyManager();
            _valueConverter = new ValueConverter(_objectManager);
            _commandRegistry = new CommandRegistry(_objectManager, _assemblyManager, _valueConverter, logger);
            _initializationSucceeded = true;
        }
        catch (Exception ex)
        {
            // Initialize with null to handle signature requests even if initialization fails
            _initializationSucceeded = false;
        }
    }

    public async Task RunAsync()
    {
        try
        {
            // Set up console for plugin communication
            Console.InputEncoding = System.Text.Encoding.UTF8;
            Console.OutputEncoding = System.Text.Encoding.UTF8;

            while (true)
            {
                try
                {
                    var line = Console.ReadLine();
                    if (line == null)
                        break;

                    if (string.IsNullOrWhiteSpace(line))
                        continue;

                    var request = JsonSerializer.Deserialize<PluginRequest>(line);
                    if (request == null)
                        continue;

                    var response = request.Type switch
                    {
                        "Signature" => HandleSignature(),
                        "Run" => await HandleRun(request),
                        _ => CreateErrorResponse($"Unknown request type: {request.Type}")
                    };

                    var responseJson = JsonSerializer.Serialize(response);
                    Console.WriteLine(responseJson);
                    Console.Out.Flush();
                }
                catch (JsonException ex)
                {
                    var errorResponse = CreateErrorResponse($"JSON parsing error: {ex.Message}");
                    var errorJson = JsonSerializer.Serialize(errorResponse);
                    Console.WriteLine(errorJson);
                    Console.Out.Flush();
                }
                catch (Exception ex)
                {
                    var errorResponse = CreateErrorResponse($"Internal error: {ex.Message}");
                    var errorJson = JsonSerializer.Serialize(errorResponse);
                    Console.WriteLine(errorJson);
                    Console.Out.Flush();
                }
            }
        }
        catch (Exception ex)
        {
            // Log to stderr to avoid interfering with plugin protocol
            await Console.Error.WriteLineAsync($"Fatal plugin error: {ex.Message}");
            Environment.Exit(1);
        }
    }

    private PluginResponse HandleSignature()
    {
        return new PluginResponse
        {
            Type = "Signature",
            Value = new List<CommandSignature>
            {
                new() { Name = "dn new", Description = "Create a new .NET object", Category = "experimental" },
                new() { Name = "dn call", Description = "Call a method on a .NET object", Category = "experimental" },
                new() { Name = "dn get", Description = "Get a property or field from a .NET object", Category = "experimental" },
                new() { Name = "dn set", Description = "Set a property or field on a .NET object", Category = "experimental" },
                new() { Name = "dn load-assembly", Description = "Load a .NET assembly", Category = "experimental" },
                new() { Name = "dn assemblies", Description = "List loaded assemblies", Category = "experimental" },
                new() { Name = "dn types", Description = "List types in an assembly", Category = "experimental" },
                new() { Name = "dn members", Description = "List members of a type", Category = "experimental" }
            }
        };
    }

    private async Task<PluginResponse> HandleRun(PluginRequest request)
    {
        try
        {
            if (!_initializationSucceeded || _commandRegistry == null)
            {
                return CreateErrorResponse("Plugin initialization failed. Please check your .NET installation.");
            }

            var call = request.Call;
            if (call == null)
                return CreateErrorResponse("Missing call information");

            var result = await _commandRegistry.ExecuteAsync(call.Head.Name, call);
            
            return new PluginResponse
            {
                Type = "Value",
                Value = result
            };
        }
        catch (Exception ex)
        {
            return CreateErrorResponse(ex.Message);
        }
    }

    private static PluginResponse CreateErrorResponse(string message)
    {
        return new PluginResponse
        {
            Type = "Error",
            Value = new PluginError
            {
                Message = message
            }
        };
    }
}

public class PluginRequest
{
    public string Type { get; set; } = "";
    public PluginCall? Call { get; set; }
}

public class PluginCall
{
    public CommandHead Head { get; set; } = new();
    public List<PluginValue> Positional { get; set; } = new();
    public Dictionary<string, PluginValue> Named { get; set; } = new();
    public PluginValue? Input { get; set; }
}

public class CommandHead
{
    public string Name { get; set; } = "";
    public Dictionary<string, object>? Span { get; set; }
}

public class PluginResponse
{
    public string Type { get; set; } = "";
    public object? Value { get; set; }
}

public class CommandSignature
{
    public string Name { get; set; } = "";
    public string Description { get; set; } = "";
    public string Category { get; set; } = "";
    public List<CommandParameter> Parameters { get; set; } = new();
}

public class CommandParameter
{
    public string Name { get; set; } = "";
    public string Description { get; set; } = "";
    public bool Required { get; set; }
    public string Type { get; set; } = "";
}

public class PluginError
{
    public string Message { get; set; } = "";
    public string? StackTrace { get; set; }
    public string? Type { get; set; }
    public PluginError? InnerException { get; set; }
} 