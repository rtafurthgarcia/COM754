from logging import Logger
import logging
from typing import Annotated
from unittest.mock import call
from fastapi import FastAPI, WebSocket, WebSocketDisconnect, Request, Response, Depends
from fastapi.responses import JSONResponse
from Detector.callanalyser import CallAnalyser
from models import Acknowledgment, CallEnded, CallStarted, ConnectionManager, SubscriptionValidation, TranscriptionData, TranscriptionMetadata, deserialise_event, deserialise_ws_message
import uvicorn
from dependency_injector.wiring import Provide, inject
from container import Container

app = FastAPI()
container = Container()
container.wire(modules=[__name__])
manager = ConnectionManager()
logger = logging.getLogger("uvicorn.error")

def get_service() -> CallAnalyser:
    return container.call_analyser()

@app.get("/ping")
async def pong_handler(request: Request):
    return Response(content="pong", status_code=200)


@app.post("/calls")
@inject
async def confirm_calls_handler(
    request: Request,
    call_analyser: CallAnalyser = Depends(get_service) 
):
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
            call_analyser.join_call(event)

        if isinstance(event, CallEnded):
            logger.info(f"{__name__}: Leaving call {event.group_id}")
            call_analyser.leave_call(event)

        if isinstance(event, Acknowledgment):
            logger.info(f"{__name__}: Received acknowledgment of type {event.type}")

    return Response(status_code=200)

@app.websocket("/ws")
@inject
async def transcription_handler(
    websocket: WebSocket,
    call_analyser: CallAnalyser = Depends(get_service),
):
    await manager.connect(websocket)
    logger.info(f"{__name__}: connection received from {websocket.client or "unknown host?"}")
    call_connection_id = None 
    try:
        while True:
            data = await websocket.receive_text()
            message = deserialise_ws_message(data)    
            logger.info(f"{__name__}: received message of type {type(message)}")

            if (isinstance(message, TranscriptionMetadata)):
                logger.info(f"{__name__}: call connection ID obtained: {message.callConnectionId}")
                call_connection_id = message.callConnectionId
            elif (isinstance(message, TranscriptionData) and call_connection_id is not None):
                logger.info(f"{__name__}: {call_connection_id}: call is being analysed...")
                call_analyser.analyse_call_for_vishing_naive(call_connection_id, message)
        
    except WebSocketDisconnect:
        logger.info(f"{__name__}: disconnected")
    except Exception as e:
        logger.info(f"{__name__}: closed unexpectedly due to an error: {e}")
    finally:
        if (call_connection_id is not None):
            call_analyser.conclude_analysis(call_connection_id)
        manager.remove(websocket)

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000,  ws_ping_interval=2, ws_ping_timeout=60)