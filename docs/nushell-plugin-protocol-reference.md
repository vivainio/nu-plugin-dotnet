# Nushell Plugin Protocol Reference

This document provides a comprehensive reference for implementing nushell plugins. It is based on the official nushell plugin protocol documentation.

## Overview

Nu plugins are standalone executables that communicate with Nushell over stdin/stdout or local sockets using a standardized serialization framework. Plugins enable extending Nushell's functionality with custom commands.

## Plugin Requirements

### Naming Convention
- Plugin executables **must** have filenames starting with `nu_plugin_`
- Examples: `nu_plugin_dotnet`, `nu_plugin_inc`, `nu_plugin_custom`

### Communication Modes

1. **Stdio Mode** (required)
   - Plugin is passed `--stdio` as command line argument
   - Communication over stdin/stdout
   - stderr available for direct messages

2. **Local Socket Mode** (optional)
   - Plugin is passed `--local-socket` as first argument
   - Second argument is socket path (Unix) or named pipe name (Windows)
   - Must advertise via `LocalSocket` feature

## Protocol Handshake

### 1. Encoding Type Declaration
After spawn, plugin must send encoding type:
- Format: `length_byte + encoding_string`
- Supported: `"\x04json"` or `"\x07msgpack"`

### 2. Hello Message Exchange
Both engine and plugin must send Hello messages:

```json
{
  "Hello": {
    "protocol": "nu-plugin",
    "version": "0.94.0",
    "features": []
  }
}
```

**Fields:**
- `protocol`: Must be "nu-plugin"
- `version`: Plugin's target Nu version (semver compatible)
- `features`: Array of supported protocol features

### 3. Feature Negotiation
Features are maps with required `name` key:

```json
{
  "name": "LocalSocket"
}
```

## Message Types

### Input Messages (Engine → Plugin)

#### Call Message
2-tuple format: `[id, call_type]`

**Metadata Call:**
```json
{
  "Call": [0, "Metadata"]
}
```

**Signature Call:**
```json
{
  "Call": [0, "Signature"]
}
```

**Run Call:**
```json
{
  "Call": [0, {
    "Run": {
      "name": "command_name",
      "call": {
        "head": {"start": 0, "end": 0},
        "positional": [],
        "named": []
      },
      "input": "Empty"
    }
  }]
}
```

#### Signal Message
```json
{
  "Signal": "Interrupt"
}
```

**Signal Types:**
- `Interrupt`: User interrupt (Ctrl+C)
- `Reset`: Reset plugin state

#### Goodbye Message
```json
"Goodbye"
```

### Output Messages (Plugin → Engine)

#### CallResponse Message

**Metadata Response:**
```json
{
  "CallResponse": [0, {
    "Metadata": {
      "version": "1.0.0"
    }
  }]
}
```

**Signature Response:**
```json
{
  "CallResponse": [0, {
    "Signature": [{
      "sig": {
        "name": "command_name",
        "description": "Command description",
        "extra_description": "",
        "search_terms": [],
        "required_positional": [],
        "optional_positional": [],
        "rest_positional": null,
        "named": [],
        "input_type": "Any",
        "output_type": "Any",
        "is_filter": false,
        "category": "Default"
      },
      "examples": []
    }]
  }]
}
```

**Value Response:**
```json
{
  "CallResponse": [0, {
    "Value": {
      "String": {
        "val": "Hello World",
        "span": {"start": 0, "end": 0}
      }
    }
  }]
}
```

**Error Response:**
```json
{
  "CallResponse": [0, {
    "Error": {
      "msg": "Error message",
      "labels": [{
        "text": "Error details",
        "span": {"start": 0, "end": 0}
      }],
      "code": "error_code",
      "url": null,
      "help": "Help text",
      "inner": []
    }
  }]
}
```

## Value Types

### Primitive Types

#### String
```json
{
  "String": {
    "val": "text",
    "span": {"start": 0, "end": 0}
  }
}
```

#### Int
```json
{
  "Int": {
    "val": 42,
    "span": {"start": 0, "end": 0}
  }
}
```

#### Float
```json
{
  "Float": {
    "val": 3.14,
    "span": {"start": 0, "end": 0}
  }
}
```

#### Bool
```json
{
  "Bool": {
    "val": true,
    "span": {"start": 0, "end": 0}
  }
}
```

#### Nothing
```json
{
  "Nothing": {
    "span": {"start": 0, "end": 0}
  }
}
```

### Complex Types

#### List
```json
{
  "List": {
    "vals": [
      {"String": {"val": "item1", "span": {"start": 0, "end": 0}}},
      {"String": {"val": "item2", "span": {"start": 0, "end": 0}}}
    ],
    "span": {"start": 0, "end": 0}
  }
}
```

#### Record
```json
{
  "Record": {
    "val": {
      "key1": {"String": {"val": "value1", "span": {"start": 0, "end": 0}}},
      "key2": {"Int": {"val": 42, "span": {"start": 0, "end": 0}}}
    },
    "span": {"start": 0, "end": 0}
  }
}
```

#### Binary
```json
{
  "Binary": {
    "val": [65, 66, 67],
    "span": {"start": 0, "end": 0}
  }
}
```

### Specialized Types

#### Date
```json
{
  "Date": {
    "val": "2023-01-01T00:00:00Z",
    "span": {"start": 0, "end": 0}
  }
}
```

#### Duration
```json
{
  "Duration": {
    "val": 1000000000,
    "span": {"start": 0, "end": 0}
  }
}
```

#### Filesize
```json
{
  "Filesize": {
    "val": 1024,
    "span": {"start": 0, "end": 0}
  }
}
```

#### Range
```json
{
  "Range": {
    "val": {
      "IntRange": {
        "start": 0,
        "step": 1,
        "end": {"Included": 10}
      }
    },
    "span": {"start": 0, "end": 0}
  }
}
```

#### Custom Values
```json
{
  "Custom": {
    "val": {
      "type": "PluginCustomValue",
      "name": "CustomType",
      "data": [1, 2, 3, 4],
      "notify_on_drop": false
    },
    "span": {"start": 0, "end": 0}
  }
}
```

## Engine Calls

Plugins can make calls back to the engine during execution:

### GetConfig
```json
{
  "EngineCall": {
    "context": 0,
    "id": 1,
    "call": "GetConfig"
  }
}
```

### GetEnvVar
```json
{
  "EngineCall": {
    "context": 0,
    "id": 2,
    "call": {
      "GetEnvVar": "PATH"
    }
  }
}
```

### GetCurrentDir
```json
{
  "EngineCall": {
    "context": 0,
    "id": 3,
    "call": "GetCurrentDir"
  }
}
```

## Stream Handling

### List Streams
```json
{
  "ListStream": {
    "id": 0,
    "span": {"start": 0, "end": 0}
  }
}
```

### Stream Data
```json
{
  "Data": [0, {
    "List": {
      "String": {
        "val": "stream item",
        "span": {"start": 0, "end": 0}
      }
    }
  }]
}
```

### Stream End
```json
{
  "End": 0
}
```

## Encoding Formats

### JSON
- Human-readable format
- Each message ends with newline
- Byte arrays as number arrays
- Recommended for debugging

### MessagePack
- Binary format for performance
- More efficient than JSON
- Native byte array support
- Recommended for production

## Error Handling

### LabeledError Structure
```json
{
  "msg": "Main error message",
  "labels": [{
    "text": "Label text",
    "span": {"start": 0, "end": 0}
  }],
  "code": "error_code",
  "url": "https://help.url",
  "help": "Helpful suggestion",
  "inner": []
}
```

### Best Practices
1. Always provide meaningful error messages
2. Include span information when available
3. Use error codes for programmatic handling
4. Provide helpful suggestions in error messages

## Plugin Lifecycle

1. **Discovery**: Engine finds `nu_plugin_*` executables
2. **Registration**: `plugin add` registers the plugin
3. **Loading**: `plugin use` loads commands into scope
4. **Execution**: Commands called during shell operation
5. **Cleanup**: Plugin stopped after inactivity

## Version Compatibility

- Plugin version must be semver compatible with engine
- Major version differences are incompatible
- Plugins should validate engine version
- Engine validates plugin compatibility

## Signal Handling

Plugins should handle signals gracefully:

```rust
// Rust example
engine.register_signal_handler(Box::new(move |action| {
    match action {
        SignalAction::Interrupt => {
            // Handle interrupt
        },
        SignalAction::Reset => {
            // Reset state
        }
    }
}));
```

## Security Considerations

1. Validate all input data
2. Handle untrusted custom values carefully
3. Implement proper error handling
4. Follow principle of least privilege
5. Sanitize output to prevent injection attacks

## Performance Tips

1. Use MessagePack for better performance
2. Implement streaming for large datasets
3. Cache expensive operations
4. Handle interrupts promptly
5. Optimize JSON serialization/deserialization

## Testing

1. Test with both JSON and MessagePack encodings
2. Verify error handling paths
3. Test signal handling
4. Validate version compatibility
5. Test with various input types

## References

- [Official Plugin Protocol Reference](https://www.nushell.sh/contributor-book/plugin_protocol_reference.html)
- [Plugin Development Guide](https://www.nushell.sh/book/plugins.html)
- [Nu Protocol Documentation](https://docs.rs/nu-protocol/latest/nu_protocol/)
- [Nu Plugin Crate](https://docs.rs/nu-plugin/latest/nu_plugin/) 