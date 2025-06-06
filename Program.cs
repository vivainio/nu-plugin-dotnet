using NuPluginDotNet.Plugin;
using Microsoft.Extensions.Logging;

namespace NuPluginDotNet;

public class Program
{
    public static async Task<int> Main(string[] args)
    {
        try
        {
            var loggerFactory = LoggerFactory.Create(builder => 
                builder.AddConsole().SetMinimumLevel(LogLevel.Warning));
            var logger = loggerFactory.CreateLogger<PluginHost>();
            
            var pluginHost = new PluginHost(logger);
            await pluginHost.RunAsync();
            return 0;
        }
        catch (Exception ex)
        {
            await Console.Error.WriteLineAsync($"Fatal error: {ex.Message}");
            return 1;
        }
    }
} 