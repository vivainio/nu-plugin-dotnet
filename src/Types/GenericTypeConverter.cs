using System.Text;
using System.Text.RegularExpressions;

namespace NuPluginDotNet.Types;

/// <summary>
/// Converts user-friendly generic type syntax to .NET internal type names
/// </summary>
public static class GenericTypeConverter
{
    // Common type aliases mapping
    private static readonly Dictionary<string, string> TypeAliases = new()
    {
        { "string", "System.String" },
        { "int", "System.Int32" },
        { "long", "System.Int64" },
        { "short", "System.Int16" },
        { "byte", "System.Byte" },
        { "bool", "System.Boolean" },
        { "double", "System.Double" },
        { "float", "System.Single" },
        { "decimal", "System.Decimal" },
        { "char", "System.Char" },
        { "object", "System.Object" },
        { "void", "System.Void" }
    };

    // Common generic types with their full names and arity
    private static readonly Dictionary<string, (string FullName, int Arity)> GenericTypes = new()
    {
        { "List", ("System.Collections.Generic.List", 1) },
        { "Dictionary", ("System.Collections.Generic.Dictionary", 2) },
        { "HashSet", ("System.Collections.Generic.HashSet", 1) },
        { "Queue", ("System.Collections.Generic.Queue", 1) },
        { "Stack", ("System.Collections.Generic.Stack", 1) },
        { "SortedDictionary", ("System.Collections.Generic.SortedDictionary", 2) },
        { "SortedSet", ("System.Collections.Generic.SortedSet", 1) },
        { "LinkedList", ("System.Collections.Generic.LinkedList", 1) },
        { "KeyValuePair", ("System.Collections.Generic.KeyValuePair", 2) },
        { "Nullable", ("System.Nullable", 1) },
        { "IEnumerable", ("System.Collections.Generic.IEnumerable", 1) },
        { "ICollection", ("System.Collections.Generic.ICollection", 1) },
        { "IList", ("System.Collections.Generic.IList", 1) },
        { "IDictionary", ("System.Collections.Generic.IDictionary", 2) },
        { "ISet", ("System.Collections.Generic.ISet", 1) },
        { "Task", ("System.Threading.Tasks.Task", 1) },
        { "Func", ("System.Func", -1) }, // Variable arity
        { "Action", ("System.Action", -1) } // Variable arity
    };

    /// <summary>
    /// Converts user-friendly generic syntax to .NET internal type name
    /// Examples:
    /// - "Dictionary<string, int>" -> "System.Collections.Generic.Dictionary`2[System.String,System.Int32]"
    /// - "List<string>" -> "System.Collections.Generic.List`1[System.String]"
    /// - "string" -> "System.String"
    /// </summary>
    public static string ConvertToInternalTypeName(string userTypeName)
    {
        if (string.IsNullOrWhiteSpace(userTypeName))
            return userTypeName;

        // First, handle simple type aliases
        if (TypeAliases.ContainsKey(userTypeName))
            return TypeAliases[userTypeName];

        // Check if it contains generic parameters (< and >)
        if (!userTypeName.Contains('<') || !userTypeName.Contains('>'))
        {
            // Not a generic type, check if it's a known generic type without parameters
            if (GenericTypes.ContainsKey(userTypeName))
            {
                return GenericTypes[userTypeName].FullName;
            }
            return userTypeName; // Return as-is
        }

        return ConvertGenericType(userTypeName);
    }

    private static string ConvertGenericType(string genericTypeName)
    {
        // Parse the generic type using regex
        var match = Regex.Match(genericTypeName, @"^([^<]+)<(.+)>$");
        if (!match.Success)
            return genericTypeName; // Invalid format, return as-is

        var baseTypeName = match.Groups[1].Value.Trim();
        var typeParametersString = match.Groups[2].Value;

        // Parse type parameters, handling nested generics
        var typeParameters = ParseTypeParameters(typeParametersString);

        // Convert base type name
        string fullBaseTypeName;
        int expectedArity;

        if (GenericTypes.ContainsKey(baseTypeName))
        {
            var typeInfo = GenericTypes[baseTypeName];
            fullBaseTypeName = typeInfo.FullName;
            expectedArity = typeInfo.Arity;

            // For variable arity types like Func and Action, use actual parameter count
            if (expectedArity == -1)
                expectedArity = typeParameters.Count;
        }
        else
        {
            // Unknown generic type, assume it's already a full name or will be resolved later
            fullBaseTypeName = baseTypeName;
            expectedArity = typeParameters.Count;
        }

        // Validate arity for known types
        if (GenericTypes.ContainsKey(baseTypeName) && 
            GenericTypes[baseTypeName].Arity != -1 && 
            typeParameters.Count != expectedArity)
        {
            throw new ArgumentException($"Generic type '{baseTypeName}' expects {expectedArity} type parameters, but {typeParameters.Count} were provided.");
        }

        // Convert each type parameter recursively
        var convertedParameters = typeParameters.Select(ConvertToInternalTypeName).ToList();

        // Build the .NET internal format: BaseType`arity[Param1,Param2,...]
        var result = new StringBuilder();
        result.Append(fullBaseTypeName);
        result.Append('`');
        result.Append(expectedArity);
        result.Append('[');
        result.Append(string.Join(",", convertedParameters));
        result.Append(']');

        return result.ToString();
    }

    private static List<string> ParseTypeParameters(string typeParametersString)
    {
        var parameters = new List<string>();
        var current = new StringBuilder();
        int depth = 0;
        bool inQuotes = false;

        foreach (char c in typeParametersString)
        {
            switch (c)
            {
                case '"':
                    inQuotes = !inQuotes;
                    current.Append(c);
                    break;

                case '<':
                    if (!inQuotes)
                        depth++;
                    current.Append(c);
                    break;

                case '>':
                    if (!inQuotes)
                        depth--;
                    current.Append(c);
                    break;

                case ',':
                    if (!inQuotes && depth == 0)
                    {
                        // This comma separates type parameters
                        parameters.Add(current.ToString().Trim());
                        current.Clear();
                    }
                    else
                    {
                        current.Append(c);
                    }
                    break;

                default:
                    current.Append(c);
                    break;
            }
        }

        // Add the last parameter
        if (current.Length > 0)
        {
            parameters.Add(current.ToString().Trim());
        }

        return parameters;
    }

    /// <summary>
    /// Checks if a type name uses user-friendly generic syntax
    /// </summary>
    public static bool IsUserFriendlyGenericSyntax(string typeName)
    {
        if (string.IsNullOrWhiteSpace(typeName))
            return false;

        // Check for < and > which indicate user-friendly generic syntax
        return typeName.Contains('<') && typeName.Contains('>') && !typeName.Contains('`');
    }

    /// <summary>
    /// Gets all available generic type shortcuts
    /// </summary>
    public static Dictionary<string, (string FullName, int Arity)> GetAvailableGenericTypes()
    {
        return new Dictionary<string, (string FullName, int Arity)>(GenericTypes);
    }

    /// <summary>
    /// Gets all available type aliases
    /// </summary>
    public static Dictionary<string, string> GetAvailableTypeAliases()
    {
        return new Dictionary<string, string>(TypeAliases);
    }
} 