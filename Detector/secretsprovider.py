from dataclasses import dataclass
from azure.keyvault.secrets import SecretClient
from azure.identity import DefaultAzureCredential
import os

@dataclass(frozen=True)
class AppSecrets:
    cs_endpoint: str
    cs_key: str
    sbus_endpoint: str
    sbus_connection_string: str
    dt_endpoint: str
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
            sbus_endpoint=self._client.get_secret("com754-sbus-endpoint").value or "",
            sbus_connection_string=self._client.get_secret("com754-sbus-connectionstring").value or "",
            dt_endpoint=self._client.get_secret("com754-dt-endpoint").value or "",
            ai_endpoint=self._client.get_secret("com754-ai-endpoint").value or "",
            ai_key=self._client.get_secret("com754-ai-key").value or "",
        )
