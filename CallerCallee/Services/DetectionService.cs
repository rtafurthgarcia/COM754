using Azure.Messaging.ServiceBus;
using CallerCallee.Models;
using CommunityToolkit.Mvvm.DependencyInjection;
using CommunityToolkit.Mvvm.Messaging;
using System;
using System.Threading.Tasks;
using static CallerCallee.Models.SystemwideMessage;

namespace CallerCallee.Services
{
    internal class DetectionService
    {
        private enum MessageSubject
        {
            END_OF_ANALYSIS,
            TURN_ANALYSIS
        }

        private readonly AuthenticationService authenticationService = Ioc.Default.GetRequiredService<AuthenticationService>();
        private readonly DatasetService datasetService = Ioc.Default.GetRequiredService<DatasetService>();
        private readonly ServiceBusClient client;
        private readonly ServiceBusProcessor processor;

        public DetectionService()
        {
            var clientOptions = new ServiceBusClientOptions()
            {
                TransportType = ServiceBusTransportType.AmqpWebSockets
            };
            client = new ServiceBusClient(authenticationService.KeyVault.GetSecret(AuthenticationService.SB_CONNECTION_STRING).Value.Value, clientOptions);

            processor = client.CreateProcessor("detection-results", new ServiceBusProcessorOptions());
        }

        public async Task StartProcessingAsync()
        {
            processor.ProcessMessageAsync += OnProcessMessageAsync;
            await processor.StartProcessingAsync();
        }

        private async Task OnProcessMessageAsync(ProcessMessageEventArgs arg)
        {
            var subject = Enum.Parse<MessageSubject>(arg.Message.Subject);

            if (subject.Equals(MessageSubject.TURN_ANALYSIS))
            {
                (Guid groupId, DetectionResult detectionResult) = await DetectionResult.FromJsonAsync(arg.Message.Body.ToString());
                if (datasetService.DoneDataset.TryGetValue(groupId, out DatasetEntry entry))
                {
                    entry.DetectionResults.Add(detectionResult);
                    datasetService.DoneDataset[groupId] = entry;
                    WeakReferenceMessenger.Default.Send(new DetectionResultReceived(detectionResult));
                }
            } 
            else
            {
                Guid groupId = await DetectionResult.FromJsonGuidOnlyAsync(arg.Message.Body.ToString());
                if (datasetService.DoneDataset.TryGetValue(groupId, out DatasetEntry entry))
                {
                    entry.State = State.Completed;
                    datasetService.DoneDataset[groupId] = entry;
                    WeakReferenceMessenger.Default.Send(new EndOfAnalysis(groupId));
                }
            }
        }
    }
}