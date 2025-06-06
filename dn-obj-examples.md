# dn obj Command Examples

## 1. Convert Version object to record
```nushell
"System.Version" | dn call "Parse" "1.2.3.4" | dn obj
```

## 2. Inspect type information
```nushell
"System.DateTime" | dn obj
```

## 3. Convert complex nested objects
```nushell
"System.Environment" | dn get "OSVersion" | dn obj
```
