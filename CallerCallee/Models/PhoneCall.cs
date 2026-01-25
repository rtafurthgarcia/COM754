using Azure.Communication.Calling.WindowsClient;
using Azure.ResourceManager.Resources.Models;
using CallerCallee.Helpers;
using CommunityToolkit.Mvvm.Messaging;
using Microsoft.UI.Xaml.Media.Animation;
using NAudio.Wave;
using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using Windows.Foundation;

namespace CallerCallee.Models
{
    public class PhoneCall
    {
        private record CallContainer(CallTokenCredential ParticipantCredentials)
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

        public PhoneCall(string callerToken, string calleeToken, DatasetEntry entry)
        {
            caller = new CallContainer(new CallTokenCredential(callerToken, callTokenRefreshOptions));
            callee = new CallContainer(new CallTokenCredential(calleeToken, callTokenRefreshOptions));
            this.entry = entry;
        }

        public async Task DialUp() {
            caller.CallClient = new(callClientOptions);
            caller.CallAgent = await caller.CallClient?.CreateCallAgentAsync(
                caller.ParticipantCredentials,
                new CallAgentOptions()
                {
                    DisplayName = $"{Environment.MachineName}/COM754-Caller",
                }
            );

            callee.CallClient = new(callClientOptions);
            callee.CallAgent = await callee?.CallClient?.CreateCallAgentAsync(
                callee.ParticipantCredentials, new CallAgentOptions()
                {
                    DisplayName = $"{Environment.MachineName}/COM754-Caller",
                }
            );
            callee.CallAgent.IncomingCallReceived += OnIncomingCallAsync;

            caller.Call = await caller.CallAgent.StartCallAsync(
                [new UserCallIdentifier(callee.ParticipantCredentials.Token.Token)],
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
            // we only want to start streaming when both are connected.
            /*outgoingAudioOptions.Stream.StateChanged += (sender, args) => {
                if (args.Stream.State.Equals(AudioStreamState.Started))
                {
                    while (caller.Turns.Count > 0)
                    {
                        var turn = caller.Turns.Dequeue();

                        PlayAudioStream(ref rawOutgoingAudioStream, turn.FilePath);
                    }

                    if (callee.Turns.Count == 0)
                    {
                        caller.Call.HangUpAsync(new HangUpOptions() { ForEveryone = true }).Wait();
                    }
                }
            };*/
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
                int counter = 0;
                while (entry.Children.Count > 0)
                {
                    var turn = entry.Children.Dequeue();

                    // To simulate a real conversation where each participant speak politely one after the other 
                    var stream = (counter % 2 == 0 ? callee.Call.ActiveOutgoingAudioStream : caller.Call.ActiveOutgoingAudioStream) as RawOutgoingAudioStream;
                    WeakReferenceMessenger.Default.Send(new SimulationNotification.DatasetEntryFinished(entry));
                    PlayAudioStream(ref stream, turn);

                    counter++;
                }
                WeakReferenceMessenger.Default.Send(new SimulationNotification.DatasetEntryFinished(entry));
                callee.Call.HangUpAsync(new HangUpOptions() { ForEveryone = true }).Wait();
            }
        }

        private unsafe void PlayAudioStream(ref RawOutgoingAudioStream stream, DatasetEntry turn)
        {
            WeakReferenceMessenger.Default.Send(new SimulationNotification.TurnBeingPlayed(new ParentChildDataset(entry, turn)));

            var reader = new AudioFileReader(turn.FilePath);

            // Resample to match ACS stream format
            var targetFormat = new WaveFormat(
                48000,   // sample rate
                16,      // bits
                1        // channels (change to 2 if stereo)
            );

            var resampler = new MediaFoundationResampler(reader, targetFormat)
            {
                ResamplerQuality = 60
            };

            var bytesPerFrame = stream.ExpectedBufferSizeInBytes;

            var nextDeliverTime = DateTime.Now;
            var managedBuffer = new byte[bytesPerFrame];

            while (true)
            {
                int bytesRead = resampler.Read(managedBuffer, 0, managedBuffer.Length);

                // Loop audio or stop when finished
                if (bytesRead == 0)
                {
                    reader.Position = 0;
                    continue;
                }

                var memoryBuffer = new MemoryBuffer((uint)bytesPerFrame);

                using (var reference = memoryBuffer.CreateReference())
                {

                    ((IMemoryBufferByteAccess)reference)
                        .GetBuffer(out byte* dataInBytes, out uint capacityInBytes);

                    // Copy decoded PCM into the ACS buffer
                    fixed (byte* src = managedBuffer)
                    {
                        Buffer.MemoryCopy(
                            src,
                            dataInBytes,
                            capacityInBytes,
                            (uint)bytesRead
                        );
                    }
                }

                var buffer = new RawAudioBuffer
                {
                    Buffer = memoryBuffer
                };
                stream.SendRawAudioBufferAsync(buffer).Wait();

                // Maintain 20 ms cadence
                nextDeliverTime = nextDeliverTime.AddMilliseconds(20);
                var wait = nextDeliverTime - DateTime.Now;
                if (wait > TimeSpan.Zero)
                {
                    Thread.Sleep(wait);
                }
            }
            
        }
    }
}
