using System.Collections;
using System.Reflection;
using NuPluginDotNet.DotNet;

namespace NuPluginDotNet.Types;

public class ValueConverter
{
    private readonly ObjectManager? _objectManager;

    public ValueConverter(ObjectManager? objectManager = null)
    {
        _objectManager = objectManager;
    }

    public object? ConvertToClr(PluginValue nushellValue, Type targetType)
    {
        if (nushellValue.IsNull)
        {
            return targetType.IsValueType && Nullable.GetUnderlyingType(targetType) == null
                ? Activator.CreateInstance(targetType)
                : null;
        }

        // Handle nullable types
        var underlyingType = Nullable.GetUnderlyingType(targetType);
        if (underlyingType != null)
        {
            return ConvertToClr(nushellValue, underlyingType);
        }

        // Handle basic types
        if (targetType == typeof(bool) && nushellValue.IsBool)
            return nushellValue.AsBool();
        
        if (targetType == typeof(string) && nushellValue.IsString)
            return nushellValue.AsString();
        
        if (IsNumericType(targetType))
            return ConvertNumeric(nushellValue, targetType);
        
        if (targetType == typeof(DateTime) && nushellValue.Type == PluginValueType.Date)
            return (DateTime)nushellValue.Value!;
        
        if (targetType == typeof(TimeSpan) && nushellValue.Type == PluginValueType.Duration)
            return (TimeSpan)nushellValue.Value!;

        // Handle byte arrays from nushell binary data
        if (targetType == typeof(byte[]) && nushellValue.Type == PluginValueType.Binary)
            return (byte[])nushellValue.Value!;

        // Handle arrays and collections
        if (nushellValue.IsList)
        {
            var list = nushellValue.AsList();
            
            if (targetType.IsArray)
            {
                var elementType = targetType.GetElementType()!;
                var array = Array.CreateInstance(elementType, list.Count);
                for (int i = 0; i < list.Count; i++)
                {
                    array.SetValue(ConvertToClr(list[i], elementType), i);
                }
                return array;
            }

            if (targetType.IsGenericType)
            {
                var genericDef = targetType.GetGenericTypeDefinition();
                if (genericDef == typeof(List<>) || genericDef == typeof(IList<>) || genericDef == typeof(ICollection<>) || genericDef == typeof(IEnumerable<>))
                {
                    var elementType = targetType.GetGenericArguments()[0];
                    var listType = typeof(List<>).MakeGenericType(elementType);
                    var result = Activator.CreateInstance(listType) as IList;
                    
                    foreach (var item in list)
                    {
                        result!.Add(ConvertToClr(item, elementType));
                    }
                    
                    return result;
                }
            }
        }

        // Handle records/dictionaries
        if (nushellValue.IsRecord)
        {
            var record = nushellValue.AsRecord();
            
            if (targetType == typeof(Dictionary<string, object>) || targetType == typeof(IDictionary<string, object>))
            {
                var result = new Dictionary<string, object>();
                foreach (var kvp in record)
                {
                    result[kvp.Key] = ConvertToClr(kvp.Value, typeof(object))!;
                }
                return result;
            }

            // Try to create object from record fields
            if (targetType.IsClass && !targetType.IsAbstract)
            {
                return CreateObjectFromRecord(record, targetType);
            }
        }

        // Handle custom objects (already .NET objects)
        if (nushellValue.IsCustom)
        {
            var objectId = nushellValue.GetObjectId();
            if (_objectManager != null)
            {
                return _objectManager.GetObject(objectId);
            }
            throw new InvalidOperationException("Custom object resolution requires ObjectManager");
        }

        // Try direct conversion
        if (nushellValue.Value != null && targetType.IsAssignableFrom(nushellValue.Value.GetType()))
        {
            return nushellValue.Value;
        }

        // Last resort - Convert.ChangeType
        try
        {
            return Convert.ChangeType(nushellValue.Value, targetType);
        }
        catch
        {
            throw new InvalidOperationException($"Cannot convert {nushellValue.Type} to {targetType.Name}");
        }
    }

    public PluginValue ConvertFromClr(object? clrObject)
    {
        if (clrObject == null)
            return PluginValue.Null();

        var type = clrObject.GetType();

        // Handle basic types
        if (type == typeof(bool))
            return PluginValue.Bool((bool)clrObject);
        
        if (type == typeof(string))
            return PluginValue.String((string)clrObject);
        
        if (IsNumericType(type))
            return ConvertNumericFromClr(clrObject);
        
        if (type == typeof(DateTime))
            return PluginValue.Date((DateTime)clrObject);
        
        if (type == typeof(TimeSpan))
            return PluginValue.Duration((TimeSpan)clrObject);

        // Handle byte arrays
        if (type == typeof(byte[]))
            return PluginValue.Binary((byte[])clrObject);

        // Handle collections
        if (clrObject is IEnumerable enumerable && type != typeof(string))
        {
            var list = new List<PluginValue>();
            foreach (var item in enumerable)
            {
                list.Add(ConvertFromClr(item));
            }
            return PluginValue.List(list);
        }

        // Handle complex objects
        if (type.IsClass || (type.IsValueType && !type.IsPrimitive))
        {
            // For complex objects, we need to register them and return a custom value
            if (_objectManager != null)
            {
                var objectId = _objectManager.RegisterObject(clrObject);
                return PluginValue.Custom(objectId, type.FullName ?? type.Name);
            }
            
            // If no object manager, try to convert to record for simple objects
            if (type.IsClass && type != typeof(string))
            {
                return ConvertObjectToRecord(clrObject);
            }
        }

        // Fallback to string representation
        return PluginValue.String(clrObject.ToString() ?? "");
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

    private object ConvertNumeric(PluginValue value, Type targetType)
    {
        var numericValue = value.IsInt ? value.AsInt() : value.AsFloat();

        object result = targetType.Name switch
        {
            nameof(Byte) => Convert.ToByte(numericValue),
            nameof(SByte) => Convert.ToSByte(numericValue),
            nameof(Int16) => Convert.ToInt16(numericValue),
            nameof(UInt16) => Convert.ToUInt16(numericValue),
            nameof(Int32) => Convert.ToInt32(numericValue),
            nameof(UInt32) => Convert.ToUInt32(numericValue),
            nameof(Int64) => Convert.ToInt64(numericValue),
            nameof(UInt64) => Convert.ToUInt64(numericValue),
            nameof(Single) => Convert.ToSingle(numericValue),
            nameof(Double) => Convert.ToDouble(numericValue),
            nameof(Decimal) => Convert.ToDecimal(numericValue),
            _ => throw new InvalidOperationException($"Unsupported numeric type: {targetType.Name}")
        };
        
        return result;
    }

    private PluginValue ConvertNumericFromClr(object value)
    {
        return value switch
        {
            byte or sbyte or short or ushort or int or uint or long or ulong => PluginValue.Int(Convert.ToInt64(value)),
            float or double or decimal => PluginValue.Float(Convert.ToDouble(value)),
            _ => throw new InvalidOperationException($"Unsupported numeric type: {value.GetType().Name}")
        };
    }

    private object CreateObjectFromRecord(Dictionary<string, PluginValue> record, Type targetType)
    {
        var instance = Activator.CreateInstance(targetType)!;
        
        foreach (var kvp in record)
        {
            // Try property first
            var property = targetType.GetProperty(kvp.Key, BindingFlags.Public | BindingFlags.Instance | BindingFlags.IgnoreCase);
            if (property != null && property.CanWrite)
            {
                var convertedValue = ConvertToClr(kvp.Value, property.PropertyType);
                property.SetValue(instance, convertedValue);
                continue;
            }

            // Try field
            var field = targetType.GetField(kvp.Key, BindingFlags.Public | BindingFlags.Instance | BindingFlags.IgnoreCase);
            if (field != null)
            {
                var convertedValue = ConvertToClr(kvp.Value, field.FieldType);
                field.SetValue(instance, convertedValue);
            }
        }

        return instance;
    }

    private PluginValue ConvertObjectToRecord(object obj)
    {
        var type = obj.GetType();
        var record = new Dictionary<string, PluginValue>();

        // Get public properties
        var properties = type.GetProperties(BindingFlags.Public | BindingFlags.Instance)
            .Where(p => p.CanRead && p.GetIndexParameters().Length == 0);

        foreach (var property in properties)
        {
            try
            {
                var value = property.GetValue(obj);
                record[property.Name] = ConvertFromClr(value);
            }
            catch
            {
                // Skip properties that can't be read
            }
        }

        // Get public fields
        var fields = type.GetFields(BindingFlags.Public | BindingFlags.Instance);
        foreach (var field in fields)
        {
            try
            {
                var value = field.GetValue(obj);
                record[field.Name] = ConvertFromClr(value);
            }
            catch
            {
                // Skip fields that can't be read
            }
        }

        return PluginValue.Record(record);
    }
} 