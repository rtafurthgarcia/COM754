using Azure.Communication.Identity;
using Azure.Identity;
using Azure.Security.KeyVault.Secrets;
using CallerCallee.Models;
using CommunityToolkit.Mvvm.DependencyInjection;
using System;
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

        CallerCalleeService() 
        {
            var csEndpoint = authenticationService.KeyVault.GetSecret(AuthenticationService.CS_ENDPOINT_NAME).Value;
            communicationIdentity = new CommunicationIdentityClient(new Uri(csEndpoint.Value), authenticationService.Credential);
        }       

        public async Task StartSimulation(int maxAmountOfParallelCalls)
        {
            ArgumentNullException.ThrowIfNull(authenticationService.Credential);

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
                    if (!audioService.GetAvailableDevice(out callerDevice))
                        continue;
                }

                if (calleeDevice is null)
                {
                    if (!audioService.GetAvailableDevice(out calleeDevice))
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

                    audioService.TryFreeDevice((int)calleeDevice);
                    audioService.TryFreeDevice((int)callerDevice);
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

                audioService.TryFreeDevice(phoneCall.caller.AudioDeviceNumber);
                audioService.TryFreeDevice(phoneCall.callee.AudioDeviceNumber);
            }
            //Console.WriteLine("The Elapsed event was raised at {0}", e.SignalTime);
        }
    }
}
