using Azure.Core;
using Azure.Identity;
using Azure.Security.KeyVault.Secrets;
using System;
using Azure.ResourceManager;
using Azure.ResourceManager.KeyVault;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Text;
using System.Threading.Tasks;

namespace CallerCallee.Services
{
    public sealed class CallerCalleeService
    {
        private static readonly string CS_KEY_NAME = "com754-cs-key";
        private static readonly string CS_ENDPOINT_NAME = "com754-cs-endpoint";
        private static readonly string SBUS_ENDPOINT_NAME = "com754-sbus-endpoint";
        private static readonly string SBUS_CONNECTION_STRING_NAME = "com754-sbus-connectionstring";

        private string? keyVaultName;
        private KeyVaultSecret? csEndpoint;

        public DefaultAzureCredential Authenticate() {
            DefaultAzureCredential credential = new();

            return credential;
        }

        //internal async Task<strin>

        public async Task StartCall(DefaultAzureCredential credential)
        {
            var armClient = new ArmClient(credential);
            
            //await foreach (var sub in armClient.GetSubscriptions().GetAllAsync())
            //{
            //    await foreach (var kv in sub.GetKeyVaultsAsync())
            //    {
            //        keyVaultName = kv.Data.Name;
            //        break;
            //    }
            //    if (keyVaultName is null)
            //    {
            //        break;
            //    }
            //}

            string keyVaultName = Environment.GetEnvironmentVariable("KEY_VAULT_NAME") ?? throw new AuthenticationFailedException(
                "No Key vault name found. Means the user is not properly authentified or doesn't have the right rights."
            );
            var kvUri = "https://" + keyVaultName + ".vault.azure.net";

            var kvClient = new SecretClient(new Uri(kvUri), new DefaultAzureCredential());

            csEndpoint = await kvClient.GetSecretAsync(CS_ENDPOINT_NAME);
        }
    }
}
