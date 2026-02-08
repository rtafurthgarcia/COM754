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


        private readonly DatasetService datasetService = Ioc.Default.GetRequiredService<DatasetService>();
        private readonly CallerCalleeService callerCalleeService = Ioc.Default.GetRequiredService<CallerCalleeService>();
        private readonly AuthenticationService authenticationService = Ioc.Default.GetRequiredService<AuthenticationService>();
        private readonly SettingsService settingsService = Ioc.Default.GetRequiredService<SettingsService>();
        private readonly DetectionService detectionService = Ioc.Default.GetRequiredService<DetectionService>();

        private readonly DispatcherQueue dispatcherQueue = DispatcherQueue.GetForCurrentThread();

        [ObservableProperty]
        public partial int MaxParallelSimulations { get; set; } = AudioService.CountAvailableDevices() / 2;

        [ObservableProperty]
        public partial int DatasetsToSkipFromBeginning { get; set; } = 0;

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

            var list = await datasetService.LoadDatasetEntries(file.Path, DatasetsToSkipFromBeginning);
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
                var list = await datasetService.LoadDatasetEntries(path, DatasetsToSkipFromBeginning);
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
                    CurrentTurnId = message.Value.DatasetEntry.Children.Peek().Id,
                    State = State.Ongoing,
                    CallerSymbol = Symbol.Volume,
                    CalleeSymbol = Symbol.Mute
                };
                DataSource.Add(phoneCall);
                DataSource2.Remove(DataSource2.Where(m => m.Id == phoneCall.Id).FirstOrDefault());
            });
        }

        public void Receive(CallCompleted message)
        {
            dispatcherQueue.TryEnqueue(() =>
            {
                var phoneCall = DataSource.Where(vm => vm.Id == message.Value)
                    .FirstOrDefault();
                if (phoneCall != null)
                {
                    phoneCall.State = State.Analysing;
                    phoneCall.CurrentTurnId = "";
                    phoneCall.CallerSymbol = Symbol.Mute;
                    phoneCall.CalleeSymbol = Symbol.Mute;
                }
            });
        }

        public void Receive(CallInterrupted message)
        {
            dispatcherQueue.TryEnqueue((async () =>
            {
                var phoneCall = DataSource.Where(vm => vm.Id == int.Parse(message.Value.Source))
                    .FirstOrDefault();

                if (phoneCall != null)
                {
                    DataSource.Remove(phoneCall);
                    phoneCall.StopTimer();
                    phoneCall.LastException = message.Value;
                    phoneCall.State = State.Failed;
                    phoneCall.CurrentTurnId = "";
                    phoneCall.CallerSymbol = Symbol.Mute;
                    phoneCall.CalleeSymbol = Symbol.Mute;
                    DataSource2.Add(phoneCall);

                    if (phoneCall.IsActive)
                    {
                        await phoneCall.TerminateAsync();
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
                var (Id, TurnId) = message.Value;
                var phoneCall = DataSource.Where(vm => vm.Id == Id).FirstOrDefault();
                if (phoneCall != null)
                {
                    if (TurnId != null)
                    {
                        phoneCall.CurrentTurnId = TurnId;
                    }
                    else
                    {
                        phoneCall.State = State.Analysing;
                        phoneCall.CurrentSpeaker = null;
                        phoneCall.CurrentTurnId = "";
                    }

                    switch (phoneCall.CurrentSpeaker)
                    {
                        case Speaker.Caller:
                            phoneCall.CallerSymbol = Symbol.Volume;
                            phoneCall.CalleeSymbol = Symbol.Mute;
                            phoneCall.CurrentSpeaker = Speaker.Callee;
                            break;
                        case Speaker.Callee:
                            phoneCall.CallerSymbol = Symbol.Mute;
                            phoneCall.CalleeSymbol = Symbol.Volume;
                            phoneCall.CurrentSpeaker = Speaker.Caller;
                            break;
                        default:
                            phoneCall.CallerSymbol = Symbol.Mute;
                            phoneCall.CalleeSymbol = Symbol.Mute;
                            break;
                    }
                }
            });
        }

        public void Receive(EndOfAnalysis message)
        {
            dispatcherQueue.TryEnqueue(async () =>
            {
                var phoneCall = DataSource.Where(vm => vm.Guid.Equals(message.Value))
                    .FirstOrDefault();

                if (phoneCall != null)
                {
                    phoneCall.StopTimer();
                    DataSource.Remove(phoneCall);
                    phoneCall.State = State.Completed;
                    phoneCall.CurrentTurnId = "";
                    DataSource2.Add(phoneCall);
                    await DatasetEntryExporter.ExportAsync(phoneCall.GetDatasetEntry());
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
                    phoneCall.AddDetectionResult(message.Value);
                }
            });
        }
    }
}
