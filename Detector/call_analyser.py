
import asyncio
import json
import logging
from pickle import TRUE
from pyclbr import Class
import time
from typing import TypeVar
from azure.communication.callautomation import CallAutomationClient, TranscriptionOptions
from azure.communication.identity import CommunicationIdentityClient
from azure.core.exceptions import ServiceResponseError
from azure.servicebus import ServiceBusClient, ServiceBusMessage
from openai import AsyncAzureOpenAI
from dataclasses import asdict
from models import CallStarted, Classification, EndOfAnalysis, IntermediateClassification, OngoingCall, TranscriptionData, TurnOfConversation, get_prompts

logger = logging.getLogger("uvicorn.error")

class CallAnalyser:
    DETECTOR_MODEL = "gpt-5-mini"
    TRANSCRIPTION_MODEL = "gpt-4o-mini-transcribe"
    QUEUE_NAME = "detection-results"

    def __init__(
        self,
        call_automation_client: CallAutomationClient,
        identity_client: CommunicationIdentityClient,
        ai_client: AsyncAzureOpenAI,
        servicebus_client: ServiceBusClient, 
        local_endpoint: str,
        cs_ai_endpoint: str
    ):
        self._call_automation_client = call_automation_client
        self._identity_client = identity_client
        self._ai_client = ai_client
        self._servicebus_client = servicebus_client
        self._servicebus_sender = servicebus_client.get_queue_sender(self.QUEUE_NAME)
        self._local_endpoint = local_endpoint
        self._cs_ai_endpoint = cs_ai_endpoint

        self._ongoing_calls: dict[str, OngoingCall] = {}
        self._lock = asyncio.Lock()
    
    def join_call(self, call: CallStarted):
        accepted_call = self._call_automation_client.connect_call(
            group_call_id=call.group_id,
            callback_url=f"https://{self._local_endpoint}/calls",
            transcription=TranscriptionOptions(
                transport_url=f"wss://{self._local_endpoint}/ws",
                transport_type="websocket",
                locale="en-US",
                start_transcription=True,
                enable_intermediate_results=False,
                pii_redaction=None,
                enable_sentiment_analysis=False,
                speech_recognition_model_endpoint_id=self.TRANSCRIPTION_MODEL
            ),
            cognitive_services_endpoint=self._cs_ai_endpoint)

        if (accepted_call.call_connection_id is None):
            logger.error(f"{__name__}: No call connection ID found")
            raise ServiceResponseError(f"{__name__}: No call connection ID found")

        self._ongoing_calls[accepted_call.call_connection_id] = OngoingCall(
            call=self._call_automation_client.get_call_connection(accepted_call.call_connection_id),
            group_id=call.group_id
        )
        
        return accepted_call.call_connection_id

    def leave_call(self, call_id: str):
        if call_id not in self._ongoing_calls.keys():
            #self.logger.inf(f"{__name__}: Call with group ID {call.group_id} not found among ongoing calls")
            # disabled cuz suspected it might be triggered 3 times, for each call has 3 participants
            return

        ongoing_call = self._ongoing_calls[call_id]
        ongoing_call.call.hang_up(is_for_everyone=False)
        #

    async def run_analysis(self, call_id: str, new_transcription: TranscriptionData): 
        timestamp = self._ongoing_calls[call_id].add_new_turn(
            speaker=new_transcription.participantRawID, 
            text=new_transcription.text
        )

        future_naive = self._analyse_call_for_vishing(
            call_id, get_prompts()["naive"], Classification
        )

        future_prohibited = self._analyse_call_for_vishing(
            call_id, get_prompts()["prohibited"], IntermediateClassification
        )

        future_authority = self._analyse_call_for_vishing(
            call_id, get_prompts()["authority"], IntermediateClassification
        )

        future_social_proof = self._analyse_call_for_vishing(
            call_id, get_prompts()["social_proof"], IntermediateClassification
        )

        future_distraction = self._analyse_call_for_vishing(
            call_id, get_prompts()["distraction"], IntermediateClassification
        )

        # naive
        naive_classification = Classification()
        enhanced_classification = Classification()

        # enhanced
        try:
            async with asyncio.timeout(60):
                results: tuple[Classification, IntermediateClassification, IntermediateClassification, IntermediateClassification, IntermediateClassification] = await asyncio.gather(future_naive, future_authority, future_distraction, future_social_proof, future_prohibited) # type: ignore

                naive_classification = results[0]

                worst_timestamp = -1
                for result in results[1:]:
                    if (result.timestamp > worst_timestamp):
                        worst_timestamp = result.timestamp

                if (results[1].answer or results[2].answer or results[3].answer) and results[4].answer:
                    enhanced_classification = Classification(answer="FRAUD", timestamp=worst_timestamp)
                else:
                    enhanced_classification = Classification(answer="SAFE", timestamp=worst_timestamp)
        except asyncio.CancelledError as e:
            logger.error(f"{__name__}: {call_id}: Failed to asssess this turn of conversation due to the following error: {e}")

        try:
            await self._send_turn_analysis_result(
                self._ongoing_calls[call_id].conclude(
                    timestamp, 
                    naive_classification, 
                    enhanced_classification
                )
            ) 
        except Exception as e:
            logger.error(f"{__name__}: {call_id}: Failed to send the analysis' results due to the following error: {e}")
        
    async def _analyse_call_for_vishing(self, call_id: str, prompt: str, object):
        content = str(self._ongoing_calls[call_id].conversation_to_str())
        response = await self._ai_client.responses.parse(
            model=self.DETECTOR_MODEL,
            store=False,
            reasoning={"effort": "medium"},
            instructions=prompt,
            input=[
                {
                    "role": "user",
                    "content": content
                }
            ],
            text_format=object,
        )

        logger.info(f"{__name__}: {call_id}: {content}")
        if (response.output_parsed is not None and response.output_parsed.answer is not None):
            logger.info(f"{__name__}: {call_id}: verdict: {response.output_parsed.answer}")
        else:
            logger.error(f"{__name__}: {call_id}: failed to assess this bit of conversation.")

        if (isinstance(response.output_parsed, Classification | IntermediateClassification)):
            response.output_parsed.timestamp = time.time()

        return response.output_parsed 
    
    async def _send_turn_analysis_result(self, turn: TurnOfConversation):
        async with self._lock:
            self._servicebus_sender.send_messages(message=ServiceBusMessage(turn.to_json(), subject="TURN_ANALYSIS")) 
            logger.info(f"{__name__}: #{turn.group_id}: {turn.id}: turn analysed.")

    async def notify_end_of_analysis(self, call_id: str):
        try:
            call = self._ongoing_calls[call_id]

            async with self._lock:
                self._servicebus_sender.send_messages(
                    message=ServiceBusMessage(EndOfAnalysis(call.group_id).to_json(), subject="END_OF_ANALYSIS")
                ) 
                logger.info(f"{__name__}: {call.group_id}: end of analysis.")
        except Exception as e:
            logger.error(f"{__name__}: #{call_id}: Couldn't notify client of the end of the analysis due to the following error:")
            logger.error(f"{__name__}: #{call_id}: {e}")
        finally:
            del self._ongoing_calls[call_id]