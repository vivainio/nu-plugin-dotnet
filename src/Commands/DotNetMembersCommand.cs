using System.Reflection;
using Microsoft.Extensions.Logging;
using NuPluginDotNet.DotNet;
using NuPluginDotNet.Types;

namespace NuPluginDotNet.Commands;

public class DotNetMembersCommand : BaseCommand
{
    public DotNetMembersCommand(
        ObjectManager objectManager,
        AssemblyManager assemblyManager,
        ValueConverter valueConverter,
        ILogger logger) : base(objectManager, assemblyManager, valueConverter, logger)
    {
    }

    public override Task<PluginValue> ExecuteAsync(CommandArgs args)
    {
        try
        {
            // Type name from first positional argument
            var typeName = args.GetPositionalString(0);
            
            // Optional filter for member type
            var memberFilter = args.GetOptionalString("type")?.ToLowerInvariant();
            var includeStatic = args.GetBool("static", true);
            var includeInstance = args.GetBool("instance", true);

            var type = AssemblyManager.FindType(typeName);
            if (type == null)
            {
                return Task.FromResult(CreateError($"Type '{typeName}' not found"));
            }

            var bindingFlags = BindingFlags.Public;
            if (includeStatic) bindingFlags |= BindingFlags.Static;
            if (includeInstance) bindingFlags |= BindingFlags.Instance;

            var memberList = new List<PluginValue>();

            // Add methods
            if (memberFilter == null || memberFilter == "methods" || memberFilter == "method")
            {
                var methods = type.GetMethods(bindingFlags)
                    .Where(m => !m.IsSpecialName) // Exclude property getters/setters
                    .OrderBy(m => m.Name);

                foreach (var method in methods)
                {
                    var methodRecord = new Dictionary<string, PluginValue>
                    {
                        ["memberType"] = PluginValue.String("Method"),
                        ["name"] = PluginValue.String(method.Name),
                        ["returnType"] = PluginValue.String(method.ReturnType.Name),
                        ["isStatic"] = PluginValue.Bool(method.IsStatic),
                        ["isPublic"] = PluginValue.Bool(method.IsPublic),
                        ["isVirtual"] = PluginValue.Bool(method.IsVirtual),
                        ["isAbstract"] = PluginValue.Bool(method.IsAbstract),
                        ["isGeneric"] = PluginValue.Bool(method.IsGenericMethod)
                    };

                    var parameters = method.GetParameters()
                        .Select(p => PluginValue.String($"{p.ParameterType.Name} {p.Name}"))
                        .ToList();
                    methodRecord["parameters"] = PluginValue.List(parameters);

                    memberList.Add(PluginValue.Record(methodRecord));
                }
            }

            // Add properties
            if (memberFilter == null || memberFilter == "properties" || memberFilter == "property")
            {
                var properties = type.GetProperties(bindingFlags).OrderBy(p => p.Name);

                foreach (var property in properties)
                {
                    var propertyRecord = new Dictionary<string, PluginValue>
                    {
                        ["memberType"] = PluginValue.String("Property"),
                        ["name"] = PluginValue.String(property.Name),
                        ["propertyType"] = PluginValue.String(property.PropertyType.Name),
                        ["canRead"] = PluginValue.Bool(property.CanRead),
                        ["canWrite"] = PluginValue.Bool(property.CanWrite),
                        ["isStatic"] = PluginValue.Bool(property.GetMethod?.IsStatic == true || property.SetMethod?.IsStatic == true)
                    };

                    var indexParameters = property.GetIndexParameters();
                    if (indexParameters.Length > 0)
                    {
                        var indexParams = indexParameters
                            .Select(p => PluginValue.String($"{p.ParameterType.Name} {p.Name}"))
                            .ToList();
                        propertyRecord["indexParameters"] = PluginValue.List(indexParams);
                    }

                    memberList.Add(PluginValue.Record(propertyRecord));
                }
            }

            // Add fields
            if (memberFilter == null || memberFilter == "fields" || memberFilter == "field")
            {
                var fields = type.GetFields(bindingFlags).OrderBy(f => f.Name);

                foreach (var field in fields)
                {
                    var fieldRecord = new Dictionary<string, PluginValue>
                    {
                        ["memberType"] = PluginValue.String("Field"),
                        ["name"] = PluginValue.String(field.Name),
                        ["fieldType"] = PluginValue.String(field.FieldType.Name),
                        ["isStatic"] = PluginValue.Bool(field.IsStatic),
                        ["isPublic"] = PluginValue.Bool(field.IsPublic),
                        ["isReadOnly"] = PluginValue.Bool(field.IsInitOnly),
                        ["isLiteral"] = PluginValue.Bool(field.IsLiteral)
                    };

                    memberList.Add(PluginValue.Record(fieldRecord));
                }
            }

            Logger.LogInformation("Listed {Count} members from type {TypeName}", memberList.Count, typeName);
            
            return Task.FromResult(PluginValue.List(memberList));
        }
        catch (Exception ex)
        {
            return Task.FromResult(CreateError($"Failed to list members: {ex.Message}", ex));
        }
    }
} 