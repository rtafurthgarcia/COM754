using Azure.Communication.Calling.WindowsClient;
using Azure.Communication.Identity;
using CallerCallee.Services;
using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.DependencyInjection;
using CommunityToolkit.Mvvm.Messaging;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Threading.Tasks;
using static CallerCallee.Models.SystemwideMessage;

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

        private readonly CallDetails caller;
        public CallDetails Caller
        {
            get { return caller; }
        }   
        private readonly CallDetails callee;
        public CallDetails Callee
        {
            get { return callee; }
        }

        private readonly DatasetEntry entry;
        public DatasetEntry Entry
        {
            get { return entry; }
        }

        public DatasetEntry CurrentTurn => entry.Children.Count > 0 ? entry.Children.Peek() : null;

        private readonly GroupCallLocator groupCallLocator = new(Guid.NewGuid());
        public Guid Guid
        {
            get { return groupCallLocator.GroupId; }
        }
        private Speaker currentSpeaker = Speaker.Callee; // will be switched to caller at the beginning of the call,
                                                         // so that the first turn gets played by the caller as intende
        public Speaker CurrentSpeaker { 
            get { return currentSpeaker; }
        }
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

            this.entry = Entry;
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
                    DisplayName = $"{entry.Id}/COM754-Caller",
                }
            );

            callee.CallClient = new(callClientOptions);
            var callerGroupOptionsTask = SetupGroupCallOptions(caller);
            var calleeGroupOptionsTask = SetupGroupCallOptions(callee);

            callee.CallAgent = await callee.CallClient.CreateCallAgentAsync(
                calleeTokenCredential,
                new CallAgentOptions()
                {
                    DisplayName = $"{entry.Id}/COM754-Callee",
                }
            );

            caller.Call = await caller.CallAgent.JoinAsync(
                groupCallLocator,
                await callerGroupOptionsTask
            );
            caller.Call.StateChanged += OnCallStateChangedAsync;
            caller.Call.RemoteParticipantsUpdated += OnCallRemoteParticipantsUpdated;
            Debug.WriteLine($"{entry.Id}: Caller is creating the group call {groupCallLocator.GroupId}");
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
                .ForEach(participant => Debug.WriteLine($"{entry.Id}: {participant.DisplayName} has joined group call {groupCallLocator.GroupId}"));
        }

        protected virtual void OnCallEnded(EventArgs args)
        {
            OnEndOfCall?.Invoke(this, args);
            //WeakReferenceMessenger.Default.Send(new CallCompleted(this));
        }

        private async void OnPlaybackStopped(object sender, EventArgs e)
        {
            try
            {
                if (entry.Children.Count > 0)
                {
                    NextTurn();
                }
                else
                {
                    Debug.WriteLine($"{entry.Id}: Conversation over.");
                    entry.Exception = null;
                    entry.State = State.WaitingForClassification;
                    WeakReferenceMessenger.Default.Send(new CallCompleted(this));
                    await caller.Call.HangUpAsync(new HangUpOptions() { ForEveryone = true });
                }
            }
            catch (Exception ex)
            {
                Debug.WriteLine($"{entry.Id}: Exception in OnPlaybackStopped: {ex.Message}");
                entry.State = State.Failed;
                entry.Exception = ex;

                // only skip once, if it fails again,
                // then we consider the call failed and move on with the rest of the dataset.
                if (entry.Children.Count > 0)
                {
                    Debug.WriteLine($"{entry.Id}: Skipping to the next one...");

                    try
                    {
                        NextTurn();
                    }
                    catch (Exception innerEx)
                    {
                        Debug.WriteLine($"{entry.Id}: Exception in NextTurn after playback failure: {innerEx.Message}");
                        entry.State = State.Failed;
                        entry.Exception = innerEx;
                        await callee.Call.HangUpAsync(new HangUpOptions() { ForEveryone = true });
                    }
                }
            }
        }

        public async Task TerminateAsync()
        {
            try
            {
                entry.Children.Clear(); // so that it doesnt trigger the next turn after the current one has finished, and instead ends the call immediately.
                await caller.Call.HangUpAsync(new HangUpOptions() { ForEveryone = true });
            }
            catch (Exception ex)
            {
                Debug.WriteLine($"{entry.Id}: Exception in ForceEndCallAsync: {ex.Message}");
                entry.State = State.Failed;
                entry.Exception = ex;
            }
        }

        public bool IsActive()
        {
            return caller.Call != null && callee.Call != null && 
                   (caller.Call.State == CallState.Connected || callee.Call.State == CallState.Connected);
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
                        Debug.WriteLine($"{entry.Id}: Call has been disconnected.");
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
                        if (entry.Children.Count > 0)
                        {
                            entry.State = State.Failed;
                            entry.Exception = new Exception("Call interrupted unexpectedly.");
                            Debug.WriteLine($"{entry.Id}: {entry.Exception.Message}");
                            WeakReferenceMessenger.Default.Send(
                                new CallInterrupted(
                                    this
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
            currentSpeaker = currentSpeaker.Equals(Speaker.Caller) ? Speaker.Callee : Speaker.Caller;
            WeakReferenceMessenger.Default.Send(
                new NextTurnBeingPlayed(this)
            );

            if (currentSpeaker.Equals(Speaker.Caller))
            {
                var duration = audioService.PlayAudioFile(caller.AudioDeviceNumber, turn.FilePath, OnPlaybackStopped);
                Debug.WriteLine($"{entry.Id}: Caller speaking: {turn.Id}, for {(int)duration.TotalSeconds}s");
            }
            else
            {
                var duration = audioService.PlayAudioFile(callee.AudioDeviceNumber, turn.FilePath, OnPlaybackStopped);
                Debug.WriteLine($"{entry.Id}: Callee speaking: {turn.Id}, for {(int)duration.TotalSeconds}s");
            }
        }
    }
}
