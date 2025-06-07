# Debug Logging

The nu-plugin-dotnet supports optional debug logging to help troubleshoot issues.

## Enabling Debug Logging

Set the `NU_PLUGIN_DOTNET_DEBUG` environment variable to any non-empty value to enable debug logging:

### Windows (PowerShell)
```powershell
$env:NU_PLUGIN_DOTNET_DEBUG = "1"
```

### Windows (Command Prompt)
```cmd
set NU_PLUGIN_DOTNET_DEBUG=1
```

### Linux/macOS (Bash)
```bash
export NU_PLUGIN_DOTNET_DEBUG=1
```

## Log File Locations

When debug logging is enabled, log files are created in the system temp directory:

- **Windows**: `%TEMP%\nu-plugin-dotnet-debug.log` and `%TEMP%\nu-plugin-dotnet.log`
- **Linux/macOS**: `/tmp/nu-plugin-dotnet-debug.log` and `/tmp/nu-plugin-dotnet.log`

## Disabling Debug Logging

To disable debug logging, unset or clear the environment variable:

### Windows (PowerShell)
```powershell
$env:NU_PLUGIN_DOTNET_DEBUG = $null
```

### Windows (Command Prompt)
```cmd
set NU_PLUGIN_DOTNET_DEBUG=
```

### Linux/macOS (Bash)
```bash
unset NU_PLUGIN_DOTNET_DEBUG
```

## What Gets Logged

When debug logging is enabled, the plugin logs:

- Plugin initialization steps
- All incoming messages from nushell
- All outgoing responses to nushell
- Error details with full stack traces
- JSON parsing and serialization details
- Object creation and method invocation details

## Performance Impact

Debug logging has minimal performance impact but will create log files that grow over time. It's recommended to:

1. Only enable debug logging when troubleshooting issues
2. Disable debug logging in production environments
3. Periodically clean up old log files

## Example Usage

```powershell
# Enable debug logging
$env:NU_PLUGIN_DOTNET_DEBUG = "1"

# Use the plugin (this will create debug logs)
let $list = dn new "List<string>"

# View the debug log
Get-Content $env:TEMP\nu-plugin-dotnet-debug.log

# Disable debug logging
$env:NU_PLUGIN_DOTNET_DEBUG = $null
``` 