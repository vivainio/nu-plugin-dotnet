using System.Text.Json;
using NuPluginDotNet.Commands;
using NuPluginDotNet.DotNet;
using NuPluginDotNet.Types;

namespace NuPluginDotNet.Plugin;

public class PluginHost
{
    private readonly CommandRegistry? _commandRegistry;
    private readonly ObjectManager? _objectManager;
    private readonly AssemblyManager? _assemblyManager;
    private readonly ValueConverter? _valueConverter;
    private readonly bool _initializationSucceeded = false;
    private readonly string _logFile;

    public PluginHost()
    {
        _logFile = Path.Combine(Path.GetTempPath(), "nu-plugin-dotnet-debug.log");
        
        try
        {
            WriteLog("Plugin starting...");
            
            WriteLog("Initializing ObjectManager...");
            _objectManager = new ObjectManager();
            
            WriteLog("Initializing AssemblyManager...");
            _assemblyManager = new AssemblyManager();
            
            WriteLog("Initializing ValueConverter...");
            _valueConverter = new ValueConverter(_objectManager);
            
            WriteLog("Initializing CommandRegistry...");
            _commandRegistry = new CommandRegistry(_objectManager, _assemblyManager, _valueConverter);
            
            _initializationSucceeded = true;
            WriteLog("Initialization completed successfully");
        }
        catch (Exception ex)
        {
            WriteLog($"Initialization failed: {ex.Message}");
            _initializationSucceeded = false;
        }
    }

    private void WriteLog(string message)
    {
        try
        {
            File.AppendAllText(_logFile, $"[{DateTime.Now:HH:mm:ss.fff}] {message}\n");
        }
        catch
        {
            // Ignore logging errors to avoid causing more issues
        }
    }

    public async Task RunAsync()
    {
        WriteLog("RunAsync started");
        
        try
        {
            WriteLog("Setting up console encoding");
            Console.InputEncoding = System.Text.Encoding.UTF8;
            Console.OutputEncoding = System.Text.Encoding.UTF8;

            WriteLog("Starting main communication loop with timeout");
            
            // Use a very short timeout to avoid hanging during registration
            string? line = null;
            
            try
            {
                WriteLog("Attempting to read input with 5-second timeout...");
                using var cts = new CancellationTokenSource(TimeSpan.FromSeconds(5));
                
                var readTask = Task.Run(async () =>
                {
                    WriteLog("ReadTask: About to call Console.ReadLine()");
                    var result = Console.ReadLine();
                    WriteLog($"ReadTask: Console.ReadLine() returned: {result ?? "null"}");
                    return result;
                });
                
                line = await readTask.WaitAsync(cts.Token);
                WriteLog($"Successfully read line: {line ?? "null"}");
            }
            catch (TimeoutException)
            {
                WriteLog("Input read timed out after 5 seconds - exiting gracefully");
                return;
            }
            catch (OperationCanceledException)
            {
                WriteLog("Input read was cancelled - exiting gracefully");
                return;
            }
            catch (Exception ex)
            {
                WriteLog($"Error reading input: {ex.Message}");
                return;
            }
            
            if (line == null)
            {
                WriteLog("No input received, exiting");
                return;
            }

            if (string.IsNullOrWhiteSpace(line))
            {
                WriteLog("Empty input received, exiting");
                return;
            }

            WriteLog("Processing input...");
            
            try
            {
                var request = JsonSerializer.Deserialize<PluginRequest>(line);
                if (request == null)
                {
                    WriteLog("Failed to deserialize request");
                    return;
                }

                WriteLog($"Request type: {request.Type}");

                var response = request.Type switch
                {
                    "Signature" => HandleSignature(),
                    "Run" => await HandleRun(request),
                    _ => CreateErrorResponse($"Unknown request type: {request.Type}")
                };

                WriteLog($"Sending response...");
                var responseJson = JsonSerializer.Serialize(response);
                Console.WriteLine(responseJson);
                Console.Out.Flush();
                WriteLog("Response sent successfully");
            }
            catch (JsonException ex)
            {
                WriteLog($"JSON error: {ex.Message}");
                var errorResponse = CreateErrorResponse($"JSON parsing error: {ex.Message}");
                var errorJson = JsonSerializer.Serialize(errorResponse);
                Console.WriteLine(errorJson);
                Console.Out.Flush();
            }
            catch (Exception ex)
            {
                WriteLog($"Error: {ex.Message}");
                var errorResponse = CreateErrorResponse($"Internal error: {ex.Message}");
                var errorJson = JsonSerializer.Serialize(errorResponse);
                Console.WriteLine(errorJson);
                Console.Out.Flush();
            }
            
            WriteLog("Main processing completed, exiting");
        }
        catch (Exception ex)
        {
            WriteLog($"Fatal error: {ex.Message}");
            await Console.Error.WriteLineAsync($"Fatal plugin error: {ex.Message}");
            Environment.Exit(1);
        }
        finally
        {
            WriteLog("Plugin shutting down");
        }
    }

    private PluginResponse HandleSignature()
    {
        WriteLog("Handling signature request");
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
        WriteLog("Handling run request");
        
        try
        {
            if (!_initializationSucceeded || _commandRegistry == null)
            {
                WriteLog("Initialization not successful, returning error");
                return CreateErrorResponse("Plugin initialization failed. Please check your .NET installation.");
            }

            var call = request.Call;
            if (call == null)
            {
                WriteLog("No call information in request");
                return CreateErrorResponse("Missing call information");
            }

            WriteLog($"Executing command: {call.Head.Name}");
            var result = await _commandRegistry.ExecuteAsync(call.Head.Name, call);
            WriteLog("Command executed successfully");
            
            return new PluginResponse
            {
                Type = "Value",
                Value = result
            };
        }
        catch (Exception ex)
        {
            WriteLog($"Error executing command: {ex.Message}");
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