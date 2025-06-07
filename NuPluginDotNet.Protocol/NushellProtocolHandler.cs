using System.Text.Json;
using System.Text.Json.Serialization;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace NuPluginDotNet.Protocol;

/// <summary>
/// Handles the nushell plugin protocol communication.
/// This class implements the protocol specification from:
/// https://www.nushell.sh/contributor-book/plugin_protocol_reference.html
/// </summary>
public class NushellProtocolHandler
{
    private readonly bool _debugEnabled;
    private readonly string? _logFile;
    private readonly IPluginCommandHandler _commandHandler;

    public NushellProtocolHandler(IPluginCommandHandler commandHandler, bool debugEnabled = false)
    {
        _commandHandler = commandHandler;
        _debugEnabled = debugEnabled;
        _logFile = debugEnabled ? Path.Combine(Path.GetTempPath(), "nu-plugin-protocol-debug.log") : null;
    }

    /// <summary>
    /// Starts the plugin protocol communication loop.
    /// This method handles the complete nushell plugin protocol lifecycle.
    /// </summary>
    public async Task RunProtocolAsync()
    {
        WriteLog("Starting nushell plugin protocol handler");
        
        try
        {
            // Send Hello message immediately after encoding (following protocol specification)
            await SendHelloMessageAsync();
            
            // Set up Console I/O for JSON protocol
            Console.InputEncoding = System.Text.Encoding.UTF8;
            Console.OutputEncoding = System.Text.Encoding.UTF8;
            
            // Read and respond to messages
            await ProcessMessagesAsync();
            
            WriteLog("Protocol communication ended normally");
        }
        catch (Exception ex)
        {
            WriteLog($"Fatal protocol error: {ex.Message}");
            WriteLog($"Stack trace: {ex.StackTrace}");
            throw;
        }
    }

    /// <summary>
    /// Sends the initial Hello message as required by the protocol.
    /// </summary>
    private async Task SendHelloMessageAsync()
    {
        var hello = new
        {
            Hello = new
            {
                protocol = "nu-plugin",
                version = "0.104.0",
                features = new object[] { }
            }
        };
        
        await SendMessageAsync(hello);
        WriteLog("Hello message sent");
    }

    /// <summary>
    /// Main message processing loop. Handles all incoming messages from nushell.
    /// </summary>
    private async Task ProcessMessagesAsync()
    {
        string? line;
        while ((line = await Console.In.ReadLineAsync()) != null)
        {
            WriteLog($"Received message: {line}");
            
            if (string.IsNullOrWhiteSpace(line))
            {
                WriteLog("Empty line, continuing");
                continue;
            }
            
            try
            {
                var response = await ProcessMessageAsync(line);
                if (response != null)
                {
                    await SendMessageAsync(response);
                }
                
                // Check for Goodbye message to exit gracefully
                if (line.Contains("\"Goodbye\""))
                {
                    WriteLog("Goodbye message detected, exiting");
                    break;
                }
            }
            catch (JsonException ex)
            {
                WriteLog($"JSON parsing error: {ex.Message}");
                var errorResponse = CreateCallErrorResponse(0, $"JSON parsing error: {ex.Message}");
                await SendMessageAsync(errorResponse);
            }
            catch (Exception ex)
            {
                WriteLog($"Message processing error: {ex.Message}");
                WriteLog($"Stack trace: {ex.StackTrace}");
                var errorResponse = CreateCallErrorResponse(0, $"Internal error: {ex.Message}");
                await SendMessageAsync(errorResponse);
            }
        }
        
        WriteLog("Input stream ended");
    }

    /// <summary>
    /// Processes a single message and returns the appropriate response.
    /// </summary>
    private async Task<object?> ProcessMessageAsync(string messageJson)
    {
        // Handle simple string messages like "Goodbye"
        if (messageJson.StartsWith('"') && messageJson.EndsWith('"'))
        {
            var message = JsonSerializer.Deserialize<string>(messageJson);
            if (message == "Goodbye")
            {
                WriteLog("Received Goodbye message, stopping protocol");
                return null; // Signal to stop processing
            }
            else
            {
                WriteLog($"Received unknown string message: {message}");
                return null;
            }
        }
        
        // Parse JSON message
        using var jsonDoc = JsonDocument.Parse(messageJson);
        var root = jsonDoc.RootElement;
        
        if (root.TryGetProperty("Hello", out var helloElement))
        {
            return await ProcessHelloMessageAsync(helloElement);
        }
        else if (root.TryGetProperty("Call", out var callElement))
        {
            return await ProcessCallMessageAsync(callElement);
        }
        else if (root.TryGetProperty("Signal", out var signalElement))
        {
            return await ProcessSignalMessageAsync(signalElement);
        }
        else
        {
            WriteLog($"Unknown message format: {messageJson}");
            return CreateCallErrorResponse(0, "Unknown message format");
        }
    }

    /// <summary>
    /// Processes Hello messages (typically just acknowledgment).
    /// </summary>
    private async Task<object?> ProcessHelloMessageAsync(JsonElement helloElement)
    {
        WriteLog("Received Hello message - no response needed (already sent ours)");
        return null; // We already sent our Hello at startup
    }

    /// <summary>
    /// Processes Call messages and routes them to appropriate handlers.
    /// </summary>
    private async Task<object> ProcessCallMessageAsync(JsonElement callElement)
    {
        WriteLog("Processing Call message");
        
        // Parse the call - it should be a 2-tuple [id, call_type]
        if (callElement.ValueKind != JsonValueKind.Array)
        {
            return CreateCallErrorResponse(0, "Call must be an array");
        }
        
        var callArray = callElement.EnumerateArray().ToArray();
        if (callArray.Length < 2)
        {
            return CreateCallErrorResponse(0, "Call array must have at least 2 elements");
        }
        
        var callId = callArray[0].GetInt32();
        
        try
        {
            object callResponse;
            
            // Check if the second element is a string (simple call type) or object (complex call)
            if (callArray[1].ValueKind == JsonValueKind.String)
            {
                var callType = callArray[1].GetString();
                WriteLog($"Processing simple call - ID: {callId}, Type: {callType}");
                
                callResponse = callType switch
                {
                    "Signature" => await _commandHandler.HandleSignatureAsync(),
                    "Metadata" => await _commandHandler.HandleMetadataAsync(),
                    _ => CreateError($"Unknown call type: {callType}")
                };
            }
            else if (callArray[1].ValueKind == JsonValueKind.Object)
            {
                var callObj = callArray[1];
                if (callObj.TryGetProperty("Run", out var runElement))
                {
                    WriteLog($"Processing Run call - ID: {callId}");
                    callResponse = await _commandHandler.HandleRunAsync(runElement);
                }
                else
                {
                    callResponse = CreateError("Unknown complex call type");
                }
            }
            else
            {
                callResponse = CreateError("Invalid call format");
            }
            
            return new
            {
                CallResponse = new object[] { callId, callResponse }
            };
        }
        catch (Exception ex)
        {
            WriteLog($"Error processing call {callId}: {ex.Message}");
            return CreateCallErrorResponse(callId, ex.Message);
        }
    }

    /// <summary>
    /// Processes Signal messages (like Interrupt, Reset).
    /// </summary>
    private async Task<object?> ProcessSignalMessageAsync(JsonElement signalElement)
    {
        WriteLog("Processing Signal message");
        
        try
        {
            await _commandHandler.HandleSignalAsync(signalElement);
            return null; // Signals typically don't require responses
        }
        catch (Exception ex)
        {
            WriteLog($"Error processing signal: {ex.Message}");
            return null; // Don't send error responses for signals
        }
    }

    /// <summary>
    /// Sends a message to nushell via stdout.
    /// </summary>
    private async Task SendMessageAsync(object message)
    {
        var messageJson = JsonSerializer.Serialize(message);
        Console.WriteLine(messageJson);
        await Console.Out.FlushAsync();
        WriteLog($"Message sent: {messageJson}");
    }

    /// <summary>
    /// Creates a standard error response for a call.
    /// </summary>
    private object CreateCallErrorResponse(int callId, string message)
    {
        return new
        {
            CallResponse = new object[] { callId, CreateError(message) }
        };
    }

    /// <summary>
    /// Creates a standard error object.
    /// </summary>
    private object CreateError(string message)
    {
        return new
        {
            Error = new
            {
                msg = message
            }
        };
    }

    /// <summary>
    /// Writes debug log messages if debugging is enabled.
    /// </summary>
    private void WriteLog(string message)
    {
        if (!_debugEnabled || _logFile == null)
            return;
            
        try
        {
            File.AppendAllText(_logFile, $"[{DateTime.Now:HH:mm:ss.fff}] [Protocol] {message}\n");
        }
        catch
        {
            // Ignore logging errors to avoid causing more issues
        }
    }
}

/// <summary>
/// Interface for handling plugin commands. Implement this interface to provide
/// your plugin's command handling logic.
/// </summary>
public interface IPluginCommandHandler
{
    /// <summary>
    /// Handle the Signature call - return command signatures.
    /// Called when nushell wants to know what commands your plugin provides.
    /// </summary>
    Task<object> HandleSignatureAsync();
    
    /// <summary>
    /// Handle the Metadata call - return plugin metadata.
    /// Called when nushell wants information about your plugin.
    /// </summary>
    Task<object> HandleMetadataAsync();
    
    /// <summary>
    /// Handle the Run call - execute a command.
    /// Called when nushell wants to execute one of your commands.
    /// </summary>
    Task<object> HandleRunAsync(JsonElement runElement);
    
    /// <summary>
    /// Handle Signal messages (optional - default implementation does nothing).
    /// Called when nushell sends signals like Interrupt (Ctrl+C) or Reset.
    /// </summary>
    Task HandleSignalAsync(JsonElement signalElement)
    {
        return Task.CompletedTask;
    }
} 