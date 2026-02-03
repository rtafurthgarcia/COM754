# tests/test_app.py

import unittest
import uuid
import time
from datetime import datetime, timezone

from fastapi.testclient import TestClient
from dependency_injector import providers

from app import app, container

class FakeCallAutomationClient:
    def connect_call(self, *args, **kwargs):
        class Result:
            call_connection_id = "call-connection-id-456"
        return Result()

    def get_call_connection(self, call_connection_id: str):
        class Call:
            def hang_up(self, is_for_everyone=False):
                pass
        return Call()
    
    def conclude_analysis(self, call_connection_id: str):
        pass

class FakeIdentityClient:
    pass


client = TestClient(app)

class TestBasicHTTP(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        """
        Override cloud dependencies ONCE before any test runs.
        """
        container.call_automation_client.override(
            providers.Singleton(FakeCallAutomationClient)
        )

        container.identity_client.override(
            providers.Singleton(FakeIdentityClient)
        )

        cls.client = TestClient(app)

    @classmethod
    def tearDownClass(cls):
        """
        Always clean up overrides.
        """
        container.call_automation_client.reset_override()
        container.identity_client.reset_override()

    def test_ping(self):
        response = client.get('/ping')
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.content, b"pong")

    def test_transcription(self):
        event_id = str(uuid.uuid4())
        event_time = datetime.now(timezone.utc).isoformat()
        call_id = "call-connection-id-456"

        payload = [
            {
                "id": event_id,
                "topic": "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.Communication/communicationServices/my-acs",
                "subject": "calls/1234567890",
                "data": {
                    "callConnectionId": call_id,
                    "serverCallId": "server-call-id-456",
                    "startedBy": {
                        "rawId": "8:acs:caller-id",
                        "communicationUser": {
                            "id": "caller-id"
                        }
                    },
                    "group": {
                        "id": "blablabla"
                    },
                },
                "eventType": "Microsoft.Communication.CallStarted",
                "eventTime": event_time,
                "dataVersion": "1.0",
                "metadataVersion": "1"
            }
        ]

        response = client.post(
            "/calls",
            json=payload,
            headers={
                "Content-Type": "application/json"
            }
        )

        assert response.status_code == 200

        with client.websocket_connect("/ws") as websocket:
            websocket.send_json(
                { 
                    "kind": "TranscriptionMetadata",
                    "transcriptionMetadata": {
                        "callConnectionId": call_id,
                        "subscriptionId": "test-call-id",
                        "locale": "en-US",
                        "locales": ["en-US"],
                        "correlationId": "test-correlation-id",
                        "piiRedactionOptions": None
                    }
                }
            )

            websocket.send_json(
                {
                    "kind": "TranscriptionData",
                    "transcriptionData": {
                        "text": "Hello, this is a test transcription",
                        "format": "Display",
                        "confidence": 0.92,
                        "offset": 12345678,
                        "duration": 2345678,
                        "participantRawID": "8:acs:00000000-0000-0000-0000-000000000000",
                        "resultStatus": "Recognized",
                        "sentimentAnalysisResult": "Neutral",
                        "words": [
                            {
                                "text": "Hello",
                                "offset": 12345678,
                                "duration": 345678
                            },
                            {
                                "text": "this",
                                "offset": 12791356,
                                "duration": 210000
                            },
                            {
                                "text": "is",
                                "offset": 13001356,
                                "duration": 150000
                            },
                            {
                                "text": "a",
                                "offset": 13151356,
                                "duration": 90000
                            },
                            {
                                "text": "test",
                                "offset": 13241356,
                                "duration": 300000
                            },
                            {
                                "text": "transcription",
                                "offset": 13541356,
                                "duration": 600000
                            }
                        ]
                    }
                }
            )

            #self.assertEqual(len(websocket.), 1)
        
    def test_basic_detection(self):
        event_id = str(uuid.uuid4())
        event_time = datetime.now(timezone.utc).isoformat()
        call_id = "call-connection-id-456"

        payload = [
            {
                "id": event_id,
                "topic": "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.Communication/communicationServices/my-acs",
                "subject": "calls/1234567890",
                "data": {
                    "callConnectionId": call_id,
                    "serverCallId": "server-call-id-456",
                    "startedBy": {
                        "rawId": "8:acs:caller-id",
                        "communicationUser": {
                            "id": "caller-id"
                        }
                    },
                    "group": {
                        "id": "blablabla"
                    },
                },
                "eventType": "Microsoft.Communication.CallStarted",
                "eventTime": event_time,
                "dataVersion": "1.0",
                "metadataVersion": "1"
            }
        ]

        response = client.post(
            "/calls",
            json=payload,
            headers={
                "Content-Type": "application/json"
            }
        )

        assert response.status_code == 200

        mock_conversation = [
            {
                "text": "Hello, this is the IT department.",
                "speaker": "8:acs:00000000-0000-0000-0000-000000000000",
                "offset_in_seconds": 6
            },
            {
                "text": "Hi Tartufe speaking.",
                "speaker": "8:acs:ffffffff-0000-0000-0000-000000000000",
                "offset_in_seconds": 4
            },
            {
                "text": "We are facing significant security issues on our end. Could you give us a hand?",
                "speaker": "8:acs:00000000-0000-0000-0000-000000000000",
                "offset_in_seconds": 11
            },
            {
                "text": "Uh sure I will see what I can do",
                "speaker": "8:acs:ffffffff-0000-0000-0000-000000000000",
                "offset_in_seconds": 8
            },
            {
                "text": "Perfect. ",
                "speaker": "8:acs:00000000-0000-0000-0000-000000000000",
                "offset_in_seconds": 5
            },
            {
                "text": "Uh",
                "speaker": "8:acs:ffffffff-0000-0000-0000-000000000000",
                "offset_in_seconds": 1
            },
            {
                "text": "I will need your fullname, department, corporate email address and current account password.",
                "speaker": "8:acs:00000000-0000-0000-0000-000000000000",
                "offset_in_seconds": 15
            },
            {
                "text": "Uh do you guys really need this? I thought you had access to all of this by default.",
                "speaker": "8:acs:ffffffff-0000-0000-0000-000000000000",
                "offset_in_seconds": 12
            },
            {
                "text": "Yes, unfortunately our database is down due to what we assume is an ongoing attack, hence my request",
                "speaker": "8:acs:00000000-0000-0000-0000-000000000000",
                "offset_in_seconds": 15
            },{
                "text": "Uh. Then I'm Simon McCrew, my email is smccrew@example.com, and the password is uh.",
                "speaker": "8:acs:ffffffff-0000-0000-0000-000000000000",
                "offset_in_seconds": 12
            },
            {
                "text": "i eat salamy 4. I space E A T space S A L A M Y space 4. Is that all you needed.",
                "speaker": "8:acs:ffffffff-0000-0000-0000-000000000000",
                "offset_in_seconds": 12
            },
            {
                "text": "Thank you. Hold on a bit. You may receive an SMS now.",
                "speaker": "8:acs:00000000-0000-0000-0000-000000000000",
                "offset_in_seconds": 7
            },
            {
                "text": "Uh okay should I read it to you?.",
                "speaker": "8:acs:ffffffff-0000-0000-0000-000000000000",
                "offset_in_seconds": 5
            },
            {
                "text": "Yes please.",
                "speaker": "8:acs:00000000-0000-0000-0000-000000000000",
                "offset_in_seconds": 2
            },
            {
                "text": "5 7 1 4 9 6.",
                "speaker": "8:acs:ffffffff-0000-0000-0000-000000000000",
                "offset_in_seconds": 12
            },
            {
                "text": "Okay. Perfect. That was all! Thank you again and have a nice day!",
                "speaker": "8:acs:00000000-0000-0000-0000-000000000000",
                "offset_in_seconds": 15
            },
            {
                "text": "Byebye!",
                "speaker": "8:acs:ffffffff-0000-0000-0000-000000000000",
                "offset_in_seconds": 2
            },
        ]

        with client.websocket_connect("/ws") as websocket:
            websocket.send_json(
                { 
                    "kind": "TranscriptionMetadata",
                    "transcriptionMetadata": {
                        "callConnectionId": call_id,
                        "subscriptionId": "test-call-id",
                        "locale": "en-US",
                        "locales": ["en-US"],
                        "correlationId": "test-correlation-id",
                        "piiRedactionOptions": None
                    }
                }
            )

            for turn in mock_conversation:
                websocket.send_json(
                    {
                        "kind": "TranscriptionData",
                        "transcriptionData": {
                            "text": turn["text"],
                            "format": "Display",
                            "confidence": 0.92,
                            "offset": float(turn["offset_in_seconds"]) * 1000000,
                            "duration": 12345678,
                            "participantRawID": turn["speaker"],
                            "resultStatus": "Recognized",
                            "sentimentAnalysisResult": "Neutral",
                            "words": []
                        }
                    }
                )

                time.sleep(float(turn["offset_in_seconds"]))
            
        analyser = container.call_analyser()

        naive, _ = analyser._ongoing_calls[call_id].get_final_results()

        self.assertIsNotNone(naive)
        self.assertIn(naive.answer, {"FRAUD"}) # type: ignore

if __name__ == "__main__":
    unittest.main()