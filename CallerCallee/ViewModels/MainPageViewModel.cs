using Azure.Identity;
using CallerCallee.Models;
using CallerCallee.Services;
using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.DependencyInjection;
using CommunityToolkit.Mvvm.Input;
using CommunityToolkit.Mvvm.Messaging;
using Microsoft.UI;
using Microsoft.Windows.AppNotifications;
using Microsoft.Windows.AppNotifications.Builder;
using ObservableCollections;
using System;
using System.Collections.ObjectModel;
using System.IO;
using System.Threading.Tasks;

namespace CallerCallee.ViewModels
{
    public partial class MainPageViewModel: ObservableObject
    {
        public ObservableCollection<DatasetEntry> DataSource { get; } = []; 
        public ObservableDictionary<DatasetEntry, DatasetEntry> CurrentTurns { get; } = [];

        [ObservableProperty]
        [NotifyCanExecuteChangedFor(nameof(RunSimulationCommand))]
        [NotifyPropertyChangedFor(nameof(IsBusy))]
        public partial string LoadedDatasetMessage { get; set; }

        [ObservableProperty]
        public partial int? DatasetCount { get; set; }

        [ObservableProperty]
        public partial int Progression { get; set; } = 0;

        [ObservableProperty]
        public partial bool Autorun { get; set; } = false;

        [ObservableProperty]
        [NotifyCanExecuteChangedFor(nameof(RunSimulationCommand))]
        [NotifyPropertyChangedFor(nameof(IsBusy))]
        public partial DefaultAzureCredential Credential { get; set; }

        public bool IsBusy => RunSimulationCommand.IsRunning || AuthenticateCommand.IsRunning || ImportDatasetCommand.IsRunning || AutorunEverythingCommand.IsRunning;

        private readonly DatasetService datasetService = Ioc.Default.GetRequiredService<DatasetService>();
        private readonly CallerCalleeService callerCalleeService = Ioc.Default.GetRequiredService<CallerCalleeService>();
        private readonly SettingsService settingsService = Ioc.Default.GetRequiredService<SettingsService>();

        public MainPageViewModel()
        {
            Autorun = settingsService.GetValue<bool>("autorun");
            if (Autorun)
            {
                AutorunEverythingCommand.Execute(null);
            }

            WeakReferenceMessenger.Default.Register<SimulationNotification.DatasetEntryWorkedOn>(this, (r, m) => DataSource.Add(m.Value));
            WeakReferenceMessenger.Default.Register<SimulationNotification.TurnBeingPlayed>(this, (r, m) => CurrentTurns[m.Value.Parent] = m.Value.Child);
            WeakReferenceMessenger.Default.Register<SimulationNotification.DatasetEntryFinished>(this, (r, m) => {
                DataSource.Remove(m.Value);
                CurrentTurns.Remove(m.Value);
            });
        }

        private bool CanRunSimulation()
        {
            return Credential is not null && LoadedDatasetMessage is not null;
        }

        [RelayCommand]
        public void SetAutorun()
        {
            settingsService.SetValue("autorun", Autorun);
        }

        [RelayCommand]
        public async Task ImportDatasetAsync(WindowId id)
        {
            var file = await FilePickerService.PickFileDialogAsync(id);
            LoadedDatasetMessage = file != null
                    ? "Picked: " + new FileInfo(file.Path).Name
                    : "No datasource selected.";
            if (file is null)
            {
                return;
            }

            await datasetService.LoadDatasetEntries(file.Path);
            DatasetCount = datasetService.Dataset == null ? 0 : datasetService.Dataset.Count;
            settingsService.SetValue("datasetpath", file.Path);
        }
        [RelayCommand(CanExecute = nameof(CanRunSimulation))]
        public async Task RunSimulation()
        {
            try
            {
                await callerCalleeService.StartSimulation(Credential);
            } 
            catch (Exception e)
            {
                AppNotification notification = new AppNotificationBuilder()
                    .AddText("Simulation interrupted!")
                    .AddText(e.Message)
                    .SetAppLogoOverride(new Uri("ms-appx:///Assets/error-96.png"), AppNotificationImageCrop.Default)
                    .BuildNotification();

                AppNotificationManager.Default.Show(notification);
            }
        }

        [RelayCommand]
        public async Task Authenticate() 
        {
            try
            {
                Credential = await callerCalleeService.Authenticate();
            }
            catch (Exception e)
            {
                AppNotification notification = new AppNotificationBuilder()
                    .AddText("Authentication failed")
                    .AddText(e.Message)
                    .SetAppLogoOverride(new Uri("ms-appx:///Assets/error-96.png"), AppNotificationImageCrop.Default)
                    .BuildNotification();

                AppNotificationManager.Default.Show(notification);
            }
        }

        [RelayCommand(CanExecute = nameof(Autorun))]
        public async Task AutorunEverything()
        {
            var path = settingsService.GetValue<string>("datasetpath");

            try
            {
                await datasetService.LoadDatasetEntries(path);
                DatasetCount = datasetService.Dataset == null ? 0 : datasetService.Dataset.Count;
                await Authenticate();
                await RunSimulation();
            }
            catch (Exception e)
            {
                AppNotification notification = new AppNotificationBuilder()
                    .AddText("Autorun interrupted")
                    .AddText(e.Message)
                    .SetAppLogoOverride(new Uri("ms-appx:///Assets/error-96.png"), AppNotificationImageCrop.Default)
                    .BuildNotification();

                AppNotificationManager.Default.Show(notification);
            }
        }
    }
}
