using CallerCallee.Models;
using CommunityToolkit.Mvvm.ComponentModel;
using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CallerCallee.ViewModels
{
    public partial class MainPageViewModel: ObservableObject
    {
        private List<DatasetEntry>? Dataset;

        public ObservableCollection<DatasetEntry>? DataSourceVishing { get; set; }
        public ObservableCollection<DatasetEntry>? DataSourceNonVishing { get; set; }

        [ObservableProperty]
        private bool buttonsVisible;



    }
}
