import os 
from typing import Literal
from azure.keyvault.secrets import SecretClient
from azure.identity import DefaultAzureCredential
import azure.cognitiveservices.speech as speechsdk
from collections import OrderedDict
from openai import OpenAI
from pydantic import BaseModel

class FinalDetectorResults(BaseModel):
    answer: Literal["SAFE", "FRAUD", "UNCERTAIN"]

class IntermediateEnhancedDetectorResults(BaseModel):
    answer: bool

naive_prompt = """
    Please analyze the call content and detect whether it is a fraud call. 
    Please carefully analyze the suspicious features in the conversation. 
    If it is a fraud call, please only return "FRAUD". 
    If it is a normal call, please only return "SAFE". 
    If there is insufficient information (e.g., it is not yet obvious that the fraud is present), 
    please return "UNCERTAIN". Do not return anything else.
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

"""if (results.authority_detected or results.distraction_detected or results.social_proof_detected) and results.sensitive_requested:
return FinalDetectorResults(answer="FRAUD")
elif (results.authority_detected or results.distraction_detected or results.social_proof_detected) or results.sensitive_requested:
return FinalDetectorResults(answer="UNCERTAIN")
else:
return FinalDetectorResults(answer="SAFE")"""

class LLMDetector():
    def __init__(self):
        keyvault_name = os.environ["KEY_VAULT_NAME"]

        # Set these variables to the names you created for your secrets
        SS_KEY_NAME = "com754-ss-key"
        SS_ENDPOINT_NAME = "com754-ss-endpoint"
        AI_KEY_NAME = "com754-ai-key"
        AI_ENDPOINT_NAME = "com754-ai-endpoint"
        CS_KEY_NAME = "com754-cs-key"
        CS_ENDPOINT_NAME = "com754-cs-endpoint"

        # URI for accessing key vault
        keyvault_uri = f"https://{keyvault_name}.vault.azure.net"

        # Instantiate the client and retrieve secrets
        credential = DefaultAzureCredential()
        kv_client = SecretClient(vault_url=keyvault_uri, credential=credential)

        print(f"Retrieving your secrets from {keyvault_name}.")

        retrieved_key = kv_client.get_secret(SS_KEY_NAME).value
        retrieved_endpoint = kv_client.get_secret(SS_ENDPOINT_NAME).value

        self.speech_client = speechsdk.SpeechConfig(subscription=retrieved_key, endpoint=retrieved_endpoint)

        retrieved_key = kv_client.get_secret(AI_KEY_NAME).value
        retrieved_endpoint = kv_client.get_secret(AI_ENDPOINT_NAME).value

        self.MODEL = "gpt-5-mini"
        self.ai_client = OpenAI(base_url=retrieved_endpoint, api_key=retrieved_key)

        self.cs_endpoint = kv_client.get_secret(CS_ENDPOINT_NAME).value or ""
        self.cs_key = kv_client.get_secret(CS_KEY_NAME).value or ""


    def _analyse_call_for_vishing_naive(self, conversation: OrderedDict) -> FinalDetectorResults | None:
        response = self.ai_client.responses.parse(
            model=self.MODEL,
            store=False,
            reasoning={"effort": "medium"},
            instructions=naive_prompt,
            input=[
                {
                    "role": "user",
                    "content": str(conversation)
                }
            ],
            text_format=FinalDetectorResults
        )

        return response.output_parsed
    
    def _analyse_call_for_vishing(
        self, 
        prompt: str, 
        conversation: OrderedDict,
        response_format
    ) -> FinalDetectorResults | None:
        response = self.ai_client.responses.parse(
            model=self.MODEL,
            store=False,
            reasoning={"effort": "medium"},
            instructions=prompt,
            input=[
                {
                    "role": "user",
                    "content": str(conversation)
                }
            ],
            text_format=response_format
        )

        return response.output_parsed