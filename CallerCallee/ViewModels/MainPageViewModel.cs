using Azure.Core;
using Azure.Identity;
using CallerCallee.Models;
using CallerCallee.Services;
using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.DependencyInjection;
using CommunityToolkit.Mvvm.Input;
using Microsoft.UI;
using Microsoft.UI.Windowing;
using Microsoft.UI.Xaml;
using Microsoft.UI.Xaml.Controls;
using Microsoft.Windows.AppNotifications;
using Microsoft.Windows.AppNotifications.Builder;
using Microsoft.Windows.Storage.Pickers;
using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Windows.System;

namespace CallerCallee.ViewModels
{
    public partial class MainPageViewModel: ObservableObject
    {
        public ObservableCollection<DatasetEntry> DataSource { get; } = []; 

        [ObservableProperty]
        [NotifyCanExecuteChangedFor(nameof(RunSimulationCommand))]
        public partial string? LoadedDatasetMessage { get; set; }

        [ObservableProperty]
        public partial int? DatasetCount { get; set; }

        [ObservableProperty]
        public partial int Progression { get; set; } = 0;
        private bool CanRunSimulation()
        {
            return Credential is not null && LoadedDatasetMessage is not null;
        }

        [ObservableProperty]
        [NotifyCanExecuteChangedFor(nameof(RunSimulationCommand))]
        public partial DefaultAzureCredential? Credential { get; set; }

        private readonly DatasetImportService datasetImportService = Ioc.Default.GetRequiredService<DatasetImportService>();
        private readonly CallerCalleeService callerCalleeService = Ioc.Default.GetRequiredService<CallerCalleeService>();

        public async Task ImportDatasetAsync(WindowId id)
        {
            var file = await Ioc.Default.GetRequiredService<FilePickerService>().PickFileDialogAsync(id);
            LoadedDatasetMessage = file != null
                    ? "Picked: " + new FileInfo(file.Path).Name
                    : "No datasource selected.";
            if (file is null)
            {
                return;
            }

            await datasetImportService.LoadDatasetEntries(file.Path);
            DatasetCount = datasetImportService.Dataset == null ? 0 : datasetImportService.Dataset.Count;  
        }
        [RelayCommand(CanExecute = nameof(CanRunSimulation))]
        public async Task RunSimulation()
        {
            try
            {
                await callerCalleeService.StartCall(Credential);

            } 
            catch (Exception e)
            {
                AppNotification notification = new AppNotificationBuilder()
                    .AddText("Simulation error")
                    .AddText(e.Message)
                    .SetAppLogoOverride(new Uri("ms-appx:///Assets/error-96.png"), AppNotificationImageCrop.Default)
                    .BuildNotification();

                AppNotificationManager.Default.Show(notification);
            }
        }

        [RelayCommand]
        public void Authenticate() {
            try
            {
                Credential = callerCalleeService.Authenticate();
            }
            catch (Exception e)
            {
                AppNotification notification = new AppNotificationBuilder()
                    .AddText("Simulation error")
                    .AddText(e.Message)
                    .SetAppLogoOverride(new Uri("ms-appx:///Assets/error-96.png"), AppNotificationImageCrop.Default)
                    .BuildNotification();

                AppNotificationManager.Default.Show(notification);
            }
        }
    }
}
