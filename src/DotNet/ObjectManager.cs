using System.Collections.Concurrent;

namespace NuPluginDotNet.DotNet;

public class ObjectManager
{
    private readonly ConcurrentDictionary<string, WeakReference> _objects = new();
    private readonly ConcurrentDictionary<string, DateTime> _lastAccessed = new();
    private readonly Timer _cleanupTimer;

    public ObjectManager()
    {
        // Cleanup every 5 minutes
        _cleanupTimer = new Timer(CleanupDeadReferences, null, TimeSpan.FromMinutes(5), TimeSpan.FromMinutes(5));
    }

    public string RegisterObject(object obj)
    {
        var objectId = Guid.NewGuid().ToString();
        _objects[objectId] = new WeakReference(obj);
        _lastAccessed[objectId] = DateTime.UtcNow;
        return objectId;
    }

    public object GetObject(string objectId)
    {
        if (!_objects.TryGetValue(objectId, out var weakRef))
            throw new InvalidOperationException($"Object with ID {objectId} not found");

        var obj = weakRef.Target;
        if (obj == null)
        {
            _objects.TryRemove(objectId, out _);
            _lastAccessed.TryRemove(objectId, out _);
            throw new InvalidOperationException($"Object with ID {objectId} has been garbage collected");
        }

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
        obj = null;
        
        if (!_objects.TryGetValue(objectId, out var weakRef))
            return false;

        obj = weakRef.Target;
        if (obj == null)
        {
            _objects.TryRemove(objectId, out _);
            _lastAccessed.TryRemove(objectId, out _);
            return false;
        }

        _lastAccessed[objectId] = DateTime.UtcNow;
        return true;
    }

    public void DisposeObject(string objectId)
    {
        if (_objects.TryRemove(objectId, out var weakRef))
        {
            _lastAccessed.TryRemove(objectId, out _);
            
            if (weakRef.Target is IDisposable disposable)
            {
                disposable.Dispose();
            }
            else if (weakRef.Target is IAsyncDisposable asyncDisposable)
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
        var liveObjects = new List<string>();
        
        foreach (var kvp in _objects)
        {
            if (kvp.Value.Target != null)
            {
                liveObjects.Add(kvp.Key);
            }
        }

        return liveObjects;
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
        
        CleanupDeadReferences(null);
    }

    private void CleanupDeadReferences(object? state)
    {
        var deadObjects = new List<string>();
        
        foreach (var kvp in _objects)
        {
            if (kvp.Value.Target == null)
            {
                deadObjects.Add(kvp.Key);
            }
        }

        foreach (var objectId in deadObjects)
        {
            _objects.TryRemove(objectId, out _);
            _lastAccessed.TryRemove(objectId, out _);
        }

        // Also clean up objects that haven't been accessed in over an hour
        var cutoff = DateTime.UtcNow.AddHours(-1);
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