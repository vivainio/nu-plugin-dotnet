using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.Json;
using System.Threading.Tasks;
using NuPluginDotNet.Protocol;

namespace SimplePluginExample;

/// <summary>
/// Example showing how to create a simple nushell plugin using the NushellProtocolHandler.
/// This demonstrates the clean separation between protocol handling and business logic.
/// </summary>
public class SimplePlugin : IPluginCommandHandler
{
    private readonly Dictionary<string, Func<JsonElement, Task<object>>> _commands;

    public SimplePlugin()
    {
        // Register our commands
        _commands = new Dictionary<string, Func<JsonElement, Task<object>>>
        {
            ["hello"] = HandleHelloCommand,
            ["add"] = HandleAddCommand,
            ["greet"] = HandleGreetCommand
        };
    }

    /// <summary>
    /// Entry point for the plugin. Shows how simple it is to start a nushell plugin.
    /// </summary>
    public static async Task Main(string[] args)
    {
        // Handle the encoding declaration (required by nushell protocol)
        if (args.Length > 0 && args[0] == "--stdio")
        {
            // Send encoding type as required by protocol
            Console.Write("\x04json");
            Console.Out.Flush();
        }

        // Create our plugin and protocol handler
        var plugin = new SimplePlugin();
        var protocolHandler = new NushellProtocolHandler(plugin, debugEnabled: true);

        // Start the protocol - this handles all the nushell communication for us
        await protocolHandler.RunProtocolAsync();
    }

    #region IPluginCommandHandler Implementation

    public async Task<object> HandleSignatureAsync()
    {
        // Return our command signatures - what commands we support
        return new object[]
        {
            new
            {
                sig = new
                {
                    name = "hello",
                    description = "Says hello to the world",
                    extra_description = "",
                    search_terms = new string[] { "greeting", "hello" },
                    required_positional = new object[0],
                    optional_positional = new object[0],
                    rest_positional = (object?)null,
                    named = new object[0],
                    input_output_types = new object[]
                    {
                        new object[]
                        {
                            new { Nothing = new object() },
                            new { String = new object() }
                        }
                    },
                    allow_variants_without_examples = true,
                    creates_scope = false,
                    allows_unknown_args = false,
                    category = "Experimental"
                }
            },
            new
            {
                sig = new
                {
                    name = "add",
                    description = "Adds two numbers together",
                    extra_description = "",
                    search_terms = new string[] { "math", "addition" },
                    required_positional = new object[]
                    {
                        new
                        {
                            name = "a",
                            description = "First number",
                            shape = new { Int = new object() }
                        },
                        new
                        {
                            name = "b", 
                            description = "Second number",
                            shape = new { Int = new object() }
                        }
                    },
                    optional_positional = new object[0],
                    rest_positional = (object?)null,
                    named = new object[0],
                    input_output_types = new object[]
                    {
                        new object[]
                        {
                            new { Nothing = new object() },
                            new { Int = new object() }
                        }
                    },
                    allow_variants_without_examples = true,
                    creates_scope = false,
                    allows_unknown_args = false,
                    category = "Math"
                }
            },
            new
            {
                sig = new
                {
                    name = "greet",
                    description = "Greets a person by name",
                    extra_description = "",
                    search_terms = new string[] { "greeting", "name" },
                    required_positional = new object[]
                    {
                        new
                        {
                            name = "name",
                            description = "Name to greet",
                            shape = new { String = new object() }
                        }
                    },
                    optional_positional = new object[0],
                    rest_positional = (object?)null,
                    named = new object[0],
                    input_output_types = new object[]
                    {
                        new object[]
                        {
                            new { Nothing = new object() },
                            new { String = new object() }
                        }
                    },
                    allow_variants_without_examples = true,
                    creates_scope = false,
                    allows_unknown_args = false,
                    category = "Experimental"
                }
            }
        };
    }

    public async Task<object> HandleMetadataAsync()
    {
        return new
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
            
            // Find and execute the command
            if (_commands.TryGetValue(name, out var handler))
            {
                return await handler(runElement);
            }
            else
            {
                return CreateError($"Unknown command: {name}");
            }
        }
        catch (Exception ex)
        {
            return CreateError($"Error executing command: {ex.Message}");
        }
    }

    #endregion

    #region Command Handlers

    private async Task<object> HandleHelloCommand(JsonElement runElement)
    {
        // Simple command that returns a greeting
        return CreateStringValue("Hello from .NET nushell plugin!");
    }

    private async Task<object> HandleAddCommand(JsonElement runElement)
    {
        try
        {
            // Extract positional arguments
            var call = runElement.GetProperty("call");
            var positional = call.GetProperty("positional");
            
            var args = positional.EnumerateArray().ToArray();
            if (args.Length < 2)
            {
                return CreateError("Add command requires two arguments");
            }

            // Parse the numbers
            var a = GetIntValue(args[0]);
            var b = GetIntValue(args[1]);
            
            var result = a + b;
            
            return CreateIntValue(result);
        }
        catch (Exception ex)
        {
            return CreateError($"Error in add command: {ex.Message}");
        }
    }

    private async Task<object> HandleGreetCommand(JsonElement runElement)
    {
        try
        {
            // Extract positional arguments
            var call = runElement.GetProperty("call");
            var positional = call.GetProperty("positional");
            
            var args = positional.EnumerateArray().ToArray();
            if (args.Length < 1)
            {
                return CreateError("Greet command requires a name argument");
            }

            // Parse the name
            var name = GetStringValue(args[0]);
            
            return CreateStringValue($"Hello, {name}! Nice to meet you.");
        }
        catch (Exception ex)
        {
            return CreateError($"Error in greet command: {ex.Message}");
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

    private object CreateStringValue(string value)
    {
        return new
        {
            String = new
            {
                val = value,
                span = new { start = 0, end = 0 }
            }
        };
    }

    private object CreateIntValue(long value)
    {
        return new
        {
            Int = new
            {
                val = value,
                span = new { start = 0, end = 0 }
            }
        };
    }

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

    #endregion
} 