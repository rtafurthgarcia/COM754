using Azure.Communication;
using Azure.Communication.Calling.WindowsClient;
using Azure.Communication.Identity;
using CallerCallee.Helpers;
using CommunityToolkit.Mvvm.DependencyInjection;
using CommunityToolkit.Mvvm.Messaging;
using CommunityToolkit.Mvvm.Messaging.Messages;
using NAudio.Wave;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Diagnostics.Metrics;
using System.Runtime.InteropServices;
using System.Threading;
using System.Threading.Tasks;
using Windows.Foundation;
using Windows.Media;
using Windows.Media.Audio;
using Windows.Storage;
using static CallerCallee.Models.SimulationNotification;

namespace CallerCallee.Models
{
    public class PhoneCall
    {
        private record CallContainer(CommunicationUserIdentifierAndToken IdentifierAndToken)
        {
            public CallClient CallClient;
            public CallAgent CallAgent;
            public CommunicationCall Call;
            public AudioGraphAcsBridge Bridge;
        };

        private readonly CallContainer caller;
        private readonly CallContainer callee;

        public CommunicationUserIdentifierAndToken OfCaller
        {
            get
            {
                return caller.IdentifierAndToken;
            }

            private set;
        }
        public CommunicationUserIdentifierAndToken OfCallee
        {
            get
            {
                return callee.IdentifierAndToken;
            }

            private set;
        }

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
        private readonly AudioGraphManager audioGraphManager;

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

        public PhoneCall(CommunicationUserIdentifierAndToken callerIdAndToken, CommunicationUserIdentifierAndToken calleeIdAndToken, DatasetEntry entry)
        {
            caller = new CallContainer(callerIdAndToken);
            callee = new CallContainer(calleeIdAndToken);
            this.entry = entry;
            audioGraphManager = new();
        }

        public EventHandler OnEndOfCall;

        public async Task DialUp()
        {
            WeakReferenceMessenger.Default.Send(new CallInitiated(entry));
            await audioGraphManager.InitializeAsync();
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
            callee.CallAgent = await callee.CallClient.CreateCallAgentAsync(
                calleeTokenCredential,
                new CallAgentOptions()
                {
                    DisplayName = $"{Environment.MachineName}/COM754-Callee",
                }
            );
            callee.CallAgent.IncomingCallReceived += OnIncomingCallAsync;

            caller.Call = await caller.CallAgent.StartCallAsync(
                new[] { new UserCallIdentifier(callee.IdentifierAndToken.User.Id) },
                GetOutgoingCallOptions()
            );
            Debug.WriteLine($"{entry.Name}: Caller is phoning callee");
            caller.Call.StateChanged += OnCallStateChangedAsync;

            caller.Bridge = new AudioGraphAcsBridge(await audioGraphManager.CreateFrameOutputNodeAsync());

            audioGraphManager.AttachQuantumHandler(caller.Bridge.OnQuantumStarted);
            audioGraphManager.AttachQuantumHandler(ConversationStarted);
            //Ioc.Default.GetRequiredService<AudioGraphService>().AttachQuantumHandler(callee.Bridge.OnQuantumStarted);

            caller.Bridge.AttachOutgoingStream(caller.Call.ActiveOutgoingAudioStream as RawOutgoingAudioStream);

        }

        protected virtual void OnCallEnded(EventArgs args)
        {
            OnEndOfCall?.Invoke(this, args);
        }

        private async void OnIncomingCallAsync(object sender, IncomingCallReceivedEventArgs args)
        {
            var incomingCall = args.IncomingCall;

            var acceptCallOptions = GetIncomingCallOptions();

            callee.Bridge = new AudioGraphAcsBridge(await audioGraphManager.CreateFrameOutputNodeAsync());
            audioGraphManager.AttachQuantumHandler(callee.Bridge.OnQuantumStarted);
            callee.Call = await incomingCall.AcceptAsync(acceptCallOptions);
            Debug.WriteLine($"{entry.Name}: Callee has picked up the phone");
            callee.Call.StateChanged += OnCallStateChangedAsync;
            callee.Bridge.AttachOutgoingStream(callee.Call.ActiveOutgoingAudioStream as RawOutgoingAudioStream);
            await audioGraphManager.StartAsync();
        }

        private async void OnCallStateChangedAsync(object sender, PropertyChangedEventArgs args)
        {
            var call = sender as CommunicationCall;
           
            if (call != null)
            {
                var state = call.State;
                switch (state)
                {
                    case CallState.Disconnected:
                        {
                            Debug.WriteLine($"{entry.Name}: Call has been disconnected.");
                            call.StateChanged -= OnCallStateChangedAsync;
                            await audioGraphManager.StopAsync();
                            OnCallEnded(new EventArgs());
                            call.Dispose();

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

        private static StartCallOptions GetOutgoingCallOptions()
        {
            var outgoingAudioProperties = new RawOutgoingAudioStreamProperties()
            {
                Format = AudioStreamFormat.Pcm16Bit,
                SampleRate = AudioStreamSampleRate.Hz_48000,
                ChannelMode = AudioStreamChannelMode.Stereo,
                BufferDuration = AudioStreamBufferDuration.Ms20,
            };
            var outgoingAudioStreamOptions = new RawOutgoingAudioStreamOptions()
            {
                Properties = outgoingAudioProperties,
            };

            var options = new StartCallOptions();
            var outgoingAudioOptions = new OutgoingAudioOptions();
            var rawOutgoingAudioStream = new RawOutgoingAudioStream(outgoingAudioStreamOptions);
            outgoingAudioOptions.Stream = rawOutgoingAudioStream;
            options.OutgoingAudioOptions = outgoingAudioOptions;

            return options;
        }

        private static AcceptCallOptions GetIncomingCallOptions()
        {
            var outgoingAudioProperties = new RawOutgoingAudioStreamProperties()
            {
                Format = AudioStreamFormat.Pcm16Bit,
                SampleRate = AudioStreamSampleRate.Hz_48000,
                ChannelMode = AudioStreamChannelMode.Stereo,
                BufferDuration = AudioStreamBufferDuration.Ms20,
            };
            var outgoingAudioStreamOptions = new RawOutgoingAudioStreamOptions()
            {
                Properties = outgoingAudioProperties,
            };

            var options = new AcceptCallOptions();
            var outgoingAudioOptions = new OutgoingAudioOptions();
            var rawOutgoingAudioStream = new RawOutgoingAudioStream(outgoingAudioStreamOptions);
            outgoingAudioOptions.Stream = rawOutgoingAudioStream;
            //outgoingAudioOptions.Stream.StateChanged += AudioStreamStateChanged;
            options.OutgoingAudioOptions = outgoingAudioOptions;

            return options;
        }

        private void ConversationStarted(AudioGraph sender, object args)
        {
            audioGraphManager.DetachQuantumHandler(ConversationStarted);
            
            currentSpeaker = Speaker.Caller;
            Debug.WriteLine($"{entry.Name}: Conversation is starting");
            while (entry.Children is not null)
            {
                var turn = entry.Children.Dequeue();
                var file = StorageFile.GetFileFromPathAsync(turn.FilePath).Get();
                
                if (currentSpeaker.Equals(Speaker.Caller))
                {
                    Debug.WriteLine($"{entry.Name}: Caller speaking: {file.Name}");
                    PlayTurn(caller.Bridge, file).Wait();
                }
                else
                {
                    Debug.WriteLine($"{entry.Name}: Callee speaking: {file.Name}");
                    PlayTurn(callee.Bridge, file).Wait();
                }
                currentSpeaker = currentSpeaker.Equals(Speaker.Caller) ? Speaker.Callee : Speaker.Caller;
            }
        }

        private async Task PlayTurn(AudioGraphAcsBridge bridge, StorageFile file)
        {
            var node = await audioGraphManager.CreateFileNodeAsync(file);
            System.Diagnostics.Debug.WriteLine($"{entry.Name}: {file.Name} will last {node.Duration.TotalSeconds} seconds.");
            var tcs = new TaskCompletionSource();

            bridge.TurnFinished += () => tcs.TrySetResult();
            node.FileCompleted += (_, __) =>
            {
                bridge.EndTurn();
                System.Diagnostics.Debug.WriteLine($"{entry.Name}: EOF reached for {file.Name}.");
            };

            bridge.StartTurn();
            node.Start();

            await tcs.Task;

            node.Stop();
            node.Dispose();
            Debug.WriteLine($"{entry.Name}: End of turn for {file.Name}.");
        }
    }
}
