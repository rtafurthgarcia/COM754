using CallerCallee.Models;
using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using static CallerCallee.Models.DatasetEntry;

namespace CallerCallee.Services
{
    public sealed class DatasetImportService
    {
        private ConcurrentQueue<DatasetEntry>? dataset;
        public ConcurrentQueue<DatasetEntry>? Dataset { 
            get { return dataset; } 
        }

        public async Task LoadDatasetEntries(string sourcePath)
        {
            dataset = new ConcurrentQueue<DatasetEntry>();

            var data = await File.ReadAllTextAsync(sourcePath);
            var rows = data.Split(Environment.NewLine);
            rows
                .Skip(1)
                .Where(row => row.Length > 3)
                .Select(s => ParseRow(s, sourcePath))
                .Select(FindTurnsOfConversation)
                .ToList()
                .ForEach(dataset.Enqueue);
        }

        internal static DatasetEntry FindTurnsOfConversation(DatasetEntry entry)
        {
            if (entry.FilePath is null)
            {
                throw new KeyNotFoundException("FilePath should not be empty");
            }

            var dir = new DirectoryInfo(entry.FilePath);
            if (dir.Exists)
            {
                entry.Children = new ObservableCollection<DatasetEntry>(
                    [.. new DirectoryInfo(entry.FilePath)
                    .GetFiles("*.wav")
                    .Select(f => new DatasetEntry
                    {
                        Name = f.Name,
                        Type = DisplayType.TurnOfConversation,
                        FilePath = f.FullName,
                        Kind = entry.Kind,
                    })]);
            }

            return entry;
        }

        internal static DatasetEntry ParseRow(string row, string parentPath)
        {
            var columns = row.Split(',');

            var parentOfParentPath = new DirectoryInfo(parentPath).Parent ?? throw new KeyNotFoundException("FilePath should not be empty");
            return new DatasetEntry
            {
                Name = columns[0],
                Type = DisplayType.Call,
                Kind = columns[2] == "0" ? DatasetEntryKind.NotVishing : DatasetEntryKind.Vishing,
                FilePath = Path.Combine(
                    parentOfParentPath.FullName,
                    columns[2] == "0" ? "nv" : "v",
                    columns[0])
            };
        }
    }
}
