using Azure.Communication.Calling.WindowsClient;
using Azure.Communication.Identity;
using CallerCallee.Services;
using CommunityToolkit.Mvvm.DependencyInjection;
using CommunityToolkit.Mvvm.Messaging;
using Microsoft.CognitiveServices.Speech.Audio;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Threading.Tasks;
using static CallerCallee.Models.PhoneCallMessage;

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

        public enum Speaker
        {
            Caller,
            Callee
        }

        public DatasetEntry? CurrentTurn
        {
            get => Entry.Children.Count > 0 ? Entry.Children.Peek() : null;
        }

        private Speaker currentSpeaker = Speaker.Caller;
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
        private AudioService audioService = Ioc.Default.GetRequiredService<AudioService>();

        public async Task DialUp()
        {
            WeakReferenceMessenger.Default.Send(new CallInitiated(this));
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
        }

        private void OnCaptionsReceived(object sender, CommunicationCaptionsReceivedEventArgs e)
        {
            if (e.CaptionsResultKind.Equals(CaptionsResultKind.Final))
            {
                Debug.WriteLine($"{e.Speaker.DisplayName} said: {e.SpokenText}");
            }
        }

        protected virtual void OnCallEnded(EventArgs args)
        {
            OnEndOfCall?.Invoke(this, args);
            WeakReferenceMessenger.Default.Send(new CallEnded(this));
        }

        private async void OnIncomingCallAsync(object sender, IncomingCallReceivedEventArgs args)
        {
            var incomingCall = args.IncomingCall;
            callee.Call = await incomingCall.AcceptAsync(await SetupIncomingCallOptions());
            //callee.Call.

            Debug.WriteLine($"{entry.Name}: Callee has picked up the phone");
            callee.Call.StateChanged += OnCallStateChangedAsync;
            
            NextTurn();
        }

        private void OnPlaybackStopped(object sender, EventArgs e)
        {
            if (entry.Children.Count > 0)
            {
                NextTurn();
            }
            else
            {
                Debug.WriteLine($"{entry.Name}: Conversation over.");
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
                            //var captions = await caller.Call.Features.Captions.GetCaptionsAsync() as CommunicationCaptions;
                            //await captions.StartCaptionsAsync(new StartCaptionsOptions() { SpokenLanguage = "en-us" });
                            //captions.CaptionsReceived += OnCaptionsReceived;

                        var captionsCallFeature = call.Features.Captions;
                        var callCaptions = await captionsCallFeature.GetCaptionsAsync();
                        if (callCaptions.CaptionsKind == CaptionsKind.CommunicationCaptions)
                        {
                            var communicationCaptions = callCaptions as CommunicationCaptions;
                            await communicationCaptions.StartCaptionsAsync(new StartCaptionsOptions() { SpokenLanguage = "en-us" });
                            communicationCaptions.CaptionsReceived += OnCaptionsReceived;
                        }

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
            deviceManager.SetMicrophone(AudioService.FindEquivalent(caller.AudioDeviceNumber, [.. deviceManager.Microphones]));
            var outgoingStream = new LocalOutgoingAudioStream();

            var options = new StartCallOptions()
            {
                OutgoingAudioOptions = new OutgoingAudioOptions()
                {
                    IsMuted = false,
                    Stream = outgoingStream,
                    Filters = new OutgoingAudioFilters()
                    {
                    },
                }
            };

            return options;
        }

        private async Task<AcceptCallOptions> SetupIncomingCallOptions()
        {
            var deviceManager = await callee.CallClient.GetDeviceManagerAsync();
            deviceManager.SetMicrophone(AudioService.FindEquivalent(callee.AudioDeviceNumber, [.. deviceManager.Microphones]));
            var incomingStream = new LocalOutgoingAudioStream();

            var options = new AcceptCallOptions()
            {
                OutgoingAudioOptions = new OutgoingAudioOptions()
                {
                    IsMuted = false,
                    Stream = incomingStream,
                    Filters = new OutgoingAudioFilters()
                    {
                    }
                },
            };

            return options;
        }

        private void NextTurn()
        {                        
            var turn = entry.Children.Dequeue();
            WeakReferenceMessenger.Default.Send(
                new NextTurnBeingPlayed(this)
            );

            if (currentSpeaker.Equals(Speaker.Caller))
            {
                var duration = audioService.PlayAudioFile(caller.AudioDeviceNumber, turn.FilePath, OnPlaybackStopped);
                Debug.WriteLine($"{entry.Name}: Caller speaking: {turn.Name}, for {(int)duration.TotalSeconds}s");
            }
            else
            {
                var duration = audioService.PlayAudioFile(callee.AudioDeviceNumber, turn.FilePath, OnPlaybackStopped);
                Debug.WriteLine($"{entry.Name}: Callee speaking: {turn.Name}, for {(int)duration.TotalSeconds}s");
            }
            currentSpeaker = currentSpeaker.Equals(Speaker.Caller) ? Speaker.Callee : Speaker.Caller;
        }
    }
}
