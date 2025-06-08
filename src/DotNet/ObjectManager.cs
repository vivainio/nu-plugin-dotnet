using System.Collections.Concurrent;

namespace NuPluginDotNet.DotNet;

public class ObjectManager
{
    private readonly ConcurrentDictionary<string, object> _objects = new();
    private readonly ConcurrentDictionary<string, DateTime> _lastAccessed = new();
    private readonly Timer _cleanupTimer;

    public ObjectManager()
    {
        // Cleanup every 10 minutes (increased from 5 minutes since we're using strong references)
        _cleanupTimer = new Timer(CleanupStaleObjects, null, TimeSpan.FromMinutes(10), TimeSpan.FromMinutes(10));
    }

    public string RegisterObject(object obj)
    {
        var objectId = Guid.NewGuid().ToString();
        _objects[objectId] = obj;
        _lastAccessed[objectId] = DateTime.UtcNow;
        return objectId;
    }

    public object GetObject(string objectId)
    {
        if (!_objects.TryGetValue(objectId, out var obj))
            throw new InvalidOperationException($"Object with ID {objectId} not found");

        _lastAccessed[objectId] = DateTime.UtcNow;
        return obj;
    }

    public T GetObject<T>(string objectId)
    {
        var obj = GetObject(objectId);
        if (obj is not T typedObj)
            throw new InvalidOperationException($"Object with ID {objectId} is not of type {typeof(T).Name}");
        return typedObj;
    }

    public bool TryGetObject(string objectId, out object? obj)
    {
        if (_objects.TryGetValue(objectId, out obj))
        {
            _lastAccessed[objectId] = DateTime.UtcNow;
            return true;
        }
        
        obj = null;
        return false;
    }

    public void DisposeObject(string objectId)
    {
        if (_objects.TryRemove(objectId, out var obj))
        {
            _lastAccessed.TryRemove(objectId, out _);
            
            if (obj is IDisposable disposable)
            {
                disposable.Dispose();
            }
            else if (obj is IAsyncDisposable asyncDisposable)
            {
                // Note: Can't await here, so we'll use a fire-and-forget approach
                _ = Task.Run(async () =>
                {
                    try
                    {
                        await asyncDisposable.DisposeAsync();
                    }
                    catch (Exception ex)
                    {
                        // Log error but don't throw
                        Console.Error.WriteLine($"Error disposing object {objectId}: {ex.Message}");
                    }
                });
            }
        }
    }

    public List<string> GetLiveObjectIds()
    {
        return _objects.Keys.ToList();
    }

    public void DisposeAll()
    {
        var objectIds = _objects.Keys.ToList();
        foreach (var objectId in objectIds)
        {
            DisposeObject(objectId);
        }
    }

    public void CollectGarbage()
    {
        GC.Collect();
        GC.WaitForPendingFinalizers();
        GC.Collect();
        
        CleanupStaleObjects(null);
    }

    private void CleanupStaleObjects(object? state)
    {
        // Clean up objects that haven't been accessed in over 2 hours (increased from 1 hour)
        var cutoff = DateTime.UtcNow.AddHours(-2);
        var staleObjects = _lastAccessed
            .Where(kvp => kvp.Value < cutoff)
            .Select(kvp => kvp.Key)
            .ToList();

        foreach (var objectId in staleObjects)
        {
            DisposeObject(objectId);
        }
    }

    public void Dispose()
    {
        _cleanupTimer?.Dispose();
        DisposeAll();
    }
} 