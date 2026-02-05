import logging
from sys import api_version
from azure.identity import DefaultAzureCredential
from azure.servicebus import ServiceBusClient
from dependency_injector import containers, providers
from openai import AsyncAzureOpenAI

from secrets_provider import KeyVaultSecretsProvider
from call_analyser import CallAnalyser
from azure.communication.callautomation import CallAutomationClient
from azure.communication.identity import CommunicationIdentityClient

class Container(containers.DeclarativeContainer):
    credential = providers.Singleton(DefaultAzureCredential)

    secrets_provider = providers.Singleton(KeyVaultSecretsProvider)
    secrets = providers.Singleton(lambda sp: sp.load(), secrets_provider)

    identity_client = providers.Singleton(
        CommunicationIdentityClient.from_connection_string,
        conn_str=providers.Callable(
            lambda s: f"endpoint={s.cs_endpoint}/;accesskey={s.cs_key}",
            secrets,
        ),
    )

    call_automation_client = providers.Singleton(
        CallAutomationClient,
        credential=credential,
        endpoint=providers.Callable(lambda s: s.cs_endpoint, secrets),
    )

    ai_client = providers.Singleton(
        AsyncAzureOpenAI,
        api_version="2025-03-01-preview",
        azure_endpoint=providers.Callable(lambda s: s.ai_endpoint, secrets),
        api_key=providers.Callable(lambda s: s.ai_key, secrets),
    )

    servicebus_client = providers.Singleton(
        ServiceBusClient.from_connection_string,
        conn_str=providers.Callable(lambda s: s.sb_connectionstring, secrets)
    )

    call_analyser = providers.Singleton(
        CallAnalyser,
        call_automation_client=call_automation_client,
        identity_client=identity_client,
        servicebus_client=servicebus_client,
        ai_client=ai_client,
        local_endpoint=providers.Callable(lambda s: s.dt_endpoint, secrets),
    )
