#from concurrent.futures import ThreadPoolExecutor
from operator import truediv
import os 
import csv
from azure.keyvault.secrets import SecretClient
from azure.identity import DefaultAzureCredential
from azure.core.credentials import AccessToken
from azure.communication.callautomation import CallAutomationClient, CallConnectionClient, TranscriptionOptions
from azure.communication.identity import CommunicationIdentityClient
from azure.servicebus.aio import ServiceBusClient
from azure.core.exceptions import ServiceResponseError
from common import CallStarted, IncomingCall, deserialise_event
import asyncio

class CallerCallee:
    PORT: int = 8081
    CS_KEY_NAME: str = "com754-cs-key"
    CS_ENDPOINT_NAME: str = "com754-cs-endpoint"
    SBUS_ENDPOINT_NAME: str = "com754-sbus-endpoint"
    SBUS_CONNECTION_STRING_NAME: str = "com754-sbus-connectionstring"
    DT_ENDPOINT_NAME: str = "com754-dt-endpoint"
    AI_ENDPOINT_NAME: str = "com754-ai-endpoint"
    QUEUE = "calls"

    def __init__(self):
        keyvault_name = os.environ["KEY_VAULT_NAME"]

        # URI for accessing key vault
        keyvault_uri = f"https://{keyvault_name}.vault.azure.net"

        # Instantiate the client and retrieve secrets
        self.credential = DefaultAzureCredential()
        kv_client = SecretClient(vault_url=keyvault_uri, credential=self.credential)

        print(f"Retrieving your secrets from {keyvault_name}.")

        self.cs_endpoint = kv_client.get_secret(self.CS_ENDPOINT_NAME).value or ""
        self.cs_key = kv_client.get_secret(self.CS_KEY_NAME).value or ""
        self.sbus_endpoint = kv_client.get_secret(self.SBUS_ENDPOINT_NAME).value or ""
        self.sbus_connection_string = kv_client.get_secret(self.SBUS_CONNECTION_STRING_NAME).value or ""
        self.sbus_uri = self.sbus_endpoint + self.QUEUE
        self.local_endpoint = kv_client.get_secret(self.DT_ENDPOINT_NAME).value or ""
        self.ai_endpoint = kv_client.get_secret(self.AI_ENDPOINT_NAME).value or ""

        self._call_identity_client = CommunicationIdentityClient.from_connection_string(
            conn_str="endpoint={}/;accesskey={}".format(self.cs_endpoint, self.cs_key)
        )

        self._call_automation_client = CallAutomationClient(credential=self.credential, endpoint=self.cs_endpoint)
        self._ongoing_calls = []
    
    def join_call(self, call: CallStarted):
        accepted_call = self._call_automation_client.connect_call(
            group_call_id=call.group_id,
            callback_url=f"https://{self.local_endpoint}calls",
            transcription=TranscriptionOptions(
                transport_url="wss://{self.local_endpoint}transcription",
                transport_type="WEBSOCKET",
                locale="en-US",
                start_transcription=True,
                speech_recognition_model_endpoint_id = "gpt-4o-mini-transcribe"
            ),
            cognitive_services_endpoint=self.ai_endpoint)

        if (accepted_call.call_connection_id is None):
            raise ServiceResponseError("No call connection ID found")

        self._ongoing_calls.append(self._call_automation_client.get_call_connection(accepted_call.call_connection_id))
    
    async def start(self):
        self._call_identity_client.create_user()

        async with ServiceBusClient.from_connection_string(
            conn_str=self.sbus_connection_string
        ) as servicebus_client:
            async with servicebus_client:
                # get the Queue Receiver object for the queue
                receiver = servicebus_client.get_queue_receiver(queue_name=self.QUEUE, )
                async with receiver:
                    while(True):
                        for message in await receiver.receive_messages():   
                            try:     
                                await self.process_message(receiver, message)
                            except:
                                print(f"Error with {message.message_id}")

    async def process_message(self, receiver, message):
        event = deserialise_event(message.body)

        if isinstance(event, CallStarted):
            self.join_call(event)

        await receiver.complete_message(message)



app = CallerCallee()
with asyncio.Runner() as runner:
    runner.run(app.start())