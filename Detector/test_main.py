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
        
    def tearDown(self):
        container.reset_singletons()
        container.unwire()

    def test_ping(self):
        response = client.get('/ping')
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.content, b"pong")

    def test_transcription(self):
        analyser = container.call_analyser()
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
            analyser._ongoing_calls.clear()

    def test_basic_prompting(self):
        analyser = container.call_analyser()

        response = analyser.ai_client.responses.parse(
            model=analyser.DETECTOR_MODEL,
            store=False,
            reasoning={"effort": "medium"},
            input=[
                {
                    "role": "user",
                    "content": "tell me 'meow meow meow'."
                }
            ],
            timeout=60
        )

        self.assertIsNotNone(response.output_text)
        self.assertEqual(response.output_text, "meow meow meow")
        analyser._ongoing_calls.clear()
    
    def test_detection_safe(self):
        analyser = container.call_analyser()
        event_id = str(uuid.uuid4())
        event_time = datetime.now(timezone.utc).isoformat()
        call_id = "call-connection-id-456"

        payload = [
            {
                "id": event_id,
                "topic": "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.Communication/communicationServices/my-acs",
                "subject": "calls/9876543210",
                "data": {
                    "callConnectionId": call_id,
                    "serverCallId": "server-call-id-students",
                    "startedBy": {
                        "rawId": "8:acs:student-a",
                        "communicationUser": {
                            "id": "student-a"
                        }
                    },
                    "group": {
                        "id": "students-group"
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
            headers={"Content-Type": "application/json"}
        )

        assert response.status_code == 200

        mock_conversation = [
            {
                "text": "Hey, are you already on campus?",
                "speaker": "8:acs:student-a",
                "offset_in_seconds": 6
            },
            {
                "text": "Yeah, I just got to the library. It’s packed today.",
                "speaker": "8:acs:student-b",
                "offset_in_seconds": 7
            },
            {
                "text": "Same here yesterday. Are you studying for the databases exam?",
                "speaker": "8:acs:student-a",
                "offset_in_seconds": 9
            },
            {
                "text": "Unfortunately yes. I still don’t fully get normalization.",
                "speaker": "8:acs:student-b",
                "offset_in_seconds": 10
            },
            {
                "text": "Third normal form is the one that always gets people.",
                "speaker": "8:acs:student-a",
                "offset_in_seconds": 11
            },
            {
                "text": "Exactly. I mix it up with BCNF every single time.",
                "speaker": "8:acs:student-b",
                "offset_in_seconds": 10
            },
            {
                "text": "Did you watch the revision lecture recording?",
                "speaker": "8:acs:student-a",
                "offset_in_seconds": 8
            },
            {
                "text": "Yeah, at one point. The audio quality was terrible though.",
                "speaker": "8:acs:student-b",
                "offset_in_seconds": 12
            },
            {
                "text": "Classic. By the way, are we still meeting the rest of the group later?",
                "speaker": "8:acs:student-a",
                "offset_in_seconds": 11
            },
            {
                "text": "At four, I think. For the software engineering project.",
                "speaker": "8:acs:student-b",
                "offset_in_seconds": 10
            },
            {
                "text": "Right, the one with the API design report.",
                "speaker": "8:acs:student-a",
                "offset_in_seconds": 8
            },
            {
                "text": "Yeah. I finished my part on authentication and error handling.",
                "speaker": "8:acs:student-b",
                "offset_in_seconds": 13
            },
            {
                "text": "Nice. I’m still cleaning up the diagrams.",
                "speaker": "8:acs:student-a",
                "offset_in_seconds": 9
            },
            {
                "text": "No rush, the deadline is Friday anyway.",
                "speaker": "8:acs:student-b",
                "offset_in_seconds": 8
            },
            {
                "text": "True. Are you grabbing lunch on campus?",
                "speaker": "8:acs:student-a",
                "offset_in_seconds": 10
            },
            {
                "text": "Probably. The cafeteria food isn’t great but it’s cheap.",
                "speaker": "8:acs:student-b",
                "offset_in_seconds": 11
            },
            {
                "text": "I might get a sandwich and coffee. I barely slept.",
                "speaker": "8:acs:student-a",
                "offset_in_seconds": 12
            },
            {
                "text": "Same. Too much last-minute revision.",
                "speaker": "8:acs:student-b",
                "offset_in_seconds": 9
            },
            {
                "text": "Alright, I’ll let you study. See you at four?",
                "speaker": "8:acs:student-a",
                "offset_in_seconds": 10
            },
            {
                "text": "Yeah, see you later. Good luck revising.",
                "speaker": "8:acs:student-b",
                "offset_in_seconds": 9
            },
        ]

        with client.websocket_connect("/ws") as websocket:
            websocket.send_json(
                {
                    "kind": "TranscriptionMetadata",
                    "transcriptionMetadata": {
                        "callConnectionId": call_id,
                        "subscriptionId": "test-student-call",
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
                            "confidence": 0.93,
                            "offset": float(turn["offset_in_seconds"]) * 1_000_000,
                            "duration": 12345678,
                            "participantRawID": turn["speaker"],
                            "resultStatus": "Recognized",
                            "sentimentAnalysisResult": "Neutral",
                            "words": []
                        }
                    }
                )
                time.sleep(float(turn["offset_in_seconds"]))

        naive, _ = analyser._ongoing_calls[call_id].get_final_results()

        self.assertIsNotNone(naive)
        self.assertIn(naive.answer, {"SAFE"}) # type: ignore
        analyser._ongoing_calls.clear()
        
    def test_detection_fraud(self):
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
        analyser._ongoing_calls.clear()


if __name__ == "__main__":
    unittest.main()