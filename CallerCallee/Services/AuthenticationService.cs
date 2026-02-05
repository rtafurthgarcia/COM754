using Azure.Identity;
using Azure.ResourceManager;
using Azure.ResourceManager.KeyVault;
using Azure.Security.KeyVault.Secrets;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CallerCallee.Services
{
    internal class AuthenticationService
    {
        public static readonly string CS_ENDPOINT_NAME = "com754-cs-endpoint";
        public static readonly string SB_CONNECTION_STRING = "com754-sb-connectionstring";

        private string keyVaultName;
        private DefaultAzureCredential credential;
        private SecretClient kvClient;

        public SecretClient KeyVault { 
            get { return kvClient; }
        }

        public DefaultAzureCredential Credential { 
            get { return credential; }
        }

        public async Task<DefaultAzureCredential> AuthenticateAsync()
        {
            credential = new DefaultAzureCredential();
            keyVaultName ??= await GetKeyVaultNameAsync(credential);
            var kvUri = "https://" + keyVaultName + ".vault.azure.net";
            kvClient = new SecretClient(new Uri(kvUri), credential);

            return credential;
        }

        private static async Task<string> GetKeyVaultNameAsync(DefaultAzureCredential credential)
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
    }
}
