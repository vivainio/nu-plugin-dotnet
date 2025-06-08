using System.Text.Json;
using NuPluginDotNet.Plugin;
using NuPluginDotNet.Types;
using NuPluginDotNet.Commands;
using NuPluginDotNet.DotNet;
using static NuPluginDotNet.Protocol.NuValues;
using Xunit.Abstractions;

namespace NuPluginDotNet.Tests;

public class ProtocolBugReproductionTest
{
    private readonly PluginHost _pluginHost;
    private readonly ITestOutputHelper _output;

    public ProtocolBugReproductionTest(ITestOutputHelper output)
    {
        _pluginHost = new PluginHost();
        _output = output;
    }

    [Fact]
    public async Task Reproduce_Protocol_Custom_Object_To_String_Bug()
    {
        _output.WriteLine("=== Testing the complete protocol pipeline to find where Custom->String conversion happens ===");
        
        // Step 1: Test PluginValue.Custom creation directly
        var customValue = PluginValue.Custom("test-object-id", "System.Collections.ArrayList");
        _output.WriteLine($"Step 1 - Direct PluginValue.Custom:");
        _output.WriteLine($"  Type: {customValue.Type}");
        _output.WriteLine($"  IsCustom: {customValue.IsCustom}");
        _output.WriteLine($"  ObjectId: {customValue.GetObjectId()}");
        _output.WriteLine($"  TypeName: {customValue.GetTypeName()}");
        
        // Step 2: Test ConvertPluginValueToNuValue method directly
        var nuValue = CallConvertPluginValueToNuValue(customValue);
        _output.WriteLine($"\nStep 2 - ConvertPluginValueToNuValue result:");
        _output.WriteLine($"  Result type: {nuValue?.GetType()}");
        _output.WriteLine($"  Result: {nuValue}");
        
        var nuValueJson = JsonSerializer.Serialize(nuValue, new JsonSerializerOptions { WriteIndented = true });
        _output.WriteLine($"  JSON:\n{nuValueJson}");
        
        // Step 3: Test PluginResponse creation and serialization
        var pluginResponse = new PluginResponse
        {
            Type = "Value",
            Value = customValue
        };
        
        _output.WriteLine($"\nStep 3 - PluginResponse creation:");
        _output.WriteLine($"  Response.Type: {pluginResponse.Type}");
        _output.WriteLine($"  Response.Value type: {pluginResponse.Value?.GetType()}");
        _output.WriteLine($"  Response.Value: {pluginResponse.Value}");
        
        var responseJson = JsonSerializer.Serialize(pluginResponse, new JsonSerializerOptions { WriteIndented = true });
        _output.WriteLine($"  PluginResponse JSON:\n{responseJson}");
        
        // Step 4: Test the HandleRunAsync full pipeline result 
        var runElement = CreateRunElement("dn new", new[] { "System.Collections.ArrayList" });
        var fullResult = await _pluginHost.HandleRunAsync(runElement);
        
        _output.WriteLine($"\nStep 4 - Full HandleRunAsync pipeline:");
        _output.WriteLine($"  Result type: {fullResult?.GetType()}");
        _output.WriteLine($"  Result: {fullResult}");
        
        var fullResultJson = JsonSerializer.Serialize(fullResult, new JsonSerializerOptions { WriteIndented = true });
        _output.WriteLine($"  Full result JSON:\n{fullResultJson}");
        
        // Step 5: Test protocol wrapper simulation
        var callResponse = fullResult;
        var protocolResponse = new
        {
            CallResponse = new object[] { 0, callResponse }
        };
        
        _output.WriteLine($"\nStep 5 - Protocol wrapper simulation:");
        _output.WriteLine($"  CallResponse type: {callResponse?.GetType()}");
        _output.WriteLine($"  Protocol response type: {protocolResponse.GetType()}");
        
        var protocolJson = JsonSerializer.Serialize(protocolResponse, new JsonSerializerOptions { WriteIndented = true });
        _output.WriteLine($"  Protocol response JSON:\n{protocolJson}");
        
        // Step 6: Check if the issue is in the JSON serialization itself
        _output.WriteLine($"\nStep 6 - JSON Serialization Analysis:");
        
        // Test serializing just the custom value
        var customValueJson = JsonSerializer.Serialize(customValue, new JsonSerializerOptions { WriteIndented = true });
        _output.WriteLine($"  Direct PluginValue.Custom JSON:\n{customValueJson}");
        
        // Test deserializing it back
        var deserializedCustomValue = JsonSerializer.Deserialize<PluginValue>(customValueJson);
        _output.WriteLine($"  Deserialized type: {deserializedCustomValue?.Type}");
        _output.WriteLine($"  Deserialized IsCustom: {deserializedCustomValue?.IsCustom}");
        
        // ASSERTIONS TO PINPOINT THE BUG
        _output.WriteLine($"\n=== ANALYSIS ===");
        
        // Check where the conversion happens
        Assert.Equal(PluginValueType.Custom, customValue.Type);
        Assert.True(customValue.IsCustom);
        
        // The ConvertPluginValueToNuValue should return a Custom object structure, not a string
        _output.WriteLine($"ConvertPluginValueToNuValue returns: {nuValue?.GetType()}");
        
        // Check if the issue is in the PluginResponse serialization
        Assert.Contains("Custom", responseJson);
        
        // The full result should contain Custom object, not String
        _output.WriteLine($"Full result analysis: Looking for Custom vs String in JSON");
        _output.WriteLine($"Contains 'Custom': {fullResultJson.Contains("Custom")}");
        _output.WriteLine($"Contains 'String': {fullResultJson.Contains("String")}");
        
        // THIS IS THE KEY TEST - if this fails, we found where the bug happens
        if (fullResultJson.Contains("String") && !fullResultJson.Contains("Custom"))
        {
            _output.WriteLine("🔥 BUG FOUND: Full pipeline converts Custom to String!");
            _output.WriteLine("The issue is in the HandleRunAsync method or its dependencies.");
        }
        else if (protocolJson.Contains("String") && !protocolJson.Contains("Custom"))
        {
            _output.WriteLine("🔥 BUG FOUND: Protocol wrapper converts Custom to String!");
            _output.WriteLine("The issue is in the protocol response wrapping.");
        }
        else
        {
            _output.WriteLine("✅ Custom object structure preserved - bug might be elsewhere");
        }
    }

    // Helper method to access the private ConvertPluginValueToNuValue method
    private object CallConvertPluginValueToNuValue(PluginValue value)
    {
        var method = typeof(PluginHost).GetMethod("ConvertPluginValueToNuValue", 
            System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance);
        return method!.Invoke(_pluginHost, new object[] { value })!;
    }

    // Helper method to create a proper RunElement for testing
    private JsonElement CreateRunElement(string commandName, string[] args)
    {
        var positionalArgs = args.Select(arg => new { String = new { val = arg, span = new { start = 0, end = 0 } } }).ToArray();
        
        var runCall = new
        {
            name = commandName,
            call = new
            {
                head = new { start = 0, end = 0 },
                positional = positionalArgs,
                named = new object[0]
            },
            input = "Empty"
        };

        var json = JsonSerializer.Serialize(runCall);
        var document = JsonDocument.Parse(json);
        return document.RootElement;
    }
} 