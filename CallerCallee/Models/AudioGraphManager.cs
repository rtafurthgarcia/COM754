using Microsoft.UI.Dispatching;
using Microsoft.UI.Xaml.Controls;
using System;
using System.Threading.Channels;
using System.Threading.Tasks;
using Windows.Foundation;
using Windows.Media.Audio;
using Windows.Media.MediaProperties;
using Windows.Storage;

namespace CallerCallee.Models
{
    public sealed class AudioGraphManager
    {
        private DispatcherQueue dispatcher;
        private DispatcherQueueController dispatcherController;
        private AudioGraph graph;
        public static int FrameMs = 20;
        public static int SampleRate = 48000;

        public async Task InitializeAsync()
        {
            dispatcherController = DispatcherQueueController.CreateOnDedicatedThread();
            dispatcher = dispatcherController.DispatcherQueue;

            await EnqueueAsync(async () =>
            {
                var settings = new AudioGraphSettings(Windows.Media.Render.AudioRenderCategory.Media)
                {
                    DesiredSamplesPerQuantum = SampleRate / 1000 * FrameMs
                };

                var result = await AudioGraph.CreateAsync(settings);

                if (result.Status != AudioGraphCreationStatus.Success)
                {
                    throw new Exception(
                        "Failed to create AudioGraph",
                        result.ExtendedError);
                }

                graph = result.Graph;
                //graph.Stop();
            });
        }

        public async Task<AudioFileInputNode> CreateFrameInputNodeFromFile(StorageFile file)
        {
            return await EnqueueAsync(async () =>
            {
                var result = await graph.CreateFileInputNodeAsync(file);

                if (result.Status != AudioFileNodeCreationStatus.Success)
                {
                    throw new Exception(
                        "Failed to create AudioFileInputNode",
                        result.ExtendedError);
                }
                result.FileInputNode.Stop();
                return result.FileInputNode;
            });
        }

        public AudioFrameOutputNode CreateFrameOutputNodeFromInputNode(AudioFileInputNode fileNode)
        {
            return graph.CreateFrameOutputNode(
                AudioEncodingProperties.CreatePcm((uint)SampleRate, 1, 16)
            );
        }

        public async Task StartAsync()
        {
            await EnqueueAsync(() => graph.Start());
        }

        public async Task StopAsync()
        {
            await EnqueueAsync(() => graph.Stop());
        }

        private async Task EnqueueAsync(Action action)
        {
            var tcs = new TaskCompletionSource();

            dispatcher.TryEnqueue(() =>
            {
                try
                {
                    action();
                    tcs.SetResult();
                }
                catch (Exception ex)
                {
                    tcs.SetException(ex);
                }
            });

            await tcs.Task;
        }


        private async Task<T> EnqueueAsync<T>(Func<Task<T>> action)
        {
            var tcs = new TaskCompletionSource<T>();

            dispatcher.TryEnqueue(async () =>
            {
                try
                {
                    var result = await action();
                    tcs.SetResult(result);
                }
                catch (Exception ex)
                {
                    tcs.SetException(ex);
                }
            });

            return await tcs.Task;
        }
    }
}
