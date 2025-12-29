import os 
from helper import start_dev_tunnel
from azure.keyvault.secrets import SecretClient
from azure.identity import DefaultAzureCredential
from azure.communication.callautomation import CallAutomationClient, CallConnectionClient
from azure.communication.identity import CommunicationIdentityClient 
from uuid import uuid4

class CallerCallee:
    def __init__(self):
        keyvault_name = os.environ["KEY_VAULT_NAME"]

        # Set these variables to the names you created for your secrets
        CS_KEY_NAME = "com754-cs-key"
        CS_ENDPOINT_NAME = "com754-cs-endpoint"

        # URI for accessing key vault
        keyvault_uri = f"https://{keyvault_name}.vault.azure.net"

        # Instantiate the client and retrieve secrets
        self.credential = DefaultAzureCredential()
        kv_client = SecretClient(vault_url=keyvault_uri, credential=self.credential)

        print(f"Retrieving your secrets from {keyvault_name}.")

        self.cs_endpoint = kv_client.get_secret(CS_ENDPOINT_NAME).value or ""
        self.cs_key = kv_client.get_secret(CS_KEY_NAME).value or ""

        self.call_identity_client = CommunicationIdentityClient.from_connection_string(
            conn_str="endpoint={}/;accesskey={}".format(self.cs_endpoint, self.cs_key)
        )

        self.local_uri = start_dev_tunnel()

    def initiate_call(self) -> CallConnectionClient:
        caller_identifier, caller_token = self.call_identity_client.create_user_and_token(["voip"])
        callee_identifier, callee_token = self.call_identity_client.create_user_and_token(["voip"])

        caller_callback_url = "http:/{}//calls/{}".format(self.local_uri, uuid4())
        callee_callback_url = "http:/{}//calls/{}".format(self.local_uri, uuid4())

        self.call_automation_client = CallAutomationClient(credential=self.credential, endpoint=self.cs_endpoint)
        call = self.call_automation_client.create_call(
            target_participant=callee_identifier,  # type: ignore
            callback_url=caller_callback_url
        )
        
        if (call.call_connection_id is None):
            raise Exception("Couldn't obtain call connection details")

        call_connection = self.call_automation_client.get_call_connection(call.call_connection_id)
        #self.call_automation_client.


        return call_connection

app = CallerCallee()
app.initiate_call()