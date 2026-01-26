using Microsoft.UI.Xaml;
using Microsoft.UI.Xaml.Controls;
using ObservableCollections;
using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.IO;
using System.Linq;

namespace CallerCallee.Models
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
        public ObservableQueue<DatasetEntry> Children { get; set; }
    }

    public record ParentChildDataset(DatasetEntry Parent, DatasetEntry Child);

    public partial class DatasetEntryTemplateSelector : DataTemplateSelector
    {
        public DataTemplate CallTemplate { get; set; }
        public DataTemplate TurnOfConversationTemplate { get; set; }

        // Determines which template to use for each item in the TreeView based on its type.
        protected override DataTemplate SelectTemplateCore(object item)
        {
            var explorerItem = (DatasetEntry)item;

            // Return the appropriate template: FolderTemplate for folders, FileTemplate for files.
            return explorerItem.Type.Equals(DatasetEntry.DisplayType.Call)
                ? CallTemplate
                : TurnOfConversationTemplate;
        }
    }
}
