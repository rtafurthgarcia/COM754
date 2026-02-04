from collections import OrderedDict
from dataclasses import dataclass, field
import dataclasses
import json
import time
from typing import List, Literal, Optional, Tuple
from azure.communication.identity import CommunicationUserIdentifier
from azure.core.exceptions import DeserializationError
from azure.communication.callautomation import CallAutomationClient, CallConnectionClient

from fastapi import WebSocket
from openai import conversations
from pydantic import BaseModel

class FinalDetectorResults(BaseModel):
    answer: Literal["SAFE", "FRAUD"]
    timestamp: float = time.time()

class IntermediateEnhancedDetectorResults(BaseModel):
    answer: bool

def get_prompts():
    return {
        "naive": naive_prompt,
        "authority": authority_prompt,
        "social_proof": social_proof_prompt,
        "distraction": distraction_prompt,
        "prohibited": prohibited_prompt
    }

naive_prompt = """
    Please analyze the call content and detect whether it is a fraud call. 
    Please carefully analyze the suspicious features in the conversation. 
    If it is a fraud call, please only return "FRAUD". 
    If it is a normal call, please only return "SAFE". 
    Do not return anything else.
"""

authority_prompt = """
    Please analyze the call content and detect whether the caller is using the "Authority" persuasion principle common in voice phishing. 
    You can determine so by answering those questions:
        - Does the caller claim to have authority over the callee?
        - Does the caller claim to have authority to access the information requested?
        - Does the caller claim to be a member of a reputable institution?
        - Is it reasonable for the callee to believe that failure to comply with the caller's request will result in repercussions (e.g. loss of privileges, humiliation, condemnation) based on the caller's supposed authority?
    If one or many seems to be true, return "TRUE", otherwise, return "FALSE".
"""

social_proof_prompt = """
    Please analyze the call content and detect whether the caller is using the "Social proof" persuasion principle common in voice phishing. 
    You can determine so by answering those questions:
        - Is it reasonable for the callee to believe that complying with the caller's request will have benefits (including helping the caller)?
        - Is it reasonable for the callee to believe that they will not be held solely responsible for any negative effects related to complying with the caller's request?
        - Is it reasonable for the callee to believe that any risk associated with helping the caller is shared by other people as well?
        - Does the caller state or imply that the callee's peers have helped the caller in this manner in the past?
        - Is it otherwise reasonable for the callee to believe that it is socially correct to help the caller?
        - Does the caller state or imply that if the callee does not comply with their request then the callee will be “left out” in some way?
    If one or many seems to be true, return "TRUE", otherwise, return "FALSE".
"""

distraction_prompt = """
    Please analyze the call content and detect whether the caller is using the "Distraction" persuasion principle common in voice phishing. 
    You can determine so by answering those questions:
        - Does the caller do anything to heighten the callee's emotional state (e.g. stress, surprise, anger, excitement)?
        - Does the caller give the callee more information than they can process?
        - Does the caller state or imply that the information they are requesting is time-sensitive?
        - Does the caller state or imply that they are in a hurry or otherwise have limited time to converse with the callee?
        - Does the caller state or imply that there is some benefit to complying with their request but that this benefit is of limited quantity?
        - Does the caller state or imply that if the callee does not comply with their request then the callee will be “left out” in some way?
        - Does the caller attempt to distract the callee from thinking about the intentions or consequences related to the caller's request?
        - Is it reasonable for the callee to believe that if they comply with the caller's request that they will personally benefit from it?
        - Does the caller state or imply that the consequences of the callee's actions are large?
        - Is it reasonable for the callee to believe that if they do not comply with the caller's request that they will suffer negative consequences because of it?
    If one or many seems to be true, return "TRUE", otherwise, return "FALSE".
"""

prohibited_prompt = """
    Please analyze the call content and detect whether the caller is requesting typically sensitive or prohibited information common in voice phishing. 
    You can determine so by answering those questions:
        - Does the caller request information that is typically considered too sensitive to be transfered over the phone?
        - Does the caller request information that is not allowed to be revealed due to data protection or data privacy laws?
    If one or many seems to be true, return "TRUE", otherwise, return "FALSE".
"""

@dataclass
class IncomingCall:
    to_user: CommunicationUserIdentifier
    from_user: CommunicationUserIdentifier
    serverCallId: str
    incomingCallContext: str

    @staticmethod
    def from_json(json: dict):
        return IncomingCall(
            to_user=CommunicationUserIdentifier(json["to"]["rawId"]),
            from_user=CommunicationUserIdentifier(json["from"]["rawId"]),
            incomingCallContext=json["incomingCallContext"],
            serverCallId=json["serverCallId"]
        )
    
@dataclass
class CallStarted:
    group_id: str

    @staticmethod
    def from_json(json: dict):
        return CallStarted(
            group_id=json["group"]["id"],
        )
    
@dataclass
class CallEnded:
    group_id: str

    @staticmethod
    def from_json(json: dict):
        return CallEnded(
            group_id=json["group"]["id"],
        )
    
@dataclass
class CallParticipantAdded:
    group_id: str
    datasetId: str

    @staticmethod
    def from_json(json: dict):
        displayName = str(json["displayName"])
         
        return CallParticipantAdded(
            group_id=json["group"]["id"],
            datasetId=displayName[:displayName.find("\\")]
        )

@dataclass
class TranscriptionMetadata:
    callConnectionId: str
    subscriptionId: str
    locale: str
    locales: List[str]
    correlationId: str
    piiRedactionOptions: Optional[dict]

    @staticmethod
    def from_json(json: dict):
        return TranscriptionMetadata(
            callConnectionId=json["callConnectionId"],
            subscriptionId=json["subscriptionId"],
            locale=json["locale"],
            locales=json["locales"],
            correlationId=json["correlationId"],
            piiRedactionOptions=json.get("piiRedactionOptions")
        )
    
@dataclass
class WordData:
    text: str
    offset: int
    duration: int

    @staticmethod
    def from_json(json: dict):
        return WordData(
            text=json["text"],
            offset=json["offset"],
            duration=json["duration"]
        )

@dataclass
class TranscriptionData:
    text: str
    format: str
    confidence: float
    offset: int
    duration: int
    participantRawID: str
    resultStatus: str
    sentimentAnalysisResult: Optional[str]
    words: List[WordData]

    @staticmethod
    def from_json(json: dict):
        return TranscriptionData(
            text=json["text"],
            format=json["format"],
            confidence=json["confidence"],
            offset=json["offset"],
            duration=json["duration"],
            participantRawID=json["participantRawID"],
            resultStatus=json["resultStatus"],
            sentimentAnalysisResult=json.get("sentimentAnalysisResult"),
            words=[WordData.from_json(w) for w in json.get("words", [])]
        )
    
@dataclass
class SubscriptionValidation:
    validationCode: str

    @staticmethod
    def from_json(json: dict):
        return SubscriptionValidation(
            validationCode=json["validationCode"]
        )

@dataclass
class TurnOfConversation:
    group_id: str 
    speaker: str
    text: str
    naive_result: Optional[FinalDetectorResults] = None
    enhanced_result: Optional[FinalDetectorResults] = None
    timestamp: float = time.time()

@dataclass
class OngoingCall:
    group_id: str 
    call: CallConnectionClient | None
    conversation: OrderedDict[float, TurnOfConversation] = field(default_factory=OrderedDict)
    start_timestamp: float = time.time()
    end_timestamp: Optional[float] = None

    def conversation_to_str(self):
        result = ""

        for turn in self.conversation.values():
            result += f"{turn.speaker} at {turn.timestamp} said:\n"
            result += f"{turn.text}"

        return result

    def get_final_results(self) -> Tuple[FinalDetectorResults | None, FinalDetectorResults | None]:
        last_ruling = self.conversation[next(reversed(self.conversation))]
        return last_ruling.naive_result, last_ruling.enhanced_result

@dataclass
class Acknowledgment:
    type: str

def deserialise_event(raw_event):
    classes = {
        "Microsoft.Communication.IncomingCall": IncomingCall.from_json,
        "Microsoft.Communication.CallStarted": CallStarted.from_json,
        "Microsoft.Communication.CallEnded": CallEnded.from_json,
        "Microsoft.Communication.CallParticipantAdded": CallParticipantAdded.from_json,
        "Microsoft.EventGrid.SubscriptionValidationEvent": SubscriptionValidation.from_json,
    }

    if "eventType" in raw_event:
        return classes[raw_event["eventType"]](raw_event["data"])
    elif "type" in raw_event:
        return Acknowledgment(raw_event["type"])
    else:
        raise DeserializationError()

def deserialise_ws_message(raw_message) -> TranscriptionData | TranscriptionMetadata:
    classes = {
        "TranscriptionMetadata": TranscriptionMetadata.from_json,
        "TranscriptionData": TranscriptionData.from_json,
    }

    dict_event = json.loads(raw_message)

    if "kind" not in dict_event or dict_event["kind"] not in classes:
        raise DeserializationError()
    else:
        return classes[dict_event["kind"]](dict_event[dict_event["kind"][0].lower() + dict_event["kind"][1:]])


class ConnectionManager:
    def __init__(self):
        self.active_connections: list[WebSocket] = []
        self.runner_active = False

    async def connect(self, websocket: WebSocket):
        await websocket.accept()
        self.active_connections.append(websocket)

    def remove(self, websocket: WebSocket):
        self.active_connections.remove(websocket)