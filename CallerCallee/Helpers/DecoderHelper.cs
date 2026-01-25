using Azure.Communication.Calling.WindowsClient;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.InteropServices;
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

        public AudioGraphAcsBridge(AudioFrameOutputNode frameNode)
        {
            this.frameNode = frameNode;
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

        public void OnQuantumStarted(AudioGraph sender, object args)
        {
            var frame = frameNode.GetFrame();
            var pcm = ConvertFrameToPcm16(frame);
            pcmChannel.Writer.TryWrite(pcm);
        }

        // BACKGROUND THREAD
        public async Task StartStreamingAsync(
            RawOutgoingAudioStream stream,
            CancellationToken token)
        {
            while (await pcmChannel.Reader.WaitToReadAsync(token))
            {
                while (pcmChannel.Reader.TryRead(out var pcm))
                {
                    var buffer = new MemoryBuffer((uint)pcm.Length);

                    using (var reference = buffer.CreateReference())
                    {
                        unsafe
                        {
                            byte* dst;
                            uint cap;
                            ((IMemoryBufferByteAccess)reference)
                                .GetBuffer(out dst, out cap);

                            Marshal.Copy(pcm, 0, (IntPtr)dst, pcm.Length);
                        }
                    }

                    await stream.SendRawAudioBufferAsync(
                        new RawAudioBuffer { Buffer = buffer });
                }
            }
        }
    }
}
