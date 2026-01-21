from dataclasses import dataclass
import json
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
class DatasetEntry:
    id: int
    path: str
    files: set[str]
    


def deserialise_event(raw_event):
    classes = {
        "Microsoft.Communication.IncomingCall": IncomingCall.from_json
    }

    dict_event = json.loads(next(raw_event).decode("utf-8"))

    if "eventType" not in dict_event or dict_event["eventType"] not in classes.keys():
        raise DeserializationError()
    else:
        return classes[dict_event["eventType"]](dict_event["data"])