using System.Text.Json;
using NuPluginDotNet.Protocol;
using NuPluginDotNet.Plugin;

namespace NuPluginDotNet.Tests;

public class ProtocolHandlerTests
{
    [Fact]
    public async Task PluginHost_Should_Implement_IPluginCommandHandler()
    {
        // Arrange
        var pluginHost = new PluginHost();

        // Act & Assert
        Assert.IsAssignableFrom<IPluginCommandHandler>(pluginHost);
    }

    [Fact]
    public async Task HandleSignatureAsync_Should_Return_Valid_Signatures()
    {
        // Arrange
        var pluginHost = new PluginHost();

        // Act
        var response = await pluginHost.HandleSignatureAsync();

        // Assert
        Assert.NotNull(response);
        Assert.NotNull(response.Signature);
        Assert.True(response.Signature.Length > 0);

        // Verify each signature has required fields
        foreach (var signature in response.Signature)
        {
            Assert.NotNull(signature);
            
            // Get the sig property
            var sigProperty = signature.GetType().GetProperty("sig");
            Assert.NotNull(sigProperty);
            
            var sig = sigProperty.GetValue(signature);
            Assert.NotNull(sig);
            
            // Check name property
            var nameProperty = sig.GetType().GetProperty("name");
            Assert.NotNull(nameProperty);
            
            var name = nameProperty.GetValue(sig)?.ToString();
            Assert.False(string.IsNullOrEmpty(name));
            
            // Check description property
            var descProperty = sig.GetType().GetProperty("description");
            Assert.NotNull(descProperty);
            
            var description = descProperty.GetValue(sig)?.ToString();
            Assert.False(string.IsNullOrEmpty(description));
        }
    }

    [Fact]
    public async Task HandleMetadataAsync_Should_Return_Version()
    {
        // Arrange
        var pluginHost = new PluginHost();

        // Act
        var response = await pluginHost.HandleMetadataAsync();

        // Assert
        Assert.NotNull(response);
        Assert.Equal("1.0.0", response.version);
    }

    [Fact]
    public async Task HandleRunAsync_Should_Process_JsonElement()
    {
        // Arrange
        var pluginHost = new PluginHost();
        var runJson = """
        {
            "name": "dn assemblies",
            "call": {
                "positional": [],
                "named": {}
            }
        }
        """;
        var runElement = JsonDocument.Parse(runJson).RootElement;

        // Act
        var response = await pluginHost.HandleRunAsync(runElement);

        // Assert
        Assert.NotNull(response);
    }

    [Fact]
    public async Task HandleSignalAsync_Should_Not_Throw()
    {
        // Arrange
        var pluginHost = new PluginHost();
        var signalJson = """
        {
            "Interrupt": {}
        }
        """;
        var signalElement = JsonDocument.Parse(signalJson).RootElement;

        // Act & Assert
        await pluginHost.HandleSignalAsync(signalElement);
        // Should not throw any exceptions
    }

    [Fact]
    public async Task Protocol_Handler_Should_Create_Without_Error()
    {
        // Arrange & Act
        var pluginHost = new PluginHost();
        var protocolHandler = new NushellProtocolHandler(pluginHost, debugEnabled: true);

        // Assert
        Assert.NotNull(protocolHandler);
    }

    [Fact]
    public async Task Plugin_Initialization_Should_Complete_Successfully()
    {
        // Arrange & Act
        var pluginHost = new PluginHost();

        // Test that we can call methods without exceptions
        var sigResponse = await pluginHost.HandleSignatureAsync();
        var metaResponse = await pluginHost.HandleMetadataAsync();

        // Assert
        Assert.NotNull(sigResponse);
        Assert.NotNull(metaResponse);
        Assert.True(sigResponse.Signature.Length > 0);
        Assert.Equal("1.0.0", metaResponse.version);
    }

    [Fact]
    public async Task All_Commands_Should_Be_Registered()
    {
        // Arrange
        var pluginHost = new PluginHost();
        var expectedCommands = new[]
        {
            "dn new",
            "dn call", 
            "dn get",
            "dn set",
            "dn load",
            "dn assemblies",
            "dn types",
            "dn members",
            "dn obj"
        };

        // Act
        var response = await pluginHost.HandleSignatureAsync();

        // Assert
        var commandNames = response.Signature
            .Select(s => s.GetType().GetProperty("sig")?.GetValue(s))
            .Cast<object>()
            .Select(sig => sig.GetType().GetProperty("name")?.GetValue(sig)?.ToString())
            .ToArray();

        foreach (var expectedCommand in expectedCommands)
        {
            Assert.Contains(expectedCommand, commandNames);
        }
    }

    [Fact]
    public async Task Run_Command_With_Invalid_Json_Should_Handle_Gracefully()
    {
        // Arrange
        var pluginHost = new PluginHost();
        var invalidJson = """
        {
            "name": "dn new",
            "call": {
                "positional": ["System.Text.StringBuilder"],
                "named": {}
            }
        }
        """;
        var runElement = JsonDocument.Parse(invalidJson).RootElement;

        // Act
        var response = await pluginHost.HandleRunAsync(runElement);

        // Assert
        Assert.NotNull(response);
        // Should not throw, should return either success or error response
    }

    [Fact]
    public async Task Commands_Should_Have_Proper_Categories()
    {
        // Arrange
        var pluginHost = new PluginHost();

        // Act
        var response = await pluginHost.HandleSignatureAsync();

        // Assert
        foreach (var signature in response.Signature)
        {
            var sig = signature.GetType().GetProperty("sig")?.GetValue(signature);
            var category = sig?.GetType().GetProperty("category")?.GetValue(sig)?.ToString();
            
            Assert.False(string.IsNullOrEmpty(category));
            Assert.NotEqual("Unknown", category);
        }
    }

    [Fact]
    public async Task Commands_Should_Have_Input_Output_Types()
    {
        // Arrange
        var pluginHost = new PluginHost();

        // Act
        var response = await pluginHost.HandleSignatureAsync();

        // Assert
        foreach (var signature in response.Signature)
        {
            var sig = signature.GetType().GetProperty("sig")?.GetValue(signature);
            var inputOutputTypes = sig?.GetType().GetProperty("input_output_types")?.GetValue(sig);
            
            Assert.NotNull(inputOutputTypes);
            // Should be an array of input/output type pairs
            if (inputOutputTypes is object[][] typeArray)
            {
                Assert.True(typeArray.Length > 0);
                foreach (var typePair in typeArray)
                {
                    Assert.Equal(2, typePair.Length); // Should have input and output type
                }
            }
        }
    }
} 