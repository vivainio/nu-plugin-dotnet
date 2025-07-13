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
    
    # Check if plugin is available
    if not (which dn | is-not-empty) {
        print "❌ nu-plugin-dotnet not found. Please install and register the plugin:"
        print "   1. Build the plugin: dotnet build"  
        print "   2. Register with nushell: plugin add target/debug/nu_plugin_dotnet.exe"
        exit 1
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