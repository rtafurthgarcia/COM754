using System.Collections.Concurrent;
using System.Collections.Generic;

namespace CallerCallee.Helpers
{
    public static class EnumerableExtension
    {
        public static IEnumerable<T> ReadAndEmptyQueue<T>(this ConcurrentQueue<T> q)
        {
            T item;
            while (q.TryDequeue(out item))
            {
                yield return item;
            }
        }

    }
}
