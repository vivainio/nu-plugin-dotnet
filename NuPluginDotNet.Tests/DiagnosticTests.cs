using System.Text.Json;
using NuPluginDotNet.Plugin;
using static NuPluginDotNet.Protocol.NuValues;
using Xunit.Abstractions;

namespace NuPluginDotNet.Tests;

public class DiagnosticTests
{
    private readonly PluginHost _pluginHost;
    private readonly ITestOutputHelper _output;

    public DiagnosticTests(ITestOutputHelper output)
    {
        _pluginHost = new PluginHost();
        _output = output;
    }

    [Fact]
    public async Task Debug_Step_By_Step_StringBuilder()
    {
        // Step 1: Create StringBuilder
        var createRunElement = CreateRunElement("dn new", new[] { "System.Text.StringBuilder" });
        var createResponse = await _pluginHost.HandleRunAsync(createRunElement);
        
        _output.WriteLine($"Step 1 - Create StringBuilder:");
        _output.WriteLine($"  Response: {JsonSerializer.Serialize(createResponse)}");
        _output.WriteLine($"  Response Type: {createResponse?.GetType().Name}");
        
        // Step 2: Try to use the created object directly as input
        var inputForCall = createResponse; // This is what the test does
        
        _output.WriteLine($"Step 2 - Input for method call:");
        _output.WriteLine($"  Input: {JsonSerializer.Serialize(inputForCall)}");
        _output.WriteLine($"  Input Type: {inputForCall?.GetType().Name}");
        
        // Step 3: Create the method call element 
        var callRunElement = CreateRunElementWithInput("dn call", new[] { "Append", "Hello" }, inputForCall);
        
        _output.WriteLine($"Step 3 - Call element:");
        _output.WriteLine($"  Call Element: {callRunElement}");
        
        // Step 4: Execute the call
        var callResponse = await _pluginHost.HandleRunAsync(callRunElement);
        
        _output.WriteLine($"Step 4 - Method call response:");
        _output.WriteLine($"  Response: {JsonSerializer.Serialize(callResponse)}");
        _output.WriteLine($"  Response Type: {callResponse?.GetType().Name}");
        
        // Check if it's an error
        var responseString = JsonSerializer.Serialize(callResponse);
        if (responseString.Contains("PluginError"))
        {
            _output.WriteLine($"  ERROR DETECTED: {responseString}");
        }
        
        // Let's also test what the StringBuilder object looks like when parsed
        if (createResponse != null)
        {
            _output.WriteLine($"Step 5 - Analyzing create response structure:");
            var responseProps = createResponse.GetType().GetProperties();
            foreach (var prop in responseProps)
            {
                try
                {
                    var value = prop.GetValue(createResponse);
                    _output.WriteLine($"  {prop.Name}: {value} (Type: {value?.GetType().Name})");
                }
                catch (Exception ex)
                {
                    _output.WriteLine($"  {prop.Name}: ERROR - {ex.Message}");
                }
            }
        }
    }

    [Fact]
    public async Task Debug_Custom_Object_Parsing()
    {
        // Step 1: Create StringBuilder
        var createRunElement = CreateRunElement("dn new", new[] { "System.Text.StringBuilder" });
        var createResponse = await _pluginHost.HandleRunAsync(createRunElement);
        
        _output.WriteLine($"Step 1 - Create response: {JsonSerializer.Serialize(createResponse, new JsonSerializerOptions { WriteIndented = true })}");
        
        // Step 2: Extract the custom object and try to use it as input
        var customValue = GetValueByReflection(createResponse, "Custom");
        if (customValue != null)
        {
            var val = GetValueByReflection(customValue, "val");
            _output.WriteLine($"Step 2 - Custom val: {JsonSerializer.Serialize(val, new JsonSerializerOptions { WriteIndented = true })}");
            
            var objectId = GetValueByReflection(val, "object_id")?.ToString();
            var typeName = GetValueByReflection(val, "type_name")?.ToString();
            _output.WriteLine($"Step 2 - Extracted object_id: {objectId}, type_name: {typeName}");
            
            // Step 3: Create a call element using the extracted custom object
            var customInput = new { Custom = customValue };
            var callRunElement = CreateRunElementWithInput("dn call", new[] { "Append", "test" }, customInput);
            
            _output.WriteLine($"Step 3 - Call element input: {JsonSerializer.Serialize(callRunElement, new JsonSerializerOptions { WriteIndented = true })}");
            
            var callResponse = await _pluginHost.HandleRunAsync(callRunElement);
            _output.WriteLine($"Step 3 - Call response: {JsonSerializer.Serialize(callResponse, new JsonSerializerOptions { WriteIndented = true })}");
        }
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

    private object GetValueByReflection(object obj, string propertyName)
    {
        var propertyInfo = obj.GetType().GetProperty(propertyName);
        if (propertyInfo != null)
        {
            return propertyInfo.GetValue(obj);
        }
        return null;
    }
} 