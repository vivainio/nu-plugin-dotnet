# Nushell Plugin JSON Examples

This document provides concrete JSON examples of plugin communication, showing real message exchanges between nushell and plugins.

## Complete Plugin Session Example

### 1. Plugin Startup and Handshake

**Step 1: Plugin sends encoding declaration:**
```
\x04json
```

**Step 2: Plugin sends Hello message first (immediately after encoding):**
```json
{
  "Hello": {
    "protocol": "nu-plugin",
    "version": "0.94.0",
    "features": []
  }
}
```

**Step 3: Engine responds with Hello:**
```json
{
  "Hello": {
    "protocol": "nu-plugin",
    "version": "0.94.0",
    "features": []
  }
}
```

**Note**: The correct handshake sequence is:
1. Plugin sends `\x04json` (encoding declaration)
2. Plugin sends Hello message immediately
3. Engine responds with Hello message
4. Normal protocol communication begins

### 2. Plugin Registration (Signature Discovery)

**Engine requests signature:**
```json
{
  "Call": [0, "Signature"]
}
```

**Plugin responds with command signatures:**
```json
{
  "CallResponse": [0, {
    "Signature": [
      {
        "sig": {
          "name": "dn-obj",
          "description": "Work with .NET objects",
          "extra_description": "Create, manipulate and invoke .NET objects",
          "search_terms": ["dotnet", "object", "clr"],
          "required_positional": [],
          "optional_positional": [
            {
              "name": "type_name",
              "desc": "The .NET type name to create",
              "shape": "String",
              "var_id": null,
              "default_value": null
            }
          ],
          "rest_positional": null,
          "named": [
            {
              "long": "help",
              "short": "h",
              "arg": null,
              "required": false,
              "desc": "Display the help message for this command",
              "var_id": null,
              "default_value": null
            },
            {
              "long": "new",
              "short": "n",
              "arg": null,
              "required": false,
              "desc": "Create a new instance",
              "var_id": null,
              "default_value": null
            }
          ],
          "input_type": "Any",
          "output_type": "Any",
          "input_output_types": [],
          "allow_variants_without_examples": false,
          "is_filter": false,
          "creates_scope": false,
          "allows_unknown_args": false,
          "category": "Default"
        },
        "examples": [
          {
            "example": "dn-obj System.String --new",
            "description": "Create a new string object",
            "result": {
              "Custom": {
                "val": {
                  "type": "PluginCustomValue",
                  "name": "DotNetObject",
                  "data": [83, 121, 115, 116, 101, 109, 46, 83, 116, 114, 105, 110, 103]
                },
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

### 3. Command Execution

**Engine executes command:**
```json
{
  "Call": [1, {
    "Run": {
      "name": "dn-obj",
      "call": {
        "head": {"start": 0, "end": 6},
        "positional": [
          {
            "String": {
              "val": "System.String",
              "span": {"start": 7, "end": 20}
            }
          }
        ],
        "named": [
          ["new", {
            "Bool": {
              "val": true,
              "span": {"start": 21, "end": 26}
            }
          }]
        ]
      },
      "input": "Empty"
    }
  }]
}
```

**Plugin responds with result:**
```json
{
  "CallResponse": [1, {
    "Value": {
      "Custom": {
        "val": {
          "type": "PluginCustomValue",
          "name": "DotNetObject",
          "data": [83, 121, 115, 116, 101, 109, 46, 83, 116, 114, 105, 110, 103, 0, 0, 0, 0]
        },
        "span": {"start": 0, "end": 0}
      }
    }
  }]
}
```

## Error Examples

### Invalid Type Name Error
**Engine call:**
```json
{
  "Call": [2, {
    "Run": {
      "name": "dn-obj",
      "call": {
        "head": {"start": 0, "end": 6},
        "positional": [
          {
            "String": {
              "val": "Invalid.Type.Name",
              "span": {"start": 7, "end": 25}
            }
          }
        ],
        "named": [["new", {"Bool": {"val": true, "span": {"start": 26, "end": 31}}}]]
      },
      "input": "Empty"
    }
  }]
}
```

**Plugin error response:**
```json
{
  "CallResponse": [2, {
    "Error": {
      "msg": "Type 'Invalid.Type.Name' not found",
      "labels": [
        {
          "text": "Unknown type name",
          "span": {"start": 7, "end": 25}
        }
      ],
      "code": "dotnet::type_not_found",
      "url": null,
      "help": "Check the type name spelling and ensure the assembly is loaded",
      "inner": []
    }
  }]
}
```

### Assembly Loading Error
```json
{
  "CallResponse": [3, {
    "Error": {
      "msg": "Assembly 'CustomLibrary.dll' could not be loaded",
      "labels": [
        {
          "text": "Assembly file not found",
          "span": {"start": 15, "end": 32}
        }
      ],
      "code": "dotnet::assembly_load_error",
      "url": "https://docs.microsoft.com/en-us/dotnet/api/system.io.filenotfoundexception",
      "help": "Ensure the assembly file exists and is accessible",
      "inner": [
        {
          "msg": "FileNotFoundException: Could not load file or assembly 'CustomLibrary.dll'"
        }
      ]
    }
  }]
}
```

## Data Type Examples

### Primitive Types in Context
```json
{
  "CallResponse": [4, {
    "Value": {
      "Record": {
        "val": {
          "string_value": {
            "String": {
              "val": "Hello World",
              "span": {"start": 0, "end": 11}
            }
          },
          "int_value": {
            "Int": {
              "val": 42,
              "span": {"start": 0, "end": 2}
            }
          },
          "float_value": {
            "Float": {
              "val": 3.14159,
              "span": {"start": 0, "end": 7}
            }
          },
          "bool_value": {
            "Bool": {
              "val": true,
              "span": {"start": 0, "end": 4}
            }
          },
          "null_value": {
            "Nothing": {
              "span": {"start": 0, "end": 4}
            }
          }
        },
        "span": {"start": 0, "end": 50}
      }
    }
  }]
}
```

### List of .NET Objects
```json
{
  "CallResponse": [5, {
    "Value": {
      "List": {
        "vals": [
          {
            "Custom": {
              "val": {
                "type": "PluginCustomValue",
                "name": "DotNetObject",
                "data": [83, 116, 114, 105, 110, 103, 49]
              },
              "span": {"start": 0, "end": 0}
            }
          },
          {
            "Custom": {
              "val": {
                "type": "PluginCustomValue", 
                "name": "DotNetObject",
                "data": [83, 116, 114, 105, 110, 103, 50]
              },
              "span": {"start": 0, "end": 0}
            }
          }
        ],
        "span": {"start": 0, "end": 20}
      }
    }
  }]
}
```

### Binary Data (Assembly Bytes)
```json
{
  "CallResponse": [6, {
    "Value": {
      "Binary": {
        "val": [77, 90, 144, 0, 3, 0, 0, 0, 4, 0, 0, 0, 255, 255, 0, 0],
        "span": {"start": 0, "end": 16}
      }
    }
  }]
}
```

## Stream Examples

### Streaming Assembly Types
**Plugin starts stream:**
```json
{
  "CallResponse": [7, {
    "ListStream": {
      "id": 1,
      "span": {"start": 0, "end": 0}
    }
  }]
}
```

**Plugin sends stream data:**
```json
{
  "Data": [1, {
    "List": {
      "Record": {
        "val": {
          "name": {
            "String": {
              "val": "System.String",
              "span": {"start": 0, "end": 13}
            }
          },
          "namespace": {
            "String": {
              "val": "System",
              "span": {"start": 0, "end": 6}
            }
          },
          "is_public": {
            "Bool": {
              "val": true,
              "span": {"start": 0, "end": 4}
            }
          }
        },
        "span": {"start": 0, "end": 30}
      }
    }
  }]
}
```

```json
{
  "Data": [1, {
    "List": {
      "Record": {
        "val": {
          "name": {
            "String": {
              "val": "System.Int32",
              "span": {"start": 0, "end": 12}
            }
          },
          "namespace": {
            "String": {
              "val": "System",
              "span": {"start": 0, "end": 6}
            }
          },
          "is_public": {
            "Bool": {
              "val": true,
              "span": {"start": 0, "end": 4}
            }
          }
        },
        "span": {"start": 0, "end": 30}
      }
    }
  }]
}
```

**Plugin ends stream:**
```json
{
  "End": 1
}
```

## Engine Call Examples

### Getting Environment Variables
**Plugin requests env var:**
```json
{
  "EngineCall": {
    "context": 1,
    "id": 1,
    "call": {
      "GetEnvVar": "DOTNET_ROOT"
    }
  }
}
```

**Engine responds:**
```json
{
  "EngineCallResponse": [1, {
    "Value": {
      "String": {
        "val": "/usr/share/dotnet",
        "span": {"start": 0, "end": 17}
      }
    }
  }]
}
```

### Getting Current Directory
**Plugin requests current dir:**
```json
{
  "EngineCall": {
    "context": 1,
    "id": 2,
    "call": "GetCurrentDir"
  }
}
```

**Engine responds:**
```json
{
  "EngineCallResponse": [2, {
    "Value": {
      "String": {
        "val": "/home/user/projects/nu-plugin-dotnet",
        "span": {"start": 0, "end": 36}
      }
    }
  }]
}
```

### Getting Configuration
**Plugin requests config:**
```json
{
  "EngineCall": {
    "context": 1,
    "id": 3,
    "call": "GetConfig"
  }
}
```

**Engine responds with config:**
```json
{
  "EngineCallResponse": [3, {
    "Config": {
      "filesize_metric": false,
      "table_mode": "rounded",
      "use_grid_icons": true,
      "footer_mode": "RowCount",
      "float_precision": 4,
      "max_external_completion_results": 100,
      "recursion_limit": 50,
      "use_ansi_coloring": true,
      "completions": {
        "case_sensitive": false,
        "quick": true,
        "partial": true,
        "algorithm": "prefix"
      }
    }
  }]
}
```

## Custom Value Operations

### ToBaseValue Operation
**Engine requests base value:**
```json
{
  "Call": [8, {
    "CustomValueOp": [
      {
        "item": {
          "name": "DotNetObject",
          "data": [83, 121, 115, 116, 101, 109, 46, 83, 116, 114, 105, 110, 103]
        },
        "span": {"start": 10, "end": 25}
      },
      "ToBaseValue"
    ]
  }]
}
```

**Plugin converts to base value:**
```json
{
  "CallResponse": [8, {
    "Value": {
      "String": {
        "val": "System.String",
        "span": {"start": 0, "end": 13}
      }
    }
  }]
}
```

### FollowPathString Operation
**Engine follows path:**
```json
{
  "Call": [9, {
    "CustomValueOp": [
      {
        "item": {
          "name": "DotNetObject",
          "data": [79, 98, 106, 101, 99, 116, 73, 110, 102, 111]
        },
        "span": {"start": 0, "end": 10}
      },
      {
        "FollowPathString": {
          "item": "name",
          "span": {"start": 11, "end": 15}
        }
      }
    ]
  }]
}
```

**Plugin returns field value:**
```json
{
  "CallResponse": [9, {
    "Value": {
      "String": {
        "val": "MyObject",
        "span": {"start": 0, "end": 8}
      }
    }
  }]
}
```

## Signal Handling Examples

### Interrupt Signal
**Engine sends interrupt:**
```json
{
  "Signal": "Interrupt"
}
```

**Plugin should gracefully stop current operation and respond to pending calls**

### Reset Signal
**Engine sends reset:**
```json
{
  "Signal": "Reset"
}
```

**Plugin should reset internal state**

## Complex Interaction Example

### Assembly Loading and Type Enumeration

1. **Load Assembly:**
```json
{
  "Call": [10, {
    "Run": {
      "name": "dn-load-asm",
      "call": {
        "head": {"start": 0, "end": 11},
        "positional": [
          {
            "String": {
              "val": "./MyLibrary.dll",
              "span": {"start": 12, "end": 28}
            }
          }
        ],
        "named": []
      },
      "input": "Empty"
    }
  }]
}
```

2. **Plugin loads and responds:**
```json
{
  "CallResponse": [10, {
    "Value": {
      "Record": {
        "val": {
          "assembly_name": {
            "String": {
              "val": "MyLibrary",
              "span": {"start": 0, "end": 9}
            }
          },
          "types_count": {
            "Int": {
              "val": 25,
              "span": {"start": 0, "end": 2}
            }
          },
          "loaded": {
            "Bool": {
              "val": true,
              "span": {"start": 0, "end": 4}
            }
          }
        },
        "span": {"start": 0, "end": 30}
      }
    }
  }]
}
```

3. **Get Types from Assembly:**
```json
{
  "Call": [11, {
    "Run": {
      "name": "dn-types",
      "call": {
        "head": {"start": 0, "end": 8},
        "positional": [],
        "named": [
          ["assembly", {
            "String": {
              "val": "MyLibrary",
              "span": {"start": 20, "end": 29}
            }
          }]
        ]
      },
      "input": "Empty"
    }
  }]
}
```

4. **Plugin streams type information:**
```json
{
  "CallResponse": [11, {
    "ListStream": {
      "id": 2,
      "span": {"start": 0, "end": 0}
    }
  }]
}
```

5. **Stream individual types:**
```json
{
  "Data": [2, {
    "List": {
      "Record": {
        "val": {
          "full_name": {
            "String": {
              "val": "MyLibrary.MyClass",
              "span": {"start": 0, "end": 17}
            }
          },
          "is_public": {
            "Bool": {
              "val": true,
              "span": {"start": 0, "end": 4}
            }
          },
          "is_class": {
            "Bool": {
              "val": true,
              "span": {"start": 0, "end": 4}
            }
          },
          "methods_count": {
            "Int": {
              "val": 5,
              "span": {"start": 0, "end": 1}
            }
          }
        },
        "span": {"start": 0, "end": 50}
      }
    }
  }]
}
```

6. **End stream:**
```json
{
  "End": 2
}
```

## Goodbye and Cleanup

**Engine signals shutdown:**
```json
"Goodbye"
```

**Plugin should clean up resources and exit gracefully**

## Testing Messages

### Metadata Request
```json
{
  "Call": [0, "Metadata"]
}
```

```json
{
  "CallResponse": [0, {
    "Metadata": {
      "version": "0.1.0"
    }
  }]
}
```

### Basic Echo Test
```json
{
  "Call": [1, {
    "Run": {
      "name": "echo-test",
      "call": {
        "head": {"start": 0, "end": 9},
        "positional": [],
        "named": []
      },
      "input": {
        "Value": {
          "String": {
            "val": "test input",
            "span": {"start": 0, "end": 10}
          }
        }
      }
    }
  }]
}
```

```json
{
  "CallResponse": [1, {
    "Value": {
      "String": {
        "val": "echo: test input",
        "span": {"start": 0, "end": 16}
      }
    }
  }]
}
```

These examples demonstrate the complete JSON protocol for nushell plugins, including handshake, command execution, error handling, streaming, engine calls, and custom value operations. 