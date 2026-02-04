
import asyncio
import json
import logging
import time
from azure.communication.callautomation import CallAutomationClient, TranscriptionOptions
from azure.communication.identity import CommunicationIdentityClient
from azure.core.exceptions import ServiceResponseError
from azure.servicebus import ServiceBusClient, ServiceBusMessage
from openai import AsyncAzureOpenAI
from dataclasses import asdict
from models import CallStarted, FinalDetectorResults, IntermediateEnhancedDetectorResults, OngoingCall, TranscriptionData, TurnOfConversation, get_prompts

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
        local_endpoint: str
    ):
        self._call_automation_client = call_automation_client
        self._identity_client = identity_client
        self._ai_client = ai_client
        self._servicebus_client = servicebus_client
        self._servicebus_sender = servicebus_client.get_queue_sender(self.QUEUE_NAME)
        self._local_endpoint = local_endpoint
        self._ai_endpoint = ai_client.base_url.scheme

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
            cognitive_services_endpoint=self._ai_endpoint)

        if (accepted_call.call_connection_id is None):
            logger.error(f"{__name__}: No call connection ID found")
            raise ServiceResponseError(f"{__name__}: No call connection ID found")

        self._ongoing_calls[accepted_call.call_connection_id] = OngoingCall(
            call=self._call_automation_client.get_call_connection(accepted_call.call_connection_id),
            group_id=call.group_id
        )
        
        return accepted_call.call_connection_id

    def leave_call(self, call_id):
        if call_id not in self._ongoing_calls.keys():
            #self.logger.inf(f"{__name__}: Call with group ID {call.group_id} not found among ongoing calls")
            # disabled cuz suspected it might be triggered 3 times, for each call has 3 participants
            return

        ongoing_call = self._ongoing_calls[call_id]
        if ongoing_call.call is None:
            #self.logger.inf(f"{__name__}: Call with group ID {call.group_id} not found among ongoing calls")
            # disabled cuz suspected it might be triggered 3 times, for each call has 3 participants
            return

        ongoing_call.call.hang_up(is_for_everyone=False)
        del self._ongoing_calls[call_id]

    def conclude_analysis(self, call_id: str):
        self._ongoing_calls[call_id].end_timestamp = time.time()

    async def run_analysis(self, call_id: str, new_transcription: TranscriptionData): 
        timeset = time.time() - self._ongoing_calls[call_id].start_timestamp
        self._ongoing_calls[call_id].conversation[timeset] = TurnOfConversation(
            group_id=self._ongoing_calls[call_id].group_id,
            speaker=new_transcription.participantRawID, 
            text=new_transcription.text
        )

        future_naive = self._analyse_call_for_vishing(
            call_id, get_prompts()["naive"], FinalDetectorResults
        )

        future_prohibited = self._analyse_call_for_vishing(
            call_id, get_prompts()["prohibited"], IntermediateEnhancedDetectorResults
        )

        future_authority = self._analyse_call_for_vishing(
            call_id, get_prompts()["authority"], IntermediateEnhancedDetectorResults
        )

        future_social_proof = self._analyse_call_for_vishing(
            call_id, get_prompts()["social_proof"], IntermediateEnhancedDetectorResults
        )

        future_distraction = self._analyse_call_for_vishing(
            call_id, get_prompts()["distraction"], IntermediateEnhancedDetectorResults
        )

        # naive
        self._ongoing_calls[call_id].conversation[timeset].naive_result = await future_naive

        # enhanced
        if (await future_authority or await future_distraction or await future_social_proof) and await future_prohibited:
            self._ongoing_calls[call_id].conversation[timeset].enhanced_result = FinalDetectorResults(answer="FRAUD")
        else:
            self._ongoing_calls[call_id].conversation[timeset].enhanced_result = FinalDetectorResults(answer="SAFE")

        await self._send_result(self._ongoing_calls[call_id].conversation[timeset])
        
    async def _analyse_call_for_vishing(self, call_id: str, prompt: str, return_type):
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
            text_format=return_type,
            timeout=60
        )

        logger.info(f"{__name__}: {call_id}: {content}")
        if (response.output_parsed is not None and response.output_parsed.answer is not None):
            logger.info(f"{__name__}: {call_id}: verdict: {response.output_parsed.answer}")
        else:
            logger.error(f"{__name__}: {call_id}: failed to assess this bit of conversation.")

        return response.output_parsed
    
    async def _send_result(self, turn: TurnOfConversation):
        async with self._lock:
            self._servicebus_sender.send_messages(message=ServiceBusMessage(json.dumps(asdict(turn)))) 
            logger.info(f"{__name__}: Group #{turn.group_id}: notified caller-callee system")