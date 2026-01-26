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
            var audioInitTask = audioGraphManager.InitializeAsync();
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
            await Task.Delay(1000); // give it enough slack so that the fist client gets registered. 

            caller.Call = await caller.CallAgent.StartCallAsync(
                new[] { new UserCallIdentifier(callee.IdentifierAndToken.User.Id) },
                GetOutgoingCallOptions()
            );
            caller.Call.StateChanged += OnCallStateChangedAsync;
            Debug.WriteLine($"{entry.Name}: Caller is phoning callee");

            caller.Bridge = new AudioGraphAcsBridge(caller.Call.ActiveOutgoingAudioStream as RawOutgoingAudioStream);
            caller.Bridge.FileEnded += OnFileEnded;
            await audioInitTask;
        }

        protected virtual void OnCallEnded(EventArgs args)
        {
            OnEndOfCall?.Invoke(this, args);
        }

        private async void OnIncomingCallAsync(object sender, IncomingCallReceivedEventArgs args)
        {
            var incomingCall = args.IncomingCall;
            var acceptCallOptions = GetIncomingCallOptions();

            callee.Call = await incomingCall.AcceptAsync(acceptCallOptions);
            callee.Bridge = new AudioGraphAcsBridge(callee.Call.ActiveOutgoingAudioStream as RawOutgoingAudioStream);
            callee.Bridge.FileEnded += OnFileEnded;

            Debug.WriteLine($"{entry.Name}: Callee has picked up the phone");
            callee.Call.StateChanged += OnCallStateChangedAsync;
            await audioGraphManager.StartAsync();
            
            await NextTurn();
        }

        private async void OnFileEnded(object sender, EventArgs e)
        {
            if (entry.Children is not null)
            {
                await NextTurn();
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
                    case CallState.Disconnected:
                        {
                            Debug.WriteLine($"{entry.Name}: Call has been disconnected.");
                            call.StateChanged -= OnCallStateChangedAsync;
                            await audioGraphManager.StopAsync();
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

        private async Task NextTurn()
        {            
            currentSpeaker = Speaker.Caller;
            Debug.WriteLine($"{entry.Name}: Conversation is starting");
            
            var turn = entry.Children.Dequeue();
            var file = await StorageFile.GetFileFromPathAsync(turn.FilePath);
            var fileNode = await audioGraphManager.CreateFrameInputNodeFromFile(file);
            var frameNode = audioGraphManager.CreateFrameOutputNodeFromInputNode(fileNode);

            if (currentSpeaker.Equals(Speaker.Caller))
            {
                Debug.WriteLine($"{entry.Name}: Caller speaking: {file.Name}");
                caller.Bridge.StartPlayingAudio(frameNode, fileNode);
            }
            else
            {
                Debug.WriteLine($"{entry.Name}: Callee speaking: {file.Name}");
                callee.Bridge.StartPlayingAudio(frameNode, fileNode);
            }
            currentSpeaker = currentSpeaker.Equals(Speaker.Caller) ? Speaker.Callee : Speaker.Caller;
            
        }
    }
}
