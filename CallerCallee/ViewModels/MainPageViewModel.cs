using Azure.Identity;
using CallerCallee.Models;
using CallerCallee.Services;
using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.DependencyInjection;
using CommunityToolkit.Mvvm.Input;
using CommunityToolkit.Mvvm.Messaging;
using Microsoft.UI;
using Microsoft.UI.Dispatching;
using Microsoft.UI.Xaml.Controls;
using Microsoft.Windows.AppNotifications;
using Microsoft.Windows.AppNotifications.Builder;
using Microsoft.Windows.Storage.Pickers;
using System;
using System.Collections.ObjectModel;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using static CallerCallee.Models.SystemwideMessage;

namespace CallerCallee.ViewModels
{
    public partial class MainPageViewModel : ObservableRecipient, 
        IRecipient<CallInitiated>, IRecipient<CallCompleted>, IRecipient<CallInterrupted>, IRecipient<NextTurnBeingPlayed>,
        IRecipient<DetectionResultReceived>, IRecipient<EndOfAnalysis>
    {
        public ObservableCollection<PhoneCallViewModel> DataSource { get; } = [];
        public ObservableCollection<DatasetViewModel> DataSource2 { get; } = [];
        
        [ObservableProperty]
        [NotifyCanExecuteChangedFor(nameof(RunSimulationCommand))]
        public partial string LoadedDatasetMessage { get; set; }

        [ObservableProperty]
        public partial int? DatasetCount { get; set; }

        [ObservableProperty]
        [NotifyPropertyChangedFor(nameof(ProgressionTitle))]
        public partial int ProgressionCompleted { get; set; } = 0;

        [ObservableProperty]
        [NotifyPropertyChangedFor(nameof(ProgressionTitle))]
        public partial int ProgressionFailed { get; set; } = 0;

        public int Progression => ProgressionFailed + ProgressionCompleted;
        public string ProgressionTitle => string.Format("Progression: {0} / {1}", ProgressionCompleted + ProgressionFailed, DatasetCount);

        [ObservableProperty]
        public partial bool Autorun { get; set; } = false;

        [ObservableProperty]
        [NotifyCanExecuteChangedFor(nameof(RunSimulationCommand))]
        public partial DefaultAzureCredential Credential { get; set; }

        private readonly DatasetService datasetService = Ioc.Default.GetRequiredService<DatasetService>();
        private readonly CallerCalleeService callerCalleeService = Ioc.Default.GetRequiredService<CallerCalleeService>();
        private readonly AuthenticationService authenticationService = Ioc.Default.GetRequiredService<AuthenticationService>();
        private readonly SettingsService settingsService = Ioc.Default.GetRequiredService<SettingsService>();

        private readonly DispatcherQueue dispatcherQueue = DispatcherQueue.GetForCurrentThread();

        private State SelectedState = State.Todo;

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
            var file = await PickFileDialogAsync(id);
            LoadedDatasetMessage = file != null
                    ? "Picked: " + new FileInfo(file.Path).Name
                    : "No datasource selected.";
            if (file is null)
            {
                return;
            }

            var list = await datasetService.LoadDatasetEntries(file.Path);
            DatasetCount = datasetService.TodoDataset is null ? 0 : datasetService.TodoDataset.Count;
            settingsService.SetValue("datasetpath", file.Path);

            list.ForEach(d => DataSource2.Add(new DatasetViewModel(d)));        
        }

        [RelayCommand(CanExecute = nameof(CanRunSimulation))]
        public async Task RunSimulation()
        {
            try
            {
                await callerCalleeService.StartSimulation(1);
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
                Credential = await authenticationService.AuthenticateAsync();
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
                var list = await datasetService.LoadDatasetEntries(path);
                list.ForEach(d => DataSource2.Add(new DatasetViewModel(d)));
                DatasetCount = datasetService.TodoDataset is null ? 0 : datasetService.TodoDataset.Count;
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

        public bool Filter(object item)
        {
            var model = (DatasetViewModel)item;
            if (model is null)
            {
                return false;
            } 
            else
            {
               return model.State.Equals(SelectedState);
            }
        }

        [RelayCommand]
        public void ChangeTab(int index)
        {
            SelectedState = index switch
            {
                0 => State.Todo,
                1 => State.Completed,
                2 => State.Failed,
                _ => State.Todo
            };
        }

        public static async Task<PickFileResult> PickFileDialogAsync(WindowId id)
        {
            var picker = new FileOpenPicker(id)
            {
                CommitButtonText = "Pick File",
                SuggestedStartLocation = PickerLocationId.DocumentsLibrary,
                ViewMode = PickerViewMode.List
            };
            picker.FileTypeFilter.Add(".csv");

            // Show the picker dialog window
            return await picker.PickSingleFileAsync();
        }

        public void Receive(CallInitiated message) 
        {
            dispatcherQueue.TryEnqueue(() =>
            {
                var phoneCall = new PhoneCallViewModel(message.Value)
                {
                    CurrentTurnId = message.Value.Entry.Children.Peek().Id,
                    CallerSymbol = Symbol.Volume,
                    CalleeSymbol = Symbol.Mute
                };
                DataSource.Add(phoneCall);
            });
        }

        public void Receive(CallCompleted message)
        {
            dispatcherQueue.TryEnqueue(() =>
            {
                var phoneCall = DataSource.Where(vm => vm.Id == message.Value.Entry.Id)
                    .FirstOrDefault();
                if (phoneCall != null)
                {
                    phoneCall.State = message.Value.Entry.State;
                    phoneCall.CurrentTurnId = "";
                    phoneCall.CallerSymbol = Symbol.Mute;
                    phoneCall.CalleeSymbol = Symbol.Mute;
                }
            });
        }

        public void Receive(CallInterrupted message)
        {
            dispatcherQueue.TryEnqueue(() =>
            {
                ProgressionFailed += 1;
                var phoneCall = DataSource.Where(vm => vm.Id == message.Value.Entry.Id)
                    .FirstOrDefault();
                phoneCall.StopTimer();
                DataSource.Remove(phoneCall);
                message.Value.Entry.State = State.Failed;
                DataSource2.Add(new DatasetViewModel(message.Value.Entry));
            });
        }

        public void Receive(NextTurnBeingPlayed message)
        {
            dispatcherQueue.TryEnqueue(() =>
            {
                var phoneCall = DataSource.Where(vm => vm.Id == message.Value.Entry.Id)
                    .FirstOrDefault();
                if (phoneCall != null)
                {
                    phoneCall.State = message.Value.Entry.State;
                    if (message.Value.CurrentSpeaker.Equals(Speaker.Caller))
                    {
                        phoneCall.CallerSymbol = Symbol.Volume;
                        phoneCall.CalleeSymbol = Symbol.Mute;
                    }
                    else
                    {
                        phoneCall.CallerSymbol = Symbol.Mute;
                        phoneCall.CalleeSymbol = Symbol.Volume;
                    }

                    if (message.Value.CurrentTurn != null)
                    {
                        phoneCall.CurrentTurnId = message.Value.CurrentTurn.Id;
                    }
                    else
                    {
                        phoneCall.CurrentTurnId = "";
                        phoneCall.CallerSymbol = Symbol.Mute;
                        phoneCall.CalleeSymbol = Symbol.Mute;
                    }
                }
            });
        }

        public void Receive(EndOfAnalysis message)
        {
            dispatcherQueue.TryEnqueue(() =>
            {
                ProgressionCompleted += 1;
                var phoneCall = DataSource.Where(vm => vm.Guid.Equals(message.Value))
                    .FirstOrDefault();
                phoneCall.StopTimer();
                DataSource.Remove(phoneCall);
                DataSource2.Add(new DatasetViewModel(datasetService.DoneDataset[message.Value]));
            });
        }

        public void Receive(DetectionResultReceived message)
        {
            dispatcherQueue.TryEnqueue(() =>
            {
                var phoneCall = DataSource.Where(vm => vm.Guid.Equals(message.Value))
                    .FirstOrDefault();
                phoneCall.LastResultTimestamp = new DateTimeOffset(DateTime.UtcNow).ToUnixTimeSeconds();
                phoneCall.Naive = datasetService.DoneDataset[message.Value].DetectionResults.LastOrDefault().NaiveClassification.Flag;
                phoneCall.Enhanced = datasetService.DoneDataset[message.Value].DetectionResults.LastOrDefault().EnhancedClassification.Flag;
            });
        }
    }
}
