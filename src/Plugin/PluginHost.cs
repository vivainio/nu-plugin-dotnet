using System.Text.Json;
using Microsoft.Extensions.Logging;
using NuPluginDotNet.Commands;
using NuPluginDotNet.DotNet;
using NuPluginDotNet.Types;

namespace NuPluginDotNet.Plugin;

public class PluginHost
{
    private readonly ILogger<PluginHost> _logger;
    private readonly CommandRegistry _commandRegistry;
    private readonly ObjectManager _objectManager;
    private readonly AssemblyManager _assemblyManager;
    private readonly ValueConverter _valueConverter;

    public PluginHost(ILogger<PluginHost> logger)
    {
        _logger = logger;
        _objectManager = new ObjectManager();
        _assemblyManager = new AssemblyManager();
        _valueConverter = new ValueConverter(_objectManager);
        _commandRegistry = new CommandRegistry(_objectManager, _assemblyManager, _valueConverter, logger);
    }

    public async Task RunAsync()
    {
        _logger.LogInformation("Nu plugin dotnet started");

        while (true)
        {
            var line = await Console.In.ReadLineAsync();
            if (line == null)
                break;

            try
            {
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
                await Console.Out.WriteLineAsync(responseJson);
                await Console.Out.FlushAsync();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error processing request: {Line}", line);
                var errorResponse = CreateErrorResponse($"Internal error: {ex.Message}");
                var errorJson = JsonSerializer.Serialize(errorResponse);
                await Console.Out.WriteLineAsync(errorJson);
                await Console.Out.FlushAsync();
            }
        }
    }

    private PluginResponse HandleSignature()
    {
        return new PluginResponse
        {
            Type = "Signature",
            Value = new List<CommandSignature>
            {
                new() { Name = "dotnet new", Description = "Create a new .NET object", Category = "experimental" },
                new() { Name = "dotnet call", Description = "Call a method on a .NET object", Category = "experimental" },
                new() { Name = "dotnet get", Description = "Get a property or field from a .NET object", Category = "experimental" },
                new() { Name = "dotnet set", Description = "Set a property or field on a .NET object", Category = "experimental" },
                new() { Name = "dotnet load-assembly", Description = "Load a .NET assembly", Category = "experimental" },
                new() { Name = "dotnet assemblies", Description = "List loaded assemblies", Category = "experimental" },
                new() { Name = "dotnet types", Description = "List types in an assembly", Category = "experimental" },
                new() { Name = "dotnet members", Description = "List members of a type", Category = "experimental" }
            }
        };
    }

    private async Task<PluginResponse> HandleRun(PluginRequest request)
    {
        try
        {
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
            _logger.LogError(ex, "Error executing command");
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