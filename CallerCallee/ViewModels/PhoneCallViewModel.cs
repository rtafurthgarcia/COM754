using CallerCallee.Models;
using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.Messaging;
using Microsoft.UI;
using Microsoft.UI.Xaml;
using Microsoft.UI.Xaml.Controls;
using Microsoft.UI.Xaml.Media;
using System;
using System.Diagnostics;
using System.Linq;
using System.Threading.Tasks;
using static CallerCallee.Models.SystemwideMessage;

namespace CallerCallee.ViewModels
{
    public partial class PhoneCallViewModel : DatasetViewModel
    {
        private readonly PhoneCall phoneCall;
        public PhoneCallViewModel(PhoneCall phoneCall): base(phoneCall.DatasetEntry)
        {
            this.phoneCall = phoneCall;
            RealDuration = "00:00";

            // Initialize the timer
            _timer = new DispatcherTimer
            {
                Interval = TimeSpan.FromSeconds(1)
            };
            _timer.Tick += OnTick;
            _timer.Start();
        }

        public Guid Guid => phoneCall.Guid;

        [ObservableProperty]
        [NotifyPropertyChangedFor(nameof(LastException))]
        [NotifyPropertyChangedFor(nameof(State))]
        public partial string CurrentTurnId { get; set; }

        [ObservableProperty]
        public partial Symbol CallerSymbol { get; set; }

        [ObservableProperty]
        public partial Symbol CalleeSymbol { get; set; }

        [ObservableProperty]
        [NotifyPropertyChangedFor(nameof(Naive))]
        [NotifyPropertyChangedFor(nameof(Enhanced))]
        public partial float LastResultTimestamp { get; set; }

        private readonly DispatcherTimer _timer;
        private readonly Stopwatch _stopwatch = Stopwatch.StartNew();

        public Speaker? CurrentSpeaker = Speaker.Caller;

        private void OnTick(object sender, object e)
        {
            // DispatcherTimer runs on UI thread, so this is safe
            RealDuration = _stopwatch.Elapsed.ToString(@"mm\:ss");

            if (_stopwatch.Elapsed.TotalSeconds - LastResultTimestamp > 90)
            {
                // If the last result is older than 1.5 minute, is likely failed
                // otherwise would have received the confirmation that its over by now.
                AddDetectionResult(new Classifications() 
                {
                    Id = "INTERRUPTION",
                    GroupId = null,
                    Speaker = Speaker.System,
                    EnhancedClassification = new ClassificationResult() 
                    { 
                        Duration = (float)_stopwatch.Elapsed.TotalSeconds - LastResultTimestamp,
                        Flag = Flag.Unknown
                    },
                    NaiveClassification = new ClassificationResult()
                    {
                        Duration = (float)_stopwatch.Elapsed.TotalSeconds - LastResultTimestamp,
                        Flag = Flag.Unknown
                    }
                });
                
                StopTimer();
                WeakReferenceMessenger.Default.Send(
                    new CallInterrupted(
                        new TimeoutException("Has received no classification for 90s.") { Source = Id.ToString() }
                    )
                );
            }
        }

        public bool IsActive => phoneCall.IsActive();
        public Task TerminateAsync() => phoneCall.TerminateAsync();

        public void StopTimer()
        {
            _timer.Tick -= OnTick;
            _timer.Stop();
            _stopwatch.Stop();
        }

        public static Brush GetRightColorState(State state)
        {
            if (state.Equals(State.Failed))
            {
                return new SolidColorBrush(Colors.Crimson);
            }
            else
            {
                return new SolidColorBrush(Colors.Gray);
            }
        }

        public static Brush GetRightColor(Flag flag)
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
