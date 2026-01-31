using CallerCallee.Models;
using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Numerics;
using System.Threading.Tasks;
using static CallerCallee.Models.DatasetEntry;

namespace CallerCallee.Services
{
    public sealed class DatasetService
    {
        private readonly ConcurrentQueue<DatasetEntry> dataset = new();
        public ConcurrentQueue<DatasetEntry> Dataset { 
            get { return dataset; } 
        }

        private int total = 0;
        public int Total
        {
            get { return total; }
        }

        public async Task LoadDatasetEntries(string sourcePath)
        {
            dataset.Clear();

            var data = await File.ReadAllTextAsync(sourcePath);
            var rows = data.Split(Environment.NewLine);
            rows
                .Skip(1)
                .Where(row => row.Length > 3)
                .Select(s => ParseRow(s, sourcePath))
                .Select(FindTurnsOfConversation)
                .Where(d => d.Children is not null)
                .ToList()
                .ForEach(dataset.Enqueue);
        }

        internal DatasetEntry FindTurnsOfConversation(DatasetEntry entry)
        {
            if (entry.FilePath is null)
            {
                throw new KeyNotFoundException("FilePath should not be empty");
            }

            var dir = new DirectoryInfo(entry.FilePath);
            if (dir.Exists)
            {
                entry.Children = new Queue<DatasetEntry>(
                    [.. new DirectoryInfo(entry.FilePath)
                    .GetFiles("*.wav")
                    .OrderBy(f => int.Parse(f.Name.Replace(".wav", "")))
                    .Select(f => new DatasetEntry
                    {
                        Name = f.Name,
                        Type = DisplayType.TurnOfConversation,
                        FilePath = f.FullName,
                        Kind = entry.Kind,
                    })]);

                total += entry.Children.Count;
            }

            return entry;
        }

        internal static DatasetEntry ParseRow(string row, string parentPath)
        {
            var columns = row.Split(';');

            var parentOfParentPath = new DirectoryInfo(parentPath).Parent ?? throw new KeyNotFoundException("FilePath should not be empty");
            return new DatasetEntry
            {
                Name = columns[0],
                Type = DisplayType.Call,
                Kind = columns[2].Equals("0") ? Flag.NotVishing : Flag.Vishing,
                FilePath = Path.Combine(
                    parentOfParentPath.FullName,
                    columns[2].Equals("0") ? "nv" : "v",
                    columns[0])
            };
        }
    }
}
