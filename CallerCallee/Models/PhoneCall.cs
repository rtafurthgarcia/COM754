using Azure.Communication.Calling.WindowsClient;
using Azure.Communication.Identity;
using CallerCallee.Services;
using CommunityToolkit.Mvvm.DependencyInjection;
using CommunityToolkit.Mvvm.Messaging;
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
        public readonly DatasetEntry Entry;

        public enum Speaker
        {
            Caller,
            Callee
        }

        public DatasetEntry CurrentTurn
        {
            get => Entry.Children.Count > 0 ? Entry.Children.Peek() : null;
        }

        private readonly GroupCallLocator groupCallLocator = new(Guid.NewGuid());
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
            DatasetEntry Entry
        )
        {
            ArgumentNullException.ThrowIfNull(callerIdAndToken);
            ArgumentNullException.ThrowIfNull(calleeIdAndToken);

            caller = new CallDetails(callerIdAndToken);
            callee = new CallDetails(calleeIdAndToken);

            this.Entry = Entry;
            caller.AudioDeviceNumber = callerDeviceNumber;
            callee.AudioDeviceNumber = calleeDeviceNumber;
        }

        public EventHandler OnEndOfCall;
        private readonly AudioService audioService = Ioc.Default.GetRequiredService<AudioService>();

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
            caller.Call.RemoteParticipantsUpdated += OnCallRemoteParticipantsUpdated;
            Debug.WriteLine($"{Entry.Name}: Caller is creating the group call {groupCallLocator.GroupId}");
            await Task.Delay(5000); // give it enough slack so that the first client gets registered. 

            callee.Call = await callee.CallAgent.JoinAsync(
                groupCallLocator,
                await calleeGroupOptionsTask
            );
            callee.Call.StateChanged += OnCallStateChangedAsync;
            //Debug.WriteLine($"{Entry.Name}: Callee is joining group call {groupCallLocator.GroupId}");
        }

        private void OnCallRemoteParticipantsUpdated(object sender, ParticipantsUpdatedEventArgs e)
        {
            e.AddedParticipants
                .ToList()
                .ForEach(participant => Debug.WriteLine($"{Entry.Name}: {participant.DisplayName} has joined group call {groupCallLocator.GroupId}"));
        }

        protected virtual void OnCallEnded(EventArgs args)
        {
            OnEndOfCall?.Invoke(this, args);
            //WeakReferenceMessenger.Default.Send(new CallCompleted(this));
        }

        private async void OnPlaybackStopped(object sender, EventArgs e)
        {
            if (Entry.Children.Count > 0)
            {
                NextTurn();
            }
            else
            {
                Debug.WriteLine($"{Entry.Name}: Conversation over.");
                await caller.Call.HangUpAsync(new HangUpOptions() { ForEveryone = true });
                WeakReferenceMessenger.Default.Send(new CallCompleted(this));
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
                        Debug.WriteLine($"{Entry.Name}: Call has been disconnected.");
                        call.StateChanged -= OnCallStateChangedAsync;
                        if (call == callee.Call)
                        {
                            callee.CallClient.Dispose();
                            callee.CallAgent.Dispose(); //otherwise doesnt liberate the credentials on the Azure side
                        }
                        else
                        {
                            caller.CallClient.Dispose();
                            caller.CallAgent.Dispose();
                            OnCallEnded(new EventArgs());
                        }
                        call.Dispose();
                        
                        // Implies the call was interrupted
                        if (Entry.Children.Count > 0)
                        {
                            Debug.WriteLine($"{Entry.Name}: Call interrupted unexpectedly.");
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
            var turn = Entry.Children.Dequeue();
            WeakReferenceMessenger.Default.Send(
                new NextTurnBeingPlayed(this)
            );

            if (currentSpeaker.Equals(Speaker.Caller))
            {
                var duration = audioService.PlayAudioFile(caller.AudioDeviceNumber, turn.FilePath, OnPlaybackStopped);
                Debug.WriteLine($"{Entry.Name}: Caller speaking: {turn.Name}, for {(int)duration.TotalSeconds}s");
            }
            else
            {
                var duration = audioService.PlayAudioFile(callee.AudioDeviceNumber, turn.FilePath, OnPlaybackStopped);
                Debug.WriteLine($"{Entry.Name}: Callee speaking: {turn.Name}, for {(int)duration.TotalSeconds}s");
            }
            currentSpeaker = currentSpeaker.Equals(Speaker.Caller) ? Speaker.Callee : Speaker.Caller;
        }
    }
}
