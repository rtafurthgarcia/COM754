import os 
from azure.keyvault.secrets import SecretClient
from azure.identity import DefaultAzureCredential
import azure.cognitiveservices.speech as speechsdk
from collections import OrderedDict
from openai import OpenAI
from azure.communication.callautomation import CallAutomationClient, CommunicationIdentifier
from azure.communication.identity import CommunicationIdentityClient, CommunicationUserIdentifier

class CallerCallee:
    def __init__(self):
        keyvault_name = os.environ["KEY_VAULT_NAME"]

        # Set these variables to the names you created for your secrets
        SS_KEY_SECRET_NAME = "com754-ss-key"
        SS_ENDPOINT_SECRET_NAME = "com754-ss-endpoint"
        AI_KEY_SECRET_NAME = "com754-ai-key"
        AI_ENDPOINT_SECRET_NAME = "com754-ai-endpoint"
        CS_CONNECTION_STRING_NAME = "com754-cs-connectionstring"

        # URI for accessing key vault
        keyvault_uri = f"https://{keyvault_name}.vault.azure.net"

        # Instantiate the client and retrieve secrets
        credential = DefaultAzureCredential()
        kv_client = SecretClient(vault_url=keyvault_uri, credential=credential)

        print(f"Retrieving your secrets from {keyvault_name}.")

        retrieved_key = kv_client.get_secret(SS_KEY_SECRET_NAME).value
        retrieved_endpoint = kv_client.get_secret(SS_ENDPOINT_SECRET_NAME).value

        self.speech_client = speechsdk.SpeechConfig(subscription=retrieved_key, endpoint=retrieved_endpoint)

        retrieved_key = kv_client.get_secret(AI_KEY_SECRET_NAME).value
        retrieved_endpoint = kv_client.get_secret(AI_ENDPOINT_SECRET_NAME).value
        retrieved_connection = kv_client.get_secret(CS_CONNECTION_STRING_NAME).value or ""

        self.MODEL = "gpt-5-mini"
        self.ai_client = OpenAI(base_url=retrieved_endpoint, api_key=retrieved_key)

        self.cs_client = CommunicationIdentityClient.from_connection_string(conn_str=retrieved_connection)
    
    def _analyse_call_for_vishing_naive(self, conversation: OrderedDict):
        raise NotImplementedError
    
    def _analyse_call_for_vishing_enhanced(self, conversation: OrderedDict):
        raise NotImplementedError

    def initiate_calls_from(self, src: str):
        visher_identifier, visher_token = self.cs_client.create_user_and_token(["voip"])
        victim_identifier, victim_token = self.cs_client.create_user_and_token(["voip"])

        visher = CommunicationUserIdentifier(id=visher_identifier.raw_id)
        victim = CommunicationUserIdentifier(id=visher_identifier.raw_id)

app = CallerCallee()
app.initiate_calls_from("")