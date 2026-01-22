using Microsoft.UI.Xaml;
using Microsoft.UI.Xaml.Controls;
using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.IO;
using System.Linq;

namespace CallerCallee
{
    public class DatasetEntry
    {
        public enum DisplayType
        {
            Call,
            TurnOfConversation,
        }

        public enum DatasetEntryKind
        {
            Vishing, 
            NotVishing
        }

        public string Name { get; set; }
        public DatasetEntryKind Kind { get; set; }
        public string FilePath { get; set; }
        public DisplayType Type { get; set; }
        public ObservableCollection<DatasetEntry>? Children { get; set; }

        public static List<DatasetEntry> LoadDatasetEntries(string sourcePath)
        {
            var data = File.ReadAllText(sourcePath);
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
            if (dir.Exists) {
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

    public class DatasetEntryTemplateSelector : DataTemplateSelector
    {
        public DataTemplate? CallTemplate { get; set; }
        public DataTemplate? TurnOfConversationTemplate { get; set; }

        // Determines which template to use for each item in the TreeView based on its type.
        protected override DataTemplate? SelectTemplateCore(object item)
        {
            var explorerItem = (DatasetEntry)item;

            // Return the appropriate template: FolderTemplate for folders, FileTemplate for files.
            return explorerItem.Type == DatasetEntry.DisplayType.Call
                ? CallTemplate
                : TurnOfConversationTemplate;
        }
    }
}
