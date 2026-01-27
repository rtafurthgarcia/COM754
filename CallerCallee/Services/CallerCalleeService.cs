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

namespace CallerCallee.Services
{
    public sealed class CallerCalleeService
    {
        private static readonly string CS_ENDPOINT_NAME = "com754-cs-endpoint";

        private string keyVaultName;
        private KeyVaultSecret csEndpoint;

        private CommunicationIdentityClient communicationIdentity;
        private ConcurrentStack<CommunicationUserIdentifierAndToken> availableCredentials;
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

            availableCredentials = new ConcurrentStack<CommunicationUserIdentifierAndToken>();
            Debug.WriteLine($"Generating {maxAmountOfParallelCalls} pairs of credentials.");
            await Task.WhenAll(
                Enumerable
                    .Range(0, (maxAmountOfParallelCalls * 2))
                    .AsParallel()
                    .Select(async i =>
                    {
                        availableCredentials.Push(await communicationIdentity.CreateUserAndTokenAsync([CommunicationTokenScope.VoIP]));
                        Debug.WriteLine($"{i} generated.");
                        return i;
                    })
            );

            semaphore = new SemaphoreSlim(maxAmountOfParallelCalls, maxAmountOfParallelCalls);
            var dataset = Ioc.Default.GetRequiredService<DatasetService>().Dataset;
            Debug.WriteLine($"Running simulation on {dataset.Count} calls.");
            do
            {
                while (dataset.TryDequeue(out DatasetEntry callEntry)) 
                {
                    await semaphore.WaitAsync();
                    var popOk1 = availableCredentials.TryPop(out CommunicationUserIdentifierAndToken caller);
                    var popOk2 = availableCredentials.TryPop(out CommunicationUserIdentifierAndToken callee);
                    int callerDevice = Ioc.Default.GetRequiredService<AudioService>().GetAvailableDevice();
                    int calleeDevice = Ioc.Default.GetRequiredService<AudioService>().GetAvailableDevice();

                    try
                    {
                        if (popOk1  && popOk2)
                        {
                            var phoneCall = new Models.PhoneCall(caller, callee, callerDevice, calleeDevice, callEntry);
                            phoneCall.OnEndOfCall += CallEnded;
                            await phoneCall.DialUp();
                        } 
                        else
                        {
                            semaphore.Release();
                            Ioc.Default.GetRequiredService<AudioService>().TryFreeDevice(calleeDevice);
                            Ioc.Default.GetRequiredService<AudioService>().TryFreeDevice(callerDevice);
                        }
                    }
                    catch (Exception)
                    {
                        semaphore.Release();
                        availableCredentials.Push(caller);
                        availableCredentials.Push(callee);
                        Ioc.Default.GetRequiredService<AudioService>().TryFreeDevice(calleeDevice);
                        Ioc.Default.GetRequiredService<AudioService>().TryFreeDevice(callerDevice);
                    }
                }
            }
            while (!dataset.IsEmpty && availableCredentials.Count >= 2);
        }

        private void CallEnded(Object source, EventArgs e)
        {
            if (source is Models.PhoneCall phoneCall)
            {
                phoneCall.OnEndOfCall -= CallEnded;
                semaphore.Release();
                Debug.WriteLine($"{phoneCall.Entry.Name}: Call ended after {(int)(DateTime.Now - phoneCall.StartTime).TotalSeconds} seconds");

                availableCredentials.Push(phoneCall.callee.IdentifierAndToken);
                availableCredentials.Push(phoneCall.caller.IdentifierAndToken);
                Ioc.Default.GetRequiredService<AudioService>().TryFreeDevice(phoneCall.caller.AudioDeviceNumber);
                Ioc.Default.GetRequiredService<AudioService>().TryFreeDevice(phoneCall.callee.AudioDeviceNumber);
            }
            //Console.WriteLine("The Elapsed event was raised at {0}", e.SignalTime);
        }
    }
}
