using Microsoft.UI.Xaml;
using Microsoft.UI.Xaml.Controls;
using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.IO;
using System.Linq;

namespace CallerCallee.Models
{
    // Odd structure I admit, but it was meant to be displayed originally in a tree-like component,
    // then I got too busy to refactorise it after dropping the idea.
    public record DatasetEntry
    {
        public string Id { get; set; }
        public Flag Is { get; set; }
        public string FilePath { get; set; }
        public EntryType Type { get; set; }
        public Queue<DatasetEntry> Children { get; set; }
        public List<DetectionResult> DetectionResults { get; set; } = [];
        public State State { get; set; } = State.Todo;
        public Exception Exception { get; set; }
    }
}
