import os 
import time
import json
from docx2pdf import convert
from pydub import AudioSegment
from azure.keyvault.secrets import SecretClient
from azure.identity import DefaultAzureCredential
from azure.core.credentials import AzureKeyCredential
import azure.cognitiveservices.speech as speechsdk
from azure.cognitiveservices.speech import SpeechConfig
from collections import OrderedDict
import threading
from openai import OpenAI
import base64
from datetime import datetime
from pydantic import BaseModel
from typing import Literal

class TurnOfConversation(BaseModel):
    offset: str
    text: str 
    duration: int = 0
    speaker: Literal["Attacker", "Victim"]

class Conversation(BaseModel):
    root: list[TurnOfConversation]

def rename_mp3_files(directory: str):
    #DIRECTORY = os.path.join(".", "Audio Recordings", "NV")

    os.chdir(directory)
    files = [f for f in os.listdir(".") if os.path.isfile(os.path.join(".", f))]
    new_name_counter = 234
    for file in files:
        print("Renaming {} to {}".format(file, str(new_name_counter) + ".mp3"))
        os.rename(
            src=file, 
            dst=str(new_name_counter) + ".mp3")

        new_name_counter += 1

def augment_dataset(src: str, dest: str, counter: int, count_to_reach: int):
    os.chdir(src)
    files = [f for f in os.listdir() if os.path.isfile(os.path.join(".", f))]

    for file in files:
        recording = AudioSegment.from_mp3(os.path.join(src, file))

        two_minutes = 120 * 1000

        first_two_minutes = recording[:two_minutes]
        first_two_minutes.export(os.path.join(dest, file), format="mp3")
        print("Shortened file {} in a 2min long file".format(file))

        # augment the dataset by splitting the long recordings into new mp3
        if (counter < count_to_reach):
            two_other_minutes = recording[two_minutes:two_minutes*2+1]
            export_file = os.path.join(dest, str(counter) + ".mp3")
            two_other_minutes.export(export_file, format="mp3")

            print("Created from {} a separate {} 2min long file".format(file, export_file))
            
            counter += 1

def split_audio_file(src: str, dest: str, conversation: OrderedDict):
    """
    Split each turn of a recorded conversation into a separate file into a destination directory
    
    :param src: Absolute path to wav file
    :type src: str
    :param dest: Export directory
    :type dest: str
    :param conversation: Transcript
    :type conversation: OrderedDict
    """
    with open(os.path.join(dest, "transcripts.json"), "w") as json_file:
        json.dump(conversation, json_file, indent=4, sort_keys=False)

    count = 1
    for timestamp, conversation in conversation.items():
        recording = AudioSegment.from_wav(src)

        turn = recording[int(timestamp):int(timestamp)+conversation["duration"]]

        export_file = os.path.join(dest, "{}.{}".format(str(count), "wav"))
        turn.export(export_file, format="wav")

        count += 1
        print("Split conversation into {}".format(export_file))

# Conversion to wav is required because diarisation service doesnt support mp3 files
def convert_existing_mp3s(src: str, dest: str):
    files = [f for f in os.listdir(src) if os.path.isfile(os.path.join(src, f))]

    for file in files:
        recording = AudioSegment.from_mp3(os.path.join(src, file))
        recording.export(os.path.join(dest, file).replace(".mp3", ".wav"), format="wav")
        print("Converted {} in a wav format".format(file))

class Transcriber():
    def __init__(self):
        keyvault_name = os.environ["KEY_VAULT_NAME"]

        # Set these variables to the names you created for your secrets
        KEY_SECRET_NAME = "com754-ss-key"
        ENDPOINT_SECRET_NAME = "com754-ss-endpoint"

        # URI for accessing key vault
        keyvault_uri = f"https://{keyvault_name}.vault.azure.net"

        # Instantiate the client and retrieve secrets
        credential = DefaultAzureCredential()
        kv_client = SecretClient(vault_url=keyvault_uri, credential=credential)

        print(f"Retrieving your secrets from {keyvault_name}.")

        retrieved_key = kv_client.get_secret(KEY_SECRET_NAME).value
        retrieved_endpoint = kv_client.get_secret(ENDPOINT_SECRET_NAME).value

        self.speech_config = speechsdk.SpeechConfig(subscription=retrieved_key, endpoint=retrieved_endpoint)
        self.ongoing_conversation = OrderedDict()

    def conversation_transcriber_recognition_canceled_cb(self, evt: speechsdk.SessionEventArgs):
        print('Canceled event')

    def conversation_transcriber_session_stopped_cb(self, evt: speechsdk.SessionEventArgs):
        print('SessionStopped event')

    def conversation_transcriber_transcribed_whole_sentence(self, evt: speechsdk.SpeechRecognitionEventArgs):
        print('\nTRANSCRIBED:')
        if evt.result.reason == speechsdk.ResultReason.RecognizedSpeech:
            print('\tText={}'.format(evt.result.text))
            print('\tSpeaker ID={}\n'.format(evt.result.speaker_id))  # type: ignore
            last_offset, last_turn_of_conversation = 0, None
            if (len(self.ongoing_conversation)) > 0:
                last_offset, last_turn_of_conversation = next(reversed(self.ongoing_conversation.items()))

            if last_turn_of_conversation is not None and last_turn_of_conversation["speaker"] == evt.result.speaker_id:  # type: ignore
                self.ongoing_conversation[last_offset]["text"] += "\n{}".format(evt.result.text)
                #self.ongoing_conversation[last_timestamp]["duration"] += int(evt.result.duration / 10000)
            else:
                # convert from hundreth of nanosecond to milisecond
                # to keep the same unit and split the text
                self.ongoing_conversation[int(evt.offset / 10000)] = {
                    "speaker": evt.result.speaker_id,  # type: ignore
                    "text": evt.result.text,
                    "duration": int(evt.result.duration / 10000)
                }

                # reason for that
                # https://learn.microsoft.com/en-us/answers/questions/2237494/diarisation-is-not-picking-up-number-of-speakers-c
                if last_turn_of_conversation is not None:
                    self.ongoing_conversation[last_offset]["duration"] = int(evt.offset / 10000) - last_offset

        elif evt.result.reason == speechsdk.ResultReason.NoMatch:
            print('\tNOMATCH: Speech could not be TRANSCRIBED: {}'.format(evt.result.no_match_details))

    def conversation_transcriber_transcribing_cb(self, evt: speechsdk.SpeechRecognitionEventArgs):
        print('TRANSCRIBING:')
        print('\tText={}'.format(evt.result.text))
        print('\tSpeaker ID={}'.format(evt.result.speaker_id))  # type: ignore

    def conversation_transcriber_session_started_cb(self, evt: speechsdk.SessionEventArgs):
        print('SessionStarted event')

    # make it so that each conversation turn goes into a separate .wav file
    def split_conversation_into_multiple_files(self, file: str):
        new_directory = file[:-4]
        os.mkdir(new_directory)

        split_audio_file(file, new_directory, self.ongoing_conversation)

        self.ongoing_conversation.clear()

    def diarise_and_split_dataset(self, src: str):
        self.speech_config.speech_recognition_language="en-US"
        self.speech_config.request_word_level_timestamps()
        self.speech_config.set_property(property_id=speechsdk.PropertyId.Speech_SegmentationStrategy, value="Semantic") 
        self.speech_config.set_property(property_id=speechsdk.PropertyId.SpeechServiceResponse_DiarizeIntermediateResults, value='true')

        files = [f for f in os.listdir(src) if os.path.isfile(os.path.join(src, f))]
        for file in files:
            print("Transcribing file {}".format(file))
            audio_config = speechsdk.audio.AudioConfig(filename=os.path.join(src, file))
            conversation_transcriber = speechsdk.transcription.ConversationTranscriber(speech_config=self.speech_config, audio_config=audio_config)

            transcribing_stop = False

            def stop_cb(evt: speechsdk.SessionEventArgs):
                #"""callback that signals to stop continuous recognition upon receiving an event `evt`"""
                print('CLOSING on {}'.format(evt))
                nonlocal transcribing_stop
                transcribing_stop = True

            # Connect callbacks to the events fired by the conversation transcriber
            conversation_transcriber.transcribed.connect(self.conversation_transcriber_transcribed_whole_sentence)
            #conversation_transcriber.transcribing.connect(conversation_transcriber_transcribing_cb)
            conversation_transcriber.session_started.connect(self.conversation_transcriber_session_started_cb)
            conversation_transcriber.session_stopped.connect(self.conversation_transcriber_session_stopped_cb)
            conversation_transcriber.canceled.connect(self.conversation_transcriber_recognition_canceled_cb)

            # stop transcribing on either session stopped or canceled events
            conversation_transcriber.session_stopped.connect(stop_cb)
            conversation_transcriber.canceled.connect(stop_cb)

            conversation_transcriber.start_transcribing_async()

            # Waits for completion.
            while not transcribing_stop:
                time.sleep(.5)

            conversation_transcriber.stop_transcribing_async()

            self.split_conversation_into_multiple_files(os.path.join(src, file))

class LLMSplitter:
    def __init__(self) -> None:
        keyvault_name = os.environ["KEY_VAULT_NAME"]

        # Set these variables to the names you created for your secrets
        KEY_SECRET_NAME = "com754-ai-key"
        ENDPOINT_SECRET_NAME = "com754-ai-endpoint"

        # URI for accessing key vault
        keyvault_uri = f"https://{keyvault_name}.vault.azure.net"

        # Instantiate the client and retrieve secrets
        credential = DefaultAzureCredential()
        kv_client = SecretClient(vault_url=keyvault_uri, credential=credential)

        print(f"Retrieving your secrets from {keyvault_name}.")

        api_key = kv_client.get_secret(KEY_SECRET_NAME).value
        endpoint = kv_client.get_secret(ENDPOINT_SECRET_NAME).value
        self.MODEL = "gpt-5-mini"

        self.client = OpenAI(
            base_url=endpoint,
            api_key=api_key
        )                

    def _convert_json_into_dict(self, conversations_list: list) -> OrderedDict:
        """
        Converts a json into an ordered dict and fills out durations based on offset
        
        :param conversations: JSON needing converting
        :type conversations: dict
        """
        conversations_dict = OrderedDict()

        last_offset_in_miliseconds = None
        for turn in conversations_list:
            offset = datetime.strptime(turn.offset, "%M:%S")
            offset_in_miliseconds = (offset.minute * 60 + offset.second) * 1000
            conversations_dict[offset_in_miliseconds] = {
                "speaker": turn.speaker,  # type: ignore
                "text": turn.text,
                "duration": 0
            }

            if last_offset_in_miliseconds is not None:
                conversations_dict[last_offset_in_miliseconds]["duration"] = offset_in_miliseconds - last_offset_in_miliseconds
                # duration of the last turn will be determined by reading the mp3 directly

            last_offset_in_miliseconds = offset_in_miliseconds            

        return conversations_dict

    def _parse_pdf_into_json(self, file_path: str) -> OrderedDict | None:
        with open(file_path, "rb") as f:
            data = f.read()

        base64_string = base64.b64encode(data).decode("utf-8")
        _, tail = os.path.split(file_path)

        print("Parsing {} into a json".format(tail))

        response = self.client.responses.parse(
            model=self.MODEL,
            store=False,
            reasoning={"effort": "medium"},
            instructions="""
                You have to parse the input pdf into a json.
            """,
            input=[
                {
                    "role": "user",
                    "content": [
                        {
                            "type": "input_file",
                            "filename": tail,
                            "file_data": f"data:application/pdf;base64,{base64_string}",
                        },
                    ]
                }
            ],
            text_format=Conversation
        )


        if response.output_parsed is not None:
            dict_conversation = self._convert_json_into_dict(response.output_parsed.root)
            print("Parsed {} into a json".format(tail))
            return dict_conversation

        return None
    
    def split_recordings(self):
        #src = os.path.abspath(os.path.join(".", "Audio Recordings", "V"))
        src = os.path.abspath(os.path.join(".", "Audio Recordings", "V-Processing"))
        transcripts_src = os.path.abspath(os.path.join(".", "Transcripts"))

        # try:
        #     convert(transcripts_src)
        # except:
        #     print("An conversion error happened")

        files = [f for f in os.listdir(transcripts_src) if ".pdf" in f]
        for file in files:
            transcript_path = os.path.join(transcripts_src, file)
            audio_path = os.path.join(src, file.replace(".pdf", ".wav"))
            conversation = self._parse_pdf_into_json(transcript_path)

            if conversation is None:
                continue

            new_directory = os.path.abspath(os.path.join(src, file[:-4]))

            if (not os.path.exists(new_directory)):
                os.mkdir(new_directory)

            split_audio_file(audio_path, new_directory, conversation)

#transcriber = Transcriber()
#transcriber2 = Transcriber()

#t1 = threading.Thread(target=transcriber.diarise_and_split_dataset, args=(os.path.abspath(os.path.join(".", "Audio Recordings", "NV-Processing")),))
#t2 = threading.Thread(target=transcriber2.diarise_and_split_dataset, args=(os.path.abspath(os.path.join(".", "Audio Recordings", "V-Processing")),))

#t1.start()
#t2.start()

#t1.join()
#t2.join()
# convert_existing_mp3s(
#     src=os.path.abspath(os.path.join(".", "Audio Recordings", "NV-Processing")),
#     dest=os.path.abspath(os.path.join(".", "Audio Recordings", "NV-Processing")),
# )

"""convert_existing_mp3s(
    src=os.path.abspath(os.path.join(".", "Audio Recordings", "V")),
    dest=os.path.abspath(os.path.join(".", "Audio Recordings", "V-Processing")),
)"""

LLMSplitter().split_recordings()

""" augment_dataset(
    src=os.path.abspath(os.path.join(".", "Audio Recordings", "NV")),
    dest=os.path.abspath(os.path.join(".", "Audio Recordings", "NV-Processing")),
    counter=410, 
    count_to_reach=420
 )"""

