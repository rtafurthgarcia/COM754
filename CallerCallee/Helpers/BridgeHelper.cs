using Azure.Communication.Calling.WindowsClient;
using System;
using System.Threading;
using Windows.Foundation;
using Windows.Media;
using Windows.Media.Audio;
using Windows.Storage.Streams;
using System.Runtime.InteropServices;
using Windows.Media.Audio;
using Windows.Media;


namespace CallerCallee.Helpers
{
    public sealed class AudioGraphAcsBridge
    {
        private AudioFrameOutputNode frameNode;
        private AudioFileInputNode fileNode;
        private RawOutgoingAudioStream outgoingStream;

        private MemoryBuffer scratchBuffer;

        private Thread pumpThread;

        private const int SampleRate = 48000;
        private const int Channels = 1;
        private const int BytesPerSample = 2; // PCM16
        private const int FrameMs = 20;
        private const int BytesPerFrame =
            SampleRate * FrameMs / 1000 * BytesPerSample * Channels;

        public bool IsPlaying { get; private set; }
        public event EventHandler FileEnded;

        public AudioGraphAcsBridge(RawOutgoingAudioStream stream) { 
            outgoingStream = stream;
            scratchBuffer = new MemoryBuffer(BytesPerFrame);
        }

        public void StartPlayingAudio(AudioFrameOutputNode frameNode, AudioFileInputNode fileNode)
        {
            // Initialize the Frame Input Node in the stopped state
            IsPlaying = true;

            this.frameNode = frameNode;
            this.fileNode = fileNode;
            this.fileNode.FileCompleted += OnFileCompleted;

            fileNode.AddOutgoingConnection(this.frameNode);

            pumpThread = new Thread(PumpLoop)
            {
                IsBackground = true,
                Priority = ThreadPriority.Highest
            };
            pumpThread.Start();
        }

        private void OnFileCompleted(AudioFileInputNode sender, object args)
        {
            IsPlaying = false;
            pumpThread?.Join();

            frameNode?.Dispose();
            fileNode?.Dispose();
        }

        private unsafe void PumpLoop()
        {
            DateTime nextTick = DateTime.UtcNow;

            while (IsPlaying)
            {
                AudioFrame frame = frameNode.GetFrame();

                // THIS is the WinUI 3-safe API
                AudioBuffer audioBuffer = frame.LockBuffer(AudioBufferAccessMode.Read);

                using (IMemoryBufferReference inRef = audioBuffer.CreateReference())
                {
                    unsafe
                    {
                        byte* src;
                        uint srcCap;
                        ((IMemoryBufferByteAccess)inRef).GetBuffer(out src, out srcCap);

                        MemoryBuffer outBuffer = new MemoryBuffer(BytesPerFrame);

                        using (IMemoryBufferReference outRef =
                               outBuffer.CreateReference())
                        {
                            byte* dst;
                            uint dstCap;
                            ((IMemoryBufferByteAccess)outRef).GetBuffer(out dst, out dstCap);

                            int bytesToCopy = (int)Math.Min(srcCap, dstCap);

                            System.Buffer.MemoryCopy(src, dst, dstCap, bytesToCopy);

                            // Zero-pad remainder
                            for (int i = bytesToCopy; i < dstCap; i++)
                                dst[i] = 0;
                        }

                        outgoingStream.SendRawAudioBufferAsync(
                            new RawAudioBuffer()
                            {
                                Buffer = outBuffer
                            }).Wait();
                    }
                }

                nextTick = nextTick.AddMilliseconds(FrameMs);
                TimeSpan wait = nextTick - DateTime.UtcNow;
                if (wait > TimeSpan.Zero)
                    Thread.Sleep(wait);
            }
        }

        /*public unsafe void OnQuantumStarted(AudioFrameInputNode sender, FrameInputNodeQuantumStartedEventArgs args)
        {
            if (!IsPlaying || outgoingStream == null)
                return;

            Debug.WriteLine("Quantum started.");

            uint numSamplesNeeded = (uint)args.RequiredSamples;

            if (numSamplesNeeded != 0)
            {
                AudioFrame audioData = GenerateAudioData(numSamplesNeeded);
                currentFrameNode.AddFrame(audioData);
            }
        }

        private unsafe AudioFrame GenerateAudioData(uint samples)
        {
            uint bufferSize = samples * sizeof(float);
            AudioFrame frame = new AudioFrame(bufferSize);
            RawOutgoingAudioStreamProperties properties = outgoingStream.Properties;
            MemoryBuffer memoryBuffer = new MemoryBuffer((uint)outgoingStream.ExpectedBufferSizeInBytes);
            using (AudioBuffer buffer = frame.LockBuffer(AudioBufferAccessMode.Write))
            using (IMemoryBufferReference reference = buffer.CreateReference())
            {
                byte* dataInBytes;
                uint capacityInBytes;
                float* dataInFloat;

                // Get the buffer from the AudioFrame
                ((IMemoryBufferByteAccess)reference).GetBuffer(out dataInBytes, out capacityInBytes);

                // Cast to float since the data we are generating is float
                dataInFloat = (float*)dataInBytes;

                float freq = 1000; // choosing to generate frequency of 1kHz
                float amplitude = 0.3f;
                double sampleIncrement = (freq * (Math.PI * 2)) / sampleRate;

                // Generate a 1kHz sine wave and populate the values in the memory buffer
                for (int i = 0; i < samples; i++)
                {
                    double sinValue = amplitude * Math.Sin(audioWaveTheta);
                    dataInFloat[i] = (float)sinValue;
                    audioWaveTheta += sampleIncrement;
                }
            }

            outgoingStream.SendRawAudioBufferAsync()

            return frame;
        }*/
    }
}
