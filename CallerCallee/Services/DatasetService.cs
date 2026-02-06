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
        private readonly ConcurrentQueue<DatasetEntry> todoDataset = new();
        public ConcurrentQueue<DatasetEntry> TodoDataset { 
            get { return todoDataset; } 
        }

        private readonly ConcurrentDictionary<Guid, DatasetEntry> doneDataset = new();
        public ConcurrentDictionary<Guid, DatasetEntry> DoneDataset
        {
            get { return doneDataset; }
        }

        private int total = 0;
        public int Total
        {
            get { return total; }
        }

        public async Task<List<DatasetEntry>> LoadDatasetEntries(string sourcePath)
        {
            todoDataset.Clear();

            var data = await File.ReadAllTextAsync(sourcePath);
            var rows = data.Split(Environment.NewLine);
            var results = rows
                .Skip(1)
                .Where(row => row.Length > 3)
                .Select(s => ParseRow(s, sourcePath))
                .Select(FindTurnsOfConversation)
                .Where(d => d.Children is not null)
                .ToList();
            results
                .ForEach(todoDataset.Enqueue);
            return results;
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
                        Id = f.Name,
                        Type = EntryType.TurnOfConversation,
                        FilePath = f.FullName,
                        Is = entry.Is
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
                Id = columns[0],
                Type = EntryType.Call,
                HumanClassification = columns[1].Equals("0") ? Flag.Safe : Flag.Fraud,
                Is = columns[2].Equals("0") ? Flag.Safe : Flag.Fraud,
                FilePath = Path.Combine(
                    parentOfParentPath.FullName,
                    columns[2].Equals("0") ? "nv" : "v",
                    columns[0])
            };
        }
    }
}
