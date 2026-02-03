import time
from fastapi.testclient import TestClient
from models import FinalDetectorResults, OngoingCall
from service import Service 
from app import app
import unittest
import uuid

client = TestClient(app)
service = Service()

class TestBasicHTTP(unittest.TestCase):
    def test_ping(self):
        response = client.get('/ping')
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.content, b"pong")

    def test_transcription(self):
        with client.websocket_connect("/ws") as websocket:
            websocket.send_json(
                { 
                    "kind": "TranscriptionMetadata",
                    "transcriptionMetadata": {
                        "callConnectionId": "test-call-id",
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
        mock_call_id = str(uuid.uuid4())
        service._ongoing_calls[mock_call_id] = OngoingCall(call=None)

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
                        "callConnectionId": mock_call_id,
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
            
            self.assertEqual(len(service._ongoing_calls), 2)

            naive, enhanced = service._ongoing_calls[mock_call_id].get_final_results()
            self.assertTrue(naive.answer, "FRAUD") # type: ignore

if __name__ == "__main__":
    unittest.main()