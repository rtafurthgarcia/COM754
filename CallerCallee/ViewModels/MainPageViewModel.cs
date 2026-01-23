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
        public ObservableCollection<DatasetEntry> DataSource { get; } = new ObservableCollection<DatasetEntry> { }; 

        [ObservableProperty]
        [NotifyCanExecuteChangedFor(nameof(RunSimulationCommand))]
        private string? loadedDatasetMessage;

        [ObservableProperty]
        private int? datasetCount;

        [ObservableProperty]
        private int progression = 0;
       

        public async Task ImportDatasetAsync(WindowId id)
        {
            var file = await Ioc.Default.GetRequiredService<FilePickerService>().PickFileDialogAsync(id);
            LoadedDatasetMessage = file != null
                    ? "Picked: " + new FileInfo(file.Path).Name
                    : "No datasource selected.";

            // only 5 are displayed due to ram space complexity constraints
            var service = Ioc.Default.GetRequiredService<DatasetImportService>();
            await service.LoadDatasetEntries(file.Path);
            DatasetCount = service.Dataset == null ? 0 : service.Dataset.Count;

            //dataset
            //    .(d => d.Kind == DatasetEntry.DatasetEntryKind.Vishing)
            //    .Take(5)
            //    .ToList().ForEach(d => DataSourceVishing.Add(d));
            //dataset
            //    .TakeWhile(d => d.Kind == DatasetEntry.DatasetEntryKind.NotVishing)
            //    .Take(5)
            //    .ToList().ForEach(d => DataSourceNonVishing.Add(d));    
        }
        [RelayCommand]
        public async Task RunSimulation()
        { 

        }
    }
}
