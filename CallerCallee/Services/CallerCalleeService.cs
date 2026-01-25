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
using System.Collections.Concurrent;
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
        public async Task<DefaultAzureCredential> Authenticate()
        {
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

        private async Task RunPhoneCallAsync(
            CommunicationUserIdentifierAndToken caller,
            CommunicationUserIdentifierAndToken callee,
            SemaphoreSlim semaphore,
            ConcurrentQueue<DatasetEntry> dataset
        )
        {
            DatasetEntry entry = null;
            await semaphore.WaitAsync();
            try
            {
                if (dataset.TryDequeue(out entry))
                {
                    var phoneCall = new PhoneCall(caller, callee, entry);
                    await phoneCall.DialUp();
                }
            }
            finally
            {
                semaphore.Release();
            }
        }

        public async Task StartSimulation(DefaultAzureCredential credential)
        {
            ArgumentNullException.ThrowIfNull(credential);

            var semaphore = new SemaphoreSlim(1, 1);
            var dataset = Ioc.Default.GetRequiredService<DatasetService>().Dataset;

            var tasks = new List<Task>();

            while (!dataset.IsEmpty)
            {
                var caller = await communicationIdentity
                    .CreateUserAndTokenAsync([CommunicationTokenScope.VoIP]);

                var callee = await communicationIdentity
                    .CreateUserAndTokenAsync([CommunicationTokenScope.VoIPJoin]);

                tasks.Add(RunPhoneCallAsync(caller, callee, semaphore, dataset));
            }

            await Task.WhenAll(tasks);
        }

    }
}
