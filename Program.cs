using NuPluginDotNet.Plugin;

namespace NuPluginDotNet;

public class Program
{
    public static async Task<int> Main(string[] args)
    {
        try
        {
            var pluginHost = new PluginHost();
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