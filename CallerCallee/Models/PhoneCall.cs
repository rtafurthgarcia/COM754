using Azure.Communication;
using Azure.Communication.Calling.WindowsClient;
using Azure.Communication.Identity;
using CallerCallee.Helpers;
using CommunityToolkit.Mvvm.Messaging;
using NAudio.Wave;
using System;
using System.Collections.Generic;
using System.Diagnostics.Metrics;
using System.Threading;
using System.Threading.Tasks;
using Windows.Foundation;
using Windows.Media;
using Windows.Media.Audio;
using Windows.Storage;

namespace CallerCallee.Models
{
    public class PhoneCall
    {
        private record CallContainer(CommunicationUserIdentifierAndToken IdentifierAndToken)
        {
            public CallClient CallClient;
            public CallAgent CallAgent;
            public CommunicationCall Call;
        };

        private readonly CallContainer caller;
        private readonly CallContainer callee;
        private readonly DatasetEntry entry;

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

        private AudioGraph audioGraph;

        public PhoneCall(CommunicationUserIdentifierAndToken callerIdAndToken, CommunicationUserIdentifierAndToken calleeIdAndToken, DatasetEntry entry)
        {
            caller = new CallContainer(callerIdAndToken);
            callee = new CallContainer(calleeIdAndToken);
            this.entry = entry;

            var settings = new AudioGraphSettings(Windows.Media.Render.AudioRenderCategory.Media);

            CreateAudioGraphResult result = AudioGraph.CreateAsync(settings).AsTask().Result;
            if (result.Status != AudioGraphCreationStatus.Success)
            {
                throw new Exception("Failed to create the Audiograph object. ", result.ExtendedError);
            }

            audioGraph = result.Graph;
        }

        public async Task DialUp() {
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

            //string token = callee.ParticipantCredentials.Token.Token;

            caller.Call = await caller.CallAgent.StartCallAsync(
                new[] {new UserCallIdentifier(callee.IdentifierAndToken.User.Id)},
                GetOutgoingCallOptions()
            );
            caller.Call.StateChanged += OnCallStateChangedAsync;
            WeakReferenceMessenger.Default.Send(new SimulationNotification.DatasetEntryWorkedOn(entry));
        }
        private async void OnIncomingCallAsync(object sender, IncomingCallReceivedEventArgs args)
        {
            var incomingCall = args.IncomingCall;

            var acceptCallOptions = GetIncomingCallOptions();

            callee.Call = await incomingCall.AcceptAsync(acceptCallOptions);
            callee.Call.StateChanged += OnCallStateChangedAsync;
        }

        private void OnCallStateChangedAsync(object sender, PropertyChangedEventArgs args)
        {
            var call = sender as CommunicationCall;
            if (call != null)
            {
                var state = call.State;
                switch (state)
                {
                    case CallState.Disconnected:
                        {
                            call.StateChanged -= OnCallStateChangedAsync;
                            call.Dispose();

                            // Implies the call was interrupted
                            if (entry.Children.Count > 0)
                            {
                                WeakReferenceMessenger.Default.Send(
                                    new SimulationNotification.DatasetEntryFailed(
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

        private AcceptCallOptions GetIncomingCallOptions()
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
            outgoingAudioOptions.Stream.StateChanged += AudioStreamStateChanged;
            options.OutgoingAudioOptions = outgoingAudioOptions;

            return options;
        }

        private void AudioStreamStateChanged(object sender, AudioStreamStateChangedEventArgs args)
        {
            if (args.Stream.State.Equals(AudioStreamState.Started))
            {                
                audioGraph.QuantumStarted += ConversationStarted;
                audioGraph.Start();
            }
        }

        private async void ConversationStarted(AudioGraph sender, object args)
        {
            int counter = 0;

            while (entry.Children.Count > 0)
            {
                var turn = entry.Children.Dequeue();

                var file = await StorageFile.GetFileFromPathAsync(turn.FilePath);
                CreateAudioFileInputNodeResult result = await audioGraph.CreateFileInputNodeAsync(file);

                if (result.Status != AudioFileNodeCreationStatus.Success)
                {
                    throw new Exception("Failed to create the Audiograph object. ", result.ExtendedError);
                }
               
                WeakReferenceMessenger.Default.Send(new SimulationNotification.TurnBeingPlayed(new ParentChildDataset(entry, turn)));
                var audioThread = new Thread(ProcessFrame(counter));
                audioThread.Start();
                audioThread.Join();

            }

            WeakReferenceMessenger.Default.Send(new SimulationNotification.DatasetEntryFinished(entry));
            caller.Call.HangUpAsync(new HangUpOptions() { ForEveryone = true }).Wait();
        }

        private unsafe ParameterizedThreadStart ProcessFrame(int counter)
        {
            // To simulate a real conversation where each participant speak politely one after the other 
            var stream = (counter % 2 == 0 ? callee.Call.ActiveOutgoingAudioStream : caller.Call.ActiveOutgoingAudioStream) as RawOutgoingAudioStream;
            var frame = audioGraph.CreateFrameOutputNode().GetFrame();

            var properties = stream.Properties;
            RawAudioBuffer buffer;

            var nextDeliverTime = DateTime.Now;
            while (true)
            {
                var memoryBuffer = new MemoryBuffer((uint)stream.ExpectedBufferSizeInBytes);
                using (var reference = memoryBuffer.CreateReference())
                {
                    byte* dataInBytes;
                    uint capacityInBytes;
                    float* dataInFloat;
                    ((IMemoryBufferByteAccess)reference).GetBuffer(out dataInBytes, out capacityInBytes);
                    dataInFloat = (float*)dataInBytes;
                }
                nextDeliverTime = nextDeliverTime.AddMilliseconds(20);
                buffer = new RawAudioBuffer();
                buffer.Buffer = memoryBuffer;
                stream.SendRawAudioBufferAsync(buffer).Wait();
                var wait = nextDeliverTime - DateTime.Now;
                if (wait > TimeSpan.Zero)
                {
                    Thread.Sleep(wait);
                }
            }
        }
    }
}
