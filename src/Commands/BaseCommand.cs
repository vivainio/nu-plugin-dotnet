using NuPluginDotNet.DotNet;
using NuPluginDotNet.Types;
using NuPluginDotNet.Plugin;

namespace NuPluginDotNet.Commands;

public abstract class BaseCommand
{
    protected readonly ObjectManager ObjectManager;
    protected readonly AssemblyManager AssemblyManager;
    protected readonly ValueConverter ValueConverter;

    protected BaseCommand(
        ObjectManager objectManager,
        AssemblyManager assemblyManager,
        ValueConverter valueConverter)
    {
        ObjectManager = objectManager;
        AssemblyManager = assemblyManager;
        ValueConverter = valueConverter;
    }

    public abstract Task<PluginValue> ExecuteAsync(CommandArgs args);

    protected PluginValue CreateError(string message, Exception? exception = null)
    {
        try
        {
            return new PluginValue
            {
                Type = PluginValueType.Error,
                Value = new PluginError
                {
                    Message = message,
                    StackTrace = GetSafeStackTrace(exception),
                    Type = GetSafeTypeName(exception)
                }
            };
        }
        catch (StackOverflowException)
        {
            // In case of stack overflow during error creation, return minimal error
            return new PluginValue
            {
                Type = PluginValueType.Error,
                Value = new PluginError
                {
                    Message = "Stack overflow detected: " + message,
                    StackTrace = "Stack overflow prevented full trace",
                    Type = "StackOverflowException"
                }
            };
        }
        catch (Exception errorEx)
        {
            // Fallback for any other errors during error creation
            return new PluginValue
            {
                Type = PluginValueType.Error,
                Value = new PluginError
                {
                    Message = $"Error creating error report: {errorEx.Message} | Original: {message}",
                    StackTrace = null,
                    Type = errorEx.GetType().Name
                }
            };
        }
    }

    private static string? GetSafeStackTrace(Exception? exception)
    {
        if (exception == null) return null;
        
        try
        {
            return exception.StackTrace;
        }
        catch
        {
            return "Stack trace unavailable due to error";
        }
    }

    private static string? GetSafeTypeName(Exception? exception)
    {
        if (exception == null) return null;
        
        try
        {
            return exception.GetType().FullName;
        }
        catch
        {
            return "Exception type unavailable";
        }
    }

    protected async Task<object?> UnwrapAsyncResult(object? result)
    {
        if (result == null)
            return null;

        var resultType = result.GetType();

        // Handle Task<T>
        if (resultType.IsGenericType && resultType.GetGenericTypeDefinition() == typeof(Task<>))
        {
            var task = (Task)result;
            await task;
            var resultProperty = resultType.GetProperty("Result");
            return resultProperty?.GetValue(task);
        }

        // Handle Task (non-generic)
        if (resultType == typeof(Task))
        {
            await (Task)result;
            return null;
        }

        // Handle ValueTask<T>
        if (resultType.IsGenericType && resultType.GetGenericTypeDefinition() == typeof(ValueTask<>))
        {
            var valueTask = result;
            var asTaskMethod = resultType.GetMethod("AsTask");
            var task = (Task)asTaskMethod!.Invoke(valueTask, null)!;
            await task;
            var resultProperty = task.GetType().GetProperty("Result");
            return resultProperty?.GetValue(task);
        }

        // Handle ValueTask (non-generic)
        if (resultType == typeof(ValueTask))
        {
            var valueTask = (ValueTask)result;
            await valueTask;
            return null;
        }

        return result;
    }

    protected bool IsAsyncMethod(System.Reflection.MethodInfo method)
    {
        var returnType = method.ReturnType;
        
        return returnType == typeof(Task) ||
               (returnType.IsGenericType && returnType.GetGenericTypeDefinition() == typeof(Task<>)) ||
               returnType == typeof(ValueTask) ||
               (returnType.IsGenericType && returnType.GetGenericTypeDefinition() == typeof(ValueTask<>));
    }
} 