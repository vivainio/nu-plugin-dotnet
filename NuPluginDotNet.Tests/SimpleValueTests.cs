using System.Text.Json;
using NuPluginDotNet.Plugin;
using static NuPluginDotNet.Protocol.NuValues;
using Xunit.Abstractions;

namespace NuPluginDotNet.Tests;

public class SimpleValueTests
{
    private readonly PluginHost _pluginHost;
    private readonly ITestOutputHelper _output;

    public SimpleValueTests(ITestOutputHelper output)
    {
        _pluginHost = new PluginHost();
        _output = output;
    }

    [Fact]
    public async Task What_Does_StringBuilder_Actually_Return()
    {
        // Create StringBuilder
        var createRunElement = CreateRunElement("dn new", new[] { "System.Text.StringBuilder" });
        var createResponse = await _pluginHost.HandleRunAsync(createRunElement);
        
        _output.WriteLine($"Create response: {JsonSerializer.Serialize(createResponse, new JsonSerializerOptions { WriteIndented = true })}");
        
        // Check what this actually is
        var responseType = createResponse.GetType();
        _output.WriteLine($"Response type: {responseType.Name}");
        
        // Try to get Length property
        var lengthRunElement = CreateRunElementWithInput("dn get", new[] { "Length" }, createResponse);
        var lengthResponse = await _pluginHost.HandleRunAsync(lengthRunElement);
        
        _output.WriteLine($"Length response: {JsonSerializer.Serialize(lengthResponse, new JsonSerializerOptions { WriteIndented = true })}");
        
        // Check if it's a String with an object reference
        if (createResponse.ToString().Contains("String"))
        {
            _output.WriteLine("This appears to be a String representation of an object");
        }
        
        Assert.NotNull(createResponse);
        Assert.NotNull(lengthResponse);
    }

    [Fact]
    public async Task What_Does_Invalid_Type_Actually_Return()
    {
        // Try creating an invalid type
        var invalidRunElement = CreateRunElement("dn new", new[] { "NonExistentType.BadClass" });
        var invalidResponse = await _pluginHost.HandleRunAsync(invalidRunElement);
        
        _output.WriteLine($"Invalid type response: {JsonSerializer.Serialize(invalidResponse, new JsonSerializerOptions { WriteIndented = true })}");
        _output.WriteLine($"Response string: {invalidResponse}");
        
        Assert.NotNull(invalidResponse);
    }

    [Fact]
    public async Task Direct_NuValues_Test()
    {
        // Test what NuValues actually creates
        var stringValue = String("Hello World");
        var intValue = Int(42);
        var errorValue = String("PluginError");
        
        _output.WriteLine($"String value: {JsonSerializer.Serialize(stringValue, new JsonSerializerOptions { WriteIndented = true })}");
        _output.WriteLine($"Int value: {JsonSerializer.Serialize(intValue, new JsonSerializerOptions { WriteIndented = true })}");
        _output.WriteLine($"Error value: {JsonSerializer.Serialize(errorValue, new JsonSerializerOptions { WriteIndented = true })}");
        
        Assert.NotNull(stringValue);
        Assert.NotNull(intValue);
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