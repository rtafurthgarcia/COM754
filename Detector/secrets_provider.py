from dataclasses import dataclass
from azure.keyvault.secrets import SecretClient
from azure.identity import DefaultAzureCredential
import os

@dataclass(frozen=True)
class AppSecrets:
    cs_endpoint: str
    cs_key: str
    sb_endpoint: str
    sb_connectionstring: str
    dt_endpoint: str
    sm_endpoint: str
    ai_endpoint: str
    ai_key: str

class KeyVaultSecretsProvider:
    def __init__(self):
        keyvault_name = os.environ["KEY_VAULT_NAME"]
        vault_url = f"https://{keyvault_name}.vault.azure.net"

        credential = DefaultAzureCredential()
        self._client = SecretClient(vault_url=vault_url, credential=credential)

    def load(self) -> AppSecrets:
        return AppSecrets(
            cs_endpoint=self._client.get_secret("com754-cs-endpoint").value or "",
            cs_key=self._client.get_secret("com754-cs-key").value or "",
            dt_endpoint=self._client.get_secret("com754-dt-endpoint").value or "",
            ai_endpoint=self._client.get_secret("com754-new-ai-endpoint").value or "",
            sm_endpoint=self._client.get_secret("com754-sm-endpoint").value or "",
            ai_key=self._client.get_secret("com754-ai-key").value or "",
            sb_endpoint=self._client.get_secret("com754-sb-endpoint").value or "",
            sb_connectionstring=self._client.get_secret("com754-sb-connectionstring").value or "",
        )
