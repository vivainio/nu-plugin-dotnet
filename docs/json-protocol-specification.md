# Nushell Plugin JSON Protocol Specification

This document provides a complete reference for the JSON-based communication protocol used between Nushell and its plugins.

## Protocol Overview

Nushell plugins communicate via JSON messages over stdin/stdout or local sockets. Each message is a JSON object, with messages separated by newlines in stdio mode.

## Handshake Sequence

### 1. Encoding Declaration
Plugin must first send encoding type as raw bytes:
- `\x04json` - 4-byte length + "json"
- `\x07msgpack` - 7-byte length + "msgpack"

### 2. Hello Messages
**Important**: The plugin must send its Hello message first, then the engine responds.

**Step 1: Plugin sends Hello message immediately after encoding:**
```json
{
  "Hello": {
    "protocol": "nu-plugin",
    "version": "0.94.0", 
    "features": []
  }
}
```

**Step 2: Engine responds with Hello message:**
```json
{
  "Hello": {
    "protocol": "nu-plugin",
    "version": "0.94.0", 
    "features": []
  }
}
```

### 3. Protocol Communication Begins
After the Hello exchange, normal protocol communication can begin with Call/CallResponse messages.

## Core Message Types

### Call Messages (Engine → Plugin)

#### Metadata Call
```json
{
  "Call": [0, "Metadata"]
}
```

#### Signature Call  
```json
{
  "Call": [0, "Signature"]
}
```

#### Run Call
```json
{
  "Call": [0, {
    "Run": {
      "name": "your_command",
      "call": {
        "head": {"start": 0, "end": 0},
        "positional": [
          {
            "String": {
              "val": "arg1",
              "span": {"start": 10, "end": 14}
            }
          }
        ],
        "named": [
          ["flag_name", {
            "Bool": {
              "val": true,
              "span": {"start": 15, "end": 25}
            }
          }]
        ]
      },
      "input": {
        "Value": {
          "String": {
            "val": "input data",
            "span": {"start": 0, "end": 10}
          }
        }
      }
    }
  }]
}
```

#### CustomValueOp Call
```json
{
  "Call": [0, {
    "CustomValueOp": [
      {
        "item": {
          "name": "custom_type",
          "data": [1, 2, 3, 4]
        },
        "span": {"start": 0, "end": 10}
      },
      "ToBaseValue"
    ]
  }]
}
```

### Response Messages (Plugin → Engine)

#### Metadata Response
```json
{
  "CallResponse": [0, {
    "Metadata": {
      "version": "1.0.0"
    }
  }]
}
```

#### Signature Response
```json
{
  "CallResponse": [0, {
    "Signature": [
      {
        "sig": {
          "name": "your_command",
          "description": "Command description",
          "extra_description": "Extended help text",
          "search_terms": ["alias1", "alias2"],
          "required_positional": [
            {
              "name": "input",
              "desc": "Input parameter",
              "shape": "String",
              "var_id": null,
              "default_value": null
            }
          ],
          "optional_positional": [],
          "rest_positional": null,
          "named": [
            {
              "long": "help",
              "short": "h", 
              "arg": null,
              "required": false,
              "desc": "Show help",
              "var_id": null,
              "default_value": null
            }
          ],
          "input_type": "String",
          "output_type": "String",
          "input_output_types": [],
          "allow_variants_without_examples": false,
          "is_filter": true,
          "creates_scope": false,
          "allows_unknown_args": false,
          "category": "Default"
        },
        "examples": [
          {
            "example": "echo 'test' | your_command",
            "description": "Example usage",
            "result": {
              "String": {
                "val": "processed test",
                "span": {"start": 0, "end": 0}
              }
            }
          }
        ]
      }
    ]
  }]
}
```

#### Value Response
```json
{
  "CallResponse": [0, {
    "Value": {
      "String": {
        "val": "result value",
        "span": {"start": 0, "end": 0}
      }
    }
  }]
}
```

#### Error Response
```json
{
  "CallResponse": [0, {
    "Error": {
      "msg": "Something went wrong",
      "labels": [
        {
          "text": "Error occurred here",
          "span": {"start": 5, "end": 10}
        }
      ],
      "code": "plugin::error::type",
      "url": "https://help.example.com/error",
      "help": "Try using different arguments",
      "inner": []
    }
  }]
}
```

#### Stream Response
```json
{
  "CallResponse": [0, {
    "ListStream": {
      "id": 1,
      "span": {"start": 0, "end": 0}
    }
  }]
}
```

### Signal Messages (Engine → Plugin)

#### Interrupt Signal
```json
{
  "Signal": "Interrupt"
}
```

#### Reset Signal  
```json
{
  "Signal": "Reset"
}
```

### Goodbye Message
```json
"Goodbye"
```

## Data Types

### Primitive Values

#### String
```json
{
  "String": {
    "val": "text content",
    "span": {"start": 0, "end": 12}
  }
}
```

#### Integer
```json
{
  "Int": {
    "val": 42,
    "span": {"start": 0, "end": 2}
  }
}
```

#### Float
```json
{
  "Float": {
    "val": 3.14159,
    "span": {"start": 0, "end": 7}
  }
}
```

#### Boolean
```json
{
  "Bool": {
    "val": true,
    "span": {"start": 0, "end": 4}
  }
}
```

#### Nothing/Null
```json
{
  "Nothing": {
    "span": {"start": 0, "end": 4}
  }
}
```

### Collection Types

#### List
```json
{
  "List": {
    "vals": [
      {
        "String": {
          "val": "item1",
          "span": {"start": 0, "end": 5}
        }
      },
      {
        "Int": {
          "val": 123,
          "span": {"start": 6, "end": 9}
        }
      }
    ],
    "span": {"start": 0, "end": 10}
  }
}
```

#### Record (Object)
```json
{
  "Record": {
    "val": {
      "name": {
        "String": {
          "val": "John",
          "span": {"start": 0, "end": 4}
        }
      },
      "age": {
        "Int": {
          "val": 30,
          "span": {"start": 5, "end": 7}
        }
      }
    },
    "span": {"start": 0, "end": 15}
  }
}
```

#### Binary Data
```json
{
  "Binary": {
    "val": [72, 101, 108, 108, 111],
    "span": {"start": 0, "end": 5}
  }
}
```

### Specialized Types

#### Date/Time
```json
{
  "Date": {
    "val": "2023-12-25T12:00:00Z",
    "span": {"start": 0, "end": 20}
  }
}
```

#### Duration (nanoseconds)
```json
{
  "Duration": {
    "val": 5000000000,
    "span": {"start": 0, "end": 5}
  }
}
```

#### File Size (bytes)
```json
{
  "Filesize": {
    "val": 1024,
    "span": {"start": 0, "end": 6}
  }
}
```

#### Range
```json
{
  "Range": {
    "val": {
      "IntRange": {
        "start": 1,
        "step": 1,
        "end": {"Included": 10}
      }
    },
    "span": {"start": 0, "end": 5}
  }
}
```

#### Cell Path
```json
{
  "CellPath": {
    "val": {
      "members": [
        {
          "String": {
            "val": "field",
            "span": {"start": 0, "end": 5},
            "optional": false
          }
        },
        {
          "Int": {
            "val": 0,
            "span": {"start": 6, "end": 7},
            "optional": true
          }
        }
      ]
    },
    "span": {"start": 0, "end": 8}
  }
}
```

#### Custom Values
```json
{
  "Custom": {
    "val": {
      "type": "PluginCustomValue",
      "name": "MyCustomType",
      "data": [1, 2, 3, 4, 5],
      "notify_on_drop": false
    },
    "span": {"start": 0, "end": 10}
  }
}
```

## Pipeline Data Headers

### Empty Pipeline
```json
"Empty"
```

### Single Value
```json
{
  "Value": {
    "String": {
      "val": "single value",
      "span": {"start": 0, "end": 12}
    }
  }
}
```

### List Stream
```json
{
  "ListStream": {
    "id": 1,
    "span": {"start": 0, "end": 10}
  }
}
```

### Byte Stream
```json
{
  "ByteStream": {
    "id": 2, 
    "span": {"start": 0, "end": 10},
    "type": "String"
  }
}
```

Stream types: `"Binary"`, `"String"`, `"Unknown"`

## Stream Messages

### Stream Data
```json
{
  "Data": [1, {
    "List": {
      "String": {
        "val": "stream item",
        "span": {"start": 0, "end": 11}
      }
    }
  }]
}
```

### Raw Stream Data
```json
{
  "Data": [2, {
    "Raw": {
      "Ok": [72, 101, 108, 108, 111]
    }
  }]
}
```

### Stream Error
```json
{
  "Data": [2, {
    "Raw": {
      "Err": {
        "msg": "Stream error",
        "labels": [],
        "code": null,
        "url": null,
        "help": null,
        "inner": []
      }
    }
  }]
}
```

### Stream End
```json
{
  "End": 1
}
```

### Stream Acknowledgment
```json
{
  "Ack": 1
}
```

### Stream Drop
```json
{
  "Drop": 1
}
```

## Engine Calls (Plugin → Engine)

### Get Configuration
```json
{
  "EngineCall": {
    "context": 0,
    "id": 1,
    "call": "GetConfig"
  }
}
```

### Get Plugin Configuration
```json
{
  "EngineCall": {
    "context": 0,
    "id": 2,
    "call": "GetPluginConfig"
  }
}
```

### Get Environment Variable
```json
{
  "EngineCall": {
    "context": 0,
    "id": 3,
    "call": {
      "GetEnvVar": "HOME"
    }
  }
}
```

### Get All Environment Variables
```json
{
  "EngineCall": {
    "context": 0,
    "id": 4,
    "call": "GetEnvVars"
  }
}
```

### Get Current Directory
```json
{
  "EngineCall": {
    "context": 0,
    "id": 5,
    "call": "GetCurrentDir"
  }
}
```

### Set Environment Variable
```json
{
  "EngineCall": {
    "context": 0,
    "id": 6,
    "call": {
      "AddEnvVar": [
        "MY_VAR",
        {
          "String": {
            "val": "value",
            "span": {"start": 0, "end": 5}
          }
        }
      ]
    }
  }
}
```

### Evaluate Closure
```json
{
  "EngineCall": {
    "context": 0,
    "id": 7,
    "call": {
      "EvalClosure": {
        "closure": {
          "item": {
            "block_id": 123,
            "captures": []
          },
          "span": {"start": 0, "end": 10}
        },
        "positional": [],
        "input": "Empty",
        "redirect_stdout": true,
        "redirect_stderr": false
      }
    }
  }
}
```

## Engine Call Responses

### Success Response
```json
{
  "EngineCallResponse": [1, {
    "Value": {
      "String": {
        "val": "result",
        "span": {"start": 0, "end": 6}
      }
    }
  }]
}
```

### Error Response
```json
{
  "EngineCallResponse": [1, {
    "Error": {
      "msg": "Engine call failed",
      "labels": [],
      "code": null,
      "url": null,
      "help": null,
      "inner": []
    }
  }]
}
```

### Config Response
```json
{
  "EngineCallResponse": [1, {
    "Config": {
      "filesize_metric": false,
      "table_mode": "rounded",
      "use_grid_icons": true
    }
  }]
}
```

### Value Map Response
```json
{
  "EngineCallResponse": [4, {
    "ValueMap": {
      "HOME": {
        "String": {
          "val": "/home/user",
          "span": {"start": 0, "end": 10}
        }
      },
      "PATH": {
        "String": {
          "val": "/usr/bin:/bin",
          "span": {"start": 0, "end": 13}
        }
      }
    }
  }]
}
```

## Error Types

### Standard Error Structure
```json
{
  "msg": "Primary error message",
  "labels": [
    {
      "text": "Specific error location",
      "span": {"start": 10, "end": 20}
    }
  ],
  "code": "plugin::namespace::error_type",
  "url": "https://docs.example.com/errors/error_type",
  "help": "Suggestion for fixing the error",
  "inner": [
    {
      "msg": "Nested error cause"
    }
  ]
}
```

### Common Error Patterns
```json
{
  "msg": "Invalid argument",
  "labels": [
    {
      "text": "Expected string, got integer",
      "span": {"start": 15, "end": 17}
    }
  ],
  "code": "plugin::type_error",
  "help": "Provide a string value instead"
}
```

## Message Flow Examples

### Simple Command Execution
1. Engine → Plugin: `{"Call": [0, "Signature"]}`
2. Plugin → Engine: `{"CallResponse": [0, {"Signature": [...]}]}`
3. Engine → Plugin: `{"Call": [1, {"Run": {...}}]}`
4. Plugin → Engine: `{"CallResponse": [1, {"Value": {...}}]}`

### Streaming Response
1. Engine → Plugin: `{"Call": [0, {"Run": {...}}]}`
2. Plugin → Engine: `{"CallResponse": [0, {"ListStream": {"id": 1, ...}}]}`
3. Plugin → Engine: `{"Data": [1, {"List": {...}}]}`
4. Plugin → Engine: `{"Data": [1, {"List": {...}}]}`
5. Plugin → Engine: `{"End": 1}`

### Error Handling
1. Engine → Plugin: `{"Call": [0, {"Run": {...}}]}`
2. Plugin → Engine: `{"CallResponse": [0, {"Error": {...}}]}`

## Protocol Features

### LocalSocket Feature
```json
{
  "name": "LocalSocket"
}
```

Enables local socket communication instead of stdio.

## Span Information

Spans indicate source code positions:
```json
{
  "start": 10,  // Start position (inclusive)
  "end": 20     // End position (exclusive)
}
```

Used for error reporting and debugging.

## Best Practices

1. **Always include span information** for better error reporting
2. **Validate message structure** before processing
3. **Handle unknown message types** gracefully
4. **Use appropriate data types** for better type safety
5. **Implement proper error handling** with descriptive messages
6. **Follow semver compatibility** for version negotiation
7. **Handle interrupts promptly** for responsive plugins
8. **Use streams for large datasets** to improve memory usage 