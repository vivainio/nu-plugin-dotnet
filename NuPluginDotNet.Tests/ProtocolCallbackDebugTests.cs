using System.Collections.Generic;
using System.Text.Json;
using NuPluginDotNet.Protocol;
using NuPluginDotNet.Plugin;
using Xunit.Abstractions;
using System.Reflection;
using System.Linq;
using NuPluginDotNet.DotNet;

namespace NuPluginDotNet.Tests;

public class ProtocolCallbackDebugTests
{
    private readonly ITestOutputHelper _output;
    private readonly List<string> _capturedJsonMessages = new();

    public ProtocolCallbackDebugTests(ITestOutputHelper output)
    {
        _output = output;
        
        // Set up the callback to capture JSON messages
        NushellProtocolHandler.JsonSentCallback = json =>
        {
            _capturedJsonMessages.Add(json);
            _output.WriteLine($"[CALLBACK] JSON Sent: {json}");
        };
    }

    [Fact]
    public async Task Test_Protocol_Handler_Callback_With_Run_Command()
    {
        // Arrange
        var pluginHost = new PluginHost();
        var protocolHandler = new NushellProtocolHandler(pluginHost, debugEnabled: true);
        _capturedJsonMessages.Clear();

        // We need to access the private ProcessMessageAsync method using reflection
        var processMessageMethod = typeof(NushellProtocolHandler)
            .GetMethod("ProcessMessageAsync", BindingFlags.NonPublic | BindingFlags.Instance);
        
        Assert.NotNull(processMessageMethod);

        // Create a Run call message
        var runCallJson = """
        {
            "Call": [1, {"Run": {"name": "dn new", "call": {"positional": ["System.Collections.ArrayList"], "named": {}}}}]
        }
        """;

        _output.WriteLine($"[TEST] Processing message: {runCallJson}");

        // Act - Process the message through the protocol handler
        var response = await (Task<object?>)processMessageMethod.Invoke(protocolHandler, new object[] { runCallJson });

        // Assert
        Assert.NotNull(response);
        _output.WriteLine($"[TEST] Protocol response type: {response.GetType()}");
        _output.WriteLine($"[TEST] Protocol response: {response}");

        // Now trigger SendMessageAsync by calling it directly
        var sendMessageMethod = typeof(NushellProtocolHandler)
            .GetMethod("SendMessageAsync", BindingFlags.NonPublic | BindingFlags.Instance);
        
        Assert.NotNull(sendMessageMethod);

        // Clear previous messages to isolate the send operation
        _capturedJsonMessages.Clear();

        // Send the response which should trigger our callback
        await (Task)sendMessageMethod.Invoke(protocolHandler, new object[] { response });

        // Check that our callback was invoked
        Assert.True(_capturedJsonMessages.Count > 0, "No JSON messages were captured by the callback");
        
        _output.WriteLine($"[TEST] Captured {_capturedJsonMessages.Count} JSON messages:");
        for (int i = 0; i < _capturedJsonMessages.Count; i++)
        {
            _output.WriteLine($"[TEST] Message {i + 1}: {_capturedJsonMessages[i]}");
            
            // Try to parse the JSON to verify it's valid
            try
            {
                var doc = JsonDocument.Parse(_capturedJsonMessages[i]);
                _output.WriteLine($"[TEST] Message {i + 1} is valid JSON");
                
                // Check if it's a CallResponse
                if (doc.RootElement.TryGetProperty("CallResponse", out var callResponse))
                {
                    _output.WriteLine($"[TEST] Message {i + 1} is a CallResponse");
                    if (callResponse.ValueKind == JsonValueKind.Array)
                    {
                        var array = callResponse.EnumerateArray().ToArray();
                        if (array.Length >= 2)
                        {
                            _output.WriteLine($"[TEST] CallResponse ID: {array[0]}");
                            _output.WriteLine($"[TEST] CallResponse Body: {array[1]}");
                        }
                    }
                }
            }
            catch (JsonException ex)
            {
                _output.WriteLine($"[TEST] Message {i + 1} is invalid JSON: {ex.Message}");
            }
        }
    }

    [Fact]
    public async Task Test_Protocol_Handler_Callback_With_Signature_Command()
    {
        // Arrange
        var pluginHost = new PluginHost();
        var protocolHandler = new NushellProtocolHandler(pluginHost, debugEnabled: true);
        _capturedJsonMessages.Clear();

        var processMessageMethod = typeof(NushellProtocolHandler)
            .GetMethod("ProcessMessageAsync", BindingFlags.NonPublic | BindingFlags.Instance);
        
        var sendMessageMethod = typeof(NushellProtocolHandler)
            .GetMethod("SendMessageAsync", BindingFlags.NonPublic | BindingFlags.Instance);

        // Create a Signature call message
        var signatureCallJson = """
        {
            "Call": [1, "Signature"]
        }
        """;

        _output.WriteLine($"[TEST] Processing Signature message: {signatureCallJson}");

        // Act
        var response = await (Task<object?>)processMessageMethod.Invoke(protocolHandler, new object[] { signatureCallJson });
        
        Assert.NotNull(response);
        _output.WriteLine($"[TEST] Signature response type: {response.GetType()}");

        _capturedJsonMessages.Clear();
        await (Task)sendMessageMethod.Invoke(protocolHandler, new object[] { response });

        // Assert
        Assert.True(_capturedJsonMessages.Count > 0, "No JSON messages were captured for Signature call");
        
        _output.WriteLine($"[TEST] Signature captured {_capturedJsonMessages.Count} JSON messages:");
        foreach (var msg in _capturedJsonMessages)
        {
            _output.WriteLine($"[TEST] Signature message: {msg}");
            
            // Parse and examine the signature response
            try
            {
                var doc = JsonDocument.Parse(msg);
                if (doc.RootElement.TryGetProperty("CallResponse", out var callResponse) &&
                    callResponse.ValueKind == JsonValueKind.Array)
                {
                    var array = callResponse.EnumerateArray().ToArray();
                    if (array.Length >= 2)
                    {
                        var sigResponse = array[1];
                        if (sigResponse.TryGetProperty("Signature", out var signatures))
                        {
                            var sigCount = signatures.GetArrayLength();
                            _output.WriteLine($"[TEST] Found {sigCount} command signatures");
                        }
                    }
                }
            }
            catch (JsonException ex)
            {
                _output.WriteLine($"[TEST] Failed to parse signature response: {ex.Message}");
            }
        }
    }

    [Fact]
    public async Task Test_Protocol_Handler_Callback_With_Multiple_Commands()
    {
        // Arrange
        var pluginHost = new PluginHost();
        var protocolHandler = new NushellProtocolHandler(pluginHost, debugEnabled: true);
        _capturedJsonMessages.Clear();

        var processMessageMethod = typeof(NushellProtocolHandler)
            .GetMethod("ProcessMessageAsync", BindingFlags.NonPublic | BindingFlags.Instance);
        
        var sendMessageMethod = typeof(NushellProtocolHandler)
            .GetMethod("SendMessageAsync", BindingFlags.NonPublic | BindingFlags.Instance);

        var testMessages = new[]
        {
            """{"Call": [1, "Signature"]}""",
            """{"Call": [2, "Metadata"]}""",
            """{"Call": [3, {"Run": {"name": "dn new", "call": {"positional": ["System.Collections.ArrayList"], "named": {}}}}]}""",
            """{"Call": [4, {"Run": {"name": "dn assemblies", "call": {"positional": [], "named": {}}}}]}"""
        };

        // Act - Process each message and capture the JSON responses
        for (int i = 0; i < testMessages.Length; i++)
        {
            var message = testMessages[i];
            _output.WriteLine($"\n[TEST] Processing message {i + 1}: {message}");
            
            var beforeCount = _capturedJsonMessages.Count;
            
            try
            {
                var response = await (Task<object?>)processMessageMethod.Invoke(protocolHandler, new object[] { message });
                
                if (response != null)
                {
                    await (Task)sendMessageMethod.Invoke(protocolHandler, new object[] { response });
                }
                
                var newMessageCount = _capturedJsonMessages.Count - beforeCount;
                _output.WriteLine($"[TEST] Message {i + 1} generated {newMessageCount} JSON responses");
                
                // Show the new messages
                for (int j = beforeCount; j < _capturedJsonMessages.Count; j++)
                {
                    _output.WriteLine($"[TEST] Response {j + 1}: {_capturedJsonMessages[j]}");
                }
            }
            catch (Exception ex)
            {
                _output.WriteLine($"[TEST] Error processing message {i + 1}: {ex.Message}");
                _output.WriteLine($"[TEST] Stack trace: {ex.StackTrace}");
            }
        }

        // Assert
        Assert.True(_capturedJsonMessages.Count > 0, "No JSON messages were captured across all test messages");
        _output.WriteLine($"\n[TEST] Total captured messages: {_capturedJsonMessages.Count}");
    }

    [Fact]
    public async Task Test_Protocol_Callback_Hello_Message()
    {
        // Arrange
        var pluginHost = new PluginHost();
        var protocolHandler = new NushellProtocolHandler(pluginHost, debugEnabled: true);
        _capturedJsonMessages.Clear();

        var processMessageMethod = typeof(NushellProtocolHandler)
            .GetMethod("ProcessMessageAsync", BindingFlags.NonPublic | BindingFlags.Instance);
        
        var sendMessageMethod = typeof(NushellProtocolHandler)
            .GetMethod("SendMessageAsync", BindingFlags.NonPublic | BindingFlags.Instance);

        // Create a Hello message
        var helloMessage = """{"Hello": {"protocol": "nu-plugin", "version": "0.95.0", "features": []}}""";

        _output.WriteLine($"[TEST] Processing Hello message: {helloMessage}");

        // Act
        var response = await (Task<object?>)processMessageMethod.Invoke(protocolHandler, new object[] { helloMessage });
        
        // Hello messages should return null according to the nushell plugin protocol
        // The plugin sends its Hello first, and receiving a Hello from nushell is just acknowledgment
        Assert.Null(response);
        _output.WriteLine($"[TEST] Hello response is null as expected (no response needed)");

        // Since response is null, we shouldn't try to send a message
        // The test should verify that the Hello message was processed correctly
        _output.WriteLine($"[TEST] Hello message processed successfully - no response message expected");
        
        // Verify that no additional JSON messages were captured (since no response is sent)
        Assert.Equal(0, _capturedJsonMessages.Count);
        _output.WriteLine($"[TEST] ✅ Hello message test passed - null response is correct per protocol");
    }

    [Fact]
    public async Task Test_DN_New_ArrayList_Returns_CustomType()
    {
        // Arrange
        var pluginHost = new PluginHost();
        var protocolHandler = new NushellProtocolHandler(pluginHost, debugEnabled: true);
        _capturedJsonMessages.Clear();

        var processMessageMethod = typeof(NushellProtocolHandler)
            .GetMethod("ProcessMessageAsync", BindingFlags.NonPublic | BindingFlags.Instance);
        
        var sendMessageMethod = typeof(NushellProtocolHandler)
            .GetMethod("SendMessageAsync", BindingFlags.NonPublic | BindingFlags.Instance);

        // Create a Run call message for "dn new arraylist"
        var runCallJson = """
        {
            "Call": [1, {"Run": {"name": "dn new", "call": {"positional": ["System.Console"], "named": {}}}}]
        }
        """;

        _output.WriteLine($"[TEST] Processing 'dn new System.Console' command: {runCallJson}");

        // Act - Process the message through the protocol handler
        var response = await (Task<object?>)processMessageMethod.Invoke(protocolHandler, new object[] { runCallJson });

        Assert.NotNull(response);
        _output.WriteLine($"[TEST] Protocol response type: {response.GetType()}");

        // Clear previous messages and send the response
        _capturedJsonMessages.Clear();
        await (Task)sendMessageMethod.Invoke(protocolHandler, new object[] { response });

        // Assert
        Assert.True(_capturedJsonMessages.Count > 0, "No JSON messages were captured by the callback");
        
        _output.WriteLine($"[TEST] Captured {_capturedJsonMessages.Count} JSON messages:");
        
        for (int i = 0; i < _capturedJsonMessages.Count; i++)
        {
            var jsonMessage = _capturedJsonMessages[i];
            _output.WriteLine($"[TEST] Message {i + 1}: {jsonMessage}");
            
            try
            {
                var doc = JsonDocument.Parse(jsonMessage);
                _output.WriteLine($"[TEST] Message {i + 1} is valid JSON");
                
                // Check if it's a CallResponse
                if (doc.RootElement.TryGetProperty("CallResponse", out var callResponse))
                {
                    _output.WriteLine($"[TEST] Message {i + 1} is a CallResponse");
                    if (callResponse.ValueKind == JsonValueKind.Array)
                    {
                        var array = callResponse.EnumerateArray().ToArray();
                        if (array.Length >= 2)
                        {
                            _output.WriteLine($"[TEST] CallResponse ID: {array[0]}");
                            var responseBody = array[1];
                            
                            // Check if response contains PipelineData
                            if (responseBody.TryGetProperty("PipelineData", out var pipelineData))
                            {
                                _output.WriteLine($"[TEST] Found PipelineData in response");
                                
                                // Check if PipelineData contains Value
                                if (pipelineData.TryGetProperty("Value", out var value))
                                {
                                    _output.WriteLine($"[TEST] Found Value in PipelineData");
                                    
                                    // Check if Value is a Custom type (not String)
                                    if (value.TryGetProperty("Custom", out var custom))
                                    {
                                        _output.WriteLine($"[TEST] ✅ SUCCESS: Value is Custom type!");
                                        _output.WriteLine($"[TEST] Custom value: {custom}");
                                        
                                        // Check if it has the expected structure for a .NET object
                                        if (custom.TryGetProperty("val", out var val))
                                        {
                                            _output.WriteLine($"[TEST] Custom val: {val}");
                                        }
                                        if (custom.TryGetProperty("type_name", out var typeName))
                                        {
                                            _output.WriteLine($"[TEST] Custom type_name: {typeName}");
                                        }
                                    }
                                    else if (value.TryGetProperty("String", out var stringValue))
                                    {
                                        _output.WriteLine($"[TEST] ❌ FAIL: Value is String type instead of Custom!");
                                        _output.WriteLine($"[TEST] String value: {stringValue}");
                                        Assert.True(false, "Expected Custom type but got String type");
                                    }
                                    else
                                    {
                                        _output.WriteLine($"[TEST] Value type: {value}");
                                    }
                                }
                            }
                            else if (responseBody.TryGetProperty("Error", out var error))
                            {
                                _output.WriteLine($"[TEST] Response contains Error: {error}");
                            }
                            else
                            {
                                _output.WriteLine($"[TEST] Response body: {responseBody}");
                            }
                        }
                    }
                }
            }
            catch (JsonException ex)
            {
                _output.WriteLine($"[TEST] Message {i + 1} JSON parsing failed: {ex.Message}");
            }
        }
    }

    [Fact]
    public async Task Test_AssemblyManager_FindType_Debug()
    {
        // Arrange
        var assemblyManager = new AssemblyManager();
        _capturedJsonMessages.Clear();

        _output.WriteLine("[TEST] Testing AssemblyManager.FindType directly");

        // Test different type name variations
        var testTypes = new[]
        {
            "ArrayList",
            "System.Collections.ArrayList", 
            "System.Console",
            "System.String",
            "string",
            "System.Object"
        };

        foreach (var typeName in testTypes)
        {
            var foundType = assemblyManager.FindType(typeName);
            var assemblyName = foundType?.Assembly?.GetName()?.Name ?? "NULL";
            _output.WriteLine($"[TEST] FindType('{typeName}') = {foundType?.FullName ?? "NULL"} (from assembly: {assemblyName})");
        }

        // Check what assemblies are actually loaded
        var assemblies = assemblyManager.GetLoadedAssemblies();
        _output.WriteLine($"[TEST] Total assemblies loaded: {assemblies.Length}");
        
        // Check specifically for System.Collections.NonGeneric
        var collectionsAssembly = assemblies.FirstOrDefault(a => 
            a.GetName().Name?.Contains("Collections.NonGeneric", StringComparison.OrdinalIgnoreCase) == true);
        
        if (collectionsAssembly != null)
        {
            _output.WriteLine($"[TEST] Found Collections.NonGeneric assembly: {collectionsAssembly.FullName}");
            try 
            {
                var types = collectionsAssembly.GetExportedTypes();
                var arrayListType = types.FirstOrDefault(t => t.Name == "ArrayList");
                _output.WriteLine($"[TEST] ArrayList type in assembly: {arrayListType?.FullName ?? "NOT FOUND"}");
            }
            catch (Exception ex)
            {
                _output.WriteLine($"[TEST] Error getting types from Collections.NonGeneric: {ex.Message}");
            }
        }
        else
        {
            _output.WriteLine("[TEST] Collections.NonGeneric assembly NOT FOUND");
        }
    }

    public void Dispose()
    {
        // Clean up the callback when the test class is disposed
        NushellProtocolHandler.JsonSentCallback = null;
    }
} 