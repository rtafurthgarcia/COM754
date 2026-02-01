from fastapi.testclient import TestClient
from fastapi.websockets import WebSocket
from app import app
import unittest

client = TestClient(app)

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


if __name__ == "__main__":
    unittest.main()