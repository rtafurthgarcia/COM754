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
        private readonly CallerCalleeService callerCalleeService = Ioc.Default.GetRequiredService<CallerCalleeService>();
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
            await Task.CompletedTask;
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
                var dto = await Classifications.FromJsonAsync(arg.Message.Body.ToString());
                if (callerCalleeService.usedIds.TryGetValue(dto.Speaker, out Speaker realSpeaker))
                {
                    var detectionResults = Classifications.FromDto(dto, realSpeaker);
                    WeakReferenceMessenger.Default.Send(new DetectionResultReceived(detectionResults));
                }
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