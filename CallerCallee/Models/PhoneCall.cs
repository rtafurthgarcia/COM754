using Azure.Communication.Calling.WindowsClient;
using Azure.ResourceManager.Resources.Models;
using CallerCallee.Helpers;
using NAudio.Wave;
using System;
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

            await caller.CallAgent.StartCallAsync(
                new[] { new UserCallIdentifier(callee.ParticipantCredentials.Token.Token) },
                GetOutgoingCallOptions()
            );
        }
        private async void OnIncomingCallAsync(object sender, IncomingCallReceivedEventArgs args)
        {
            var incomingCall = args.IncomingCall;

            var acceptCallOptions = GetIncomingCallOptions();

            callee.Call = await incomingCall.AcceptAsync(acceptCallOptions);
            caller.Call.StateChanged += OnIncomingCallStateChangedAsync;
        }

        private void OnIncomingCallStateChangedAsync(object sender, PropertyChangedEventArgs args)
        {
            var call = sender as CommunicationCall;
            if (call != null)
            {
                var state = call.State;
                // Update the UI
                switch (state)
                {
                    case CallState.Connected:
                        {
                            //call.
                            //PlayAudioStream(call.);

                            // will probably send back messages somehow
                            break;
                        }
                    case CallState.Disconnected:
                        {
                            call.StateChanged -= OnIncomingCallStateChangedAsync;
                            call.Dispose();

                            break;
                        }
                    default: break;
                }
            }
        }

        private StartCallOptions GetOutgoingCallOptions()
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
            outgoingAudioOptions.Stream.StateChanged += (sender, args) => {
                if (args.Stream.State.Equals(AudioStreamState.Started))
                {
                    PlayAudioStream(rawOutgoingAudioStream);
                }
            };
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
            outgoingAudioOptions.Stream.StateChanged += (sender, args) => {
                if (args.Stream.State.Equals(AudioStreamState.Started))
                {
                    PlayAudioStream(rawOutgoingAudioStream);
                }
            };
            options.OutgoingAudioOptions = outgoingAudioOptions;

            return options;
        }

        private unsafe void PlayAudioStream(RawOutgoingAudioStream stream)
        {
            // Example: WAV or MP3 file
            var reader = new AudioFileReader("prompt.wav");

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

            new Thread(() =>
            {
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

                    var buffer = new RawAudioBuffer();
                    buffer.Buffer = memoryBuffer;
                    stream.SendRawAudioBufferAsync(buffer).Wait();

                    // Maintain 20 ms cadence
                    nextDeliverTime = nextDeliverTime.AddMilliseconds(20);
                    var wait = nextDeliverTime - DateTime.Now;
                    if (wait > TimeSpan.Zero)
                    {
                        Thread.Sleep(wait);
                    }
                }
            })
            {
                IsBackground = true
            }.Start();
        }
    }
}
