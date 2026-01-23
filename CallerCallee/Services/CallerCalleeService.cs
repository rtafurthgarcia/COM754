using Azure.Communication.Calling.WindowsClient;
using Azure.Communication.Identity;
using Azure.Identity;
using Azure.ResourceManager;
using Azure.ResourceManager.KeyVault;
using Azure.Security.KeyVault.Secrets;
using CallerCallee.Models;
using CommunityToolkit.Mvvm.DependencyInjection;
using System;
using System.Threading.Tasks;
using System.Threading;
using System.Collections.Generic;

namespace CallerCallee.Services
{
    public sealed class CallerCalleeService
    {
        private record CallContainer(
            CallTokenCredential ParticipantCredentials
        ) {
            public CallClient? CallClient;
            public CallAgent? CallAgent;
            public CommunicationCall? Call;
        };

        private CallContainer callerContainer;
        private CallContainer calleeContainer;

        private static readonly string CS_ENDPOINT_NAME = "com754-cs-endpoint";

        private string? keyVaultName;
        private KeyVaultSecret? csEndpoint;

        private CallClientOptions callClientOptions;
        private LocalOutgoingAudioStream micStream;

        private DatasetImportService datasetService = Ioc.Default.GetRequiredService<DatasetImportService>();

        public async Task<DefaultAzureCredential> Authenticate() {
            var credential = new DefaultAzureCredential();

            keyVaultName = await GetKeyVaultName(credential);
            var kvUri = "https://" + keyVaultName + ".vault.azure.net";

            var kvClient = new SecretClient(new Uri(kvUri), new DefaultAzureCredential());
            csEndpoint = await kvClient.GetSecretAsync(CS_ENDPOINT_NAME);

            var communicationIdentity = new CommunicationIdentityClient(new Uri(csEndpoint.Value), credential);

            var caller = await communicationIdentity.CreateUserAndTokenAsync(scopes: [CommunicationTokenScope.VoIP]);
            var callee = await communicationIdentity.CreateUserAndTokenAsync(scopes: [CommunicationTokenScope.VoIPJoin]);

            callerContainer = new CallContainer(new CallTokenCredential(caller.Value.AccessToken.Token));
            calleeContainer = new CallContainer(new CallTokenCredential(callee.Value.AccessToken.Token));

            return credential;
        }

        private static async Task<string> GetKeyVaultName(DefaultAzureCredential credential)
        {
            var armClient = new ArmClient(credential);

            await foreach (var sub in armClient.GetSubscriptions().GetAllAsync())
            {
                await foreach (var kv in sub.GetKeyVaultsAsync())
                {
                    return kv.Data.Name;
                }
            }

            throw new AuthenticationFailedException("Could not find the keyvault name");
        }

        private async Task PrepareParticipants()
        {
            callClientOptions = new()
            {
                Diagnostics = new CallDiagnosticsOptions()
                {
                    AppName = "COM754-CallerCallee",
                    AppVersion = "1.0",
                    Tags = new List<string>(["Calling", "ACS", "Windows"])
                }
            };

            var callAgentOptions = new CallAgentOptions()
            {
                DisplayName = $"{Environment.MachineName}/{Environment.UserName}",
            };

            callerContainer?.CallClient = new(callClientOptions);
            callerContainer?.CallAgent = await callerContainer?.CallClient?.CreateCallAgentAsync(callerContainer.ParticipantCredentials, callAgentOptions);

            calleeContainer?.CallClient = new(callClientOptions);
            calleeContainer?.CallAgent = await calleeContainer?.CallClient?.CreateCallAgentAsync(calleeContainer.ParticipantCredentials, callAgentOptions);
            calleeContainer?.CallAgent.IncomingCallReceived += OnIncomingCallAsync;
        }

        public async Task StartSimulation(DefaultAzureCredential credential)
        {
            await PrepareParticipants();

            //ThreadPool.SetMaxThreads(4, 8);
            while (! datasetService.Dataset!.IsEmpty)
            {
                DatasetEntry entry;
                datasetService.Dataset.TryDequeue(out entry);
                
                //callerContainer.CallAgent.StartCallAsync(new UserCallIdentifier(calleeContainer.ParticipantCredentials.))  
            }
        }

        private async void OnIncomingCallAsync(object sender, IncomingCallReceivedEventArgs args)
        {
            var incomingCall = args.IncomingCall;

            var acceptCallOptions = new AcceptCallOptions() { };

            callerContainer?.Call = await incomingCall.AcceptAsync(acceptCallOptions);
            callerContainer?.Call.StateChanged += OnStateChangedAsync;
        }

        private async void OnStateChangedAsync(object sender, PropertyChangedEventArgs args)
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
                            await PickUp();
                            break;
                        }
                    case CallState.Disconnected:
                        {
                            call.StateChanged -= OnStateChangedAsync;
                            call.Dispose();

                            break;
                        }
                    default: break;
                }
            }
        }

        private async Task PickUp()
        {

        }
    }
}
