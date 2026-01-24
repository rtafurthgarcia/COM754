using Azure.Communication.Calling.WindowsClient;
using Azure.Communication.Identity;
using Azure.ResourceManager;
using Azure.ResourceManager.KeyVault;
using Azure.Security.KeyVault.Secrets;
using CallerCallee.Models;
using CommunityToolkit.Mvvm.DependencyInjection;
using System;
using System.Threading.Tasks;
using System.Collections.Generic;
using Azure.Identity;
using WinRT.Interop;

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

        private DatasetService datasetService = Ioc.Default.GetRequiredService<DatasetService>();

        public async Task<DefaultAzureCredential> Authenticate() {
            var credential = new DefaultAzureCredential();

            /*keyVaultName = await GetKeyVaultName(credential);
            var kvUri = "https://" + keyVaultName + ".vault.azure.net";

            var kvClient = new SecretClient(new Uri(kvUri), new DefaultAzureCredential());
            csEndpoint = await kvClient.GetSecretAsync(CS_ENDPOINT_NAME);

            var communicationIdentity = new CommunicationIdentityClient(new Uri(csEndpoint.Value), credential);

            var caller = await communicationIdentity.CreateUserAndTokenAsync(scopes: new[] { CommunicationTokenScope.VoIP });
            var callee = await communicationIdentity.CreateUserAndTokenAsync(scopes: new[] { CommunicationTokenScope.VoIPJoin });*/

            string token = "\"eyJhbGciOiJSUzI1NiIsImtpZCI6IjAxOUQzMTYyMzQ0RTQ4REEwNUU1OUQxMzYwNkYwQkFDRjU4QTQwRUMiLCJ4NXQiOiJBWjB4WWpST1NOb0Y1WjBUWUc4THJQV0tRT3ciLCJ0eXAiOiJKV1QifQ.eyJza3lwZWlkIjoiYWNzOjRkM2RmNDc2LTY4N2MtNDAzMy04YmMwLTkyMmM1YmFhNDlhMV8wMDAwMDAyYy04ZDQxLTk2YjEtN2NhZi1mNGJkNDU2MDYxN2QiLCJzY3AiOjE3OTIsImNzaSI6IjE3NjkyMTQwNDYiLCJleHAiOjE3NjkzMDA0NDYsInJnbiI6ImZyIiwiYWNzU2NvcGUiOiJ2b2lwIiwicmVzb3VyY2VJZCI6IjRkM2RmNDc2LTY4N2MtNDAzMy04YmMwLTkyMmM1YmFhNDlhMSIsInJlc291cmNlTG9jYXRpb24iOiJmcmFuY2UiLCJpYXQiOjE3NjkyMTQwNDZ9.rREkSG8FWUks09sv-ZECgG0GmopDPXXQiDVIyt1fC2h7ufkoY9DqsebGk-3Nv3AFQFPYft2Cw3mBNU60T15IJ9mdNckU3AhoEdzYyN3Ho_OHYgquP0Ee4Z14BqWhSyfISqxIxE5sHUMdN60DT43NfAgHykgumf1TgHm4rS1k0NdnPMM3JZfwThM_T8RKak73YL0nIMrToqpoijc998JTQe6FFRX0xq29Fi4HJ030qa-Ix5aY_uksYPINBdC2eGabB8Y4bG8w0d53JkBj45BuFMiKMg61n5i06Sg4POsQcrrk_pZo1IY42Ox2EKz2CgOpe-gCREIryVtpkyLAs2RAZQ\"";
            var callerToken = new CallTokenCredential(token, new CallTokenRefreshOptions(false));
            //callerContainer = new CallContainer(callerToken);
            //calleeContainer = new CallContainer(new CallTokenCredential(callee.Value.AccessToken.Token));

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
