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
using System.Diagnostics;
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
            public AudioGraphAcsBridge Bridge;
        };

        private readonly CallContainer caller;
        private readonly CallContainer callee;
        private readonly DatasetEntry entry;

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

        public PhoneCall(CommunicationUserIdentifierAndToken callerIdAndToken, CommunicationUserIdentifierAndToken calleeIdAndToken, DatasetEntry entry)
        {
            caller = new CallContainer(callerIdAndToken);
            callee = new CallContainer(calleeIdAndToken);
            this.entry = entry;
        }

        public async Task DialUp()
        {
            WeakReferenceMessenger.Default.Send(new SimulationNotification.DatasetEntryWorkedOn(entry));
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
            System.Diagnostics.Debug.WriteLine($"{entry.Name}: Caller is phoning callee");
            caller.Call.StateChanged += OnCallStateChangedAsync;

            caller.Bridge = new AudioGraphAcsBridge(await Ioc.Default.GetRequiredService<AudioGraphService>().CreateFrameOutputNodeAsync());

            Ioc.Default.GetRequiredService<AudioGraphService>().AttachQuantumHandler(caller.Bridge.OnQuantumStarted);
            Ioc.Default.GetRequiredService<AudioGraphService>().AttachQuantumHandler(ConversationStarted);
            //Ioc.Default.GetRequiredService<AudioGraphService>().AttachQuantumHandler(callee.Bridge.OnQuantumStarted);

            caller.Bridge.AttachOutgoingStream(caller.Call.ActiveOutgoingAudioStream as RawOutgoingAudioStream);

        }
        private async void OnIncomingCallAsync(object sender, IncomingCallReceivedEventArgs args)
        {
            var incomingCall = args.IncomingCall;

            var acceptCallOptions = GetIncomingCallOptions();

            callee.Bridge = new AudioGraphAcsBridge(await Ioc.Default.GetRequiredService<AudioGraphService>().CreateFrameOutputNodeAsync());
            Ioc.Default.GetRequiredService<AudioGraphService>().AttachQuantumHandler(callee.Bridge.OnQuantumStarted);
            callee.Call = await incomingCall.AcceptAsync(acceptCallOptions);
            Debug.WriteLine($"{entry.Name}: Callee has picked up the phone");
            callee.Call.StateChanged += OnCallStateChangedAsync;
            callee.Bridge.AttachOutgoingStream(callee.Call.ActiveOutgoingAudioStream as RawOutgoingAudioStream);
            await Ioc.Default.GetRequiredService<AudioGraphService>().StartAsync();
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
                            await Ioc.Default.GetRequiredService<AudioGraphService>().StopAsync();
                            call.Dispose();

                            // Implies the call was interrupted
                            if (entry.Children.Count > 0)
                            {
                                System.Diagnostics.Debug.WriteLine($"{entry.Name}: Call interrupted unexpectedly.");
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
            //outgoingAudioOptions.Stream.StateChanged += AudioStreamStateChanged;
            options.OutgoingAudioOptions = outgoingAudioOptions;

            return options;
        }

        private void AudioStreamStateChanged(object sender, AudioStreamStateChangedEventArgs args)
        {
            if (args.Stream.State.Equals(AudioStreamState.Started))
            {
                //audioGraph.QuantumStarted += ConversationStarted;
                //audioGraph.Start();
                //Ioc.Default.GetRequiredService<AudioGraphService>().StartAsync();
                
                System.Diagnostics.Debug.WriteLine($"{entry.Name}: Audio Stream is starting");
            }
        }

        private void ConversationStarted(AudioGraph sender, object args)
        {
            //audioGraph.QuantumStarted -= ConversationStarted;
            
            currentSpeaker = Speaker.Caller;
            System.Diagnostics.Debug.WriteLine($"{entry.Name}: Conversation is starting");
            while (entry.Children is not null)
            {
                var turn = entry.Children.Dequeue();
                var file = StorageFile.GetFileFromPathAsync(turn.FilePath).Get();
                
                if (currentSpeaker.Equals(Speaker.Caller))
                {
                    System.Diagnostics.Debug.WriteLine($"{entry.Name}: Caller speaking: {file.Name}");
                    PlayTurn(caller.Bridge, file).Wait();
                }
                else
                {
                    System.Diagnostics.Debug.WriteLine($"{entry.Name}: Callee speaking: {file.Name}");
                    PlayTurn(callee.Bridge, file).Wait();
                }
                currentSpeaker = currentSpeaker.Equals(Speaker.Caller) ? Speaker.Callee : Speaker.Caller;
            }
        }

        private async Task PlayTurn(AudioGraphAcsBridge bridge, StorageFile file)
        {
            var node = Ioc.Default.GetRequiredService<AudioGraphService>().CreateFileNodeAsync(file).Result;
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
            System.Diagnostics.Debug.WriteLine($"{entry.Name}: End of turn for {file.Name}.");
        }
    }
}
