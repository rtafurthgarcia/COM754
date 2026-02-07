using Azure.Messaging.ServiceBus;
using CallerCallee.Models;
using CommunityToolkit.Mvvm.DependencyInjection;
using CommunityToolkit.Mvvm.Messaging;
using System;
using System.Diagnostics;
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
        private ServiceBusClient client;
        private ServiceBusProcessor processor;

        public async Task StartProcessingAsync()
        {
            var clientOptions = new ServiceBusClientOptions()
            {
                TransportType = ServiceBusTransportType.AmqpWebSockets
            };
            client = new ServiceBusClient(authenticationService.KeyVault.GetSecret(AuthenticationService.SB_CONNECTION_STRING).Value.Value, clientOptions);

            processor = client.CreateProcessor("detection-results", new ServiceBusProcessorOptions());
            processor.ProcessMessageAsync += OnProcessMessageAsync;
            processor.ProcessErrorAsync += OnProcessErrorAsync;
            await processor.StartProcessingAsync();
        }

        private async Task OnProcessErrorAsync(ProcessErrorEventArgs arg)
        {
            Debug.WriteLine($"Exception encountered whilst procesing incoming messages: {arg.Exception.Message}");   
        }

        public async Task StopProcessingAsync()
        {
            if (processor != null)
            {
                await processor.StopProcessingAsync();
                await processor.DisposeAsync();
            }
            if (client != null)
            {
                await client.DisposeAsync();
            }
        }

        private async Task OnProcessMessageAsync(ProcessMessageEventArgs arg)
        {
            var subject = Enum.Parse<MessageSubject>(arg.Message.Subject);

            if (subject.Equals(MessageSubject.TURN_ANALYSIS))
            {
                Classifications detectionResult = await Classifications.FromJsonAsync(arg.Message.Body.ToString());
                WeakReferenceMessenger.Default.Send(new DetectionResultReceived(detectionResult));
                
            } 
            else
            {
                Guid groupId = await Classifications.FromJsonGuidOnlyAsync(arg.Message.Body.ToString());
                WeakReferenceMessenger.Default.Send(new EndOfAnalysis(groupId));
                
            }
            await arg.CompleteMessageAsync(arg.Message);
        }
    }
}