using CallerCallee.Models;
using System;
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
        public async Task<List<DatasetEntry>> LoadDatasetEntries(string sourcePath)
        {
            var data = await File.ReadAllTextAsync(sourcePath);
            var rows = data.Split(Environment.NewLine);
            return rows
                .Skip(1)
                .Where(row => row.Length > 0)
                .Select(s => ParseRow(s, sourcePath))
                .Select(FindTurnsOfConversation)
                .ToList();
        }

        internal static DatasetEntry FindTurnsOfConversation(DatasetEntry entry)
        {
            var dir = new DirectoryInfo(entry.FilePath);
            if (dir.Exists)
            {
                entry.Children = new ObservableCollection<DatasetEntry>(
                    new DirectoryInfo(entry.FilePath)
                    .GetFiles("*.wav")
                    .Select(f => new DatasetEntry
                    {
                        Name = f.Name,
                        Type = DisplayType.TurnOfConversation,
                        FilePath = f.FullName,
                        Kind = entry.Kind,
                    })
                    .ToList());
            }

            return entry;
        }

        internal static DatasetEntry ParseRow(string row, string parentPath)
        {
            var columns = row.Split(',');

            var turnsOfConversation = new ObservableCollection<DatasetEntry>();

            return new DatasetEntry
            {
                Name = columns[0],
                Type = DisplayType.Call,
                Kind = columns[2] == "0" ? DatasetEntryKind.NotVishing : DatasetEntryKind.Vishing,
                FilePath = Path.Combine(new DirectoryInfo(parentPath).Parent.FullName, columns[2] == "0" ? "nv" : "v", columns[0])
            };
        }
    }
}
