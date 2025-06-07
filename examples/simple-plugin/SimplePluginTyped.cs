using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.Json;
using System.Threading.Tasks;
using NuPluginDotNet.Protocol;
using static NuPluginDotNet.Protocol.CommandHelpers;
using static NuPluginDotNet.Protocol.NuTypes;
using static NuPluginDotNet.Protocol.NuValues;

namespace SimplePluginExample;

/// <summary>
/// Example showing how to create a simple nushell plugin using strongly-typed, directly serializable classes.
/// This demonstrates the clean, type-safe approach with excellent IntelliSense support.
/// </summary>
public class SimplePluginTyped : IPluginCommandHandler
{
    /// <summary>
    /// Entry point for the plugin.
    /// </summary>
    public static async Task Main(string[] args)
    {
        // Handle the encoding declaration (required by nushell protocol)
        if (args.Length > 0 && args[0] == "--stdio")
        {
            Console.Write("\x04json");
            Console.Out.Flush();
        }

        // Create our plugin and protocol handler
        var plugin = new SimplePluginTyped();
        var protocolHandler = new NushellProtocolHandler(plugin, debugEnabled: true);

        // Start the protocol - this handles all the nushell communication for us
        await protocolHandler.RunProtocolAsync();
    }

    #region IPluginCommandHandler Implementation

    public async Task<SignatureResponse> HandleSignatureAsync()
    {
        // Return our command signatures using strongly-typed, fluent API
        return new SignatureResponse
        {
            Signature = new object[]
            {
                Command(
                    name: "hello",
                    description: "Says hello to the world",
                    category: "Experimental",
                    searchTerms: new[] { "greeting", "hello" },
                    inputOutputTypes: new[] { InputOutput(NuTypes.Nothing, NuTypes.String) }
                ),
                
                Command(
                    name: "add",
                    description: "Adds two numbers together",
                    category: "Math",
                    searchTerms: new[] { "math", "addition" },
                    requiredPositional: new[]
                    {
                        Positional("a", "First number", NuTypes.Int),
                        Positional("b", "Second number", NuTypes.Int)
                    },
                    inputOutputTypes: new[] { InputOutput(NuTypes.Nothing, NuTypes.Int) }
                ),
                
                Command(
                    name: "greet",
                    description: "Greets a person by name",
                    category: "Experimental",
                    searchTerms: new[] { "greeting", "name" },
                    requiredPositional: new[]
                    {
                        Positional("name", "Name to greet", NuTypes.String)
                    },
                    inputOutputTypes: new[] { InputOutput(NuTypes.Nothing, NuTypes.String) }
                )
            }
        };
    }

    public async Task<MetadataResponse> HandleMetadataAsync()
    {
        return new MetadataResponse
        {
            version = "1.0.0"
        };
    }

    public async Task<object> HandleRunAsync(JsonElement runElement)
    {
        try
        {
            // Extract command name
            var name = runElement.GetProperty("name").GetString() ?? "";
            
            // Route to appropriate command handler
            return name switch
            {
                "hello" => HandleHelloCommand(runElement),
                "add" => HandleAddCommand(runElement),
                "greet" => HandleGreetCommand(runElement),
                _ => NuValues.Error($"Unknown command: {name}")
            };
        }
        catch (Exception ex)
        {
            return NuValues.Error($"Error executing command: {ex.Message}");
        }
    }

    #endregion

    #region Command Handlers

    private object HandleHelloCommand(JsonElement runElement)
    {
        // Simple command that returns a greeting - type-safe and clean!
        return NuValues.String("Hello from .NET nushell plugin!");
    }

    private object HandleAddCommand(JsonElement runElement)
    {
        try
        {
            // Extract positional arguments
            var call = runElement.GetProperty("call");
            var positional = call.GetProperty("positional");
            
            var args = positional.EnumerateArray().ToArray();
            if (args.Length < 2)
            {
                return NuValues.Error("Add command requires two arguments");
            }

            // Parse the numbers using helper methods
            var a = GetIntValue(args[0]);
            var b = GetIntValue(args[1]);
            
            var result = a + b;
            
            // Return type-safe integer value
            return NuValues.Int(result);
        }
        catch (Exception ex)
        {
            return NuValues.Error($"Error in add command: {ex.Message}");
        }
    }

    private object HandleGreetCommand(JsonElement runElement)
    {
        try
        {
            // Extract positional arguments
            var call = runElement.GetProperty("call");
            var positional = call.GetProperty("positional");
            
            var args = positional.EnumerateArray().ToArray();
            if (args.Length < 1)
            {
                return NuValues.Error("Greet command requires a name argument");
            }

            // Parse the name
            var name = GetStringValue(args[0]);
            
            // Return type-safe string value
            return NuValues.String($"Hello, {name}! Nice to meet you.");
        }
        catch (Exception ex)
        {
            return NuValues.Error($"Error in greet command: {ex.Message}");
        }
    }

    #endregion

    #region Helper Methods

    private long GetIntValue(JsonElement element)
    {
        if (element.TryGetProperty("Int", out var intElement) &&
            intElement.TryGetProperty("val", out var valElement))
        {
            return valElement.GetInt64();
        }
        throw new ArgumentException("Expected Int value");
    }

    private string GetStringValue(JsonElement element)
    {
        if (element.TryGetProperty("String", out var stringElement) &&
            stringElement.TryGetProperty("val", out var valElement))
        {
            return valElement.GetString() ?? "";
        }
        throw new ArgumentException("Expected String value");
    }

    #endregion
} 