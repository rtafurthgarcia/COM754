using Azure.Communication.Identity;
using Azure.Identity;
using Azure.Security.KeyVault.Secrets;
using CallerCallee.Models;
using CommunityToolkit.Mvvm.DependencyInjection;
using System;
using System.Collections.Concurrent;
using System.Diagnostics;
using System.Threading;
using System.Threading.Tasks;

namespace CallerCallee.Services
{
    public sealed class CallerCalleeService
    {
        private CommunicationIdentityClient communicationIdentity;
        private SemaphoreSlim semaphore;
        private readonly AuthenticationService authenticationService = Ioc.Default.GetRequiredService<AuthenticationService>();
        private readonly AudioService audioService = Ioc.Default.GetRequiredService<AudioService>();
        private readonly DatasetService datasetService = Ioc.Default.GetRequiredService<DatasetService>();
        private readonly ConcurrentDictionary<DatasetEntry, int> retries = [];

        public async Task StartSimulation(int maxAmountOfParallelCalls)
        {
            var csEndpoint = authenticationService.KeyVault.GetSecret(AuthenticationService.CS_ENDPOINT_NAME).Value;
            communicationIdentity = new CommunicationIdentityClient(new Uri(csEndpoint.Value), authenticationService.Credential);
            ArgumentNullException.ThrowIfNull(authenticationService.Credential);

            semaphore = new SemaphoreSlim(maxAmountOfParallelCalls, maxAmountOfParallelCalls);
            Debug.WriteLine($"Running simulation on {datasetService.TodoDataset.Count} calls.");

            DatasetEntry callEntry = null;
            int? callerDevice = null;
            int? calleeDevice = null;
            CommunicationUserIdentifierAndToken caller = null;
            CommunicationUserIdentifierAndToken callee = null;

            while (!datasetService.TodoDataset.IsEmpty) 
            {
                if (callEntry is null)
                {
                    if (!datasetService.TodoDataset.TryDequeue(out callEntry))
                        continue;
                }

                if (callerDevice is null)
                {
                    if (!audioService.GetAvailableDevice(out callerDevice))
                        continue;
                }

                if (calleeDevice is null)
                {
                    if (!audioService.GetAvailableDevice(out calleeDevice))
                        continue;
                }

                caller ??= await communicationIdentity.CreateUserAndTokenAsync([CommunicationTokenScope.VoIP]);
                callee ??= await communicationIdentity.CreateUserAndTokenAsync([CommunicationTokenScope.VoIP]);

                try
                {
                    await semaphore.WaitAsync();

                    var phoneCall = new PhoneCall(
                        caller,
                        callee,
                        (int)callerDevice,
                        (int)calleeDevice,
                        callEntry
                    );
                    phoneCall.OnEndOfCall += CallEnded;
                    callEntry.State = State.Ongoing;
                    await phoneCall.DialUp();
                    datasetService.DoneDataset.TryAdd(phoneCall.Guid, callEntry);
                }
                catch (Exception e)
                {
                    Debug.WriteLine($"{callEntry.Id}: Error during call init: {e}");
                    semaphore.Release();
                    audioService.TryFreeDevice((int)calleeDevice);
                    audioService.TryFreeDevice((int)callerDevice);

                    if (retries.TryGetValue(callEntry, out var retryCount) && retryCount >= 3)
                    {
                        Debug.WriteLine($"{callEntry.Id}: Reached max retry count. Skipping call.");
                        callEntry.Exception = e;
                        callEntry.State = State.Failed;
                        datasetService.DoneDataset.TryAdd(Guid.NewGuid(), callEntry);
                    }
                    else
                    {
                        datasetService.TodoDataset.Enqueue(callEntry);
                        retries.AddOrUpdate(
                            callEntry,
                            1,
                            (_, current) => current + 1
                        );
                    }
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

        private void CallEnded(object source, EventArgs e)
        {
            if (source is PhoneCall phoneCall)
            {
                phoneCall.OnEndOfCall -= CallEnded;
                semaphore.Release();
                Debug.WriteLine($"{phoneCall.Entry.Id}: Call ended after {(int)(DateTime.Now - phoneCall.Caller.Call.StartTime).TotalSeconds}s.");

                audioService.TryFreeDevice(phoneCall.Caller.AudioDeviceNumber);
                audioService.TryFreeDevice(phoneCall.Callee.AudioDeviceNumber);
            }
            //Console.WriteLine("The Elapsed event was raised at {0}", e.SignalTime);
        }
    }
}
