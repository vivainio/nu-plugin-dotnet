#!/usr/bin/env nu

# Nu Plugin DotNet - Cross-Platform Installation Script
# This script downloads and installs the latest release for your platform

def main [
    --version: string = "latest"    # Version to install (default: latest)
    --path: string                  # Installation path (default: ~/.nu-plugins)
    --force                         # Force overwrite existing installation
] {
    let install_path = if ($path | is-empty) {
        $env.HOME | path join ".nu-plugins"
    } else {
        $path
    }

    print "🚀 Nu Plugin DotNet Installer"
    print "============================="

    # Create installation directory
    if not ($install_path | path exists) {
        print $"📁 Creating installation directory: ($install_path)"
        mkdir $install_path
    }

    # Detect platform and architecture
    let os_info = sys host
    let os_name = $os_info.name | str downcase
    
    # Simple architecture detection - default to x64 for most cases
    let arch = ($env.PROCESSOR_ARCHITECTURE? | default "AMD64" | str downcase)
    let is_arm = ($arch | str contains "arm")
    let arch_suffix = if $is_arm { "arm64" } else { "x64" }

    let platform_info = match $os_name {
        $name if ($name | str contains "windows") => {
            {platform: $"win-($arch_suffix)", ext: "zip", executable: "nu_plugin_dotnet.exe"}
        }
        $name if ($name | str contains "linux") => {
            {platform: $"linux-($arch_suffix)", ext: "tar.gz", executable: "nu_plugin_dotnet"}
        }
        $name if ($name | str contains "darwin" or $name | str contains "macos") => {
            {platform: $"osx-($arch_suffix)", ext: "tar.gz", executable: "nu_plugin_dotnet"}
        }
        _ => {
            error make { msg: $"❌ Unsupported platform: ($os_name)" }
        }
    }

    let platform = $platform_info.platform
    let file_ext = $platform_info.ext
    let executable_name = $platform_info.executable

    print $"🔍 Detected platform: ($platform)"

    # Get release information
    print "📡 Fetching release information..."
    let repo = "vivainio/nu-plugin-dotnet"
    let api_url = if $version == "latest" {
        $"https://api.github.com/repos/($repo)/releases/latest"
    } else {
        $"https://api.github.com/repos/($repo)/releases/tags/($version)"
    }

    let release = try {
        http get $api_url
    } catch {
        error make { msg: $"❌ Failed to fetch release information: ($in)" }
    }

    let release_version = $release.tag_name
    print $"📦 Found version: ($release_version)"

    # Find download URL
    let file_name = $"nu-plugin-dotnet-($platform).($file_ext)"
    let download_url = ($release.assets 
        | where name == $file_name 
        | get browser_download_url.0?)

    if ($download_url | is-empty) {
        error make { msg: $"❌ Could not find download URL for ($file_name)" }
    }

    # Download the file
    let temp_dir = $nu.temp-path
    let download_path = $temp_dir | path join $file_name
    let extract_path = $install_path | path join "nu-plugin-dotnet"

    print $"⬇️  Downloading from: ($download_url)"
    http get $download_url | save $download_path

    # Handle existing installation
    if ($extract_path | path exists) {
        if $force {
            print $"🗑️  Removing existing installation..."
            rm -rf $extract_path
        } else {
            error make { msg: "❌ Installation directory already exists. Use --force to overwrite." }
        }
    }

    # Extract the file
    print $"📂 Extracting to: ($extract_path)"
    mkdir $extract_path

    if ($file_ext == "zip") {
        # For Windows zip files
        try {
            ^powershell -Command $"Expand-Archive -Path '($download_path)' -DestinationPath '($extract_path)' -Force"
        } catch {
            error make { msg: $"❌ Failed to extract zip file: ($in)" }
        }
    } else {
        # For Unix tar.gz files
        cd $extract_path
        ^tar -xzf $download_path
    }

    # Clean up download
    rm $download_path

    let plugin_path = $extract_path | path join $executable_name

    # Make executable on Unix systems
    if (($os_name | str contains "linux") or ($os_name | str contains "darwin")) {
        ^chmod +x $plugin_path
    }

    # Register with nushell
    print "🔧 Registering plugin with nushell..."
    try {
        plugin add $plugin_path
        print "✅ Plugin registered successfully!"
    } catch {
        print "⚠️  Could not auto-register plugin. Please run manually:"
        print $"   plugin add ($plugin_path)"
    }

    # Verify installation
    print "🧪 Verifying installation..."
    try {
        let dn_commands = (help commands | where name =~ "dn" | length)
        if $dn_commands > 0 {
            print $"🎉 Installation successful! Found ($dn_commands) dn commands."
        } else {
            print "⚠️  Installation may not be complete. No dn commands found."
        }
    } catch {
        print "⚠️  Could not verify installation. Please test manually."
    }

    print ""
    print "📚 Quick Start:"
    print "   let $max = \"System.Math\" | dn call \"Max\" 10 20"
    print "   let $pi = \"System.Math\" | dn get \"PI\""
    print "   dn assemblies | first 5"

    print ""
    print $"📖 Documentation: https://github.com/($repo)#readme"
    print $"🎯 Plugin installed to: ($plugin_path)"

    # Test basic functionality
    print ""
    print "🧪 Running quick test..."
    try {
        let test_result = ("System.Math" | dn call "Max" 5 10)
        if $test_result == 10 {
            print "✅ Quick test passed! Plugin is working correctly."
        } else {
            print $"⚠️  Quick test returned unexpected result: ($test_result)"
        }
    } catch {
        print $"⚠️  Quick test failed: ($in)"
    }
}

# Show usage if no subcommand provided
def "main help" [] {
    print "Nu Plugin DotNet Installer"
    print ""
    print "Usage:"
    print "  ./install.nu                    # Install latest version"
    print "  ./install.nu --version v1.0.0  # Install specific version"
    print "  ./install.nu --force            # Force reinstall"
    print "  ./install.nu --path ~/my-plugins # Custom install path"
    print ""
    print "Examples:"
    print "  ./install.nu"
    print "  ./install.nu --version latest --force"
    print "  ./install.nu --path ~/.local/nu-plugins"
} 