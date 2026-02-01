using Azure.Communication.Identity;
using Azure.Identity;
using Azure.ResourceManager;
using Azure.ResourceManager.KeyVault;
using Azure.Security.KeyVault.Secrets;
using CallerCallee.Models;
using CommunityToolkit.Mvvm.DependencyInjection;
using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Windows.ApplicationModel.Calls;
using Windows.Media.Protection.PlayReady;

namespace CallerCallee.Services
{
    public sealed class CallerCalleeService
    {
        private static readonly string CS_ENDPOINT_NAME = "com754-cs-endpoint";

        private string keyVaultName;
        private KeyVaultSecret csEndpoint;

        private CommunicationIdentityClient communicationIdentity;
        private SemaphoreSlim semaphore;

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

        public async Task StartSimulation(DefaultAzureCredential credential, int maxAmountOfParallelCalls)
        {
            ArgumentNullException.ThrowIfNull(credential);

            semaphore = new SemaphoreSlim(maxAmountOfParallelCalls, maxAmountOfParallelCalls);
            var dataset = Ioc.Default.GetRequiredService<DatasetService>().Dataset;
            Debug.WriteLine($"Running simulation on {dataset.Count} calls.");

            DatasetEntry callEntry = null;
            int? callerDevice = null;
            int? calleeDevice = null;
            CommunicationUserIdentifierAndToken caller = null;
            CommunicationUserIdentifierAndToken callee = null;

            while (!dataset.IsEmpty) 
            {
                if (callEntry is null)
                {
                    if (! dataset.TryDequeue(out callEntry))
                        continue;
                }

                if (callerDevice is null)
                {
                    if (!Ioc.Default.GetRequiredService<AudioService>().GetAvailableDevice(out callerDevice))
                        continue;
                }

                if (calleeDevice is null)
                {
                    if (!Ioc.Default.GetRequiredService<AudioService>().GetAvailableDevice(out calleeDevice))
                        continue;
                }

                if (caller is null)
                {
                    caller = await communicationIdentity.CreateUserAndTokenAsync([CommunicationTokenScope.VoIP]);
                }

                if (callee is null)
                {
                    callee = await communicationIdentity.CreateUserAndTokenAsync([CommunicationTokenScope.VoIP]);
                }

                try
                {
                    await semaphore.WaitAsync();

                    var phoneCall = new Models.PhoneCall(
                        caller,
                        callee,
                        (int)callerDevice,
                        (int)calleeDevice,
                        callEntry
                    );
                    phoneCall.OnEndOfCall += CallEnded;
                    await phoneCall.DialUp();
                }
                catch (Exception e)
                {
                    Debug.WriteLine($"{callEntry.Name}: Error during call init: {e}");
                    semaphore.Release();

                    Ioc.Default.GetRequiredService<AudioService>().TryFreeDevice((int)calleeDevice);
                    Ioc.Default.GetRequiredService<AudioService>().TryFreeDevice((int)callerDevice);
                } 
                finally
                {
                    caller = null;
                    callee = null;
                    callerDevice = null;
                    calleeDevice = null;
                    callEntry = null;
                }
            }

            Debug.WriteLine("End of process");
        }

        private void CallEnded(Object source, EventArgs e)
        {
            if (source is Models.PhoneCall phoneCall)
            {
                phoneCall.OnEndOfCall -= CallEnded;
                semaphore.Release();
                Debug.WriteLine($"{phoneCall.Entry.Name}: Call ended after {(int)(DateTime.Now - phoneCall.caller.Call.StartTime).TotalSeconds}s.");

                Ioc.Default.GetRequiredService<AudioService>().TryFreeDevice(phoneCall.caller.AudioDeviceNumber);
                Ioc.Default.GetRequiredService<AudioService>().TryFreeDevice(phoneCall.callee.AudioDeviceNumber);
            }
            //Console.WriteLine("The Elapsed event was raised at {0}", e.SignalTime);
        }
    }
}
