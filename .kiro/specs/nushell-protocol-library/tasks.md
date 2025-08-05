# Implementation Plan

- [x] 1. Set up protocol library project structure and core interfaces
  - Create NuPluginDotNet.Protocol project with proper .NET 8.0 configuration
  - Define IPluginCommandHandler interface with all required methods
  - Set up project dependencies (System.Text.Json, logging)
  - Create basic project structure with proper namespacing
  - _Requirements: 1.1, 1.2, 1.3_

- [x] 2. Implement core protocol handler foundation
  - [x] 2.1 Create NushellProtocolHandler class with constructor and basic setup
    - Implement constructor accepting IPluginCommandHandler and debug options
    - Set up logging infrastructure with conditional file logging
    - Initialize console I/O encoding for JSON protocol
    - _Requirements: 2.1, 3.1, 3.2_

  - [x] 2.2 Implement protocol handshake and Hello message handling
    - Create SendHelloMessageAsync method with proper protocol version
    - Implement ProcessHelloMessageAsync for engine response validation
    - Add protocol compatibility checking and feature negotiation
    - _Requirements: 6.1, 6.2, 7.1, 7.2_

- [x] 3. Implement message processing and routing system
  - [x] 3.1 Create main message processing loop
    - Implement ProcessMessagesAsync with stdin reading loop
    - Add JSON message parsing with proper error handling
    - Create message type detection and routing logic
    - Handle Goodbye message detection for graceful shutdown
    - _Requirements: 6.3, 2.1, 2.2_

  - [x] 3.2 Implement Call message processing and routing
    - Create ProcessCallMessageAsync with call ID extraction
    - Implement routing to HandleSignatureAsync, HandleMetadataAsync, HandleRunAsync
    - Add proper response wrapping in CallResponse format
    - Handle both simple string calls and complex object calls
    - _Requirements: 6.3, 1.1, 1.2_

  - [x] 3.3 Implement Signal message processing
    - Create ProcessSignalMessageAsync for Interrupt and Reset signals
    - Route signals to HandleSignalAsync with proper error handling
    - Implement no-response behavior for signal processing as per protocol
    - _Requirements: 4.1, 4.2, 4.4_

- [x] 4. Implement comprehensive error handling system
  - [x] 4.1 Create error response generation methods
    - Implement CreateCallErrorResponse for call-specific errors
    - Create CreateError method for standard error object format
    - Add error message sanitization and formatting
    - _Requirements: 2.1, 2.2, 2.3_

  - [x] 4.2 Add exception handling throughout protocol handler
    - Wrap all message processing in try-catch blocks
    - Convert exceptions to nushell-compatible error responses
    - Implement graceful recovery from protocol errors
    - Add detailed error logging with stack traces when debugging
    - _Requirements: 2.1, 2.2, 2.3, 3.3_

- [x] 5. Create helper classes for nushell value creation
  - [x] 5.1 Implement NuValues static helper class
    - Create factory methods for String, Int, Float, Bool values with span support
    - Implement List and Record creation methods with proper nesting
    - Add Nothing and Error value creation methods
    - Ensure all methods generate correct JSON structure for nushell
    - _Requirements: 5.1, 5.3_

  - [x] 5.2 Implement NuTypes constants for command signatures
    - Define all nushell shape types as static readonly objects
    - Ensure type constants match nushell's expected string values
    - Add comprehensive type coverage for all nushell built-in types
    - _Requirements: 5.1, 5.3_

- [x] 6. Create command signature helper system
  - [x] 6.1 Implement data model classes for command signatures
    - Create CommandSignatureWrapper, CommandSig, PositionalArg, NamedArg classes
    - Add proper JSON serialization attributes for nushell compatibility
    - Implement required and optional properties with sensible defaults
    - _Requirements: 5.2, 5.4_

  - [x] 6.2 Create CommandHelpers static utility class
    - Implement Positional method for creating positional arguments
    - Create Named method for creating named arguments with optional parameters
    - Add Command method for creating complete command signatures
    - Ensure all helper methods generate type-safe, validated objects
    - _Requirements: 5.2, 5.4_

- [x] 7. Implement response type system
  - [x] 7.1 Create SignatureResponse and MetadataResponse classes
    - Define SignatureResponse with Signature array property
    - Create MetadataResponse with version and extensibility support
    - Add proper serialization support for nushell protocol
    - _Requirements: 1.1, 6.3_

  - [x] 7.2 Update IPluginCommandHandler interface with proper return types
    - Modify HandleSignatureAsync to return SignatureResponse
    - Update HandleMetadataAsync to return MetadataResponse
    - Ensure HandleRunAsync returns object for flexibility
    - Add default implementation for HandleSignalAsync
    - _Requirements: 1.1, 4.3_

- [x] 8. Add comprehensive debug logging system
  - [x] 8.1 Implement detailed protocol message logging
    - Log all incoming messages with timestamps and formatting
    - Add outgoing message logging with JSON serialization details
    - Create structured logging for message processing steps
    - _Requirements: 3.1, 3.2_

  - [x] 8.2 Create debug log file management
    - Implement conditional logging based on debug flag
    - Create unique log files per process to avoid conflicts
    - Add log rotation and cleanup for long-running plugins
    - Ensure logging doesn't impact performance when disabled
    - _Requirements: 3.2, 3.4_

- [x] 9. Implement JsonSentCallback testing support
  - Add static callback property for testing message output
  - Invoke callback for all sent JSON messages
  - Ensure callback is optional and doesn't affect normal operation
  - _Requirements: Testing support for validation_

- [ ] 10. Create comprehensive unit test suite
  - [ ] 10.1 Write protocol handler unit tests
    - Test message parsing for all message types (Hello, Call, Signal)
    - Verify error handling for malformed JSON and invalid messages
    - Test response generation and formatting
    - _Requirements: All error handling requirements_

  - [ ] 10.2 Write helper class unit tests
    - Test NuValues methods for correct JSON output format
    - Verify CommandHelpers generate valid command signatures
    - Test all data model classes for proper serialization
    - _Requirements: 5.1, 5.2, 5.3, 5.4_

- [ ] 11. Create integration tests and examples
  - [ ] 11.1 Build complete example plugin using the library
    - Create simple plugin demonstrating all interface methods
    - Show proper usage of helper classes and error handling
    - Include comprehensive documentation and comments
    - _Requirements: 8.3_

  - [ ] 11.2 Write integration tests with mock nushell communication
    - Test complete protocol flow from Hello to Goodbye
    - Verify error scenarios and recovery behavior
    - Test signal handling and graceful shutdown
    - _Requirements: All requirements validation_

- [ ] 12. Finalize documentation and packaging
  - [ ] 12.1 Complete README with quick-start guide
    - Write step-by-step plugin creation instructions
    - Include complete working code examples
    - Add troubleshooting section with common issues
    - _Requirements: 8.1, 8.4_

  - [ ] 12.2 Prepare NuGet package configuration
    - Set up proper package metadata and versioning
    - Configure package dependencies and target frameworks
    - Add package documentation and release notes
    - _Requirements: Distribution and usability_