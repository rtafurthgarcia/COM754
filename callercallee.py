import os 
from helper import start_dev_tunnel, close_dev_tunnel
from azure.keyvault.secrets import SecretClient
from azure.identity import DefaultAzureCredential
from azure.core.credentials import AccessToken
from azure.communication.callautomation import CallAutomationClient, TranscriptionOptions
from azure.communication.identity import CommunicationIdentityClient, CommunicationUserIdentifier
from flask import Flask, Response, request, json, send_file, render_template, redirect
from azure.core.messaging import CloudEvent
import threading

class CallerCallee:
    PORT: int = 8081
    CS_KEY_NAME: str = "com754-cs-key"
    CS_ENDPOINT_NAME: str = "com754-cs-endpoint"
    LOCAL_ENDPOINT: str = "calls"
    ongoing_calls: dict = {}
    threads: list[threading.Thread] = []

    def __init__(self):
        self._webserver = Flask(__name__)
        # so that its not blocking
        # for normally, run is, but is also for local dev and normally not for production
        self.threads.append(
            threading.Thread(
                target=lambda: self._webserver.run(port=self.PORT, debug=True, use_reloader=False), 
                name="flask")
            #threading.Thread(target=self._webserver.run, name="flask", args=(self.PORT,))
        )

        keyvault_name = os.environ["KEY_VAULT_NAME"]

        # URI for accessing key vault
        keyvault_uri = f"https://{keyvault_name}.vault.azure.net"

        # Instantiate the client and retrieve secrets
        self.credential = DefaultAzureCredential()
        kv_client = SecretClient(vault_url=keyvault_uri, credential=self.credential)

        print(f"Retrieving your secrets from {keyvault_name}.")

        self.cs_endpoint = kv_client.get_secret(self.CS_ENDPOINT_NAME).value or ""
        self.cs_key = kv_client.get_secret(self.CS_KEY_NAME).value or ""

        self._call_identity_client = CommunicationIdentityClient.from_connection_string(
            conn_str="endpoint={}/;accesskey={}".format(self.cs_endpoint, self.cs_key)
        )
        self._local_uri, self._process = start_dev_tunnel("callercallee.pid", self.PORT)
        self._call_automation_client = CallAutomationClient(credential=self.credential, endpoint=self.cs_endpoint)
        self._webserver.add_url_rule(
            rule="/", 
            endpoint=self.LOCAL_ENDPOINT, 
            view_func=self._callback_events_handler, 
            methods=['POST'])
        
    def stop_neatly(self):
        close_dev_tunnel(self._process)

    def create_new_participant(self) -> tuple[CommunicationUserIdentifier, AccessToken]:
        """
        Return credentials for a new call participant. The last str of the tuple is the Callback address
        to receive or start calls from.
        
        :return: Description
        :rtype: tuple[CommunicationUserIdentifier, AccessToken, str]
        """
        identifier, token = self._call_identity_client.create_user_and_token(["voip"])

        return identifier, token
    
    def start_calls(self, dataset_path: str):
        caller_identifier, caller_token = self.create_new_participant()

        callback_url = "{}/{}".format(self._local_uri, self.LOCAL_ENDPOINT)
        self._webserver.logger.info("Starting call to " + caller_identifier.raw_id)
        self.threads.append(
            threading.Thread(
                target=lambda: self._call_automation_client.create_call(
                    target_participant=caller_identifier,              # type: ignore
                    callback_url=callback_url,
                    #cognitive_services_endpoint=self.cs_endpoint,
                    #transcription=TranscriptionOptions(
                    #    transport_url="WEBSOCKET_URI_HOST",
                    #    transport_type="websocket",
                    #    locale="en-US",
                    #    start_transcription=True,
                    #)
                ),
                name="call to " + caller_identifier.raw_id
            )
        )

        for thread in self.threads:
            thread.start()
        
        for thread in self.threads:
            thread.join()

    # POST endpoint to handle callback events
    def _callback_events_handler(self):
        for event_dict in request.json:
            # Parsing callback events
            event = CloudEvent.from_dict(event_dict)
            call_connection_id = event.data['callConnectionId'] # type: ignore
            self._webserver.logger.info("%s event received for call connection id: %s", event.type, call_connection_id)
            call_connection_client = self._call_automation_client.get_call_connection(call_connection_id)
            #if event.type == "Microsoft.Communication.CallConnected":  
            #    self.webserver.logger.info("Call connec")
            #    #self.call_automation_client.answer_call()

            self._webserver.logger.info(event.type)

            return Response(status=200)
        
        # if no other case
        return Response(status=500)


app = CallerCallee()
try:
    app.start_calls("")
finally:
    app.stop_neatly()