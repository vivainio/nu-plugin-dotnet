using System.Text.Json;
using NuPluginDotNet.Plugin;
using static NuPluginDotNet.Protocol.NuValues;

namespace NuPluginDotNet.Tests;

public class IssueDebugTests
{
    private readonly PluginHost _pluginHost;

    public IssueDebugTests()
    {
        _pluginHost = new PluginHost();
    }

    [Fact]
    public async Task Debug_StringBuilder_Creation_And_Length()
    {
        // Test creating StringBuilder and getting its length
        var createRunElement = CreateRunElement("dn new", new[] { "System.Text.StringBuilder" });
        var createResponse = await _pluginHost.HandleRunAsync(createRunElement);
        
        Console.WriteLine($"Create response: {JsonSerializer.Serialize(createResponse)}");

        // Get Length property
        var lengthRunElement = CreateRunElementWithInput("dn get", new[] { "Length" }, createResponse);
        var lengthResponse = await _pluginHost.HandleRunAsync(lengthRunElement);
        
        Console.WriteLine($"Length response: {JsonSerializer.Serialize(lengthResponse)}");
        
        Assert.NotNull(createResponse);
        Assert.NotNull(lengthResponse);
    }

    [Fact]
    public async Task Debug_StringBuilder_Append_And_ToString()
    {
        // Create StringBuilder
        var createRunElement = CreateRunElement("dn new", new[] { "System.Text.StringBuilder" });
        var createResponse = await _pluginHost.HandleRunAsync(createRunElement);
        
        Console.WriteLine($"Create response: {JsonSerializer.Serialize(createResponse)}");

        // Append to it
        var appendRunElement = CreateRunElementWithInput("dn call", new[] { "Append", "Hello World" }, createResponse);
        var appendResponse = await _pluginHost.HandleRunAsync(appendRunElement);
        
        Console.WriteLine($"Append response: {JsonSerializer.Serialize(appendResponse)}");

        // Get ToString
        var toStringRunElement = CreateRunElementWithInput("dn call", new[] { "ToString" }, appendResponse);
        var toStringResponse = await _pluginHost.HandleRunAsync(toStringRunElement);
        
        Console.WriteLine($"ToString response: {JsonSerializer.Serialize(toStringResponse)}");
        
        Assert.NotNull(createResponse);
        Assert.NotNull(appendResponse);
        Assert.NotNull(toStringResponse);
    }

    [Fact]
    public async Task Debug_Error_Responses()
    {
        // Try creating an invalid type to see error format
        var invalidRunElement = CreateRunElement("dn new", new[] { "NonExistentType.BadClass" });
        var invalidResponse = await _pluginHost.HandleRunAsync(invalidRunElement);
        
        Console.WriteLine($"Invalid type response: {JsonSerializer.Serialize(invalidResponse)}");
        
        Assert.NotNull(invalidResponse);
    }

    [Fact]
    public async Task Debug_Assembly_List()
    {
        // Get assembly list to see what's actually returned
        var assembliesRunElement = CreateRunElement("dn assemblies", Array.Empty<string>());
        var assembliesResponse = await _pluginHost.HandleRunAsync(assembliesRunElement);
        
        Console.WriteLine($"Assemblies response: {JsonSerializer.Serialize(assembliesResponse)}");
        
        Assert.NotNull(assembliesResponse);
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