import asyncio
import contextlib
import os
from azure.keyvault.secrets import SecretClient
from azure.identity import DefaultAzureCredential
from azure.communication.callautomation import CallAutomationClient, CallConnectionClient, TranscriptionOptions
from azure.communication.identity import CommunicationIdentityClient
from azure.servicebus.aio import ServiceBusClient
from azure.core.exceptions import ServiceResponseError
from common import CallEnded, CallParticipantAdded, CallStarted, deserialise_event, deserialise_ws_message
import logging
from fastapi import FastAPI, WebSocket, WebSocketDisconnect, Request, Response, WebSocketException
import uvicorn
import weakref

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

        # URI for accessing key vault
        keyvault_uri = f"https://{keyvault_name}.vault.azure.net"

        # Instantiate the client and retrieve secrets
        self.credential = DefaultAzureCredential()
        kv_client = SecretClient(vault_url=keyvault_uri, credential=self.credential)

        logging.info(f"Retrieving your secrets from {keyvault_name}.")

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
            endpoint=self.cs_endpoint)
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
            logging.error("No call connection ID found")
            raise ServiceResponseError("No call connection ID found")

        self._ongoing_calls[call.group_id] = self._call_automation_client.get_call_connection(accepted_call.call_connection_id)
        
    async def start_bus_listener(self):
        self._call_identity_client.create_user()
        logging.info(f"Listening for group calls on {self.local_endpoint}")
        async with ServiceBusClient.from_connection_string(
            conn_str=self.sbus_connection_string
        ) as servicebus_client:
            async with servicebus_client:
                # get the Queue Receiver object for the queue
                receiver = servicebus_client.get_queue_receiver(queue_name=self.QUEUE)
                async with receiver:
                    while(True):
                        for message in await receiver.receive_messages():   
                            try:     
                                await self.process_message(message.body)
                            except Exception as e:
                                logging.info(f"Error from {message.message_id}: {e}")
                            finally:
                                await receiver.complete_message(message)

    async def process_message(self, body):
        event = deserialise_event(body)

        if isinstance(event, CallStarted):
            logging.info(f"Joining call {event.group_id}")
            self.join_call(event)

        if isinstance(event, CallEnded):
            logging.info(f"Call {event.group_id} ended")
            del self._ongoing_calls[event.group_id]

        if isinstance(event, CallParticipantAdded):
            logging.info(f"Participant added, joining")
            #self._ongoing_calls[event.group_id].start_transcription()

class ConnectionManager:
    def __init__(self):
        self.active_connections: list[WebSocket] = []
        self.runner_active = False

    async def connect(self, websocket: WebSocket):
        await websocket.accept()

        self.active_connections.append(websocket)

    def disconnect(self, websocket: WebSocket):
        self.active_connections.remove(websocket)

app = FastAPI()
logging.basicConfig(level=logging.INFO)

servicebus_task: asyncio.Task | None = None
websockets = weakref.WeakSet()
manager = ConnectionManager()

@app.on_event("startup")
async def startup_event():
    global servicebus_task
    listener = ServiceBusListener()
    servicebus_task = asyncio.create_task(listener.start_bus_listener())
    logging.info("ServiceBus listener started")

@app.on_event("shutdown")
async def shutdown_event():
    global servicebus_task

    for ws in list(websockets):
        await ws.close()

    if servicebus_task:
        servicebus_task.cancel()
        with contextlib.suppress(asyncio.CancelledError):
            await servicebus_task

@app.get("/ping")
async def pong_handler(request: Request):
    return Response(content="pong", status_code=200)

@app.post("/calls")
async def confirm_calls_handler(request: Request):
    return Response(status_code=200)

@app.websocket("/ws")
async def transcription_handler(websocket: WebSocket):
    await manager.connect(websocket)
    logging.info(f"WS: connection received from {websocket.client}")
    try:
        while True:
            data = await websocket.receive_text()
            logging.info("WS: reading data")
            event = deserialise_ws_message(data)    
            logging.info(f"WS: received event of type {type(event)}")
    except WebSocketDisconnect:
        manager.disconnect(websocket)
        logging.info("WebSocket disconnected")
    except WebSocketException as e:
        manager.disconnect(websocket)
        logging.info(f"WebSocket closed unexpectedly: {e}")
    finally:
        websockets.discard(websocket)

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000,  ws_ping_interval=2, ws_ping_timeout=60)