from dataclasses import dataclass
import json
from typing import List, Optional
from azure.communication.identity import CommunicationUserIdentifier
from azure.core.exceptions import DeserializationError

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
class DatasetEntry:
    id: int
    path: str
    files: set[str]

def deserialise_event(raw_event):
    classes = {
        "Microsoft.Communication.IncomingCall": IncomingCall.from_json,
        "Microsoft.Communication.CallStarted": CallStarted.from_json,
        "Microsoft.Communication.CallEnded": CallEnded.from_json,
        "Microsoft.Communication.CallParticipantAdded": CallParticipantAdded.from_json,
    }

    dict_event = json.loads(next(raw_event).decode("utf-8"))

    if "eventType" not in dict_event:
        raise DeserializationError()
    elif dict_event["eventType"] in classes:
        return classes[dict_event["eventType"]](dict_event["data"])
    return None

def deserialise_ws_message(raw_message):
    classes = {
        "TranscriptionMetadata": TranscriptionMetadata.from_json,
        "TranscriptionData": TranscriptionData.from_json,
    }

    dict_event = json.loads(raw_message)

    if "kind" not in dict_event:
        raise DeserializationError()
    elif dict_event["kind"] in classes:
        return classes[dict_event["kind"]](dict_event[dict_event["kind"][0].lower() + dict_event["kind"][1:]])
    return None