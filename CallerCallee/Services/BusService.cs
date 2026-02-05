using Azure.Communication.Identity;
using Azure.Identity;
using Azure.Messaging.ServiceBus;
using Azure.Security.KeyVault.Secrets;
using CommunityToolkit.Mvvm.DependencyInjection;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CallerCallee.Services
{
    internal class BusService
    {
        private readonly AuthenticationService authenticationService = Ioc.Default.GetRequiredService<AuthenticationService>();
        private readonly ServiceBusClient client;

        private readonly ServiceBusProcessor processor;
        public BusService()
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
            processor.ProcessMessageAsync += OnProcessMessageAsync; ;
            processor.ProcessErrorAsync += OnProcessErrorAsync; ;
            await processor.StartProcessingAsync();
        }

        private Task OnProcessErrorAsync(ProcessErrorEventArgs arg)
        {
            throw new NotImplementedException();
        }

        private Task OnProcessMessageAsync(ProcessMessageEventArgs arg)
        {
            throw new NotImplementedException();
        }
    }
}