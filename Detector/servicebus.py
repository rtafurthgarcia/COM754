
import logging
import os
from azure.keyvault.secrets import SecretClient
from azure.identity import DefaultAzureCredential
from azure.communication.callautomation import CallAutomationClient, CallConnectionClient, TranscriptionOptions
from azure.communication.identity import CommunicationIdentityClient
from azure.core.exceptions import ServiceResponseError
from common import CallEnded, CallStarted

class ServiceBusListener:
    CS_KEY_NAME: str = "com754-cs-key"
    CS_ENDPOINT_NAME: str = "com754-cs-endpoint"
    SBUS_ENDPOINT_NAME: str = "com754-sbus-endpoint"
    SBUS_CONNECTION_STRING_NAME: str = "com754-sbus-connectionstring"
    DT_ENDPOINT_NAME: str = "com754-dt-endpoint"
    AI_ENDPOINT_NAME: str = "com754-ai-endpoint"
    QUEUE = "calls"

    def __init__(self):
        keyvault_name = os.environ["KEY_VAULT_NAME"] or "com754-kv"
        self.logger = logging.getLogger("uvicorn.error")
        # URI for accessing key vault
        keyvault_uri = f"https://{keyvault_name}.vault.azure.net"

        # Instantiate the client and retrieve secrets
        self.credential = DefaultAzureCredential()
        kv_client = SecretClient(vault_url=keyvault_uri, credential=self.credential)

        self.logger.info(f"{__name__}: Retrieving your secrets from {keyvault_name}.")

        self.cs_endpoint = kv_client.get_secret(self.CS_ENDPOINT_NAME).value or ""
        self.cs_key = kv_client.get_secret(self.CS_KEY_NAME).value or ""
        self.sbus_endpoint = kv_client.get_secret(self.SBUS_ENDPOINT_NAME).value or ""
        self.sbus_connection_string = kv_client.get_secret(self.SBUS_CONNECTION_STRING_NAME).value or ""
        self.sbus_uri = self.sbus_endpoint + self.QUEUE
        self.local_endpoint = kv_client.get_secret(self.DT_ENDPOINT_NAME).value or ""
        self.ai_endpoint = kv_client.get_secret(self.AI_ENDPOINT_NAME).value or ""

        self._call_identity_client = CommunicationIdentityClient.from_connection_string(
            conn_str=f"endpoint={self.cs_endpoint}/;accesskey={self.cs_key}"
        )

        self._call_automation_client = CallAutomationClient(
            credential=self.credential, 
            endpoint=self.cs_endpoint
        )
        self._ongoing_calls : dict[str, CallConnectionClient] = {}
    
    def join_call(self, call: CallStarted):
        accepted_call = self._call_automation_client.connect_call(
            group_call_id=call.group_id,
            callback_url=f"https://{self.local_endpoint}/calls",
            transcription=TranscriptionOptions(
                transport_url=f"wss://{self.local_endpoint}/ws",
                transport_type="websocket",
                locale="en-US",
                start_transcription=True,
                enable_intermediate_results=False,
                pii_redaction=None, 
                enable_sentiment_analysis=False,
                speech_recognition_model_endpoint_id="azureml://registries/azure-openai/models/gpt-4o-mini-transcribe/versions/2025-12-15"
            ),
            cognitive_services_endpoint=self.ai_endpoint)

        if (accepted_call.call_connection_id is None):
            self.logger.error(f"{__name__}: No call connection ID found")
            raise ServiceResponseError(f"{__name__}: No call connection ID found")

        self._ongoing_calls[call.group_id] = self._call_automation_client.get_call_connection(accepted_call.call_connection_id)

    def leave_call(self, call: CallEnded):
        if call.group_id not in self._ongoing_calls:
            self.logger.error(f"{__name__}: Call with group ID {call.group_id} not found among ongoing calls")
            return

        call_connection = self._ongoing_calls[call.group_id]
        call_connection.hang_up(is_for_everyone=True)
        del self._ongoing_calls[call.group_id]