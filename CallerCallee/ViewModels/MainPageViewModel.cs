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
using Windows.ApplicationModel.Contacts;
using static CallerCallee.Models.SystemwideMessage;
using static System.Windows.Forms.VisualStyles.VisualStyleElement.TrackBar;

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

        [ObservableProperty]
        public partial int MaxParallelSimulations { get; set; } = 1;

        private readonly DatasetService datasetService = Ioc.Default.GetRequiredService<DatasetService>();
        private readonly CallerCalleeService callerCalleeService = Ioc.Default.GetRequiredService<CallerCalleeService>();
        private readonly AuthenticationService authenticationService = Ioc.Default.GetRequiredService<AuthenticationService>();
        private readonly SettingsService settingsService = Ioc.Default.GetRequiredService<SettingsService>();
        private readonly DetectionService detectionService = Ioc.Default.GetRequiredService<DetectionService>();

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
            return Credential is not null && LoadedDatasetMessage is not null && MaxParallelSimulations > 0;
        }

        [RelayCommand]
        public void SetAutorun()
        {
            settingsService.SetValue("autorun", Autorun);
            if (AutorunEverythingCommand.IsRunning)
            {
                AutorunEverythingCommand.Cancel();
                datasetService.TodoDataset.Clear();
                DatasetCount = 0;
                DataSource.Clear();
                DataSource2.Clear();
            }
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
                await Task.WhenAll([
                    callerCalleeService.StartSimulation(MaxParallelSimulations),
                    detectionService.StartProcessingAsync()
                ]);
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
                DatasetCount = datasetService.TodoDataset is null ? 0 : datasetService.TodoDataset.Count;
                list.ForEach(d => DataSource2.Add(new DatasetViewModel(d)));
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
            dispatcherQueue.TryEnqueue((DispatcherQueueHandler)(async () =>
            {
                var phoneCall = DataSource.Where(vm => vm.Id.Equals(message.Value.Entry.Id))
                    .FirstOrDefault();

                if (phoneCall != null)
                {
                    DataSource.Remove(phoneCall);
                    phoneCall.StopTimer();
                    phoneCall.State = State.Failed;
                    phoneCall.CurrentTurnId = "";
                    phoneCall.CallerSymbol = Symbol.Mute;
                    phoneCall.CalleeSymbol = Symbol.Mute;
                    DataSource2.Where(d => d.Entry.Id.Equals(phoneCall.Id)).FirstOrDefault().Entry = phoneCall.Call.Entry;

                    if (phoneCall.Call.IsActive())
                    {
                        await phoneCall.Call.TerminateAsync();
                    }
                }

                if (datasetService.TodoDataset.IsEmpty)
                {
                    await detectionService.StopProcessingAsync();

                    AppNotification notification = new AppNotificationBuilder()
                        .AddText("Simulation completed!")
                        .AddText(string.Format("Progression: {0} / {1}", Progression, DatasetCount))
                        .SetAppLogoOverride(new Uri("ms-appx:///Assets/success-96.png"), AppNotificationImageCrop.Default)
                        .BuildNotification();
                    AppNotificationManager.Default.Show(notification);
                }
                ProgressionFailed = DataSource2.Where(d => d.State.Equals(State.Failed)).Count();
            }));
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
            dispatcherQueue.TryEnqueue(async () =>
            {
                var phoneCall = DataSource.Where(vm => vm.Guid == message.Value)
                    .FirstOrDefault();

                if (phoneCall != null)
                {
                    phoneCall.StopTimer();
                    DataSource.Remove(phoneCall);
                    phoneCall.State = State.Completed;
                    DataSource2.Where(d => phoneCall.Call.Entry.Id.Equals(d.Entry.Id)).FirstOrDefault().Entry = phoneCall.Call.Entry;
                }

                if (datasetService.TodoDataset.IsEmpty)
                {
                    await detectionService.StopProcessingAsync();

                    AppNotification notification = new AppNotificationBuilder()
                        .AddText("Simulation completed!")
                        .AddText(string.Format("Progression: {0} / {1}", Progression, DatasetCount))
                        .SetAppLogoOverride(new Uri("ms-appx:///Assets/success-96.png"), AppNotificationImageCrop.Default)
                        .BuildNotification();
                    AppNotificationManager.Default.Show(notification);
                }

                ProgressionCompleted = DataSource2.Where(d => d.State.Equals(State.Completed)).Count();
            });
        }

        public void Receive(DetectionResultReceived message)
        {
            dispatcherQueue.TryEnqueue(() =>
            {
                var phoneCall = DataSource.Where(vm => vm.Guid.Equals(message.Value.GroupId))
                    .FirstOrDefault();

                if (phoneCall != null)
                {
                    phoneCall.LastResultTimestamp = new DateTimeOffset(DateTime.UtcNow).ToUnixTimeSeconds();
                    phoneCall.Naive = message.Value.NaiveClassification.Flag;
                    phoneCall.Enhanced = message.Value.EnhancedClassification.Flag;
                }
            });
        }
    }
}
