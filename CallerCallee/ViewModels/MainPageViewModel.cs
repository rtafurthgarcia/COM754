using CallerCallee.Models;
using CallerCallee.Services;
using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.DependencyInjection;
using CommunityToolkit.Mvvm.Input;
using Microsoft.UI;
using Microsoft.UI.Windowing;
using Microsoft.UI.Xaml;
using Microsoft.UI.Xaml.Controls;
using Microsoft.Windows.Storage.Pickers;
using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CallerCallee.ViewModels
{
    public partial class MainPageViewModel: ObservableObject
    {
        public ObservableCollection<DatasetEntry> DataSourceVishing { get; } = new ObservableCollection<DatasetEntry> { }; 
        public ObservableCollection<DatasetEntry> DataSourceNonVishing { get; } = new ObservableCollection<DatasetEntry> { };

        [ObservableProperty]
        public partial string? LoadedDatasetMessage { get; set; }

        public async Task ImportDatasetAsync(WindowId id)
        {
            var file = await Ioc.Default.GetRequiredService<FilePickerService>().PickFileDialogAsync(id);
            LoadedDatasetMessage = file != null
                    ? "Picked: " + new FileInfo(file.Path).Name
                    : "No datasource selected.";

            var dataset = await Ioc.Default.GetRequiredService<DatasetImportService>().LoadDatasetEntries(file.Path);
            dataset
                .TakeWhile(d => d.Kind == DatasetEntry.DatasetEntryKind.Vishing)
                .ToList().ForEach(d => DataSourceVishing.Add(d));
            dataset
                .TakeWhile(d => d.Kind == DatasetEntry.DatasetEntryKind.NotVishing)
                .ToList().ForEach(d => DataSourceNonVishing.Add(d));    
        }
    }
}
