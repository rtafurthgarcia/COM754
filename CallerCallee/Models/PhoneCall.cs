using Azure.Communication.Calling.WindowsClient;
using Azure.Communication.Identity;
using CallerCallee.Services;
using CommunityToolkit.Mvvm.DependencyInjection;
using CommunityToolkit.Mvvm.Messaging;
using System;
using System.Collections.Generic;
using System.Diagnostics;
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

        private readonly GroupCallLocator groupCallLocator = new GroupCallLocator(Guid.NewGuid());
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
                    DisplayName = $"{Entry.Name}/COM754-Caller",
                }
            );

            callee.CallClient = new(callClientOptions);
            var callerGroupOptionsTask = SetupGroupCallOptions(caller);
            var calleeGroupOptionsTask = SetupGroupCallOptions(callee);

            callee.CallAgent = await callee.CallClient.CreateCallAgentAsync(
                calleeTokenCredential,
                new CallAgentOptions()
                {
                    DisplayName = $"{Entry.Name}/COM754-Callee",
                }
            );

            caller.Call = await caller.CallAgent.JoinAsync(
                groupCallLocator,
                await callerGroupOptionsTask
            );
            caller.Call.StateChanged += OnCallStateChangedAsync;
            Debug.WriteLine($"{entry.Name}: Caller is joining group call {groupCallLocator.GroupId}");
            await Task.Delay(5000); // give it enough slack so that the first client gets registered. 

            callee.Call = await callee.CallAgent.JoinAsync(
                groupCallLocator,
                await calleeGroupOptionsTask
            );
            callee.Call.StateChanged += OnCallStateChangedAsync;
            Debug.WriteLine($"{entry.Name}: Callee is joining group call {groupCallLocator.GroupId}");
        }

        protected virtual void OnCallEnded(EventArgs args)
        {
            OnEndOfCall?.Invoke(this, args);
            //WeakReferenceMessenger.Default.Send(new CallEnded(this));
        }

        private async void OnPlaybackStopped(object sender, EventArgs e)
        {
            if (entry.Children.Count > 0)
            {
                NextTurn();
            }
            else
            {
                Debug.WriteLine($"{entry.Name}: Conversation over.");
                await caller.Call.HangUpAsync(new HangUpOptions() { ForEveryone = true });
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
                        if (call == callee.Call)
                        {
                            NextTurn();
                        }

                        break;
                    }
                    case CallState.Disconnected:
                    {
                        Debug.WriteLine($"{entry.Name}: Call has been disconnected.");
                        call.StateChanged -= OnCallStateChangedAsync;
                        call.Dispose();
                        if (call == callee.Call)
                        {
                            callee.CallAgent.Dispose(); //otherwise doesnt liberate the credentials on the Azure side
                        }
                        else
                        {
                            caller.CallAgent.Dispose();
                            OnCallEnded(new EventArgs());
                        }
                        
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

        private static async Task<JoinCallOptions> SetupGroupCallOptions(CallDetails participantDetails)
        {
            var deviceManager = await participantDetails.CallClient.GetDeviceManagerAsync();
            deviceManager.SetMicrophone(AudioService.FindEquivalent(participantDetails.AudioDeviceNumber, [.. deviceManager.Microphones]));
            var stream = new LocalOutgoingAudioStream();

            return new JoinCallOptions()
            {
                OutgoingAudioOptions = new OutgoingAudioOptions() { IsMuted = false, Stream = stream },
            };
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
