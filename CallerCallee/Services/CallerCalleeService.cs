using Azure.Communication.Calling.WindowsClient;
using Azure.Communication.Identity;
using Azure.Identity;
using Azure.ResourceManager;
using Azure.ResourceManager.KeyVault;
using Azure.Security.KeyVault.Secrets;
using CallerCallee.Helpers;
using CallerCallee.Models;
using CommunityToolkit.Mvvm.DependencyInjection;
using CommunityToolkit.Mvvm.Messaging;
using NAudio.Wave;
using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using System.Windows.Forms;
using Windows.Foundation;
using static System.Windows.Forms.VisualStyles.VisualStyleElement.TrackBar;

namespace CallerCallee.Services
{
    public sealed class CallerCalleeService
    {
        private static readonly string CS_ENDPOINT_NAME = "com754-cs-endpoint";

        private string keyVaultName;
        private KeyVaultSecret csEndpoint;

        CommunicationIdentityClient communicationIdentity;

        // A padding interval to make the output more orderly.
        private int padding;
        private int semaphoreCount;
        public async Task<DefaultAzureCredential> Authenticate() {
            var credential = new DefaultAzureCredential();

            keyVaultName = await GetKeyVaultName(credential);
            var kvUri = "https://" + keyVaultName + ".vault.azure.net";

            var kvClient = new SecretClient(new Uri(kvUri), new DefaultAzureCredential());
            csEndpoint = await kvClient.GetSecretAsync(CS_ENDPOINT_NAME);

            communicationIdentity = new CommunicationIdentityClient(new Uri(csEndpoint.Value), credential);

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

        public async Task StartSimulation(DefaultAzureCredential credential)
        {
            ArgumentNullException.ThrowIfNull(credential);
            var semaphore = new SemaphoreSlim(0, 4); // Limit to 4 concurrent tasks
            var dataset = Ioc.Default.GetRequiredService<DatasetService>().Dataset;
            var ongoingPhoneCalls = new Task[dataset.Count];
            int counter = 0;
            
            while (!dataset.IsEmpty)
            {
                ongoingPhoneCalls[counter] = Task.Run(async () =>
                {
                    DatasetEntry entry = null;
                    await semaphore.WaitAsync();
                    try
                    {
                        Interlocked.Add(ref padding, 100);

                        if (dataset.TryDequeue(out entry))
                        {
                            var callerIdentity = await communicationIdentity.CreateUserAndTokenAsync(scopes: [CommunicationTokenScope.VoIP]);
                            var calleeIdentity = await communicationIdentity.CreateUserAndTokenAsync(scopes: [CommunicationTokenScope.VoIPJoin]);

                            var phoneCall = new PhoneCall(callerIdentity.Value.AccessToken.Token, calleeIdentity.Value.AccessToken.Token, entry);
                            await phoneCall.DialUp();
                            counter += 1;
                            entry = null;
                        }
                    }
                    catch (Exception ex) 
                    {
                        WeakReferenceMessenger.Default.Send(
                            new SimulationNotification.DatasetEntryFailed(
                                new Exception(ex.Message, ex.InnerException)
                                {
                                    Source = entry is null ? ex.Source : entry.Name
                                }
                            )
                        );
                    }
                    finally
                    {
                        semaphoreCount = semaphore.Release();
                    }
                });
            }

            //semaphore.Release();
            await Task.WhenAll(ongoingPhoneCalls);
        }
    }
}
