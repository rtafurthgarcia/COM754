#from concurrent.futures import ThreadPoolExecutor
import os 
import csv
from azure.keyvault.secrets import SecretClient
from azure.identity import DefaultAzureCredential
from azure.core.credentials import AccessToken
from azure.communication.callautomation import CallAutomationClient, TranscriptionOptions
from azure.communication.identity import CommunicationIdentityClient
from azure.servicebus.aio import ServiceBusClient
from azure.core.exceptions import ServiceResponseError
from common import IncomingCall, deserialise_event
import asyncio

class CallerCallee:
    PORT: int = 8081
    CS_KEY_NAME: str = "com754-cs-key"
    CS_ENDPOINT_NAME: str = "com754-cs-endpoint"
    SBUS_ENDPOINT_NAME: str = "com754-sbus-endpoint"
    SBUS_CONNECTION_STRING_NAME: str = "com754-sbus-connectionstring"
    QUEUE = "calls"

    def __init__(self):

        # there is an upper limit due to the max throughpout the dev tunnel allows
        # which is 20mb/s
        #self.executor = ThreadPoolExecutor(max_workers=4)
        
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

        self._call_identity_client = CommunicationIdentityClient.from_connection_string(
            conn_str="endpoint={}/;accesskey={}".format(self.cs_endpoint, self.cs_key)
        )

        self._call_automation_client = CallAutomationClient(credential=self.credential, endpoint=self.cs_endpoint)
    
    def handle_call(self, call: IncomingCall):
        accepted_call = self._call_automation_client.answer_call(
            call.incomingCallContext, 
            callback_url=self.sbus_uri)

        if (accepted_call.call_connection_id is None):
            raise ServiceResponseError("No call connection ID found")

        call_connection = self._call_automation_client.get_call_connection(accepted_call.call_connection_id)
        #call_connection.play_media()

    def parse_dataset(self, path: str):
        with open(os.path.join("dataset", "Source.csv"), newline='') as csvfile:
            reader = csv.reader(csvfile, delimiter=';', quotechar='|')
            for row in reader:
                if reader.line_num == 1:
                    continue

                if row[0] == '': #eol
                    break

                path = os.path.join("dataset", "v", row[0]) if int(row[2]) == 1 else os.path.join("dataset", "nv", row[0])

    
    async def start_calls(self, dataset_path: str):
        self.leftover_calls = self.parse_dataset(dataset_path)

        callee_identifier = self._call_identity_client.create_user()

        self._call_automation_client.create_call(
            target_participant=callee_identifier, # type: ignore
            callback_url=self.sbus_uri
        )

        async with ServiceBusClient.from_connection_string(
            conn_str=self.sbus_connection_string
        ) as servicebus_client:
            async with servicebus_client:
                # get the Queue Receiver object for the queue
                receiver = servicebus_client.get_queue_receiver(queue_name=self.QUEUE)
                async with receiver:
                    received_msgs = await receiver.receive_messages(max_wait_time=5, max_message_count=20)
                    for message in received_msgs:        
                        event = deserialise_event(message.body)

                        if isinstance(event, IncomingCall):
                            self.handle_call(event)

                        await receiver.complete_message(message)



app = CallerCallee()
with asyncio.Runner() as runner:
    runner.run(app.start_calls(""))