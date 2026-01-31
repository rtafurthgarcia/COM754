using Azure.Identity;
using CallerCallee.Models;
using CallerCallee.Services;
using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.DependencyInjection;
using CommunityToolkit.Mvvm.Input;
using CommunityToolkit.Mvvm.Messaging;
using Microsoft.UI;
using Microsoft.UI.Dispatching;
using Microsoft.Windows.AppNotifications;
using Microsoft.Windows.AppNotifications.Builder;
using System;
using System.Collections.ObjectModel;
using System.IO;
using System.Threading.Tasks;
using static CallerCallee.Models.PhoneCallMessage;

namespace CallerCallee.ViewModels
{
    public partial class MainPageViewModel : ObservableRecipient, IRecipient<CallInitiated>, IRecipient<CallCompleted>, IRecipient<CallInterrupted>
    {
        public ObservableCollection<PhoneCall> DataSource { get; } = [];

        [ObservableProperty]
        [NotifyCanExecuteChangedFor(nameof(RunSimulationCommand))]
        public partial string LoadedDatasetMessage { get; set; }

        [ObservableProperty]
        public partial int? DatasetCount { get; set; }

        [ObservableProperty]
        [NotifyPropertyChangedFor(nameof(DataSource))]
        public partial int Progression { get; set; } = 0;

        [ObservableProperty]
        public partial bool Autorun { get; set; } = false;

        [ObservableProperty]
        [NotifyCanExecuteChangedFor(nameof(RunSimulationCommand))]
        public partial DefaultAzureCredential Credential { get; set; }

        private readonly DatasetService datasetService = Ioc.Default.GetRequiredService<DatasetService>();
        private readonly CallerCalleeService callerCalleeService = Ioc.Default.GetRequiredService<CallerCalleeService>();
        private readonly SettingsService settingsService = Ioc.Default.GetRequiredService<SettingsService>();

        DispatcherQueue dispatcherQueue = DispatcherQueue.GetForCurrentThread();

        public MainPageViewModel()
        {
            IsActive = true;
            Autorun = settingsService.GetValue<bool>("autorun");
            if (Autorun)
            {
                AutorunEverythingCommand.ExecuteAsync(null);
            }
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
            DatasetCount = datasetService.Dataset is null ? 0 : datasetService.Total;
            settingsService.SetValue("datasetpath", file.Path);
        }

        [RelayCommand(CanExecute = nameof(CanRunSimulation))]
        public async Task RunSimulation()
        {
            try
            {
                Progression = 0;
                await callerCalleeService.StartSimulation(Credential, 1);
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
                DatasetCount = datasetService.Dataset is null ? 0 : datasetService.Dataset.Count;
                await AuthenticateCommand.ExecuteAsync(null);
                await RunSimulationCommand.ExecuteAsync(null);
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

        public void Receive(CallInitiated message) 
        {
            dispatcherQueue.TryEnqueue(() =>
            {
                DataSource.Add(message.Value);
            });
        }

        public void Receive(CallCompleted message)
        {
            dispatcherQueue.TryEnqueue(() =>
            {
                if (DataSource.Contains(message.Value))
                {
                    DataSource.Remove(message.Value);
                }
            });
        }

        public void Receive(CallInterrupted message)
        {
            OnPropertyChanged(nameof(Progression));
            Progression += 1;
        }
    }
}
