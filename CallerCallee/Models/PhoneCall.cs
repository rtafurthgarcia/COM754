using Azure.Communication;
using Azure.Communication.Calling.WindowsClient;
using Azure.Communication.Identity;
using CallerCallee.Helpers;
using CallerCallee.Services;
using CommunityToolkit.Mvvm.DependencyInjection;
using CommunityToolkit.Mvvm.Messaging;
using NAudio.Wave;
using System;
using System.Collections.Generic;
using System.Diagnostics.Metrics;
using System.Runtime.InteropServices;
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
        private AudioGraphAcsBridge bridge;

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

        public async Task DialUp()
        {
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
            caller.Call.StateChanged += OnCallStateChangedAsync;

            var frameNode = await Ioc.Default.GetRequiredService<AudioGraphService>().CreateFrameOutputNodeAsync();
            bridge = new AudioGraphAcsBridge(frameNode);
            Ioc.Default.GetRequiredService<AudioGraphService>().AttachQuantumHandler(bridge.OnQuantumStarted);

            await bridge.StartStreamingAsync(
                (RawOutgoingAudioStream)caller.Call.ActiveOutgoingAudioStream,
                CancellationToken.None);

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
            while (entry.Children.Count > 0)
            {
                var turn = entry.Children.Dequeue();
                var file = await StorageFile.GetFileFromPathAsync(turn.FilePath);

                var node = await Ioc.Default.GetRequiredService<AudioGraphService>().CreateFileNodeAsync(file);

                WeakReferenceMessenger.Default.Send(
                    new SimulationNotification.TurnBeingPlayed(
                        new ParentChildDataset(entry, turn)));

                node.Start();
                await Task.Delay(node.Duration);
                node.Stop();
            }

            //WeakReferenceMessenger.Default.Send(
            //    new SimulationNotification.DatasetEntryFinished(entry));

            //await caller.Call.HangUpAsync(new HangUpOptions { ForEveryone = true });
        }
    }
}
