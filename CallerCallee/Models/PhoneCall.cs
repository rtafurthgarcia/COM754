using Azure.Communication.Calling.WindowsClient;
using Azure.Communication.Identity;
using CallerCallee.Services;
using CommunityToolkit.Mvvm.DependencyInjection;
using CommunityToolkit.Mvvm.Messaging;
using NAudio.Wave;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Net.Quic;
using System.Threading.Tasks;
using Windows.Storage;
using static CallerCallee.Models.SimulationNotification;

namespace CallerCallee.Models
{
    public class PhoneCall
    {
        public record CallDetails(CommunicationUserIdentifierAndToken IdentifierAndToken)
        {
            public CallClient CallClient;
            public CallAgent CallAgent;
            public CommunicationCall Call;
            public int AudioDeviceNumber;
            //public AudioGraphAcsBridge Bridge;
        };

        public readonly CallDetails caller;
        public readonly CallDetails callee;
        private readonly DatasetEntry entry;
        public DatasetEntry Entry
        {
            get => entry;
            private set;
        }

        enum Speaker
        {
            Caller,
            Callee
        }

        private Speaker currentSpeaker;
        private readonly CallTokenRefreshOptions callTokenRefreshOptions = new(true);
        private readonly CallClientOptions callClientOptions = new()
        {
            Diagnostics = new CallDiagnosticsOptions()
            {
                AppName = "COM754-CallerCallee",
                AppVersion = "1.0",
                Tags = new List<string>(["Calling", "ACS", "Windows"])
            }
        };

        public readonly DateTime StartTime = DateTime.Now;

        public PhoneCall(
            CommunicationUserIdentifierAndToken callerIdAndToken, 
            CommunicationUserIdentifierAndToken calleeIdAndToken, 
            int callerDeviceNumber, 
            int calleeDeviceNumber, 
            DatasetEntry entry
        )
        {
            caller = new CallDetails(callerIdAndToken);
            callee = new CallDetails(calleeIdAndToken);
            this.entry = entry;
            caller.AudioDeviceNumber = callerDeviceNumber;
            callee.AudioDeviceNumber = calleeDeviceNumber;
        }

        public EventHandler OnEndOfCall;

        public async Task DialUp()
        {
            WeakReferenceMessenger.Default.Send(new CallInitiated(entry));
            var callerTokenCredential = new CallTokenCredential(caller.IdentifierAndToken.AccessToken.Token, callTokenRefreshOptions);
            var calleeTokenCredential = new CallTokenCredential(callee.IdentifierAndToken.AccessToken.Token, callTokenRefreshOptions);

            caller.CallClient = new(callClientOptions);

            caller.CallAgent = await caller.CallClient.CreateCallAgentAsync(
                callerTokenCredential,
                new CallAgentOptions()
                {
                    DisplayName = $"{Environment.MachineName}/COM754-Caller",
                }
            );

            callee.CallClient = new(callClientOptions);
            var setupCallTask = SetupOutgoingCallOptions();

            callee.CallAgent = await callee.CallClient.CreateCallAgentAsync(
                calleeTokenCredential,
                new CallAgentOptions()
                {
                    DisplayName = $"{Environment.MachineName}/COM754-Callee",
                }
            );
            callee.CallAgent.IncomingCallReceived += OnIncomingCallAsync;
            await Task.Delay(5000); // give it enough slack so that the fist client gets registered. 

            caller.Call = await caller.CallAgent.StartCallAsync(
                new[] { new UserCallIdentifier(callee.IdentifierAndToken.User.Id) },
                await setupCallTask
            );
            caller.Call.StateChanged += OnCallStateChangedAsync;
            Debug.WriteLine($"{entry.Name}: Caller is phoning callee");



            //caller.Bridge = new AudioGraphAcsBridge(caller.Call.ActiveOutgoingAudioStream as RawOutgoingAudioStream);

            //caller.Bridge.FileEnded += OnFileEnded;
            //await audioInitTask;
        }

        protected virtual void OnCallEnded(EventArgs args)
        {
            OnEndOfCall?.Invoke(this, args);
        }

        private async void OnIncomingCallAsync(object sender, IncomingCallReceivedEventArgs args)
        {
            var incomingCall = args.IncomingCall;
            callee.Call = await incomingCall.AcceptAsync(await SetupIncomingCallOptions());

            Debug.WriteLine($"{entry.Name}: Callee has picked up the phone");
            callee.Call.StateChanged += OnCallStateChangedAsync;
            
            NextTurn();
        }

        private void OnPlaybackStopped(object sender, EventArgs e)
        {
            if (entry.Children is not null)
            {
                NextTurn();
            }
        }

        private async void OnCallStateChangedAsync(object sender, PropertyChangedEventArgs args)
        {
            var call = sender as CommunicationCall;
           
            if (call != null)
            {
                var state = call.State;
                switch (state)
                {
                    case CallState.Connected:
                    {
                        await call.StartAudioAsync(call.ActiveOutgoingAudioStream);
                        break;
                    }
                    case CallState.Disconnected:
                    {
                        Debug.WriteLine($"{entry.Name}: Call has been disconnected.");
                        call.StateChanged -= OnCallStateChangedAsync;
                        OnCallEnded(new EventArgs());
                        call.Dispose();
                        caller.CallAgent.Dispose(); //otherwise doesnt liberate the credentials on the Azure side
                        callee.CallAgent.Dispose();
                        
                        // Implies the call was interrupted
                        if (entry.Children.Count > 0)
                        {
                            Debug.WriteLine($"{entry.Name}: Call interrupted unexpectedly.");
                            WeakReferenceMessenger.Default.Send(
                                new CallInterrupted(
                                    new Exception("Call interrupted unexpectedly")
                                )
                            );
                        }

                        break;
                    }
                    default: break;
                }
            }
        }

        private async Task<StartCallOptions> SetupOutgoingCallOptions()
        {
            var deviceManager = await caller.CallClient.GetDeviceManagerAsync();
            deviceManager.SetMicrophone(Ioc.Default.GetRequiredService<AudioService>().FindEquivalent(caller.AudioDeviceNumber, deviceManager.Microphones.ToList()));
            var microphoneStream = new LocalOutgoingAudioStream();

            var options = new StartCallOptions()
            {
                OutgoingAudioOptions = new OutgoingAudioOptions()
                {
                    IsMuted = false,
                    Stream = microphoneStream,
                    Filters = new OutgoingAudioFilters()
                    {
                        AnalogAutomaticGainControlEnabled = true,
                        AcousticEchoCancellationEnabled = true,
                        NoiseSuppressionMode = NoiseSuppressionMode.High
                    }
                }
            };

            return options;
        }

        private async Task<AcceptCallOptions> SetupIncomingCallOptions()
        {
            var deviceManager = await callee.CallClient.GetDeviceManagerAsync();
            deviceManager.SetMicrophone(Ioc.Default.GetRequiredService<AudioService>().FindEquivalent(callee.AudioDeviceNumber, deviceManager.Microphones.ToList()));
            var microphoneStream = new LocalOutgoingAudioStream();

            var options = new AcceptCallOptions()
            {
                OutgoingAudioOptions = new OutgoingAudioOptions()
                {
                    IsMuted = false,
                    Stream = microphoneStream,
                    Filters = new OutgoingAudioFilters()
                    {
                        AnalogAutomaticGainControlEnabled = true,
                        AcousticEchoCancellationEnabled = true,
                        NoiseSuppressionMode = NoiseSuppressionMode.High
                    }
                }
            };

            return options;
        }

        private void NextTurn()
        {            
            currentSpeaker = Speaker.Caller;
            Debug.WriteLine($"{entry.Name}: Conversation is starting");
            
            var turn = entry.Children.Dequeue();

            if (currentSpeaker.Equals(Speaker.Caller))
            {
                var duration = Ioc.Default.GetRequiredService<AudioService>().PlayAudioFile(caller.AudioDeviceNumber, turn.FilePath, OnPlaybackStopped);
                Debug.WriteLine($"{entry.Name}: Caller speaking: {turn.Name}, for {(int)duration.TotalSeconds}s");
            }
            else
            {
                var duration = Ioc.Default.GetRequiredService<AudioService>().PlayAudioFile(callee.AudioDeviceNumber, turn.FilePath, OnPlaybackStopped);
                Debug.WriteLine($"{entry.Name}: Callee speaking: {turn.Name}, for {(int)duration.TotalSeconds}s");
            }
            currentSpeaker = currentSpeaker.Equals(Speaker.Caller) ? Speaker.Callee : Speaker.Caller;
        }
    }
}
