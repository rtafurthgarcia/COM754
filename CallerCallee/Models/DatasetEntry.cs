using Microsoft.UI.Xaml;
using Microsoft.UI.Xaml.Controls;
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

        public enum Flag
        {
            Vishing,
            NotVishing
        }

        public string Name { get; set; }
        public Flag Kind { get; set; }
        public string FilePath { get; set; }
        public DisplayType Type { get; set; }
        public Queue<DatasetEntry> Children { get; set; }
    }
}
