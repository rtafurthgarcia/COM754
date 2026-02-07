using CallerCallee.Models;
using CommunityToolkit.Mvvm.ComponentModel;
using Microsoft.UI;
using Microsoft.UI.Xaml;
using Microsoft.UI.Xaml.Controls;
using Microsoft.UI.Xaml.Media;
using System;
using System.Diagnostics;
using System.Linq;
using System.Reflection;
using System.Windows.Forms;

namespace CallerCallee.ViewModels
{
    public partial class DatasetViewModel(DatasetEntry datasetEntry) : ObservableObject
    {
        private DatasetEntry Entry { get; set; } = datasetEntry;

        public int Id => int.Parse(Entry.Id);

        public Flag Is => Entry.Is; 

        public Flag Human => Entry.HumanClassification;

        [ObservableProperty]
        public partial Flag Naive { get; set; } = Flag.Unknown;
        [ObservableProperty]
        public partial Flag Enhanced { get; set; } = Flag.Unknown;

        public int Turns => Entry.Children?.Count ?? 0;

        public State State
        {
            get => Entry.State;
            set => SetProperty(Entry.State, value, Entry, (e, v) => e.State = v);
        }

        public void AddDetectionResult(Classifications classifications)
        {
            Entry.DetectionResults.Add(classifications);
            Naive = classifications.NaiveClassification.Flag;
            Enhanced = classifications.EnhancedClassification.Flag;
        }

        public Exception LastException
        {
            get => Entry.Exception;
            set => SetProperty(Entry.Exception, value, Entry, (e, v) => e.Exception = v);
        }

        public string RealDuration
        {
            get => Entry.RealDuration;
            set => SetProperty(Entry.RealDuration, value, Entry, (e, v) => e.RealDuration = v);
        }
    }
}
