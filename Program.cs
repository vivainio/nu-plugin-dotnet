using NuPluginDotNet.Plugin;

namespace NuPluginDotNet;

public class Program
{
    public static async Task<int> Main(string[] args)
    {
        try
        {
            // CRITICAL: Send encoding declaration FIRST, exactly once at program startup
            // This follows the nushell plugin protocol: [length_byte][encoding_string]
            // For JSON: \x04json (4 bytes + "json")
            var encoding = "json";
            var encodingBytes = System.Text.Encoding.UTF8.GetBytes(encoding);
            var lengthByte = (byte)encodingBytes.Length;
            
            // Write directly to stdout
            using var stdout = Console.OpenStandardOutput();
            await stdout.WriteAsync(new[] { lengthByte }, 0, 1);
            await stdout.WriteAsync(encodingBytes, 0, encodingBytes.Length);
            await stdout.FlushAsync();
            
            // Now start the plugin host
            var pluginHost = new PluginHost();
            await pluginHost.RunAsync();
            return 0;
        }
        catch (Exception ex)
        {
            await Console.Error.WriteLineAsync($"Fatal error: {ex.Message}");
            await Console.Error.WriteLineAsync($"Stack trace: {ex.StackTrace}");
            return 1;
        }
    }
} 