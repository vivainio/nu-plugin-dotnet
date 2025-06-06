using System.Collections;
using System.Reflection;
using NuPluginDotNet.DotNet;
using NuPluginDotNet.Types;

namespace NuPluginDotNet.Commands;

public class DotNetObjCommand : BaseCommand
{
    public DotNetObjCommand(
        ObjectManager objectManager,
        AssemblyManager assemblyManager,
        ValueConverter valueConverter) : base(objectManager, assemblyManager, valueConverter)
    {
    }

    public override async Task<PluginValue> ExecuteAsync(CommandArgs args)
    {
        try
        {
            // Get the input object
            if (args.Input == null)
            {
                return CreateError("No input provided. Pass a .NET object to convert to nushell format.");
            }

            object? targetObject = null;

            if (args.Input.IsCustom)
            {
                // Get object from ObjectManager
                var objectId = args.Input.GetObjectId();
                targetObject = ObjectManager.GetObject(objectId);
            }
            else if (args.Input.IsString)
            {
                // Try to parse as type name for static inspection
                var typeName = args.Input.AsString();
                var type = AssemblyManager.FindType(typeName);
                if (type != null)
                {
                    return ConvertTypeInfoToNushell(type);
                }
                else
                {
                    // Treat as string object
                    targetObject = typeName;
                }
            }
            else
            {
                // Convert other basic types
                targetObject = ConvertPluginValueToClrForInspection(args.Input);
            }

            if (targetObject == null)
            {
                return PluginValue.Null();
            }

            // Convert the object to nushell-native format
            var converted = ConvertObjectToNushellNative(targetObject, new HashSet<object>());
            return converted;
        }
        catch (Exception ex)
        {
            return CreateError($"Failed to convert object: {ex.Message}", ex);
        }
    }

    private PluginValue ConvertObjectToNushellNative(object obj, HashSet<object> visited)
    {
        // Handle null
        if (obj == null)
        {
            return PluginValue.Null();
        }

        // Prevent infinite recursion
        if (visited.Contains(obj))
        {
            return PluginValue.String($"[Circular Reference: {obj.GetType().Name}]");
        }
        visited.Add(obj);

        var type = obj.GetType();

        try
        {
            // Handle basic types directly
            if (type == typeof(bool))
                return PluginValue.Bool((bool)obj);
            
            if (type == typeof(string))
                return PluginValue.String((string)obj);
            
            if (IsNumericType(type))
                return ConvertNumericToPluginValue(obj);
            
            if (type == typeof(DateTime))
                return PluginValue.Date((DateTime)obj);
            
            if (type == typeof(TimeSpan))
                return PluginValue.Duration((TimeSpan)obj);

            // Handle enums
            if (type.IsEnum)
                return PluginValue.String(obj.ToString()!);

            // Handle collections (arrays, lists, etc.)
            if (obj is IEnumerable enumerable && type != typeof(string))
            {
                var list = new List<PluginValue>();
                foreach (var item in enumerable)
                {
                    list.Add(ConvertObjectToNushellNative(item, new HashSet<object>(visited)));
                }
                return PluginValue.List(list);
            }

            // Handle complex objects as records
            if (type.IsClass || (type.IsValueType && !type.IsPrimitive))
            {
                return ConvertObjectToRecord(obj, visited);
            }

            // Fallback
            return PluginValue.String(obj.ToString() ?? "");
        }
        finally
        {
            visited.Remove(obj);
        }
    }

    private PluginValue ConvertObjectToRecord(object obj, HashSet<object> visited)
    {
        var record = new Dictionary<string, PluginValue>();
        var type = obj.GetType();

        // Add type information
        record["__type__"] = PluginValue.String(type.Name);
        record["__full_type__"] = PluginValue.String(type.FullName ?? type.Name);

        // Get all public properties
        var properties = type.GetProperties(BindingFlags.Public | BindingFlags.Instance)
            .Where(p => p.CanRead && p.GetIndexParameters().Length == 0) // Skip indexers
            .Take(50); // Limit to prevent overwhelming output

        foreach (var prop in properties)
        {
            try
            {
                var value = prop.GetValue(obj);
                var key = prop.Name.ToLowerInvariant(); // nushell style naming
                record[key] = ConvertObjectToNushellNative(value, new HashSet<object>(visited));
            }
            catch (Exception ex)
            {
                // If property access fails, show the error
                record[prop.Name.ToLowerInvariant()] = PluginValue.String($"[Error: {ex.Message}]");
            }
        }

        // Get some public fields if it's a struct or simple class
        if (type.IsValueType || record.Count < 5)
        {
            var fields = type.GetFields(BindingFlags.Public | BindingFlags.Instance)
                .Take(20);

            foreach (var field in fields)
            {
                try
                {
                    var value = field.GetValue(obj);
                    var key = field.Name.ToLowerInvariant();
                    if (!record.ContainsKey(key)) // Don't override properties
                    {
                        record[key] = ConvertObjectToNushellNative(value, new HashSet<object>(visited));
                    }
                }
                catch (Exception ex)
                {
                    record[field.Name.ToLowerInvariant()] = PluginValue.String($"[Error: {ex.Message}]");
                }
            }
        }

        return PluginValue.Record(record);
    }

    private PluginValue ConvertTypeInfoToNushell(Type type)
    {
        var record = new Dictionary<string, PluginValue>
        {
            ["name"] = PluginValue.String(type.Name),
            ["full_name"] = PluginValue.String(type.FullName ?? type.Name),
            ["namespace"] = PluginValue.String(type.Namespace ?? ""),
            ["is_class"] = PluginValue.Bool(type.IsClass),
            ["is_struct"] = PluginValue.Bool(type.IsValueType && !type.IsPrimitive),
            ["is_enum"] = PluginValue.Bool(type.IsEnum),
            ["is_generic"] = PluginValue.Bool(type.IsGenericType)
        };

        // Add properties info
        var properties = type.GetProperties(BindingFlags.Public | BindingFlags.Instance | BindingFlags.Static)
            .Select(p => PluginValue.String($"{p.Name}: {p.PropertyType.Name}"))
            .ToList();
        record["properties"] = PluginValue.List(properties);

        // Add methods info (just names, limited)
        var methods = type.GetMethods(BindingFlags.Public | BindingFlags.Instance | BindingFlags.Static)
            .Where(m => !m.IsSpecialName) // Skip property getters/setters
            .Select(m => m.Name)
            .Distinct()
            .Take(20)
            .Select(name => PluginValue.String(name))
            .ToList();
        record["methods"] = PluginValue.List(methods);

        return PluginValue.Record(record);
    }

    private object? ConvertPluginValueToClrForInspection(PluginValue value)
    {
        return value.Type switch
        {
            PluginValueType.String => value.AsString(),
            PluginValueType.Int => value.AsInt(),
            PluginValueType.Float => value.AsFloat(),
            PluginValueType.Bool => value.AsBool(),
            PluginValueType.List => value.AsList().Select(ConvertPluginValueToClrForInspection).ToArray(),
            PluginValueType.Record => value.AsRecord().ToDictionary(kvp => kvp.Key, kvp => ConvertPluginValueToClrForInspection(kvp.Value)),
            _ => null
        };
    }

    private static bool IsNumericType(Type type)
    {
        return type == typeof(byte) || type == typeof(sbyte) ||
               type == typeof(short) || type == typeof(ushort) ||
               type == typeof(int) || type == typeof(uint) ||
               type == typeof(long) || type == typeof(ulong) ||
               type == typeof(float) || type == typeof(double) ||
               type == typeof(decimal);
    }

    private PluginValue ConvertNumericToPluginValue(object value)
    {
        return value switch
        {
            byte or sbyte or short or ushort or int or uint or long or ulong => PluginValue.Int(Convert.ToInt64(value)),
            float or double or decimal => PluginValue.Float(Convert.ToDouble(value)),
            _ => PluginValue.String(value.ToString()!)
        };
    }
} 