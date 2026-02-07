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
using static CallerCallee.Models.SystemwideMessage;

namespace CallerCallee.ViewModels
{
    public partial class PhoneCallViewModel : ObservableObject
    {
        private readonly PhoneCall phoneCall;
        public PhoneCall Call => phoneCall;

        public PhoneCallViewModel(PhoneCall phoneCall)
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

        public string Id => phoneCall.Entry.Id;

        public Guid Guid => phoneCall.Guid;

        [ObservableProperty]
        public partial string CurrentTurnId { get; set; }

        [ObservableProperty]
        public partial Symbol CallerSymbol { get; set; }

        [ObservableProperty]
        public partial Symbol CalleeSymbol { get; set; }

        [ObservableProperty]
        public partial State State { get; set; }

        [ObservableProperty]
        public partial Flag Is { get; set; } 

        [ObservableProperty]
        public partial Flag Human { get; set; }

        [ObservableProperty]
        public partial Flag Naive { get; set; } = Flag.Unknown;

        [ObservableProperty]
        public partial Flag Enhanced { get; set; } = Flag.Unknown;

        [ObservableProperty]
        public partial string RealDuration { get; set; }

        [ObservableProperty]
        public partial float LastResultTimestamp { get; set; }

        private readonly DispatcherTimer _timer;
        private readonly Stopwatch _stopwatch = Stopwatch.StartNew();

        private void OnTick(object sender, object e)
        {
            // DispatcherTimer runs on UI thread, so this is safe
            RealDuration = _stopwatch.Elapsed.ToString(@"mm\:ss");
            Call.Entry.RealDuration = RealDuration;

            if (_stopwatch.Elapsed.TotalSeconds - LastResultTimestamp > 120)
            {
                // If the last result is older than 2 minutes, is likely failed
                Naive = Flag.Unknown;
                Enhanced = Flag.Unknown;
                State = State.Failed;
                StopTimer();
                WeakReferenceMessenger.Default.Send(
                    new CallInterrupted(
                        phoneCall
                    )
                );
            }
        }

        public void StopTimer()
        {
            _timer.Tick -= OnTick;
            _timer.Stop();
            _stopwatch.Stop();
        }

        public Brush GetRightColor(Flag flag)
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

        public Brush GetRightColorState(State state)
        {
            switch (state)
            {
                case State.Failed:
                    return new SolidColorBrush(Colors.Crimson);
                default:
                    return new SolidColorBrush(Colors.Gray);
            }
        }
    }
}
