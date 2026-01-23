using Azure.Communication.Calling.WindowsClient;
using Azure.Communication.Identity;
using Azure.Core;
using Azure.Identity;
using Azure.ResourceManager;
using Azure.ResourceManager.KeyVault;
using Azure.Security.KeyVault.Secrets;
using Microsoft.Identity.Client;
using System;
using System.Threading.Tasks;

namespace CallerCallee.Services
{
    public sealed class CallerCalleeService
    {
        private record CallContainer
        {
            public required CallTokenCredential ParticipantCredentials;
            public CallClient? CallClient;
            public CallAgent? CallAgent;
            public CommunicationCall? Call;
        }

        private CallContainer callerContainer;
        private CallContainer calleeContainer;

        private static readonly string CS_ENDPOINT_NAME = "com754-cs-endpoint";

        private string? keyVaultName;
        private KeyVaultSecret? csEndpoint;

        private readonly CallTokenRefreshOptions callTokenRefreshOptions = new(false);
        private readonly CallClientOptions callClientOptions = new()
        {
            Diagnostics = new CallDiagnosticsOptions()
            {
                AppName = "COM754-CallerCallee",
                AppVersion = "1.0",
                Tags = ["Calling", "ACS", "Windows"]
            }
        };
        private LocalOutgoingAudioStream micStream;

        public async Task<DefaultAzureCredential> Authenticate() {
            var credential = new DefaultAzureCredential();

            keyVaultName = await GetKeyVaultName(credential);
            var kvUri = "https://" + keyVaultName + ".vault.azure.net";

            var kvClient = new SecretClient(new Uri(kvUri), new DefaultAzureCredential());
            csEndpoint = await kvClient.GetSecretAsync(CS_ENDPOINT_NAME);

            var communicationIdentity = new CommunicationIdentityClient(new Uri(kvUri), credential);

            var caller = await communicationIdentity.CreateUserAndTokenAsync(scopes: [CommunicationTokenScope.VoIP]);
            var callee = await communicationIdentity.CreateUserAndTokenAsync(scopes: [CommunicationTokenScope.VoIPJoin]);

            callerContainer = new CallContainer() 
            { 
                ParticipantCredentials = new CallTokenCredential(caller.Value.AccessToken.Token)
            };
            calleeContainer = new CallContainer()
            {
                ParticipantCredentials = new CallTokenCredential(callee.Value.AccessToken.Token)
            };

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
                            await call.StartAudioAsync(micStream);
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
    }
}
