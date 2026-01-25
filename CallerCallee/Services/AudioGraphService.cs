using Microsoft.UI.Dispatching;
using Windows.Media.Audio;
using Windows.Storage;
using System;
using System.Threading.Tasks;

namespace CallerCallee.Services
{
    public sealed class AudioGraphService
    {
        private readonly DispatcherQueue dispatcher;
        private AudioGraph graph;

        public AudioGraphService(DispatcherQueue dispatcher)
        {
            this.dispatcher = dispatcher;
        }

        public async Task InitializeAsync()
        {
            await EnqueueAsync(async () =>
            {
                var settings = new AudioGraphSettings(
                    Windows.Media.Render.AudioRenderCategory.Media);

                var result = await AudioGraph.CreateAsync(settings);

                if (result.Status != AudioGraphCreationStatus.Success)
                {
                    throw new Exception(
                        "Failed to create AudioGraph",
                        result.ExtendedError);
                }

                graph = result.Graph;
            });
        }

        public async Task<AudioFileInputNode> CreateFileNodeAsync(StorageFile file)
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

                return result.FileInputNode;
            });
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
