using CallerCallee.Models;
using CommunityToolkit.Mvvm.ComponentModel;
using Microsoft.UI;
using Microsoft.UI.Xaml;
using Microsoft.UI.Xaml.Controls;
using Microsoft.UI.Xaml.Media;
using System;
using System.Diagnostics;
using System.Linq;

namespace CallerCallee.ViewModels
{
    public partial class DatasetViewModel(DatasetEntry datasetEntry) : ObservableObject
    {
        [ObservableProperty]
        public partial DatasetEntry Entry { get; set; } = datasetEntry;

        public string Id => "Entry #" + Entry.Id;

        public Flag Is => Entry.Is; 

        public Flag Human => Entry.HumanClassification;

        public Flag Naive => Entry.DetectionResults.Count > 0 ? Entry.DetectionResults.LastOrDefault().NaiveClassification.Flag : Flag.Unknown;
        public Flag Enhanced => Entry.DetectionResults.Count > 0 ? Entry.DetectionResults.LastOrDefault().EnhancedClassification.Flag : Flag.Unknown;

        public int Turns => Entry.Children?.Count ?? 0;

        public State State => Entry.State;

        [ObservableProperty]
        public partial Exception LastException { get; set; }

        public string RealDuration => Entry.RealDuration;

        public Brush GetRightColor(Flag flag)
        {
            if (flag is Flag.Safe)
            {
                return new SolidColorBrush(Colors.Chartreuse);
            }
            else if (flag is Flag.Fraud)
            {
                return new SolidColorBrush(Colors.Crimson);
            }
            else
            {
                return new SolidColorBrush(Colors.Gray);
            }
        }
    }
}
