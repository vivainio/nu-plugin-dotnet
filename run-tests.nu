#!/usr/bin/env nu

# Nu Plugin .NET Test Runner
# Simple script to run the test suite with different options

def main [
    --suite: string = "all"  # Test suite to run: all, unit, integration, smoke, performance
    --verbose             # Enable verbose output
] {
    if $verbose {
        print "🔧 Verbose mode enabled"
        print $"📂 Current directory: ($env.PWD)"
        print $"🎯 Test suite: ($suite)"
        print ""
    }
    
    # Auto-register plugin if not available
    if not (which dn | is-not-empty) {
        print "🔧 Plugin not registered, attempting to register..."
        
        # Find the plugin executable
        let plugin_path = ($env.PWD | path join "bin" "Debug" "net8.0" "win-x64" "nu_plugin_dotnet.exe")
        
        if not ($plugin_path | path exists) {
            print "❌ Plugin executable not found. Please build first:"
            print "   dotnet build NuPluginDotNet.sln"
            exit 1
        }
        
        # Register the plugin
        try {
            plugin add $plugin_path
            print "✅ Plugin registered successfully"
        } catch { |e|
            print $"❌ Failed to register plugin: ($e.msg)"
            print "Please try manually:"
            print $"   plugin add ($plugin_path)"
            exit 1
        }
        
        # Verify plugin is now available
        if not (which dn | is-not-empty) {
            print "❌ Plugin registration failed - commands not available"
            exit 1
        }
    }
    
    # Run the appropriate test suite
    match $suite {
        "all" => {
            use tests/mod.nu
            run-all-tests
        },
        "unit" => {
            use tests/mod.nu
            run-unit-tests
        },
        "integration" => {
            use tests/mod.nu
            run-integration-tests
        },
        "smoke" => {
            use tests/mod.nu
            run-smoke-tests
        },
        "performance" => {
            use tests/mod.nu
            run-performance-tests
        },
        "basic" => {
            use tests/unit/basic-functionality.nu
            run-basic-tests
        },
        "assembly" => {
            use tests/unit/assembly-operations.nu
            run-assembly-tests
        },
        "error" => {
            use tests/unit/error-handling.nu
            run-error-tests
        },
        "dll" => {
            use tests/integration/custom-dll.nu
            run-custom-dll-tests
        },
        _ => {
            print $"❌ Unknown test suite: ($suite)"
            print ""
            print "Available test suites:"
            print "  all          - Run all test suites (default)"
            print "  unit         - Run all unit tests"
            print "  integration  - Run all integration tests"  
            print "  smoke        - Run quick smoke tests"
            print "  performance  - Run performance tests"
            print ""
            print "Individual test categories:"
            print "  basic        - Basic functionality tests"
            print "  assembly     - Assembly operation tests"
            print "  error        - Error handling tests"
            print "  dll          - Custom DLL integration tests"
            print ""
            print "Usage examples:"
            print "  nu run-tests.nu                    # Run all tests"
            print "  nu run-tests.nu --suite smoke      # Quick validation"
            print "  nu run-tests.nu --suite unit       # Unit tests only"
            print "  nu run-tests.nu --suite basic      # Basic functionality only"
            exit 1
        }
    }
}