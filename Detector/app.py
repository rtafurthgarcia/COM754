from ast import Call
import logging
from logging.config import dictConfig
from fastapi import FastAPI, WebSocket, WebSocketDisconnect, Request, Response, WebSocketException, websockets
from fastapi.responses import JSONResponse
from rich.status import Status
from uvicorn.config import LOGGING_CONFIG
from common import Acknowledgment, CallEnded, CallStarted, SubscriptionValidation, deserialise_event, deserialise_ws_message
import uvicorn

from servicebus import ServiceBusListener

class ConnectionManager:
    def __init__(self):
        self.active_connections: list[WebSocket] = []
        self.runner_active = False

    async def connect(self, websocket: WebSocket):
        await websocket.accept()
        self.active_connections.append(websocket)

    def remove(self, websocket: WebSocket):
        self.active_connections.remove(websocket)

app = FastAPI()
manager = ConnectionManager()
logger = logging.getLogger("uvicorn.error")
servicebus = ServiceBusListener()

@app.get("/ping")
async def pong_handler(request: Request):
    return Response(content="pong", status_code=200)

@app.post("/calls")
async def confirm_calls_handler(request: Request):
    events = await request.json()

    for raw_event in events:
        event = deserialise_event(raw_event)
        logger.info(f"{__name__}: received event of type {type(event)}")

        if isinstance(event, SubscriptionValidation):
            logger.info(f"{__name__}: Validating webhook with {event.validationCode}")
            return JSONResponse(
                content={"validationResponse": event.validationCode},
                status_code=200
            )

        if isinstance(event, CallStarted):
            logger.info(f"{__name__}: Joining call {event.group_id}")
            servicebus.join_call(event)

        if isinstance(event, CallEnded):
            logger.info(f"{__name__}: Leaving call {event.group_id}")
            servicebus.leave_call(event)

        if isinstance(event, Acknowledgment):
            logger.info(f"{__name__}: Received acknowledgment of type {event.type}")

    return Response(status_code=200)

@app.websocket("/ws")
async def transcription_handler(websocket: WebSocket):
    await manager.connect(websocket)
    logger.info(f"{__name__}: connection received from {websocket.client or "unknown host?"}")
    try:
        while True:
            data = await websocket.receive_text()
            event = deserialise_ws_message(data)    
            logger.info(f"{__name__}: received event of type {type(event)}")
        
    except WebSocketDisconnect:
        logger.info(f"{__name__}: disconnected")
    except Exception as e:
        logger.info(f"{__name__}: closed unexpectedly due to an error: {e}")
    finally:
        manager.remove(websocket)

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000,  ws_ping_interval=2, ws_ping_timeout=60)