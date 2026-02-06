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
        public string Id => "Entry #" + datasetEntry.Id;

        public Flag Is => datasetEntry.Is; 

        public Flag Human => datasetEntry.HumanClassification;

        public Flag Naive => datasetEntry.DetectionResults.Count > 0 ? datasetEntry.DetectionResults.LastOrDefault().NaiveClassification.Flag : Flag.Unknown;

        public Flag Enhanced => datasetEntry.DetectionResults.Count > 0 ? datasetEntry.DetectionResults.LastOrDefault().EnhancedClassification.Flag : Flag.Unknown;

        public int Turns => datasetEntry.Children?.Count ?? 0;

        public State State => datasetEntry.State;

        [ObservableProperty]
        public partial Exception LastException { get; set; }

        public string RealDuration => datasetEntry.RealDuration;

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
