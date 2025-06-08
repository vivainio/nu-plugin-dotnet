using System.Text.Json;
using NuPluginDotNet.Plugin;
using NuPluginDotNet.Types;
using NuPluginDotNet.Commands;
using NuPluginDotNet.DotNet;
using static NuPluginDotNet.Protocol.NuValues;
using Xunit.Abstractions;

namespace NuPluginDotNet.Tests;

public class CustomObjectBugTest
{
    private readonly PluginHost _pluginHost;
    private readonly ITestOutputHelper _output;

    public CustomObjectBugTest(ITestOutputHelper output)
    {
        _pluginHost = new PluginHost();
        _output = output;
    }

    [Fact]
    public async Task Debug_Custom_Object_Conversion()
    {
        // Test creating a PluginValue.Custom directly
        var customValue = PluginValue.Custom("test-object-id", "System.Collections.ArrayList");
        
        // Check the PluginValue properties
        Assert.Equal(PluginValueType.Custom, customValue.Type);
        Assert.Equal("test-object-id", customValue.GetObjectId());
        Assert.Equal("System.Collections.ArrayList", customValue.GetTypeName());
        
        _output.WriteLine($"PluginValue.Type: {customValue.Type}");
        _output.WriteLine($"PluginValue.Value: {JsonSerializer.Serialize(customValue.Value)}");
    }

    [Fact]
    public async Task Debug_DnNew_ArrayList_Response()
    {
        // Test what dn new actually returns
        var createRunElement = CreateRunElement("dn new", new[] { "System.Collections.ArrayList" });
        var createResponse = await _pluginHost.HandleRunAsync(createRunElement);

        // Serialize the response to see its structure
        var responseJson = JsonSerializer.Serialize(createResponse, new JsonSerializerOptions { WriteIndented = true });
        Console.WriteLine($"dn new ArrayList response:\n{responseJson}");
        
        // Check what type it is
        Console.WriteLine($"Response type: {createResponse?.GetType()}");
        Console.WriteLine($"Response string: {createResponse}");
        
        Assert.NotNull(createResponse);
    }

    [Fact]
    public async Task Test_ConvertPluginValueToNuValue_With_Custom()
    {
        // Create a custom PluginValue 
        var customValue = PluginValue.Custom("test-id", "TestType");
        
        // Test the private ConvertPluginValueToNuValue method using reflection
        var pluginHost = new PluginHost();
        var method = typeof(PluginHost).GetMethod("ConvertPluginValueToNuValue", 
            System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance);
        
        if (method != null)
        {
            var result = method.Invoke(pluginHost, new object[] { customValue });
            var resultJson = JsonSerializer.Serialize(result, new JsonSerializerOptions { WriteIndented = true });
            
            _output.WriteLine($"ConvertPluginValueToNuValue result:\n{resultJson}");
            _output.WriteLine($"Result type: {result?.GetType()}");
            
            Assert.NotNull(result);
            // The result should contain a Custom property
            Assert.Contains("Custom", resultJson);
            Assert.Contains("object_id", resultJson);
            Assert.Contains("type_name", resultJson);
        }
        else
        {
            Assert.True(false, "Could not find ConvertPluginValueToNuValue method");
        }
    }

    [Fact]
    public async Task Reproduce_Custom_Object_Bug_Step_By_Step()
    {
        // This test reproduces the exact bug step by step to isolate where the issue occurs
        
        _output.WriteLine("=== STEP 1: Test DnNewCommand directly ===");
        
        // Create the components manually
        var objectManager = new ObjectManager();
        var assemblyManager = new AssemblyManager();
        var valueConverter = new ValueConverter(objectManager);
        var dnNewCommand = new DotNetNewCommand(objectManager, assemblyManager, valueConverter);
        
        // Create command args for "dn new System.Collections.ArrayList"
        var pluginCall = new PluginCall();
        pluginCall.Head.Name = "dn new";
        pluginCall.Positional.Add(PluginValue.String("System.Collections.ArrayList"));
        var commandArgs = new CommandArgs(pluginCall, valueConverter);
        
        // Execute the command directly
        var directResult = await dnNewCommand.ExecuteAsync(commandArgs);
        
        _output.WriteLine($"Direct command result - Type: {directResult.Type}");
        _output.WriteLine($"Direct command result - Value: {JsonSerializer.Serialize(directResult.Value)}");
        _output.WriteLine($"Direct command result - IsCustom: {directResult.IsCustom}");
        
        // This should be a Custom PluginValue
        Assert.Equal(PluginValueType.Custom, directResult.Type);
        Assert.True(directResult.IsCustom);
        
        _output.WriteLine("\n=== STEP 2: Test CommandRegistry.ExecuteAsync ===");
        
        // Test through CommandRegistry
        var commandRegistry = new CommandRegistry(objectManager, assemblyManager, valueConverter);
        var registryResult = await commandRegistry.ExecuteAsync("dn new", pluginCall);
        
        _output.WriteLine($"Registry result - Type: {registryResult.Type}");
        _output.WriteLine($"Registry result - Value: {JsonSerializer.Serialize(registryResult.Value)}");
        _output.WriteLine($"Registry result - IsCustom: {registryResult.IsCustom}");
        
        // This should still be a Custom PluginValue
        Assert.Equal(PluginValueType.Custom, registryResult.Type);
        Assert.True(registryResult.IsCustom);
        
        _output.WriteLine("\n=== STEP 3: Test PluginHost.HandleRun (internal) ===");
        
        // Test the internal HandleRun method through reflection
        var pluginHost = new PluginHost();
        var handleRunMethod = typeof(PluginHost).GetMethod("HandleRun", 
            System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance);
        
        var pluginRequest = new PluginRequest
        {
            Type = "Run",
            Call = pluginCall
        };
        
        if (handleRunMethod != null)
        {
            var handleRunTask = (Task<PluginResponse>)handleRunMethod.Invoke(pluginHost, new object[] { pluginRequest });
            var handleRunResult = await handleRunTask;
            
            _output.WriteLine($"HandleRun result - Type: {handleRunResult.Type}");
            _output.WriteLine($"HandleRun result - Value type: {handleRunResult.Value?.GetType()}");
            _output.WriteLine($"HandleRun result - Value: {handleRunResult.Value}");
            
            // Check if this is still a PluginValue
            if (handleRunResult.Value is PluginValue pluginValue)
            {
                _output.WriteLine($"HandleRun PluginValue - Type: {pluginValue.Type}");
                _output.WriteLine($"HandleRun PluginValue - IsCustom: {pluginValue.IsCustom}");
                Assert.Equal(PluginValueType.Custom, pluginValue.Type);
            }
            else
            {
                _output.WriteLine($"HandleRun result is NOT a PluginValue, it's: {handleRunResult.Value?.GetType()}");
                Assert.True(false, $"HandleRun should return a PluginValue, but returned: {handleRunResult.Value?.GetType()}");
            }
        }
        else
        {
            Assert.True(false, "Could not find HandleRun method");
        }
        
        _output.WriteLine("\n=== STEP 4: Test ConvertPluginValueToNuValue ===");
        
        // Test the conversion method that should preserve Custom objects
        var convertMethod = typeof(PluginHost).GetMethod("ConvertPluginValueToNuValue", 
            System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance);
        
        if (convertMethod != null)
        {
            var convertResult = convertMethod.Invoke(pluginHost, new object[] { directResult });
            var convertJson = JsonSerializer.Serialize(convertResult, new JsonSerializerOptions { WriteIndented = true });
            
            _output.WriteLine($"ConvertPluginValueToNuValue result:\n{convertJson}");
            
            // This should contain a Custom object structure
            Assert.Contains("Custom", convertJson);
            Assert.Contains("object_id", convertJson);
            Assert.Contains("type_name", convertJson);
        }
        
        _output.WriteLine("\n=== STEP 5: Test full HandleRunAsync pipeline ===");
        
        // Test the full pipeline
        var runElement = CreateRunElement("dn new", new[] { "System.Collections.ArrayList" });
        var fullResult = await pluginHost.HandleRunAsync(runElement);
        
        var fullJson = JsonSerializer.Serialize(fullResult, new JsonSerializerOptions { WriteIndented = true });
        _output.WriteLine($"Full pipeline result:\n{fullJson}");
        
        // THIS IS WHERE THE BUG SHOULD MANIFEST
        if (fullJson.Contains("\"String\""))
        {
            _output.WriteLine("🐛 BUG FOUND: Full pipeline returns String instead of Custom object!");
            _output.WriteLine("The issue is in the HandleRunAsync method or the protocol layer.");
            Assert.True(false, "Bug found: Custom object converted to string in full pipeline!");
        }
        else if (fullJson.Contains("\"Custom\""))
        {
            _output.WriteLine("✅ Full pipeline correctly returns Custom object");
        }
        else
        {
            _output.WriteLine("❓ Unexpected result structure");
            Assert.True(false, $"Unexpected result structure: {fullJson}");
        }
    }

    [Fact]
    public async Task Simple_Debug_DnNew_ArrayList()
    {
        // Just see what happens when we call dn new directly
        _output.WriteLine("=== Testing DnNewCommand directly ===");
        
        try
        {
            // Create components manually
            var objectManager = new ObjectManager();
            var assemblyManager = new AssemblyManager();
            var valueConverter = new ValueConverter(objectManager);
            var dnNewCommand = new DotNetNewCommand(objectManager, assemblyManager, valueConverter);
            
            // Create command args for "dn new System.Collections.ArrayList"
            var pluginCall = new PluginCall();
            pluginCall.Head.Name = "dn new";
            pluginCall.Positional.Add(PluginValue.String("System.Collections.ArrayList"));
            var commandArgs = new CommandArgs(pluginCall, valueConverter);
            
            // Execute the command directly
            var directResult = await dnNewCommand.ExecuteAsync(commandArgs);
            
            _output.WriteLine($"=== DIRECT COMMAND RESULT ===");
            _output.WriteLine($"Type: {directResult.Type}");
            _output.WriteLine($"IsCustom: {directResult.IsCustom}");
            _output.WriteLine($"Value: {directResult.Value}");
            _output.WriteLine($"Value type: {directResult.Value?.GetType()}");
            
            if (directResult.IsCustom)
            {
                _output.WriteLine($"Object ID: {directResult.GetObjectId()}");
                _output.WriteLine($"Type Name: {directResult.GetTypeName()}");
            }
            
            var resultJson = JsonSerializer.Serialize(directResult.Value, new JsonSerializerOptions { WriteIndented = true });
            _output.WriteLine($"Value JSON:\n{resultJson}");

            // This should be a Custom PluginValue
            Assert.Equal(PluginValueType.Custom, directResult.Type);
            Assert.True(directResult.IsCustom);
            
            // Now test the full pipeline to see where the conversion happens
            _output.WriteLine("\n=== Testing full PluginHost.HandleRunAsync pipeline ===");
            
            var runElement = CreateRunElement("dn new", new[] { "System.Collections.ArrayList" });
            var fullResult = await _pluginHost.HandleRunAsync(runElement);
            
            var fullJson = JsonSerializer.Serialize(fullResult, new JsonSerializerOptions { WriteIndented = true });
            _output.WriteLine($"Full pipeline result:\n{fullJson}");
            
            // THIS IS WHERE THE BUG SHOULD MANIFEST
            if (fullJson.Contains("\"String\""))
            {
                _output.WriteLine("🐛 BUG FOUND: Full pipeline returns String instead of Custom object!");
                _output.WriteLine("The issue is in the HandleRunAsync method or the protocol layer.");
                Assert.True(false, "Bug found: Custom object converted to string in full pipeline!");
            }
            else if (fullJson.Contains("\"Custom\""))
            {
                _output.WriteLine("✅ Full pipeline correctly returns Custom object");
            }
            else
            {
                _output.WriteLine("❓ Unexpected result structure");
                Assert.True(false, $"Unexpected result structure: {fullJson}");
            }
        }
        catch (Exception ex)
        {
            _output.WriteLine($"Exception: {ex.Message}");
            _output.WriteLine($"Stack trace: {ex.StackTrace}");
            throw; // Re-throw so test fails
        }
    }

    [Fact]
    public async Task Debug_Response_Value_Cast_Issue()
    {
        _output.WriteLine("=== Testing response.Value cast issue ===");
        
        // Create components manually
        var objectManager = new ObjectManager();
        var assemblyManager = new AssemblyManager();
        var valueConverter = new ValueConverter(objectManager);
        var dnNewCommand = new DotNetNewCommand(objectManager, assemblyManager, valueConverter);
        
        // Create command args for "dn new System.Collections.ArrayList"
        var pluginCall = new PluginCall();
        pluginCall.Head.Name = "dn new";
        pluginCall.Positional.Add(PluginValue.String("System.Collections.ArrayList"));
        var commandArgs = new CommandArgs(pluginCall, valueConverter);
        
        // Execute the command directly
        var directResult = await dnNewCommand.ExecuteAsync(commandArgs);
        
        _output.WriteLine($"Direct command result type: {directResult.GetType()}");
        _output.WriteLine($"Direct command result: {directResult}");
        _output.WriteLine($"Is PluginValue: {directResult is PluginValue}");
        
        if (directResult is PluginValue pluginValue)
        {
            _output.WriteLine($"PluginValue.Type: {pluginValue.Type}");
            _output.WriteLine($"PluginValue.IsCustom: {pluginValue.IsCustom}");
        }
        
        // Now test the cast that happens in HandleRunAsync
        var pluginResponse = new PluginResponse
        {
            Type = "Value",
            Value = directResult
        };
        
        _output.WriteLine($"PluginResponse.Value type: {pluginResponse.Value?.GetType()}");
        _output.WriteLine($"PluginResponse.Value: {pluginResponse.Value}");
        
        // This is the cast that happens in HandleRunAsync
        var castedValue = pluginResponse.Value as PluginValue ?? new PluginValue { Type = PluginValueType.Nothing };
        
        _output.WriteLine($"After cast - Type: {castedValue.Type}");
        _output.WriteLine($"After cast - IsCustom: {castedValue.IsCustom}");
        _output.WriteLine($"After cast - Value: {castedValue.Value}");
        
        // This should be Custom, not Nothing
        if (castedValue.Type == PluginValueType.Nothing)
        {
            _output.WriteLine("🐛 BUG FOUND: Cast failed! PluginValue was converted to Nothing");
            _output.WriteLine("The issue is that response.Value is not actually a PluginValue");
            Assert.True(false, "Cast failed - response.Value is not a PluginValue!");
        }
        else if (castedValue.Type == PluginValueType.Custom)
        {
            _output.WriteLine("✅ Cast succeeded - Custom object preserved");
        }
        else
        {
            _output.WriteLine($"❓ Unexpected type after cast: {castedValue.Type}");
            Assert.True(false, $"Unexpected type after cast: {castedValue.Type}");
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
} 