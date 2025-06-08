using System.Text.Json;
using NuPluginDotNet.Plugin;
using static NuPluginDotNet.Protocol.NuValues;

namespace NuPluginDotNet.Tests;

public class DebugTests
{
    private readonly PluginHost _pluginHost;

    public DebugTests()
    {
        _pluginHost = new PluginHost();
    }

    [Fact]
    public async Task Debug_NuValues_DirectUsage()
    {
        // Test creating values directly with NuValues
        var stringValue = String("Hello World");
        var intValue = Int(42);
        var floatValue = Float(3.14);

        // Output what we get
        var stringJson = JsonSerializer.Serialize(stringValue);
        var intJson = JsonSerializer.Serialize(intValue);
        var floatJson = JsonSerializer.Serialize(floatValue);

        // These should not fail - just to see the structure
        Assert.NotNull(stringJson);
        Assert.NotNull(intJson);
        Assert.NotNull(floatJson);

        // Debug output for understanding
        System.Console.WriteLine($"String: {stringJson}");
        System.Console.WriteLine($"Int: {intJson}");
        System.Console.WriteLine($"Float: {floatJson}");
    }

    [Fact]
    public async Task Debug_Plugin_StringBuilder_Creation()
    {
        // Test what the plugin actually returns for StringBuilder creation
        var createRunElement = CreateRunElement("dn new", new[] { "System.Text.StringBuilder" });
        var createResponse = await _pluginHost.HandleRunAsync(createRunElement);

        var responseJson = JsonSerializer.Serialize(createResponse);
        System.Console.WriteLine($"StringBuilder creation response: {responseJson}");

        Assert.NotNull(createResponse);
    }

    [Fact]
    public async Task Debug_Plugin_StringBuilder_ToString()
    {
        // Test getting the ToString() of a StringBuilder
        var createRunElement = CreateRunElement("dn new", new[] { "System.Text.StringBuilder" });
        var createResponse = await _pluginHost.HandleRunAsync(createRunElement);

        // Try calling ToString() on it
        var toStringRunElement = CreateRunElementWithInput(
            "dn call", 
            new[] { "ToString" }, 
            createResponse
        );

        var toStringResponse = await _pluginHost.HandleRunAsync(toStringRunElement);
        var responseJson = JsonSerializer.Serialize(toStringResponse);
        System.Console.WriteLine($"StringBuilder ToString response: {responseJson}");

        Assert.NotNull(toStringResponse);
    }

    private JsonElement CreateRunElement(string commandName, string[] args)
    {
        var runData = new
        {
            name = commandName,
            call = new
            {
                positional = args.Select(arg => String(arg)).ToArray(),
                named = new { }
            }
        };

        var json = JsonSerializer.Serialize(runData);
        return JsonDocument.Parse(json).RootElement;
    }

    private JsonElement CreateRunElementWithInput(string commandName, string[] args, object input)
    {
        var runData = new
        {
            name = commandName,
            call = new
            {
                positional = args.Select(arg => String(arg)).ToArray(),
                named = new { }
            },
            input = new { Value = input }
        };

        var json = JsonSerializer.Serialize(runData);
        return JsonDocument.Parse(json).RootElement;
    }
} 