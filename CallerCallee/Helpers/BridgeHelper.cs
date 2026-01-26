using Azure.Communication.Calling.WindowsClient;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Runtime.InteropServices;
using System.Security.Cryptography.Xml;
using System.Text;
using System.Threading;
using System.Threading.Channels;
using System.Threading.Tasks;
using Windows.Foundation;
using Windows.Media;
using Windows.Media.Audio;

namespace CallerCallee.Helpers
{
    public sealed class AudioGraphAcsBridge
    {
        private readonly Channel<byte[]> pcmChannel =
            Channel.CreateBounded<byte[]>(4);

        private AudioFrameOutputNode frameNode;
        private RawOutgoingAudioStream outgoingStream;
        public bool IsPlaying { get; private set; }
        public event Action TurnFinished;

        public AudioGraphAcsBridge(AudioFrameOutputNode frameNode)
        {
            this.frameNode = frameNode;
        }
        public void AttachOutgoingStream(RawOutgoingAudioStream stream)
        {
            outgoingStream = stream;
        }

        public void StartTurn()
        {
            //Debug.WriteLine($"{}")
            IsPlaying = true;
        }

        public void EndTurn()
        {
            IsPlaying = false;
            TurnFinished?.Invoke();
        }

        private unsafe byte[] ConvertFrameToPcm16(AudioFrame frame)
        {
            using var buffer = frame.LockBuffer(AudioBufferAccessMode.Read);
            using var reference = buffer.CreateReference();

            byte* data;
            uint capacity;
            ((IMemoryBufferByteAccess)reference).GetBuffer(out data, out capacity);

            // AudioGraph outputs float32 samples
            float* floatSamples = (float*)data;

            int sampleCount = (int)(capacity / sizeof(float));
            var pcm = new byte[sampleCount * 2];

            for (int i = 0; i < sampleCount; i++)
            {
                float sample = Math.Clamp(floatSamples[i], -1f, 1f);
                short pcmSample = (short)(sample * short.MaxValue);
                BitConverter.GetBytes(pcmSample).CopyTo(pcm, i * 2);
            }

            return pcm;
        }

        public unsafe void OnQuantumStarted(AudioGraph sender, object args)
        {
            if (!IsPlaying || outgoingStream == null)
                return;

            Debug.WriteLine("Quantum started.");

            using var frame = frameNode.GetFrame();
            using var audioBuffer = frame.LockBuffer(AudioBufferAccessMode.Read);
            using var reference = audioBuffer.CreateReference();

            byte* src;
            uint capacity;
            ((IMemoryBufferByteAccess)reference).GetBuffer(out src, out capacity);

            if (capacity == 0)
                return;

            // Create ACS-compatible buffer
            var memoryBuffer = new MemoryBuffer(capacity);

            using (var dstRef = memoryBuffer.CreateReference())
            {
                byte* dst;
                uint dstCap;
                ((IMemoryBufferByteAccess)dstRef).GetBuffer(out dst, out dstCap);

                Buffer.MemoryCopy(src, dst, dstCap, capacity);
            }

            var rawBuffer = new RawAudioBuffer
            {
                Buffer = memoryBuffer
            };

            Debug.WriteLine("Firing stream!");
            // Fire-and-forget is OK here (real-time audio)
            _ = outgoingStream.SendRawAudioBufferAsync(rawBuffer);
        }
    }
}
