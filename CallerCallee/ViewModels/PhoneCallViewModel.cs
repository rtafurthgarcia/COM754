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
            timer = new DispatcherTimer
            {
                Interval = TimeSpan.FromSeconds(1)
            };
            timer.Tick += OnTick;
            timer.Start();
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

        private readonly DispatcherTimer timer;
        private readonly Stopwatch stopwatch = Stopwatch.StartNew();

        public Speaker? CurrentSpeaker = Speaker.Caller;

        private void OnTick(object sender, object e)
        {
            // DispatcherTimer runs on UI thread, so this is safe
            RealDuration = stopwatch.Elapsed.ToString(@"mm\:ss");

            if (stopwatch.Elapsed.TotalSeconds - LastResultTimestamp > 90)
            {
                StopTimer();
                
                WeakReferenceMessenger.Default.Send(
                    new EndOfAnalysis(
                        Guid
                    )
                );
            }
        }

        public bool IsActive => phoneCall.IsActive();
        public Task TerminateAsync() => phoneCall.TerminateAsync();

        public void StopTimer()
        {
            timer.Tick -= OnTick;
            timer.Stop();
            stopwatch.Stop();
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
