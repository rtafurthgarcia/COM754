using Azure.Communication.Identity;
using CallerCallee.Models;
using CommunityToolkit.Mvvm.DependencyInjection;
using CommunityToolkit.Mvvm.Messaging;
using System;
using System.Collections.Concurrent;
using System.Diagnostics;
using System.Threading;
using System.Threading.Tasks;
using static CallerCallee.Models.SystemwideMessage;
using static CallerCallee.Services.AudioService;

namespace CallerCallee.Services
{
    public sealed class CallerCalleeService
    {
        private SemaphoreSlim semaphore;
        private readonly AuthenticationService authenticationService = Ioc.Default.GetRequiredService<AuthenticationService>();
        private readonly AudioService audioService = Ioc.Default.GetRequiredService<AudioService>();
        private readonly DatasetService datasetService = Ioc.Default.GetRequiredService<DatasetService>();
        private readonly ConcurrentDictionary<DatasetEntry, int> retries = [];
        public readonly ConcurrentDictionary<string, Speaker> usedIds = [];
        
        public async Task StartSimulation(int maxAmountOfParallelCalls)
        {
            retries.Clear();
            var connectionString = authenticationService.KeyVault.GetSecret(AuthenticationService.CS_CONNECTION_STRING).Value;
            var communicationIdentity = new CommunicationIdentityClient(connectionString.Value);
            semaphore = new SemaphoreSlim(maxAmountOfParallelCalls, maxAmountOfParallelCalls);
            Debug.WriteLine($"Running simulation on {datasetService.TodoDataset.Count} calls.");

            DatasetEntry callEntry = null;
            int? callerDevice = null;
            int? calleeDevice = null;
            PhoneCall phoneCall = null;

            while (!datasetService.TodoDataset.IsEmpty) 
            {
                await semaphore.WaitAsync();

                CommunicationUserIdentifierAndToken callerId = communicationIdentity.CreateUserAndToken([CommunicationTokenScope.VoIP]);
                CommunicationUserIdentifierAndToken calleeId = communicationIdentity.CreateUserAndToken([CommunicationTokenScope.VoIP]);

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

                try
                {
                    phoneCall = new PhoneCall(callerId, calleeId, (int)callerDevice, (int)calleeDevice, callEntry);
                    phoneCall.OnEndOfCall += CallEnded;
                    await phoneCall.DialUp();
                    usedIds.TryAdd(callerId.User.Id, Speaker.Caller); // to link who's been identified during deserialisation
                    usedIds.TryAdd(calleeId.User.Id, Speaker.Callee);
                }
                catch (VirtualMicrophoneNotFound)
                {
                    throw;
                }
                catch (Exception e)
                {
                    Debug.WriteLine($"{callEntry.Id}: Error during call init: {e}");
                    semaphore.Release();
                    audioService.TryFreeDevice((int)calleeDevice);
                    audioService.TryFreeDevice((int)callerDevice);
                    e.Source = callEntry.Id;
                    if (retries.TryGetValue(callEntry, out var retryCount) && retryCount >= 3)
                    {
                        Debug.WriteLine($"{callEntry.Id}: Reached max retry count. Skipping call.");
                        phoneCall.OnEndOfCall -= CallEnded;
                        WeakReferenceMessenger.Default.Send(
                            new CallInterrupted(
                                e
                            )
                        );
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
                    callerDevice = null;
                    calleeDevice = null;
                    callEntry = null;
                    phoneCall = null;
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
                
                Debug.WriteLine($"{phoneCall.DatasetEntry.Id}: Call ended after {(int)(DateTime.Now - phoneCall.Caller.Call.StartTime).TotalSeconds}s.");

                audioService.TryFreeDevice(phoneCall.Caller.AudioDeviceNumber);
                audioService.TryFreeDevice(phoneCall.Callee.AudioDeviceNumber);
            }
            //Console.WriteLine("The Elapsed event was raised at {0}", e.SignalTime);
        }
    }
}
