param vaults_com754_kv_name string = 'com754-kv'
param serverfarms_com754_asp_name string = 'com754-asp'
param virtualNetworks_com754_vnet_name string = 'com754-vnet'
param accounts_com754_ss_name string = 'com754-ss'
param components_com754_as_detector_name string = 'com754-as-detector'
param accounts_com754_ss_ai_name string = 'com754-ss-ai'
param systemTopics_com754_egst_calls_name string = 'com754-egst-calls'
param workspaces_com754_ls_name string = 'com754-ls'
param sites_com754_as_transcript_and_detect_name string = 'com754-as-transcript-and-detect'
param accounts_com754_ai_general_name string = 'com754-ai-general'
param CommunicationServices_com754cs_name string = 'com754cs'
param namespaces_com754_sb_detection_results_name string = 'com754-sb-detection-results'
param actionGroups_Application_Insights_Smart_Detection_name string = 'Application Insights Smart Detection'

resource accounts_com754_ai_general_name_resource 'Microsoft.CognitiveServices/accounts@2025-10-01-preview' = {
  name: accounts_com754_ai_general_name
  location: 'swedencentral'
  sku: {
    name: 'S0'
  }
  kind: 'AIServices'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    apiProperties: {}
    customSubDomainName: accounts_com754_ai_general_name
    networkAcls: {
      defaultAction: 'Allow'
      virtualNetworkRules: []
      ipRules: []
    }
    allowProjectManagement: true
    defaultProject: 'proj-default'
    associatedProjects: [
      'proj-default'
    ]
    publicNetworkAccess: 'Enabled'
    storedCompletionsDisabled: false
  }
}

resource accounts_com754_ss_name_resource 'Microsoft.CognitiveServices/accounts@2025-10-01-preview' = {
  name: accounts_com754_ss_name
  location: 'francecentral'
  sku: {
    name: 'S0'
  }
  kind: 'SpeechServices'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    networkAcls: {
      defaultAction: 'Allow'
      virtualNetworkRules: []
      ipRules: []
    }
    allowProjectManagement: false
    publicNetworkAccess: 'Enabled'
  }
}

resource accounts_com754_ss_ai_name_resource 'Microsoft.CognitiveServices/accounts@2025-10-01-preview' = {
  name: accounts_com754_ss_ai_name
  location: 'francecentral'
  sku: {
    name: 'S0'
  }
  kind: 'OpenAI'
  properties: {
    apiProperties: {}
    allowProjectManagement: false
    publicNetworkAccess: 'Enabled'
  }
}

resource CommunicationServices_com754cs_name_resource 'Microsoft.Communication/CommunicationServices@2025-09-01' = {
  name: CommunicationServices_com754cs_name
  location: 'global'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    dataLocation: 'france'
  }
}

resource actionGroups_Application_Insights_Smart_Detection_name_resource 'microsoft.insights/actionGroups@2024-10-01-preview' = {
  name: actionGroups_Application_Insights_Smart_Detection_name
  location: 'Global'
  properties: {
    groupShortName: 'SmartDetect'
    enabled: true
    emailReceivers: []
    smsReceivers: []
    webhookReceivers: []
    eventHubReceivers: []
    itsmReceivers: []
    azureAppPushReceivers: []
    automationRunbookReceivers: []
    voiceReceivers: []
    logicAppReceivers: []
    azureFunctionReceivers: []
    armRoleReceivers: [
      {
        name: 'Monitoring Contributor'
        roleId: '749f88d5-cbae-40b8-bcfc-e573ddc772fa'
        useCommonAlertSchema: true
      }
      {
        name: 'Monitoring Reader'
        roleId: '43d0d8ad-25c7-4714-9337-8ba259a9fe05'
        useCommonAlertSchema: true
      }
    ]
  }
}

resource vaults_com754_kv_name_resource 'Microsoft.KeyVault/vaults@2025-05-01' = {
  name: vaults_com754_kv_name
  location: 'francecentral'
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: '0bba78d8-4f4d-4dd9-9b5a-ee121b116efe'
    networkAcls: {
      bypass: 'None'
      defaultAction: 'Allow'
      ipRules: []
      virtualNetworkRules: []
    }
    accessPolicies: [
      {
        tenantId: '0bba78d8-4f4d-4dd9-9b5a-ee121b116efe'
        objectId: 'e4d1d826-0f62-4933-9ecf-33450eda3890'
        permissions: {
          keys: []
          secrets: [
            'delete'
            'get'
            'list'
            'set'
            'purge'
          ]
          certificates: []
          storage: []
        }
      }
      {
        tenantId: '0bba78d8-4f4d-4dd9-9b5a-ee121b116efe'
        objectId: 'e850f297-c3bc-4616-a32c-a0b261991321'
        permissions: {
          secrets: [
            'get'
            'list'
            'set'
            'delete'
          ]
        }
      }
    ]
    enabledForDeployment: false
    enabledForDiskEncryption: false
    enabledForTemplateDeployment: false
    enableSoftDelete: true
    softDeleteRetentionInDays: 90
    enableRbacAuthorization: true
    vaultUri: 'https://${vaults_com754_kv_name}.vault.azure.net/'
    provisioningState: 'Succeeded'
    publicNetworkAccess: 'Enabled'
  }
}

resource virtualNetworks_com754_vnet_name_resource 'Microsoft.Network/virtualNetworks@2025-05-01' = {
  name: virtualNetworks_com754_vnet_name
  location: 'francecentral'
  properties: {
    addressSpace: {
      addressPrefixes: [
        '172.16.0.0/26'
      ]
    }
    privateEndpointVNetPolicies: 'Disabled'
    subnets: [
      {
        name: 'com754-subnet'
        id: virtualNetworks_com754_vnet_name_com754_subnet.id
        properties: {
          addressPrefix: '172.16.0.0/26'
          serviceEndpoints: [
            {
              service: 'Microsoft.CognitiveServices'
              locations: [
                '*'
              ]
            }
          ]
          delegations: []
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
        type: 'Microsoft.Network/virtualNetworks/subnets'
      }
    ]
    virtualNetworkPeerings: []
    enableDdosProtection: false
  }
}

resource workspaces_com754_ls_name_resource 'Microsoft.OperationalInsights/workspaces@2025-07-01' = {
  name: workspaces_com754_ls_name
  location: 'francecentral'
  properties: {
    sku: {
      name: 'pergb2018'
    }
    retentionInDays: 30
    features: {
      legacy: 0
      searchVersion: 1
      enableLogAccessUsingOnlyResourcePermissions: true
    }
    workspaceCapping: {
      dailyQuotaGb: json('-1')
    }
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

resource namespaces_com754_sb_detection_results_name_resource 'Microsoft.ServiceBus/namespaces@2025-05-01-preview' = {
  name: namespaces_com754_sb_detection_results_name
  location: 'francecentral'
  sku: {
    name: 'Standard'
    tier: 'Standard'
  }
  properties: {
    platformCapabilities: {
      confidentialCompute: {
        mode: 'Disabled'
      }
    }
    geoDataReplication: {
      maxReplicationLagDurationInSeconds: 0
      locations: [
        {
          locationName: 'francecentral'
          roleType: 'Primary'
        }
      ]
    }
    premiumMessagingPartitions: 0
    minimumTlsVersion: '1.2'
    publicNetworkAccess: 'Enabled'
    disableLocalAuth: false
    zoneRedundant: true
  }
}

resource serverfarms_com754_asp_name_resource 'Microsoft.Web/serverfarms@2024-11-01' = {
  name: serverfarms_com754_asp_name
  location: 'France Central'
  sku: {
    name: 'B3'
    tier: 'Basic'
    size: 'B3'
    family: 'B'
    capacity: 1
  }
  kind: 'linux'
  properties: {
    perSiteScaling: false
    elasticScaleEnabled: false
    maximumElasticWorkerCount: 1
    isSpot: false
    reserved: true
    isXenon: false
    hyperV: false
    targetWorkerCount: 0
    targetWorkerSizeId: 0
    zoneRedundant: false
    asyncScalingEnabled: false
  }
}

resource accounts_com754_ai_general_name_Default 'Microsoft.CognitiveServices/accounts/defenderForAISettings@2025-10-01-preview' = {
  parent: accounts_com754_ai_general_name_resource
  name: 'Default'
  properties: {
    state: 'Disabled'
  }
}

resource accounts_com754_ss_ai_name_Default 'Microsoft.CognitiveServices/accounts/defenderForAISettings@2025-10-01-preview' = {
  parent: accounts_com754_ss_ai_name_resource
  name: 'Default'
  properties: {
    state: 'Disabled'
  }
}

resource accounts_com754_ai_general_name_gpt_5_mini 'Microsoft.CognitiveServices/accounts/deployments@2025-10-01-preview' = {
  parent: accounts_com754_ai_general_name_resource
  name: 'gpt-5-mini'
  sku: {
    name: 'GlobalStandard'
    capacity: 100
  }
  properties: {
    model: {
      format: 'OpenAI'
      name: 'gpt-5-mini'
      version: '2025-08-07'
    }
    versionUpgradeOption: 'OnceNewDefaultVersionAvailable'
    currentCapacity: 100
    raiPolicyName: 'Microsoft.DefaultV2'
    deploymentState: 'Running'
  }
}

resource accounts_com754_ai_general_name_proj_default 'Microsoft.CognitiveServices/accounts/projects@2025-10-01-preview' = {
  parent: accounts_com754_ai_general_name_resource
  name: 'proj-default'
  location: 'swedencentral'
  kind: 'AIServices'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    description: 'Default project created with the resource'
    displayName: 'proj-default'
  }
}

resource accounts_com754_ai_general_name_Microsoft_Default 'Microsoft.CognitiveServices/accounts/raiPolicies@2025-10-01-preview' = {
  parent: accounts_com754_ai_general_name_resource
  name: 'Microsoft.Default'
  properties: {
    mode: 'Blocking'
    contentFilters: [
      {
        name: 'Hate'
        severityThreshold: 'Medium'
        blocking: true
        enabled: true
        source: 'Prompt'
        action: 'NONE'
      }
      {
        name: 'Hate'
        severityThreshold: 'Medium'
        blocking: true
        enabled: true
        source: 'Completion'
        action: 'NONE'
      }
      {
        name: 'Sexual'
        severityThreshold: 'Medium'
        blocking: true
        enabled: true
        source: 'Prompt'
        action: 'NONE'
      }
      {
        name: 'Sexual'
        severityThreshold: 'Medium'
        blocking: true
        enabled: true
        source: 'Completion'
        action: 'NONE'
      }
      {
        name: 'Violence'
        severityThreshold: 'Medium'
        blocking: true
        enabled: true
        source: 'Prompt'
        action: 'NONE'
      }
      {
        name: 'Violence'
        severityThreshold: 'Medium'
        blocking: true
        enabled: true
        source: 'Completion'
        action: 'NONE'
      }
      {
        name: 'Selfharm'
        severityThreshold: 'Medium'
        blocking: true
        enabled: true
        source: 'Prompt'
        action: 'NONE'
      }
      {
        name: 'Selfharm'
        severityThreshold: 'Medium'
        blocking: true
        enabled: true
        source: 'Completion'
        action: 'NONE'
      }
    ]
  }
}

resource accounts_com754_ss_ai_name_Microsoft_Default 'Microsoft.CognitiveServices/accounts/raiPolicies@2025-10-01-preview' = {
  parent: accounts_com754_ss_ai_name_resource
  name: 'Microsoft.Default'
  properties: {
    mode: 'Blocking'
    contentFilters: [
      {
        name: 'Hate'
        severityThreshold: 'Medium'
        blocking: true
        enabled: true
        source: 'Prompt'
        action: 'NONE'
      }
      {
        name: 'Hate'
        severityThreshold: 'Medium'
        blocking: true
        enabled: true
        source: 'Completion'
        action: 'NONE'
      }
      {
        name: 'Sexual'
        severityThreshold: 'Medium'
        blocking: true
        enabled: true
        source: 'Prompt'
        action: 'NONE'
      }
      {
        name: 'Sexual'
        severityThreshold: 'Medium'
        blocking: true
        enabled: true
        source: 'Completion'
        action: 'NONE'
      }
      {
        name: 'Violence'
        severityThreshold: 'Medium'
        blocking: true
        enabled: true
        source: 'Prompt'
        action: 'NONE'
      }
      {
        name: 'Violence'
        severityThreshold: 'Medium'
        blocking: true
        enabled: true
        source: 'Completion'
        action: 'NONE'
      }
      {
        name: 'Selfharm'
        severityThreshold: 'Medium'
        blocking: true
        enabled: true
        source: 'Prompt'
        action: 'NONE'
      }
      {
        name: 'Selfharm'
        severityThreshold: 'Medium'
        blocking: true
        enabled: true
        source: 'Completion'
        action: 'NONE'
      }
    ]
  }
}

resource accounts_com754_ai_general_name_Microsoft_DefaultV2 'Microsoft.CognitiveServices/accounts/raiPolicies@2025-10-01-preview' = {
  parent: accounts_com754_ai_general_name_resource
  name: 'Microsoft.DefaultV2'
  properties: {
    mode: 'Blocking'
    contentFilters: [
      {
        name: 'Hate'
        severityThreshold: 'Medium'
        blocking: true
        enabled: true
        source: 'Prompt'
        action: 'NONE'
      }
      {
        name: 'Hate'
        severityThreshold: 'Medium'
        blocking: true
        enabled: true
        source: 'Completion'
        action: 'NONE'
      }
      {
        name: 'Sexual'
        severityThreshold: 'Medium'
        blocking: true
        enabled: true
        source: 'Prompt'
        action: 'NONE'
      }
      {
        name: 'Sexual'
        severityThreshold: 'Medium'
        blocking: true
        enabled: true
        source: 'Completion'
        action: 'NONE'
      }
      {
        name: 'Violence'
        severityThreshold: 'Medium'
        blocking: true
        enabled: true
        source: 'Prompt'
        action: 'NONE'
      }
      {
        name: 'Violence'
        severityThreshold: 'Medium'
        blocking: true
        enabled: true
        source: 'Completion'
        action: 'NONE'
      }
      {
        name: 'Selfharm'
        severityThreshold: 'Medium'
        blocking: true
        enabled: true
        source: 'Prompt'
        action: 'NONE'
      }
      {
        name: 'Selfharm'
        severityThreshold: 'Medium'
        blocking: true
        enabled: true
        source: 'Completion'
        action: 'NONE'
      }
      {
        name: 'Jailbreak'
        blocking: true
        enabled: true
        source: 'Prompt'
        action: 'NONE'
      }
      {
        name: 'Protected Material Text'
        blocking: true
        enabled: true
        source: 'Completion'
        action: 'NONE'
      }
      {
        name: 'Protected Material Code'
        blocking: false
        enabled: true
        source: 'Completion'
        action: 'NONE'
      }
    ]
  }
}

resource accounts_com754_ss_ai_name_Microsoft_DefaultV2 'Microsoft.CognitiveServices/accounts/raiPolicies@2025-10-01-preview' = {
  parent: accounts_com754_ss_ai_name_resource
  name: 'Microsoft.DefaultV2'
  properties: {
    mode: 'Blocking'
    contentFilters: [
      {
        name: 'Hate'
        severityThreshold: 'Medium'
        blocking: true
        enabled: true
        source: 'Prompt'
        action: 'NONE'
      }
      {
        name: 'Hate'
        severityThreshold: 'Medium'
        blocking: true
        enabled: true
        source: 'Completion'
        action: 'NONE'
      }
      {
        name: 'Sexual'
        severityThreshold: 'Medium'
        blocking: true
        enabled: true
        source: 'Prompt'
        action: 'NONE'
      }
      {
        name: 'Sexual'
        severityThreshold: 'Medium'
        blocking: true
        enabled: true
        source: 'Completion'
        action: 'NONE'
      }
      {
        name: 'Violence'
        severityThreshold: 'Medium'
        blocking: true
        enabled: true
        source: 'Prompt'
        action: 'NONE'
      }
      {
        name: 'Violence'
        severityThreshold: 'Medium'
        blocking: true
        enabled: true
        source: 'Completion'
        action: 'NONE'
      }
      {
        name: 'Selfharm'
        severityThreshold: 'Medium'
        blocking: true
        enabled: true
        source: 'Prompt'
        action: 'NONE'
      }
      {
        name: 'Selfharm'
        severityThreshold: 'Medium'
        blocking: true
        enabled: true
        source: 'Completion'
        action: 'NONE'
      }
      {
        name: 'Jailbreak'
        blocking: true
        enabled: true
        source: 'Prompt'
        action: 'NONE'
      }
      {
        name: 'Protected Material Text'
        blocking: true
        enabled: true
        source: 'Completion'
        action: 'NONE'
      }
      {
        name: 'Protected Material Code'
        blocking: false
        enabled: true
        source: 'Completion'
        action: 'NONE'
      }
    ]
  }
}

resource systemTopics_com754_egst_calls_name_resource 'Microsoft.EventGrid/systemTopics@2025-07-15-preview' = {
  name: systemTopics_com754_egst_calls_name
  location: 'global'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    source: CommunicationServices_com754cs_name_resource.id
    topicType: 'Microsoft.Communication.CommunicationServices'
  }
}

resource systemTopics_com754_egst_calls_name_com754_es_http_prod 'Microsoft.EventGrid/systemTopics/eventSubscriptions@2025-07-15-preview' = {
  parent: systemTopics_com754_egst_calls_name_resource
  name: 'com754-es-http-prod'
  properties: {
    destination: {
      properties: {
        maxEventsPerBatch: 1
        preferredBatchSizeInKilobytes: 64
        minimumTlsVersionAllowed: '1.2'
      }
      endpointType: 'WebHook'
    }
    filter: {
      includedEventTypes: [
        'Microsoft.Communication.CallStarted'
        'Microsoft.Communication.CallEnded'
      ]
      enableAdvancedFilteringOnArrays: true
    }
    labels: []
    eventDeliverySchema: 'EventGridSchema'
    retryPolicy: {
      maxDeliveryAttempts: 30
      eventTimeToLiveInMinutes: 1440
    }
  }
}

resource components_com754_as_detector_name_resource 'microsoft.insights/components@2020-02-02' = {
  name: components_com754_as_detector_name
  location: 'francecentral'
  kind: 'web'
  properties: {
    Application_Type: 'web'
    RetentionInDays: 90
    WorkspaceResourceId: workspaces_com754_ls_name_resource.id
    IngestionMode: 'LogAnalytics'
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

resource components_com754_as_detector_name_degradationindependencyduration 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_com754_as_detector_name_resource
  name: 'degradationindependencyduration'
  location: 'francecentral'
  properties: {
    RuleDefinitions: {
      Name: 'degradationindependencyduration'
      DisplayName: 'Degradation in dependency duration'
      Description: 'Smart Detection rules notify you of performance anomaly issues.'
      HelpUrl: 'https://docs.microsoft.com/en-us/azure/application-insights/app-insights-proactive-performance-diagnostics'
      IsHidden: false
      IsEnabledByDefault: true
      IsInPreview: false
      SupportsEmailNotifications: true
    }
    Enabled: true
    SendEmailsToSubscriptionOwners: true
    CustomEmails: []
  }
}

resource components_com754_as_detector_name_degradationinserverresponsetime 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_com754_as_detector_name_resource
  name: 'degradationinserverresponsetime'
  location: 'francecentral'
  properties: {
    RuleDefinitions: {
      Name: 'degradationinserverresponsetime'
      DisplayName: 'Degradation in server response time'
      Description: 'Smart Detection rules notify you of performance anomaly issues.'
      HelpUrl: 'https://docs.microsoft.com/en-us/azure/application-insights/app-insights-proactive-performance-diagnostics'
      IsHidden: false
      IsEnabledByDefault: true
      IsInPreview: false
      SupportsEmailNotifications: true
    }
    Enabled: true
    SendEmailsToSubscriptionOwners: true
    CustomEmails: []
  }
}

resource components_com754_as_detector_name_digestMailConfiguration 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_com754_as_detector_name_resource
  name: 'digestMailConfiguration'
  location: 'francecentral'
  properties: {
    RuleDefinitions: {
      Name: 'digestMailConfiguration'
      DisplayName: 'Digest Mail Configuration'
      Description: 'This rule describes the digest mail preferences'
      HelpUrl: 'www.homail.com'
      IsHidden: true
      IsEnabledByDefault: true
      IsInPreview: false
      SupportsEmailNotifications: true
    }
    Enabled: true
    SendEmailsToSubscriptionOwners: true
    CustomEmails: []
  }
}

resource components_com754_as_detector_name_extension_billingdatavolumedailyspikeextension 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_com754_as_detector_name_resource
  name: 'extension_billingdatavolumedailyspikeextension'
  location: 'francecentral'
  properties: {
    RuleDefinitions: {
      Name: 'extension_billingdatavolumedailyspikeextension'
      DisplayName: 'Abnormal rise in daily data volume (preview)'
      Description: 'This detection rule automatically analyzes the billing data generated by your application, and can warn you about an unusual increase in your application\'s billing costs'
      HelpUrl: 'https://github.com/Microsoft/ApplicationInsights-Home/tree/master/SmartDetection/billing-data-volume-daily-spike.md'
      IsHidden: false
      IsEnabledByDefault: true
      IsInPreview: true
      SupportsEmailNotifications: false
    }
    Enabled: true
    SendEmailsToSubscriptionOwners: true
    CustomEmails: []
  }
}

resource components_com754_as_detector_name_extension_canaryextension 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_com754_as_detector_name_resource
  name: 'extension_canaryextension'
  location: 'francecentral'
  properties: {
    RuleDefinitions: {
      Name: 'extension_canaryextension'
      DisplayName: 'Canary extension'
      Description: 'Canary extension'
      HelpUrl: 'https://github.com/Microsoft/ApplicationInsights-Home/blob/master/SmartDetection/'
      IsHidden: true
      IsEnabledByDefault: true
      IsInPreview: true
      SupportsEmailNotifications: false
    }
    Enabled: true
    SendEmailsToSubscriptionOwners: true
    CustomEmails: []
  }
}

resource components_com754_as_detector_name_extension_exceptionchangeextension 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_com754_as_detector_name_resource
  name: 'extension_exceptionchangeextension'
  location: 'francecentral'
  properties: {
    RuleDefinitions: {
      Name: 'extension_exceptionchangeextension'
      DisplayName: 'Abnormal rise in exception volume (preview)'
      Description: 'This detection rule automatically analyzes the exceptions thrown in your application, and can warn you about unusual patterns in your exception telemetry.'
      HelpUrl: 'https://github.com/Microsoft/ApplicationInsights-Home/blob/master/SmartDetection/abnormal-rise-in-exception-volume.md'
      IsHidden: false
      IsEnabledByDefault: true
      IsInPreview: true
      SupportsEmailNotifications: false
    }
    Enabled: true
    SendEmailsToSubscriptionOwners: true
    CustomEmails: []
  }
}

resource components_com754_as_detector_name_extension_memoryleakextension 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_com754_as_detector_name_resource
  name: 'extension_memoryleakextension'
  location: 'francecentral'
  properties: {
    RuleDefinitions: {
      Name: 'extension_memoryleakextension'
      DisplayName: 'Potential memory leak detected (preview)'
      Description: 'This detection rule automatically analyzes the memory consumption of each process in your application, and can warn you about potential memory leaks or increased memory consumption.'
      HelpUrl: 'https://github.com/Microsoft/ApplicationInsights-Home/tree/master/SmartDetection/memory-leak.md'
      IsHidden: false
      IsEnabledByDefault: true
      IsInPreview: true
      SupportsEmailNotifications: false
    }
    Enabled: true
    SendEmailsToSubscriptionOwners: true
    CustomEmails: []
  }
}

resource components_com754_as_detector_name_extension_securityextensionspackage 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_com754_as_detector_name_resource
  name: 'extension_securityextensionspackage'
  location: 'francecentral'
  properties: {
    RuleDefinitions: {
      Name: 'extension_securityextensionspackage'
      DisplayName: 'Potential security issue detected (preview)'
      Description: 'This detection rule automatically analyzes the telemetry generated by your application and detects potential security issues.'
      HelpUrl: 'https://github.com/Microsoft/ApplicationInsights-Home/blob/master/SmartDetection/application-security-detection-pack.md'
      IsHidden: false
      IsEnabledByDefault: true
      IsInPreview: true
      SupportsEmailNotifications: false
    }
    Enabled: true
    SendEmailsToSubscriptionOwners: true
    CustomEmails: []
  }
}

resource components_com754_as_detector_name_extension_traceseveritydetector 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_com754_as_detector_name_resource
  name: 'extension_traceseveritydetector'
  location: 'francecentral'
  properties: {
    RuleDefinitions: {
      Name: 'extension_traceseveritydetector'
      DisplayName: 'Degradation in trace severity ratio (preview)'
      Description: 'This detection rule automatically analyzes the trace logs emitted from your application, and can warn you about unusual patterns in the severity of your trace telemetry.'
      HelpUrl: 'https://github.com/Microsoft/ApplicationInsights-Home/blob/master/SmartDetection/degradation-in-trace-severity-ratio.md'
      IsHidden: false
      IsEnabledByDefault: true
      IsInPreview: true
      SupportsEmailNotifications: false
    }
    Enabled: true
    SendEmailsToSubscriptionOwners: true
    CustomEmails: []
  }
}

resource components_com754_as_detector_name_longdependencyduration 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_com754_as_detector_name_resource
  name: 'longdependencyduration'
  location: 'francecentral'
  properties: {
    RuleDefinitions: {
      Name: 'longdependencyduration'
      DisplayName: 'Long dependency duration'
      Description: 'Smart Detection rules notify you of performance anomaly issues.'
      HelpUrl: 'https://docs.microsoft.com/en-us/azure/application-insights/app-insights-proactive-performance-diagnostics'
      IsHidden: false
      IsEnabledByDefault: true
      IsInPreview: false
      SupportsEmailNotifications: true
    }
    Enabled: true
    SendEmailsToSubscriptionOwners: true
    CustomEmails: []
  }
}

resource components_com754_as_detector_name_migrationToAlertRulesCompleted 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_com754_as_detector_name_resource
  name: 'migrationToAlertRulesCompleted'
  location: 'francecentral'
  properties: {
    RuleDefinitions: {
      Name: 'migrationToAlertRulesCompleted'
      DisplayName: 'Migration To Alert Rules Completed'
      Description: 'A configuration that controls the migration state of Smart Detection to Smart Alerts'
      HelpUrl: 'https://docs.microsoft.com/en-us/azure/application-insights/app-insights-proactive-performance-diagnostics'
      IsHidden: true
      IsEnabledByDefault: false
      IsInPreview: true
      SupportsEmailNotifications: false
    }
    Enabled: false
    SendEmailsToSubscriptionOwners: true
    CustomEmails: []
  }
}

resource components_com754_as_detector_name_slowpageloadtime 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_com754_as_detector_name_resource
  name: 'slowpageloadtime'
  location: 'francecentral'
  properties: {
    RuleDefinitions: {
      Name: 'slowpageloadtime'
      DisplayName: 'Slow page load time'
      Description: 'Smart Detection rules notify you of performance anomaly issues.'
      HelpUrl: 'https://docs.microsoft.com/en-us/azure/application-insights/app-insights-proactive-performance-diagnostics'
      IsHidden: false
      IsEnabledByDefault: true
      IsInPreview: false
      SupportsEmailNotifications: true
    }
    Enabled: true
    SendEmailsToSubscriptionOwners: true
    CustomEmails: []
  }
}

resource components_com754_as_detector_name_slowserverresponsetime 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_com754_as_detector_name_resource
  name: 'slowserverresponsetime'
  location: 'francecentral'
  properties: {
    RuleDefinitions: {
      Name: 'slowserverresponsetime'
      DisplayName: 'Slow server response time'
      Description: 'Smart Detection rules notify you of performance anomaly issues.'
      HelpUrl: 'https://docs.microsoft.com/en-us/azure/application-insights/app-insights-proactive-performance-diagnostics'
      IsHidden: false
      IsEnabledByDefault: true
      IsInPreview: false
      SupportsEmailNotifications: true
    }
    Enabled: true
    SendEmailsToSubscriptionOwners: true
    CustomEmails: []
  }
}

resource vaults_com754_kv_name_com754_ai_endpoint 'Microsoft.KeyVault/vaults/secrets@2025-05-01' = {
  parent: vaults_com754_kv_name_resource
  name: 'com754-ai-endpoint'
  location: 'francecentral'
  properties: {
    attributes: {
      enabled: true
      exp: 1770580800
    }
  }
}

resource vaults_com754_kv_name_com754_ai_key 'Microsoft.KeyVault/vaults/secrets@2025-05-01' = {
  parent: vaults_com754_kv_name_resource
  name: 'com754-ai-key'
  location: 'francecentral'
  properties: {
    attributes: {
      enabled: true
      exp: 1770546506
    }
  }
}

resource vaults_com754_kv_name_com754_cs_ai_endpoint 'Microsoft.KeyVault/vaults/secrets@2025-05-01' = {
  parent: vaults_com754_kv_name_resource
  name: 'com754-cs-ai-endpoint'
  location: 'francecentral'
  properties: {
    attributes: {
      enabled: true
      exp: 1770576063
    }
  }
}

resource vaults_com754_kv_name_com754_cs_connectionstring 'Microsoft.KeyVault/vaults/secrets@2025-05-01' = {
  parent: vaults_com754_kv_name_resource
  name: 'com754-cs-connectionstring'
  location: 'francecentral'
  properties: {
    attributes: {
      enabled: true
      exp: 1770579690
    }
  }
}

resource vaults_com754_kv_name_com754_cs_endpoint 'Microsoft.KeyVault/vaults/secrets@2025-05-01' = {
  parent: vaults_com754_kv_name_resource
  name: 'com754-cs-endpoint'
  location: 'francecentral'
  properties: {
    attributes: {
      enabled: true
      exp: 1770589107
    }
  }
}

resource vaults_com754_kv_name_com754_cs_key 'Microsoft.KeyVault/vaults/secrets@2025-05-01' = {
  parent: vaults_com754_kv_name_resource
  name: 'com754-cs-key'
  location: 'francecentral'
  properties: {
    attributes: {
      enabled: true
      exp: 1770581907
    }
  }
}

resource vaults_com754_kv_name_com754_dt_endpoint 'Microsoft.KeyVault/vaults/secrets@2025-05-01' = {
  parent: vaults_com754_kv_name_resource
  name: 'com754-dt-endpoint'
  location: 'francecentral'
  properties: {
    attributes: {
      enabled: true
      exp: 1770587255
    }
  }
}

resource vaults_com754_kv_name_com754_sb_connectionstring 'Microsoft.KeyVault/vaults/secrets@2025-05-01' = {
  parent: vaults_com754_kv_name_resource
  name: 'com754-sb-connectionstring'
  location: 'francecentral'
  properties: {
    attributes: {
      enabled: true
      exp: 1770593481
    }
  }
}

resource vaults_com754_kv_name_com754_sb_endpoint 'Microsoft.KeyVault/vaults/secrets@2025-05-01' = {
  parent: vaults_com754_kv_name_resource
  name: 'com754-sb-endpoint'
  location: 'francecentral'
  properties: {
    attributes: {
      enabled: true
      exp: 1770576731
    }
  }
}

resource vaults_com754_kv_name_com754_sm_endpoint 'Microsoft.KeyVault/vaults/secrets@2025-05-01' = {
  parent: vaults_com754_kv_name_resource
  name: 'com754-sm-endpoint'
  location: 'francecentral'
  properties: {
    attributes: {
      enabled: true
      exp: 1770573600
    }
  }
}

resource virtualNetworks_com754_vnet_name_com754_subnet 'Microsoft.Network/virtualNetworks/subnets@2025-05-01' = {
  name: '${virtualNetworks_com754_vnet_name}/com754-subnet'
  properties: {
    addressPrefix: '172.16.0.0/26'
    serviceEndpoints: [
      {
        service: 'Microsoft.CognitiveServices'
        locations: [
          '*'
        ]
      }
    ]
    delegations: []
    privateEndpointNetworkPolicies: 'Disabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
}

resource workspaces_com754_ls_name_LogManagement_workspaces_com754_ls_name_General_AlphabeticallySortedComputers 'Microsoft.OperationalInsights/workspaces/savedSearches@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'LogManagement(${workspaces_com754_ls_name})_General|AlphabeticallySortedComputers'
  properties: {
    category: 'General Exploration'
    displayName: 'All Computers with their most recent data'
    version: 2
    query: 'search not(ObjectName == "Advisor Metrics" or ObjectName == "ManagedSpace") | summarize AggregatedValue = max(TimeGenerated) by Computer | limit 500000 | sort by Computer asc\r\n// Oql: NOT(ObjectName="Advisor Metrics" OR ObjectName=ManagedSpace) | measure max(TimeGenerated) by Computer | top 500000 | Sort Computer // Args: {OQ: True; WorkspaceId: 00000000-0000-0000-0000-000000000000} // Settings: {PTT: True; SortI: True; SortF: True} // Version: 0.1.122'
  }
}

resource workspaces_com754_ls_name_LogManagement_workspaces_com754_ls_name_General_dataPointsPerManagementGroup 'Microsoft.OperationalInsights/workspaces/savedSearches@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'LogManagement(${workspaces_com754_ls_name})_General|dataPointsPerManagementGroup'
  properties: {
    category: 'General Exploration'
    displayName: 'Which Management Group is generating the most data points?'
    version: 2
    query: 'search * | summarize AggregatedValue = count() by ManagementGroupName\r\n// Oql: * | Measure count() by ManagementGroupName // Args: {OQ: True; WorkspaceId: 00000000-0000-0000-0000-000000000000} // Settings: {PTT: True; SortI: True; SortF: True} // Version: 0.1.122'
  }
}

resource workspaces_com754_ls_name_LogManagement_workspaces_com754_ls_name_General_dataTypeDistribution 'Microsoft.OperationalInsights/workspaces/savedSearches@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'LogManagement(${workspaces_com754_ls_name})_General|dataTypeDistribution'
  properties: {
    category: 'General Exploration'
    displayName: 'Distribution of data Types'
    version: 2
    query: 'search * | extend Type = $table | summarize AggregatedValue = count() by Type\r\n// Oql: * | Measure count() by Type // Args: {OQ: True; WorkspaceId: 00000000-0000-0000-0000-000000000000} // Settings: {PTT: True; SortI: True; SortF: True} // Version: 0.1.122'
  }
}

resource workspaces_com754_ls_name_LogManagement_workspaces_com754_ls_name_General_StaleComputers 'Microsoft.OperationalInsights/workspaces/savedSearches@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'LogManagement(${workspaces_com754_ls_name})_General|StaleComputers'
  properties: {
    category: 'General Exploration'
    displayName: 'Stale Computers (data older than 24 hours)'
    version: 2
    query: 'search not(ObjectName == "Advisor Metrics" or ObjectName == "ManagedSpace") | summarize lastdata = max(TimeGenerated) by Computer | limit 500000 | where lastdata < ago(24h)\r\n// Oql: NOT(ObjectName="Advisor Metrics" OR ObjectName=ManagedSpace) | measure max(TimeGenerated) as lastdata by Computer | top 500000 | where lastdata < NOW-24HOURS // Args: {OQ: True; WorkspaceId: 00000000-0000-0000-0000-000000000000} // Settings: {PTT: True; SortI: True; SortF: True} // Version: 0.1.122'
  }
}

resource workspaces_com754_ls_name_LogManagement_workspaces_com754_ls_name_LogManagement_AllEvents 'Microsoft.OperationalInsights/workspaces/savedSearches@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'LogManagement(${workspaces_com754_ls_name})_LogManagement|AllEvents'
  properties: {
    category: 'Log Management'
    displayName: 'All Events'
    version: 2
    query: 'Event | sort by TimeGenerated desc\r\n// Oql: Type=Event // Args: {OQ: True; WorkspaceId: 00000000-0000-0000-0000-000000000000} // Settings: {PTT: True; SortI: True; SortF: True} // Version: 0.1.122'
  }
}

resource workspaces_com754_ls_name_LogManagement_workspaces_com754_ls_name_LogManagement_AllSyslog 'Microsoft.OperationalInsights/workspaces/savedSearches@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'LogManagement(${workspaces_com754_ls_name})_LogManagement|AllSyslog'
  properties: {
    category: 'Log Management'
    displayName: 'All Syslogs'
    version: 2
    query: 'Syslog | sort by TimeGenerated desc\r\n// Oql: Type=Syslog // Args: {OQ: True; WorkspaceId: 00000000-0000-0000-0000-000000000000} // Settings: {PTT: True; SortI: True; SortF: True} // Version: 0.1.122'
  }
}

resource workspaces_com754_ls_name_LogManagement_workspaces_com754_ls_name_LogManagement_AllSyslogByFacility 'Microsoft.OperationalInsights/workspaces/savedSearches@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'LogManagement(${workspaces_com754_ls_name})_LogManagement|AllSyslogByFacility'
  properties: {
    category: 'Log Management'
    displayName: 'All Syslog Records grouped by Facility'
    version: 2
    query: 'Syslog | summarize AggregatedValue = count() by Facility\r\n// Oql: Type=Syslog | Measure count() by Facility // Args: {OQ: True; WorkspaceId: 00000000-0000-0000-0000-000000000000} // Settings: {PTT: True; SortI: True; SortF: True} // Version: 0.1.122'
  }
}

resource workspaces_com754_ls_name_LogManagement_workspaces_com754_ls_name_LogManagement_AllSyslogByProcess 'Microsoft.OperationalInsights/workspaces/savedSearches@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'LogManagement(${workspaces_com754_ls_name})_LogManagement|AllSyslogByProcessName'
  properties: {
    category: 'Log Management'
    displayName: 'All Syslog Records grouped by ProcessName'
    version: 2
    query: 'Syslog | summarize AggregatedValue = count() by ProcessName\r\n// Oql: Type=Syslog | Measure count() by ProcessName // Args: {OQ: True; WorkspaceId: 00000000-0000-0000-0000-000000000000} // Settings: {PTT: True; SortI: True; SortF: True} // Version: 0.1.122'
  }
}

resource workspaces_com754_ls_name_LogManagement_workspaces_com754_ls_name_LogManagement_AllSyslogsWithErrors 'Microsoft.OperationalInsights/workspaces/savedSearches@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'LogManagement(${workspaces_com754_ls_name})_LogManagement|AllSyslogsWithErrors'
  properties: {
    category: 'Log Management'
    displayName: 'All Syslog Records with Errors'
    version: 2
    query: 'Syslog | where SeverityLevel == "error" | sort by TimeGenerated desc\r\n// Oql: Type=Syslog SeverityLevel=error // Args: {OQ: True; WorkspaceId: 00000000-0000-0000-0000-000000000000} // Settings: {PTT: True; SortI: True; SortF: True} // Version: 0.1.122'
  }
}

resource workspaces_com754_ls_name_LogManagement_workspaces_com754_ls_name_LogManagement_AverageHTTPRequestTimeByClientIPAddress 'Microsoft.OperationalInsights/workspaces/savedSearches@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'LogManagement(${workspaces_com754_ls_name})_LogManagement|AverageHTTPRequestTimeByClientIPAddress'
  properties: {
    category: 'Log Management'
    displayName: 'Average HTTP Request time by Client IP Address'
    version: 2
    query: 'search * | extend Type = $table | where Type == W3CIISLog | summarize AggregatedValue = avg(TimeTaken) by cIP\r\n// Oql: Type=W3CIISLog | Measure Avg(TimeTaken) by cIP // Args: {OQ: True; WorkspaceId: 00000000-0000-0000-0000-000000000000} // Settings: {PEF: True; SortI: True; SortF: True} // Version: 0.1.122'
  }
}

resource workspaces_com754_ls_name_LogManagement_workspaces_com754_ls_name_LogManagement_AverageHTTPRequestTimeHTTPMethod 'Microsoft.OperationalInsights/workspaces/savedSearches@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'LogManagement(${workspaces_com754_ls_name})_LogManagement|AverageHTTPRequestTimeHTTPMethod'
  properties: {
    category: 'Log Management'
    displayName: 'Average HTTP Request time by HTTP Method'
    version: 2
    query: 'search * | extend Type = $table | where Type == W3CIISLog | summarize AggregatedValue = avg(TimeTaken) by csMethod\r\n// Oql: Type=W3CIISLog | Measure Avg(TimeTaken) by csMethod // Args: {OQ: True; WorkspaceId: 00000000-0000-0000-0000-000000000000} // Settings: {PEF: True; SortI: True; SortF: True} // Version: 0.1.122'
  }
}

resource workspaces_com754_ls_name_LogManagement_workspaces_com754_ls_name_LogManagement_CountIISLogEntriesClientIPAddress 'Microsoft.OperationalInsights/workspaces/savedSearches@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'LogManagement(${workspaces_com754_ls_name})_LogManagement|CountIISLogEntriesClientIPAddress'
  properties: {
    category: 'Log Management'
    displayName: 'Count of IIS Log Entries by Client IP Address'
    version: 2
    query: 'search * | extend Type = $table | where Type == W3CIISLog | summarize AggregatedValue = count() by cIP\r\n// Oql: Type=W3CIISLog | Measure count() by cIP // Args: {OQ: True; WorkspaceId: 00000000-0000-0000-0000-000000000000} // Settings: {PEF: True; SortI: True; SortF: True} // Version: 0.1.122'
  }
}

resource workspaces_com754_ls_name_LogManagement_workspaces_com754_ls_name_LogManagement_CountIISLogEntriesHTTPRequestMethod 'Microsoft.OperationalInsights/workspaces/savedSearches@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'LogManagement(${workspaces_com754_ls_name})_LogManagement|CountIISLogEntriesHTTPRequestMethod'
  properties: {
    category: 'Log Management'
    displayName: 'Count of IIS Log Entries by HTTP Request Method'
    version: 2
    query: 'search * | extend Type = $table | where Type == W3CIISLog | summarize AggregatedValue = count() by csMethod\r\n// Oql: Type=W3CIISLog | Measure count() by csMethod // Args: {OQ: True; WorkspaceId: 00000000-0000-0000-0000-000000000000} // Settings: {PEF: True; SortI: True; SortF: True} // Version: 0.1.122'
  }
}

resource workspaces_com754_ls_name_LogManagement_workspaces_com754_ls_name_LogManagement_CountIISLogEntriesHTTPUserAgent 'Microsoft.OperationalInsights/workspaces/savedSearches@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'LogManagement(${workspaces_com754_ls_name})_LogManagement|CountIISLogEntriesHTTPUserAgent'
  properties: {
    category: 'Log Management'
    displayName: 'Count of IIS Log Entries by HTTP User Agent'
    version: 2
    query: 'search * | extend Type = $table | where Type == W3CIISLog | summarize AggregatedValue = count() by csUserAgent\r\n// Oql: Type=W3CIISLog | Measure count() by csUserAgent // Args: {OQ: True; WorkspaceId: 00000000-0000-0000-0000-000000000000} // Settings: {PEF: True; SortI: True; SortF: True} // Version: 0.1.122'
  }
}

resource workspaces_com754_ls_name_LogManagement_workspaces_com754_ls_name_LogManagement_CountOfIISLogEntriesByHostRequestedByClient 'Microsoft.OperationalInsights/workspaces/savedSearches@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'LogManagement(${workspaces_com754_ls_name})_LogManagement|CountOfIISLogEntriesByHostRequestedByClient'
  properties: {
    category: 'Log Management'
    displayName: 'Count of IIS Log Entries by Host requested by client'
    version: 2
    query: 'search * | extend Type = $table | where Type == W3CIISLog | summarize AggregatedValue = count() by csHost\r\n// Oql: Type=W3CIISLog | Measure count() by csHost // Args: {OQ: True; WorkspaceId: 00000000-0000-0000-0000-000000000000} // Settings: {PEF: True; SortI: True; SortF: True} // Version: 0.1.122'
  }
}

resource workspaces_com754_ls_name_LogManagement_workspaces_com754_ls_name_LogManagement_CountOfIISLogEntriesByURLForHost 'Microsoft.OperationalInsights/workspaces/savedSearches@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'LogManagement(${workspaces_com754_ls_name})_LogManagement|CountOfIISLogEntriesByURLForHost'
  properties: {
    category: 'Log Management'
    displayName: 'Count of IIS Log Entries by URL for the host "www.contoso.com" (replace with your own)'
    version: 2
    query: 'search csHost == "www.contoso.com" | extend Type = $table | where Type == W3CIISLog | summarize AggregatedValue = count() by csUriStem\r\n// Oql: Type=W3CIISLog csHost="www.contoso.com" | Measure count() by csUriStem // Args: {OQ: True; WorkspaceId: 00000000-0000-0000-0000-000000000000} // Settings: {PEF: True; SortI: True; SortF: True} // Version: 0.1.122'
  }
}

resource workspaces_com754_ls_name_LogManagement_workspaces_com754_ls_name_LogManagement_CountOfIISLogEntriesByURLRequestedByClient 'Microsoft.OperationalInsights/workspaces/savedSearches@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'LogManagement(${workspaces_com754_ls_name})_LogManagement|CountOfIISLogEntriesByURLRequestedByClient'
  properties: {
    category: 'Log Management'
    displayName: 'Count of IIS Log Entries by URL requested by client (without query strings)'
    version: 2
    query: 'search * | extend Type = $table | where Type == W3CIISLog | summarize AggregatedValue = count() by csUriStem\r\n// Oql: Type=W3CIISLog | Measure count() by csUriStem // Args: {OQ: True; WorkspaceId: 00000000-0000-0000-0000-000000000000} // Settings: {PEF: True; SortI: True; SortF: True} // Version: 0.1.122'
  }
}

resource workspaces_com754_ls_name_LogManagement_workspaces_com754_ls_name_LogManagement_CountOfWarningEvents 'Microsoft.OperationalInsights/workspaces/savedSearches@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'LogManagement(${workspaces_com754_ls_name})_LogManagement|CountOfWarningEvents'
  properties: {
    category: 'Log Management'
    displayName: 'Count of Events with level "Warning" grouped by Event ID'
    version: 2
    query: 'Event | where EventLevelName == "warning" | summarize AggregatedValue = count() by EventID\r\n// Oql: Type=Event EventLevelName=warning | Measure count() by EventID // Args: {OQ: True; WorkspaceId: 00000000-0000-0000-0000-000000000000} // Settings: {PTT: True; SortI: True; SortF: True} // Version: 0.1.122'
  }
}

resource workspaces_com754_ls_name_LogManagement_workspaces_com754_ls_name_LogManagement_DisplayBreakdownRespondCodes 'Microsoft.OperationalInsights/workspaces/savedSearches@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'LogManagement(${workspaces_com754_ls_name})_LogManagement|DisplayBreakdownRespondCodes'
  properties: {
    category: 'Log Management'
    displayName: 'Shows breakdown of response codes'
    version: 2
    query: 'search * | extend Type = $table | where Type == W3CIISLog | summarize AggregatedValue = count() by scStatus\r\n// Oql: Type=W3CIISLog | Measure count() by scStatus // Args: {OQ: True; WorkspaceId: 00000000-0000-0000-0000-000000000000} // Settings: {PEF: True; SortI: True; SortF: True} // Version: 0.1.122'
  }
}

resource workspaces_com754_ls_name_LogManagement_workspaces_com754_ls_name_LogManagement_EventsByEventLog 'Microsoft.OperationalInsights/workspaces/savedSearches@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'LogManagement(${workspaces_com754_ls_name})_LogManagement|EventsByEventLog'
  properties: {
    category: 'Log Management'
    displayName: 'Count of Events grouped by Event Log'
    version: 2
    query: 'Event | summarize AggregatedValue = count() by EventLog\r\n// Oql: Type=Event | Measure count() by EventLog // Args: {OQ: True; WorkspaceId: 00000000-0000-0000-0000-000000000000} // Settings: {PTT: True; SortI: True; SortF: True} // Version: 0.1.122'
  }
}

resource workspaces_com754_ls_name_LogManagement_workspaces_com754_ls_name_LogManagement_EventsByEventsID 'Microsoft.OperationalInsights/workspaces/savedSearches@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'LogManagement(${workspaces_com754_ls_name})_LogManagement|EventsByEventsID'
  properties: {
    category: 'Log Management'
    displayName: 'Count of Events grouped by Event ID'
    version: 2
    query: 'Event | summarize AggregatedValue = count() by EventID\r\n// Oql: Type=Event | Measure count() by EventID // Args: {OQ: True; WorkspaceId: 00000000-0000-0000-0000-000000000000} // Settings: {PTT: True; SortI: True; SortF: True} // Version: 0.1.122'
  }
}

resource workspaces_com754_ls_name_LogManagement_workspaces_com754_ls_name_LogManagement_EventsByEventSource 'Microsoft.OperationalInsights/workspaces/savedSearches@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'LogManagement(${workspaces_com754_ls_name})_LogManagement|EventsByEventSource'
  properties: {
    category: 'Log Management'
    displayName: 'Count of Events grouped by Event Source'
    version: 2
    query: 'Event | summarize AggregatedValue = count() by Source\r\n// Oql: Type=Event | Measure count() by Source // Args: {OQ: True; WorkspaceId: 00000000-0000-0000-0000-000000000000} // Settings: {PTT: True; SortI: True; SortF: True} // Version: 0.1.122'
  }
}

resource workspaces_com754_ls_name_LogManagement_workspaces_com754_ls_name_LogManagement_EventsInOMBetween2000to3000 'Microsoft.OperationalInsights/workspaces/savedSearches@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'LogManagement(${workspaces_com754_ls_name})_LogManagement|EventsInOMBetween2000to3000'
  properties: {
    category: 'Log Management'
    displayName: 'Events in the Operations Manager Event Log whose Event ID is in the range between 2000 and 3000'
    version: 2
    query: 'Event | where EventLog == "Operations Manager" and EventID >= 2000 and EventID <= 3000 | sort by TimeGenerated desc\r\n// Oql: Type=Event EventLog="Operations Manager" EventID:[2000..3000] // Args: {OQ: True; WorkspaceId: 00000000-0000-0000-0000-000000000000} // Settings: {PTT: True; SortI: True; SortF: True} // Version: 0.1.122'
  }
}

resource workspaces_com754_ls_name_LogManagement_workspaces_com754_ls_name_LogManagement_EventsWithStartedinEventID 'Microsoft.OperationalInsights/workspaces/savedSearches@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'LogManagement(${workspaces_com754_ls_name})_LogManagement|EventsWithStartedinEventID'
  properties: {
    category: 'Log Management'
    displayName: 'Count of Events containing the word "started" grouped by EventID'
    version: 2
    query: 'search in (Event) "started" | summarize AggregatedValue = count() by EventID\r\n// Oql: Type=Event "started" | Measure count() by EventID // Args: {OQ: True; WorkspaceId: 00000000-0000-0000-0000-000000000000} // Settings: {PTT: True; SortI: True; SortF: True} // Version: 0.1.122'
  }
}

resource workspaces_com754_ls_name_LogManagement_workspaces_com754_ls_name_LogManagement_FindMaximumTimeTakenForEachPage 'Microsoft.OperationalInsights/workspaces/savedSearches@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'LogManagement(${workspaces_com754_ls_name})_LogManagement|FindMaximumTimeTakenForEachPage'
  properties: {
    category: 'Log Management'
    displayName: 'Find the maximum time taken for each page'
    version: 2
    query: 'search * | extend Type = $table | where Type == W3CIISLog | summarize AggregatedValue = max(TimeTaken) by csUriStem\r\n// Oql: Type=W3CIISLog | Measure Max(TimeTaken) by csUriStem // Args: {OQ: True; WorkspaceId: 00000000-0000-0000-0000-000000000000} // Settings: {PEF: True; SortI: True; SortF: True} // Version: 0.1.122'
  }
}

resource workspaces_com754_ls_name_LogManagement_workspaces_com754_ls_name_LogManagement_IISLogEntriesForClientIP 'Microsoft.OperationalInsights/workspaces/savedSearches@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'LogManagement(${workspaces_com754_ls_name})_LogManagement|IISLogEntriesForClientIP'
  properties: {
    category: 'Log Management'
    displayName: 'IIS Log Entries for a specific client IP Address (replace with your own)'
    version: 2
    query: 'search cIP == "192.168.0.1" | extend Type = $table | where Type == W3CIISLog | sort by TimeGenerated desc | project csUriStem, scBytes, csBytes, TimeTaken, scStatus\r\n// Oql: Type=W3CIISLog cIP="192.168.0.1" | Select csUriStem,scBytes,csBytes,TimeTaken,scStatus // Args: {OQ: True; WorkspaceId: 00000000-0000-0000-0000-000000000000} // Settings: {PEF: True; SortI: True; SortF: True} // Version: 0.1.122'
  }
}

resource workspaces_com754_ls_name_LogManagement_workspaces_com754_ls_name_LogManagement_ListAllIISLogEntries 'Microsoft.OperationalInsights/workspaces/savedSearches@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'LogManagement(${workspaces_com754_ls_name})_LogManagement|ListAllIISLogEntries'
  properties: {
    category: 'Log Management'
    displayName: 'All IIS Log Entries'
    version: 2
    query: 'search * | extend Type = $table | where Type == W3CIISLog | sort by TimeGenerated desc\r\n// Oql: Type=W3CIISLog // Args: {OQ: True; WorkspaceId: 00000000-0000-0000-0000-000000000000} // Settings: {PEF: True; SortI: True; SortF: True} // Version: 0.1.122'
  }
}

resource workspaces_com754_ls_name_LogManagement_workspaces_com754_ls_name_LogManagement_NoOfConnectionsToOMSDKService 'Microsoft.OperationalInsights/workspaces/savedSearches@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'LogManagement(${workspaces_com754_ls_name})_LogManagement|NoOfConnectionsToOMSDKService'
  properties: {
    category: 'Log Management'
    displayName: 'How many connections to Operations Manager\'s SDK service by day'
    version: 2
    query: 'Event | where EventID == 26328 and EventLog == "Operations Manager" | summarize AggregatedValue = count() by bin(TimeGenerated, 1d) | sort by TimeGenerated desc\r\n// Oql: Type=Event EventID=26328 EventLog="Operations Manager" | Measure count() interval 1DAY // Args: {OQ: True; WorkspaceId: 00000000-0000-0000-0000-000000000000} // Settings: {PTT: True; SortI: True; SortF: True} // Version: 0.1.122'
  }
}

resource workspaces_com754_ls_name_LogManagement_workspaces_com754_ls_name_LogManagement_ServerRestartTime 'Microsoft.OperationalInsights/workspaces/savedSearches@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'LogManagement(${workspaces_com754_ls_name})_LogManagement|ServerRestartTime'
  properties: {
    category: 'Log Management'
    displayName: 'When did my servers initiate restart?'
    version: 2
    query: 'search in (Event) "shutdown" and EventLog == "System" and Source == "User32" and EventID == 1074 | sort by TimeGenerated desc | project TimeGenerated, Computer\r\n// Oql: shutdown Type=Event EventLog=System Source=User32 EventID=1074 | Select TimeGenerated,Computer // Args: {OQ: True; WorkspaceId: 00000000-0000-0000-0000-000000000000} // Settings: {PTT: True; SortI: True; SortF: True} // Version: 0.1.122'
  }
}

resource workspaces_com754_ls_name_LogManagement_workspaces_com754_ls_name_LogManagement_Show404PagesList 'Microsoft.OperationalInsights/workspaces/savedSearches@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'LogManagement(${workspaces_com754_ls_name})_LogManagement|Show404PagesList'
  properties: {
    category: 'Log Management'
    displayName: 'Shows which pages people are getting a 404 for'
    version: 2
    query: 'search scStatus == 404 | extend Type = $table | where Type == W3CIISLog | summarize AggregatedValue = count() by csUriStem\r\n// Oql: Type=W3CIISLog scStatus=404 | Measure count() by csUriStem // Args: {OQ: True; WorkspaceId: 00000000-0000-0000-0000-000000000000} // Settings: {PEF: True; SortI: True; SortF: True} // Version: 0.1.122'
  }
}

resource workspaces_com754_ls_name_LogManagement_workspaces_com754_ls_name_LogManagement_ShowServersThrowingInternalServerError 'Microsoft.OperationalInsights/workspaces/savedSearches@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'LogManagement(${workspaces_com754_ls_name})_LogManagement|ShowServersThrowingInternalServerError'
  properties: {
    category: 'Log Management'
    displayName: 'Shows servers that are throwing internal server error'
    version: 2
    query: 'search scStatus == 500 | extend Type = $table | where Type == W3CIISLog | summarize AggregatedValue = count() by sComputerName\r\n// Oql: Type=W3CIISLog scStatus=500 | Measure count() by sComputerName // Args: {OQ: True; WorkspaceId: 00000000-0000-0000-0000-000000000000} // Settings: {PEF: True; SortI: True; SortF: True} // Version: 0.1.122'
  }
}

resource workspaces_com754_ls_name_LogManagement_workspaces_com754_ls_name_LogManagement_TotalBytesReceivedByEachAzureRoleInstance 'Microsoft.OperationalInsights/workspaces/savedSearches@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'LogManagement(${workspaces_com754_ls_name})_LogManagement|TotalBytesReceivedByEachAzureRoleInstance'
  properties: {
    category: 'Log Management'
    displayName: 'Total Bytes received by each Azure Role Instance'
    version: 2
    query: 'search * | extend Type = $table | where Type == W3CIISLog | summarize AggregatedValue = sum(csBytes) by RoleInstance\r\n// Oql: Type=W3CIISLog | Measure Sum(csBytes) by RoleInstance // Args: {OQ: True; WorkspaceId: 00000000-0000-0000-0000-000000000000} // Settings: {PEF: True; SortI: True; SortF: True} // Version: 0.1.122'
  }
}

resource workspaces_com754_ls_name_LogManagement_workspaces_com754_ls_name_LogManagement_TotalBytesReceivedByEachIISComputer 'Microsoft.OperationalInsights/workspaces/savedSearches@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'LogManagement(${workspaces_com754_ls_name})_LogManagement|TotalBytesReceivedByEachIISComputer'
  properties: {
    category: 'Log Management'
    displayName: 'Total Bytes received by each IIS Computer'
    version: 2
    query: 'search * | extend Type = $table | where Type == W3CIISLog | summarize AggregatedValue = sum(csBytes) by Computer | limit 500000\r\n// Oql: Type=W3CIISLog | Measure Sum(csBytes) by Computer | top 500000 // Args: {OQ: True; WorkspaceId: 00000000-0000-0000-0000-000000000000} // Settings: {PEF: True; SortI: True; SortF: True} // Version: 0.1.122'
  }
}

resource workspaces_com754_ls_name_LogManagement_workspaces_com754_ls_name_LogManagement_TotalBytesRespondedToClientsByClientIPAddress 'Microsoft.OperationalInsights/workspaces/savedSearches@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'LogManagement(${workspaces_com754_ls_name})_LogManagement|TotalBytesRespondedToClientsByClientIPAddress'
  properties: {
    category: 'Log Management'
    displayName: 'Total Bytes responded back to clients by Client IP Address'
    version: 2
    query: 'search * | extend Type = $table | where Type == W3CIISLog | summarize AggregatedValue = sum(scBytes) by cIP\r\n// Oql: Type=W3CIISLog | Measure Sum(scBytes) by cIP // Args: {OQ: True; WorkspaceId: 00000000-0000-0000-0000-000000000000} // Settings: {PEF: True; SortI: True; SortF: True} // Version: 0.1.122'
  }
}

resource workspaces_com754_ls_name_LogManagement_workspaces_com754_ls_name_LogManagement_TotalBytesRespondedToClientsByEachIISServerIPAddress 'Microsoft.OperationalInsights/workspaces/savedSearches@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'LogManagement(${workspaces_com754_ls_name})_LogManagement|TotalBytesRespondedToClientsByEachIISServerIPAddress'
  properties: {
    category: 'Log Management'
    displayName: 'Total Bytes responded back to clients by each IIS ServerIP Address'
    version: 2
    query: 'search * | extend Type = $table | where Type == W3CIISLog | summarize AggregatedValue = sum(scBytes) by sIP\r\n// Oql: Type=W3CIISLog | Measure Sum(scBytes) by sIP // Args: {OQ: True; WorkspaceId: 00000000-0000-0000-0000-000000000000} // Settings: {PEF: True; SortI: True; SortF: True} // Version: 0.1.122'
  }
}

resource workspaces_com754_ls_name_LogManagement_workspaces_com754_ls_name_LogManagement_TotalBytesSentByClientIPAddress 'Microsoft.OperationalInsights/workspaces/savedSearches@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'LogManagement(${workspaces_com754_ls_name})_LogManagement|TotalBytesSentByClientIPAddress'
  properties: {
    category: 'Log Management'
    displayName: 'Total Bytes sent by Client IP Address'
    version: 2
    query: 'search * | extend Type = $table | where Type == W3CIISLog | summarize AggregatedValue = sum(csBytes) by cIP\r\n// Oql: Type=W3CIISLog | Measure Sum(csBytes) by cIP // Args: {OQ: True; WorkspaceId: 00000000-0000-0000-0000-000000000000} // Settings: {PEF: True; SortI: True; SortF: True} // Version: 0.1.122'
  }
}

resource workspaces_com754_ls_name_LogManagement_workspaces_com754_ls_name_LogManagement_WarningEvents 'Microsoft.OperationalInsights/workspaces/savedSearches@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'LogManagement(${workspaces_com754_ls_name})_LogManagement|WarningEvents'
  properties: {
    category: 'Log Management'
    displayName: 'All Events with level "Warning"'
    version: 2
    query: 'Event | where EventLevelName == "warning" | sort by TimeGenerated desc\r\n// Oql: Type=Event EventLevelName=warning // Args: {OQ: True; WorkspaceId: 00000000-0000-0000-0000-000000000000} // Settings: {PTT: True; SortI: True; SortF: True} // Version: 0.1.122'
  }
}

resource workspaces_com754_ls_name_LogManagement_workspaces_com754_ls_name_LogManagement_WindowsFireawallPolicySettingsChanged 'Microsoft.OperationalInsights/workspaces/savedSearches@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'LogManagement(${workspaces_com754_ls_name})_LogManagement|WindowsFireawallPolicySettingsChanged'
  properties: {
    category: 'Log Management'
    displayName: 'Windows Firewall Policy settings have changed'
    version: 2
    query: 'Event | where EventLog == "Microsoft-Windows-Windows Firewall With Advanced Security/Firewall" and EventID == 2008 | sort by TimeGenerated desc\r\n// Oql: Type=Event EventLog="Microsoft-Windows-Windows Firewall With Advanced Security/Firewall" EventID=2008 // Args: {OQ: True; WorkspaceId: 00000000-0000-0000-0000-000000000000} // Settings: {PTT: True; SortI: True; SortF: True} // Version: 0.1.122'
  }
}

resource workspaces_com754_ls_name_LogManagement_workspaces_com754_ls_name_LogManagement_WindowsFireawallPolicySettingsChangedByMachines 'Microsoft.OperationalInsights/workspaces/savedSearches@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'LogManagement(${workspaces_com754_ls_name})_LogManagement|WindowsFireawallPolicySettingsChangedByMachines'
  properties: {
    category: 'Log Management'
    displayName: 'On which machines and how many times have Windows Firewall Policy settings changed'
    version: 2
    query: 'Event | where EventLog == "Microsoft-Windows-Windows Firewall With Advanced Security/Firewall" and EventID == 2008 | summarize AggregatedValue = count() by Computer | limit 500000\r\n// Oql: Type=Event EventLog="Microsoft-Windows-Windows Firewall With Advanced Security/Firewall" EventID=2008 | measure count() by Computer | top 500000 // Args: {OQ: True; WorkspaceId: 00000000-0000-0000-0000-000000000000} // Settings: {PTT: True; SortI: True; SortF: True} // Version: 0.1.122'
  }
}

resource workspaces_com754_ls_name_AACAudit 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AACAudit'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AACAudit'
      displayName: 'AACAudit'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AACHttpRequest 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AACHttpRequest'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AACHttpRequest'
      displayName: 'AACHttpRequest'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AADAgentRiskEvents 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AADAgentRiskEvents'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AADAgentRiskEvents'
      displayName: 'AADAgentRiskEvents'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AADB2CRequestLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AADB2CRequestLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AADB2CRequestLogs'
      displayName: 'AADB2CRequestLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AADCustomSecurityAttributeAuditLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AADCustomSecurityAttributeAuditLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AADCustomSecurityAttributeAuditLogs'
      displayName: 'AADCustomSecurityAttributeAuditLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AADDomainServicesAccountLogon 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AADDomainServicesAccountLogon'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AADDomainServicesAccountLogon'
      displayName: 'AADDomainServicesAccountLogon'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AADDomainServicesAccountManagement 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AADDomainServicesAccountManagement'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AADDomainServicesAccountManagement'
      displayName: 'AADDomainServicesAccountManagement'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AADDomainServicesDirectoryServiceAccess 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AADDomainServicesDirectoryServiceAccess'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AADDomainServicesDirectoryServiceAccess'
      displayName: 'AADDomainServicesDirectoryServiceAccess'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AADDomainServicesDNSAuditsDynamicUpdates 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AADDomainServicesDNSAuditsDynamicUpdates'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AADDomainServicesDNSAuditsDynamicUpdates'
      displayName: 'AADDomainServicesDNSAuditsDynamicUpdates'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AADDomainServicesDNSAuditsGeneral 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AADDomainServicesDNSAuditsGeneral'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AADDomainServicesDNSAuditsGeneral'
      displayName: 'AADDomainServicesDNSAuditsGeneral'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AADDomainServicesLogonLogoff 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AADDomainServicesLogonLogoff'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AADDomainServicesLogonLogoff'
      displayName: 'AADDomainServicesLogonLogoff'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AADDomainServicesPolicyChange 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AADDomainServicesPolicyChange'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AADDomainServicesPolicyChange'
      displayName: 'AADDomainServicesPolicyChange'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AADDomainServicesPrivilegeUse 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AADDomainServicesPrivilegeUse'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AADDomainServicesPrivilegeUse'
      displayName: 'AADDomainServicesPrivilegeUse'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AADDomainServicesSystemSecurity 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AADDomainServicesSystemSecurity'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AADDomainServicesSystemSecurity'
      displayName: 'AADDomainServicesSystemSecurity'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AADFirstPartyToFirstPartySignInLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AADFirstPartyToFirstPartySignInLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AADFirstPartyToFirstPartySignInLogs'
      displayName: 'AADFirstPartyToFirstPartySignInLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AADGraphActivityLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AADGraphActivityLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AADGraphActivityLogs'
      displayName: 'AADGraphActivityLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AADManagedIdentitySignInLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AADManagedIdentitySignInLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AADManagedIdentitySignInLogs'
      displayName: 'AADManagedIdentitySignInLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AADNonInteractiveUserSignInLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AADNonInteractiveUserSignInLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AADNonInteractiveUserSignInLogs'
      displayName: 'AADNonInteractiveUserSignInLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AADProvisioningLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AADProvisioningLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AADProvisioningLogs'
      displayName: 'AADProvisioningLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AADRiskyAgents 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AADRiskyAgents'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AADRiskyAgents'
      displayName: 'AADRiskyAgents'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AADRiskyServicePrincipals 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AADRiskyServicePrincipals'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AADRiskyServicePrincipals'
      displayName: 'AADRiskyServicePrincipals'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AADRiskyUsers 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AADRiskyUsers'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AADRiskyUsers'
      displayName: 'AADRiskyUsers'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AADServicePrincipalRiskEvents 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AADServicePrincipalRiskEvents'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AADServicePrincipalRiskEvents'
      displayName: 'AADServicePrincipalRiskEvents'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AADServicePrincipalSignInLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AADServicePrincipalSignInLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AADServicePrincipalSignInLogs'
      displayName: 'AADServicePrincipalSignInLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AADUserRiskEvents 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AADUserRiskEvents'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AADUserRiskEvents'
      displayName: 'AADUserRiskEvents'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_ABSBotRequests 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'ABSBotRequests'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'ABSBotRequests'
      displayName: 'ABSBotRequests'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_ACICollaborationAudit 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'ACICollaborationAudit'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'ACICollaborationAudit'
      displayName: 'ACICollaborationAudit'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_ACLTransactionLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'ACLTransactionLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'ACLTransactionLogs'
      displayName: 'ACLTransactionLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_ACLUserDefinedLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'ACLUserDefinedLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'ACLUserDefinedLogs'
      displayName: 'ACLUserDefinedLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_ACRConnectedClientList 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'ACRConnectedClientList'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'ACRConnectedClientList'
      displayName: 'ACRConnectedClientList'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_ACREntraAuthenticationAuditLog 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'ACREntraAuthenticationAuditLog'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'ACREntraAuthenticationAuditLog'
      displayName: 'ACREntraAuthenticationAuditLog'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_ACSAdvancedMessagingOperations 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'ACSAdvancedMessagingOperations'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'ACSAdvancedMessagingOperations'
      displayName: 'ACSAdvancedMessagingOperations'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_ACSAuthIncomingOperations 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'ACSAuthIncomingOperations'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'ACSAuthIncomingOperations'
      displayName: 'ACSAuthIncomingOperations'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_ACSBillingUsage 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'ACSBillingUsage'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'ACSBillingUsage'
      displayName: 'ACSBillingUsage'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_ACSCallAutomationIncomingOperations 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'ACSCallAutomationIncomingOperations'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'ACSCallAutomationIncomingOperations'
      displayName: 'ACSCallAutomationIncomingOperations'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_ACSCallAutomationMediaSummary 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'ACSCallAutomationMediaSummary'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'ACSCallAutomationMediaSummary'
      displayName: 'ACSCallAutomationMediaSummary'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_ACSCallAutomationStreamingUsage 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'ACSCallAutomationStreamingUsage'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'ACSCallAutomationStreamingUsage'
      displayName: 'ACSCallAutomationStreamingUsage'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_ACSCallClientMediaStatsTimeSeries 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'ACSCallClientMediaStatsTimeSeries'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'ACSCallClientMediaStatsTimeSeries'
      displayName: 'ACSCallClientMediaStatsTimeSeries'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_ACSCallClientOperations 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'ACSCallClientOperations'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'ACSCallClientOperations'
      displayName: 'ACSCallClientOperations'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_ACSCallClientServiceRequestAndOutcome 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'ACSCallClientServiceRequestAndOutcome'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'ACSCallClientServiceRequestAndOutcome'
      displayName: 'ACSCallClientServiceRequestAndOutcome'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_ACSCallClosedCaptionsSummary 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'ACSCallClosedCaptionsSummary'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'ACSCallClosedCaptionsSummary'
      displayName: 'ACSCallClosedCaptionsSummary'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_ACSCallDiagnostics 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'ACSCallDiagnostics'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'ACSCallDiagnostics'
      displayName: 'ACSCallDiagnostics'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_ACSCallDiagnosticsUpdates 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'ACSCallDiagnosticsUpdates'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'ACSCallDiagnosticsUpdates'
      displayName: 'ACSCallDiagnosticsUpdates'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_ACSCallingMetrics 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'ACSCallingMetrics'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'ACSCallingMetrics'
      displayName: 'ACSCallingMetrics'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_ACSCallRecordingIncomingOperations 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'ACSCallRecordingIncomingOperations'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'ACSCallRecordingIncomingOperations'
      displayName: 'ACSCallRecordingIncomingOperations'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_ACSCallRecordingSummary 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'ACSCallRecordingSummary'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'ACSCallRecordingSummary'
      displayName: 'ACSCallRecordingSummary'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_ACSCallSummary 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'ACSCallSummary'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'ACSCallSummary'
      displayName: 'ACSCallSummary'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_ACSCallSummaryUpdates 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'ACSCallSummaryUpdates'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'ACSCallSummaryUpdates'
      displayName: 'ACSCallSummaryUpdates'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_ACSCallSurvey 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'ACSCallSurvey'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'ACSCallSurvey'
      displayName: 'ACSCallSurvey'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_ACSChatIncomingOperations 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'ACSChatIncomingOperations'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'ACSChatIncomingOperations'
      displayName: 'ACSChatIncomingOperations'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_ACSEmailSendMailOperational 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'ACSEmailSendMailOperational'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'ACSEmailSendMailOperational'
      displayName: 'ACSEmailSendMailOperational'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_ACSEmailStatusUpdateOperational 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'ACSEmailStatusUpdateOperational'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'ACSEmailStatusUpdateOperational'
      displayName: 'ACSEmailStatusUpdateOperational'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_ACSEmailUserEngagementOperational 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'ACSEmailUserEngagementOperational'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'ACSEmailUserEngagementOperational'
      displayName: 'ACSEmailUserEngagementOperational'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_ACSJobRouterIncomingOperations 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'ACSJobRouterIncomingOperations'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'ACSJobRouterIncomingOperations'
      displayName: 'ACSJobRouterIncomingOperations'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_ACSOptOutManagementOperations 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'ACSOptOutManagementOperations'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'ACSOptOutManagementOperations'
      displayName: 'ACSOptOutManagementOperations'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_ACSRoomsIncomingOperations 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'ACSRoomsIncomingOperations'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'ACSRoomsIncomingOperations'
      displayName: 'ACSRoomsIncomingOperations'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_ACSSMSIncomingOperations 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'ACSSMSIncomingOperations'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'ACSSMSIncomingOperations'
      displayName: 'ACSSMSIncomingOperations'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_ADAssessmentRecommendation 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'ADAssessmentRecommendation'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'ADAssessmentRecommendation'
      displayName: 'ADAssessmentRecommendation'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AddonAzureBackupAlerts 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AddonAzureBackupAlerts'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AddonAzureBackupAlerts'
      displayName: 'AddonAzureBackupAlerts'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AddonAzureBackupJobs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AddonAzureBackupJobs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AddonAzureBackupJobs'
      displayName: 'AddonAzureBackupJobs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AddonAzureBackupPolicy 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AddonAzureBackupPolicy'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AddonAzureBackupPolicy'
      displayName: 'AddonAzureBackupPolicy'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AddonAzureBackupProtectedInstance 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AddonAzureBackupProtectedInstance'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AddonAzureBackupProtectedInstance'
      displayName: 'AddonAzureBackupProtectedInstance'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AddonAzureBackupStorage 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AddonAzureBackupStorage'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AddonAzureBackupStorage'
      displayName: 'AddonAzureBackupStorage'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_ADFActivityRun 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'ADFActivityRun'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'ADFActivityRun'
      displayName: 'ADFActivityRun'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_ADFAirflowSchedulerLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'ADFAirflowSchedulerLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'ADFAirflowSchedulerLogs'
      displayName: 'ADFAirflowSchedulerLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_ADFAirflowTaskLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'ADFAirflowTaskLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'ADFAirflowTaskLogs'
      displayName: 'ADFAirflowTaskLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_ADFAirflowWebLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'ADFAirflowWebLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'ADFAirflowWebLogs'
      displayName: 'ADFAirflowWebLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_ADFAirflowWorkerLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'ADFAirflowWorkerLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'ADFAirflowWorkerLogs'
      displayName: 'ADFAirflowWorkerLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_ADFPipelineRun 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'ADFPipelineRun'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'ADFPipelineRun'
      displayName: 'ADFPipelineRun'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_ADFSandboxActivityRun 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'ADFSandboxActivityRun'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'ADFSandboxActivityRun'
      displayName: 'ADFSandboxActivityRun'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_ADFSandboxPipelineRun 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'ADFSandboxPipelineRun'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'ADFSandboxPipelineRun'
      displayName: 'ADFSandboxPipelineRun'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_ADFSSignInLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'ADFSSignInLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'ADFSSignInLogs'
      displayName: 'ADFSSignInLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_ADFSSISIntegrationRuntimeLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'ADFSSISIntegrationRuntimeLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'ADFSSISIntegrationRuntimeLogs'
      displayName: 'ADFSSISIntegrationRuntimeLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_ADFSSISPackageEventMessageContext 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'ADFSSISPackageEventMessageContext'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'ADFSSISPackageEventMessageContext'
      displayName: 'ADFSSISPackageEventMessageContext'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_ADFSSISPackageEventMessages 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'ADFSSISPackageEventMessages'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'ADFSSISPackageEventMessages'
      displayName: 'ADFSSISPackageEventMessages'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_ADFSSISPackageExecutableStatistics 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'ADFSSISPackageExecutableStatistics'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'ADFSSISPackageExecutableStatistics'
      displayName: 'ADFSSISPackageExecutableStatistics'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_ADFSSISPackageExecutionComponentPhases 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'ADFSSISPackageExecutionComponentPhases'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'ADFSSISPackageExecutionComponentPhases'
      displayName: 'ADFSSISPackageExecutionComponentPhases'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_ADFSSISPackageExecutionDataStatistics 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'ADFSSISPackageExecutionDataStatistics'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'ADFSSISPackageExecutionDataStatistics'
      displayName: 'ADFSSISPackageExecutionDataStatistics'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_ADFTriggerRun 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'ADFTriggerRun'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'ADFTriggerRun'
      displayName: 'ADFTriggerRun'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_ADReplicationResult 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'ADReplicationResult'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'ADReplicationResult'
      displayName: 'ADReplicationResult'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_ADSecurityAssessmentRecommendation 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'ADSecurityAssessmentRecommendation'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'ADSecurityAssessmentRecommendation'
      displayName: 'ADSecurityAssessmentRecommendation'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_ADTDataHistoryOperation 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'ADTDataHistoryOperation'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'ADTDataHistoryOperation'
      displayName: 'ADTDataHistoryOperation'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_ADTDigitalTwinsOperation 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'ADTDigitalTwinsOperation'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'ADTDigitalTwinsOperation'
      displayName: 'ADTDigitalTwinsOperation'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_ADTEventRoutesOperation 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'ADTEventRoutesOperation'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'ADTEventRoutesOperation'
      displayName: 'ADTEventRoutesOperation'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_ADTModelsOperation 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'ADTModelsOperation'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'ADTModelsOperation'
      displayName: 'ADTModelsOperation'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_ADTQueryOperation 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'ADTQueryOperation'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'ADTQueryOperation'
      displayName: 'ADTQueryOperation'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_ADXCommand 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'ADXCommand'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'ADXCommand'
      displayName: 'ADXCommand'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_ADXDataOperation 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'ADXDataOperation'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'ADXDataOperation'
      displayName: 'ADXDataOperation'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_ADXIngestionBatching 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'ADXIngestionBatching'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'ADXIngestionBatching'
      displayName: 'ADXIngestionBatching'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_ADXJournal 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'ADXJournal'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'ADXJournal'
      displayName: 'ADXJournal'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_ADXQuery 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'ADXQuery'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'ADXQuery'
      displayName: 'ADXQuery'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_ADXTableDetails 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'ADXTableDetails'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'ADXTableDetails'
      displayName: 'ADXTableDetails'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_ADXTableUsageStatistics 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'ADXTableUsageStatistics'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'ADXTableUsageStatistics'
      displayName: 'ADXTableUsageStatistics'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AegDataPlaneRequests 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AegDataPlaneRequests'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AegDataPlaneRequests'
      displayName: 'AegDataPlaneRequests'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AegDeliveryFailureLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AegDeliveryFailureLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AegDeliveryFailureLogs'
      displayName: 'AegDeliveryFailureLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AegPublishFailureLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AegPublishFailureLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AegPublishFailureLogs'
      displayName: 'AegPublishFailureLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AEWAssignmentBlobLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AEWAssignmentBlobLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AEWAssignmentBlobLogs'
      displayName: 'AEWAssignmentBlobLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AEWAuditLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AEWAuditLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AEWAuditLogs'
      displayName: 'AEWAuditLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AEWComputePipelinesLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AEWComputePipelinesLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AEWComputePipelinesLogs'
      displayName: 'AEWComputePipelinesLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AEWExperimentAssignmentSummary 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AEWExperimentAssignmentSummary'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AEWExperimentAssignmentSummary'
      displayName: 'AEWExperimentAssignmentSummary'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AEWExperimentScorecardMetricPairs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AEWExperimentScorecardMetricPairs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AEWExperimentScorecardMetricPairs'
      displayName: 'AEWExperimentScorecardMetricPairs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AEWExperimentScorecards 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AEWExperimentScorecards'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AEWExperimentScorecards'
      displayName: 'AEWExperimentScorecards'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AFSAuditLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AFSAuditLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AFSAuditLogs'
      displayName: 'AFSAuditLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AGCAccessLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AGCAccessLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AGCAccessLogs'
      displayName: 'AGCAccessLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AGCFirewallLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AGCFirewallLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AGCFirewallLogs'
      displayName: 'AGCFirewallLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AgriFoodApplicationAuditLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AgriFoodApplicationAuditLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AgriFoodApplicationAuditLogs'
      displayName: 'AgriFoodApplicationAuditLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AgriFoodFarmManagementLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AgriFoodFarmManagementLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AgriFoodFarmManagementLogs'
      displayName: 'AgriFoodFarmManagementLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AgriFoodFarmOperationLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AgriFoodFarmOperationLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AgriFoodFarmOperationLogs'
      displayName: 'AgriFoodFarmOperationLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AgriFoodInsightLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AgriFoodInsightLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AgriFoodInsightLogs'
      displayName: 'AgriFoodInsightLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AgriFoodJobProcessedLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AgriFoodJobProcessedLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AgriFoodJobProcessedLogs'
      displayName: 'AgriFoodJobProcessedLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AgriFoodModelInferenceLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AgriFoodModelInferenceLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AgriFoodModelInferenceLogs'
      displayName: 'AgriFoodModelInferenceLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AgriFoodProviderAuthLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AgriFoodProviderAuthLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AgriFoodProviderAuthLogs'
      displayName: 'AgriFoodProviderAuthLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AgriFoodSatelliteLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AgriFoodSatelliteLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AgriFoodSatelliteLogs'
      displayName: 'AgriFoodSatelliteLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AgriFoodSensorManagementLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AgriFoodSensorManagementLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AgriFoodSensorManagementLogs'
      displayName: 'AgriFoodSensorManagementLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AgriFoodWeatherLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AgriFoodWeatherLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AgriFoodWeatherLogs'
      displayName: 'AgriFoodWeatherLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AGSGrafanaLoginEvents 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AGSGrafanaLoginEvents'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AGSGrafanaLoginEvents'
      displayName: 'AGSGrafanaLoginEvents'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AGSGrafanaUsageInsightsEvents 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AGSGrafanaUsageInsightsEvents'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AGSGrafanaUsageInsightsEvents'
      displayName: 'AGSGrafanaUsageInsightsEvents'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AGSUpdateEvents 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AGSUpdateEvents'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AGSUpdateEvents'
      displayName: 'AGSUpdateEvents'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AGWAccessLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AGWAccessLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AGWAccessLogs'
      displayName: 'AGWAccessLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AGWFirewallLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AGWFirewallLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AGWFirewallLogs'
      displayName: 'AGWFirewallLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AGWPerformanceLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AGWPerformanceLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AGWPerformanceLogs'
      displayName: 'AGWPerformanceLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AHCIDiagnosticLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AHCIDiagnosticLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AHCIDiagnosticLogs'
      displayName: 'AHCIDiagnosticLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AHDSDeidAuditLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AHDSDeidAuditLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AHDSDeidAuditLogs'
      displayName: 'AHDSDeidAuditLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AHDSDicomAuditLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AHDSDicomAuditLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AHDSDicomAuditLogs'
      displayName: 'AHDSDicomAuditLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AHDSDicomDiagnosticLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AHDSDicomDiagnosticLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AHDSDicomDiagnosticLogs'
      displayName: 'AHDSDicomDiagnosticLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AHDSMedTechDiagnosticLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AHDSMedTechDiagnosticLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AHDSMedTechDiagnosticLogs'
      displayName: 'AHDSMedTechDiagnosticLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AirflowDagProcessingLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AirflowDagProcessingLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AirflowDagProcessingLogs'
      displayName: 'AirflowDagProcessingLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AKSAudit 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AKSAudit'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AKSAudit'
      displayName: 'AKSAudit'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AKSAuditAdmin 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AKSAuditAdmin'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AKSAuditAdmin'
      displayName: 'AKSAuditAdmin'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AKSControlPlane 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AKSControlPlane'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AKSControlPlane'
      displayName: 'AKSControlPlane'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_ALBHealthEvent 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'ALBHealthEvent'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'ALBHealthEvent'
      displayName: 'ALBHealthEvent'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_Alert 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'Alert'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'Alert'
      displayName: 'Alert'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AMAHealth 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AMAHealth'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AMAHealth'
      displayName: 'AMAHealth'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AmlComputeClusterEvent 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AmlComputeClusterEvent'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AmlComputeClusterEvent'
      displayName: 'AmlComputeClusterEvent'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AmlComputeClusterNodeEvent 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AmlComputeClusterNodeEvent'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AmlComputeClusterNodeEvent'
      displayName: 'AmlComputeClusterNodeEvent'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AmlComputeCpuGpuUtilization 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AmlComputeCpuGpuUtilization'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AmlComputeCpuGpuUtilization'
      displayName: 'AmlComputeCpuGpuUtilization'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AmlComputeInstanceEvent 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AmlComputeInstanceEvent'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AmlComputeInstanceEvent'
      displayName: 'AmlComputeInstanceEvent'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AmlComputeJobEvent 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AmlComputeJobEvent'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AmlComputeJobEvent'
      displayName: 'AmlComputeJobEvent'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AmlDataLabelEvent 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AmlDataLabelEvent'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AmlDataLabelEvent'
      displayName: 'AmlDataLabelEvent'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AmlDataSetEvent 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AmlDataSetEvent'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AmlDataSetEvent'
      displayName: 'AmlDataSetEvent'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AmlDataStoreEvent 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AmlDataStoreEvent'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AmlDataStoreEvent'
      displayName: 'AmlDataStoreEvent'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AmlDeploymentEvent 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AmlDeploymentEvent'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AmlDeploymentEvent'
      displayName: 'AmlDeploymentEvent'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AmlEnvironmentEvent 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AmlEnvironmentEvent'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AmlEnvironmentEvent'
      displayName: 'AmlEnvironmentEvent'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AmlInferencingEvent 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AmlInferencingEvent'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AmlInferencingEvent'
      displayName: 'AmlInferencingEvent'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AmlModelsEvent 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AmlModelsEvent'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AmlModelsEvent'
      displayName: 'AmlModelsEvent'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AmlOnlineEndpointConsoleLog 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AmlOnlineEndpointConsoleLog'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AmlOnlineEndpointConsoleLog'
      displayName: 'AmlOnlineEndpointConsoleLog'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AmlOnlineEndpointEventLog 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AmlOnlineEndpointEventLog'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AmlOnlineEndpointEventLog'
      displayName: 'AmlOnlineEndpointEventLog'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AmlOnlineEndpointTrafficLog 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AmlOnlineEndpointTrafficLog'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AmlOnlineEndpointTrafficLog'
      displayName: 'AmlOnlineEndpointTrafficLog'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AmlPipelineEvent 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AmlPipelineEvent'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AmlPipelineEvent'
      displayName: 'AmlPipelineEvent'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AmlRegistryReadEventsLog 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AmlRegistryReadEventsLog'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AmlRegistryReadEventsLog'
      displayName: 'AmlRegistryReadEventsLog'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AmlRegistryWriteEventsLog 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AmlRegistryWriteEventsLog'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AmlRegistryWriteEventsLog'
      displayName: 'AmlRegistryWriteEventsLog'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AmlRunEvent 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AmlRunEvent'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AmlRunEvent'
      displayName: 'AmlRunEvent'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AmlRunStatusChangedEvent 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AmlRunStatusChangedEvent'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AmlRunStatusChangedEvent'
      displayName: 'AmlRunStatusChangedEvent'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AMSKeyDeliveryRequests 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AMSKeyDeliveryRequests'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AMSKeyDeliveryRequests'
      displayName: 'AMSKeyDeliveryRequests'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AMSLiveEventOperations 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AMSLiveEventOperations'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AMSLiveEventOperations'
      displayName: 'AMSLiveEventOperations'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AMSMediaAccountHealth 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AMSMediaAccountHealth'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AMSMediaAccountHealth'
      displayName: 'AMSMediaAccountHealth'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AMSStreamingEndpointRequests 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AMSStreamingEndpointRequests'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AMSStreamingEndpointRequests'
      displayName: 'AMSStreamingEndpointRequests'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AMWMetricsUsageDetails 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AMWMetricsUsageDetails'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AMWMetricsUsageDetails'
      displayName: 'AMWMetricsUsageDetails'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_ANFFileAccess 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'ANFFileAccess'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'ANFFileAccess'
      displayName: 'ANFFileAccess'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AOIDatabaseQuery 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AOIDatabaseQuery'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AOIDatabaseQuery'
      displayName: 'AOIDatabaseQuery'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AOIDigestion 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AOIDigestion'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AOIDigestion'
      displayName: 'AOIDigestion'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AOIStorage 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AOIStorage'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AOIStorage'
      displayName: 'AOIStorage'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_ApiManagementGatewayLlmLog 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'ApiManagementGatewayLlmLog'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'ApiManagementGatewayLlmLog'
      displayName: 'ApiManagementGatewayLlmLog'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_ApiManagementGatewayLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'ApiManagementGatewayLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'ApiManagementGatewayLogs'
      displayName: 'ApiManagementGatewayLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_ApiManagementGatewayMCPLog 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'ApiManagementGatewayMCPLog'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'ApiManagementGatewayMCPLog'
      displayName: 'ApiManagementGatewayMCPLog'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_ApiManagementWebSocketConnectionLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'ApiManagementWebSocketConnectionLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'ApiManagementWebSocketConnectionLogs'
      displayName: 'ApiManagementWebSocketConnectionLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_APIMDevPortalAuditDiagnosticLog 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'APIMDevPortalAuditDiagnosticLog'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'APIMDevPortalAuditDiagnosticLog'
      displayName: 'APIMDevPortalAuditDiagnosticLog'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AppAvailabilityResults 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AppAvailabilityResults'
  properties: {
    totalRetentionInDays: 90
    plan: 'Analytics'
    schema: {
      name: 'AppAvailabilityResults'
      displayName: 'AppAvailabilityResults'
    }
    retentionInDays: 90
  }
}

resource workspaces_com754_ls_name_AppBrowserTimings 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AppBrowserTimings'
  properties: {
    totalRetentionInDays: 90
    plan: 'Analytics'
    schema: {
      name: 'AppBrowserTimings'
      displayName: 'AppBrowserTimings'
    }
    retentionInDays: 90
  }
}

resource workspaces_com754_ls_name_AppCenterError 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AppCenterError'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AppCenterError'
      displayName: 'AppCenterError'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AppDependencies 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AppDependencies'
  properties: {
    totalRetentionInDays: 90
    plan: 'Analytics'
    schema: {
      name: 'AppDependencies'
      displayName: 'AppDependencies'
    }
    retentionInDays: 90
  }
}

resource workspaces_com754_ls_name_AppEnvSessionConsoleLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AppEnvSessionConsoleLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AppEnvSessionConsoleLogs'
      displayName: 'AppEnvSessionConsoleLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AppEnvSessionLifecycleLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AppEnvSessionLifecycleLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AppEnvSessionLifecycleLogs'
      displayName: 'AppEnvSessionLifecycleLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AppEnvSessionPoolEventLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AppEnvSessionPoolEventLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AppEnvSessionPoolEventLogs'
      displayName: 'AppEnvSessionPoolEventLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AppEnvSpringAppConsoleLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AppEnvSpringAppConsoleLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AppEnvSpringAppConsoleLogs'
      displayName: 'AppEnvSpringAppConsoleLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AppEvents 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AppEvents'
  properties: {
    totalRetentionInDays: 90
    plan: 'Analytics'
    schema: {
      name: 'AppEvents'
      displayName: 'AppEvents'
    }
    retentionInDays: 90
  }
}

resource workspaces_com754_ls_name_AppExceptions 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AppExceptions'
  properties: {
    totalRetentionInDays: 90
    plan: 'Analytics'
    schema: {
      name: 'AppExceptions'
      displayName: 'AppExceptions'
    }
    retentionInDays: 90
  }
}

resource workspaces_com754_ls_name_AppGenAIContent 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AppGenAIContent'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AppGenAIContent'
      displayName: 'AppGenAIContent'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AppMetrics 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AppMetrics'
  properties: {
    totalRetentionInDays: 90
    plan: 'Analytics'
    schema: {
      name: 'AppMetrics'
      displayName: 'AppMetrics'
    }
    retentionInDays: 90
  }
}

resource workspaces_com754_ls_name_AppPageViews 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AppPageViews'
  properties: {
    totalRetentionInDays: 90
    plan: 'Analytics'
    schema: {
      name: 'AppPageViews'
      displayName: 'AppPageViews'
    }
    retentionInDays: 90
  }
}

resource workspaces_com754_ls_name_AppPerformanceCounters 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AppPerformanceCounters'
  properties: {
    totalRetentionInDays: 90
    plan: 'Analytics'
    schema: {
      name: 'AppPerformanceCounters'
      displayName: 'AppPerformanceCounters'
    }
    retentionInDays: 90
  }
}

resource workspaces_com754_ls_name_AppPlatformBuildLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AppPlatformBuildLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AppPlatformBuildLogs'
      displayName: 'AppPlatformBuildLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AppPlatformContainerEventLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AppPlatformContainerEventLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AppPlatformContainerEventLogs'
      displayName: 'AppPlatformContainerEventLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AppPlatformIngressLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AppPlatformIngressLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AppPlatformIngressLogs'
      displayName: 'AppPlatformIngressLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AppPlatformLogsforSpring 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AppPlatformLogsforSpring'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AppPlatformLogsforSpring'
      displayName: 'AppPlatformLogsforSpring'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AppPlatformSystemLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AppPlatformSystemLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AppPlatformSystemLogs'
      displayName: 'AppPlatformSystemLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AppRequests 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AppRequests'
  properties: {
    totalRetentionInDays: 90
    plan: 'Analytics'
    schema: {
      name: 'AppRequests'
      displayName: 'AppRequests'
    }
    retentionInDays: 90
  }
}

resource workspaces_com754_ls_name_AppServiceAntivirusScanAuditLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AppServiceAntivirusScanAuditLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AppServiceAntivirusScanAuditLogs'
      displayName: 'AppServiceAntivirusScanAuditLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AppServiceAppLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AppServiceAppLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AppServiceAppLogs'
      displayName: 'AppServiceAppLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AppServiceAuditLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AppServiceAuditLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AppServiceAuditLogs'
      displayName: 'AppServiceAuditLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AppServiceAuthenticationLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AppServiceAuthenticationLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AppServiceAuthenticationLogs'
      displayName: 'AppServiceAuthenticationLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AppServiceConsoleLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AppServiceConsoleLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AppServiceConsoleLogs'
      displayName: 'AppServiceConsoleLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AppServiceEnvironmentPlatformLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AppServiceEnvironmentPlatformLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AppServiceEnvironmentPlatformLogs'
      displayName: 'AppServiceEnvironmentPlatformLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AppServiceFileAuditLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AppServiceFileAuditLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AppServiceFileAuditLogs'
      displayName: 'AppServiceFileAuditLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AppServiceHTTPLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AppServiceHTTPLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AppServiceHTTPLogs'
      displayName: 'AppServiceHTTPLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AppServiceIPSecAuditLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AppServiceIPSecAuditLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AppServiceIPSecAuditLogs'
      displayName: 'AppServiceIPSecAuditLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AppServicePlatformLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AppServicePlatformLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AppServicePlatformLogs'
      displayName: 'AppServicePlatformLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AppServiceServerlessSecurityPluginData 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AppServiceServerlessSecurityPluginData'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AppServiceServerlessSecurityPluginData'
      displayName: 'AppServiceServerlessSecurityPluginData'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AppSystemEvents 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AppSystemEvents'
  properties: {
    totalRetentionInDays: 90
    plan: 'Analytics'
    schema: {
      name: 'AppSystemEvents'
      displayName: 'AppSystemEvents'
    }
    retentionInDays: 90
  }
}

resource workspaces_com754_ls_name_AppTraces 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AppTraces'
  properties: {
    totalRetentionInDays: 90
    plan: 'Analytics'
    schema: {
      name: 'AppTraces'
      displayName: 'AppTraces'
    }
    retentionInDays: 90
  }
}

resource workspaces_com754_ls_name_ArcK8sAudit 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'ArcK8sAudit'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'ArcK8sAudit'
      displayName: 'ArcK8sAudit'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_ArcK8sAuditAdmin 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'ArcK8sAuditAdmin'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'ArcK8sAuditAdmin'
      displayName: 'ArcK8sAuditAdmin'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_ArcK8sControlPlane 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'ArcK8sControlPlane'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'ArcK8sControlPlane'
      displayName: 'ArcK8sControlPlane'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_ASCAuditLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'ASCAuditLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'ASCAuditLogs'
      displayName: 'ASCAuditLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_ASCDeviceEvents 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'ASCDeviceEvents'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'ASCDeviceEvents'
      displayName: 'ASCDeviceEvents'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_ASRJobs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'ASRJobs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'ASRJobs'
      displayName: 'ASRJobs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_ASRReplicatedItems 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'ASRReplicatedItems'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'ASRReplicatedItems'
      displayName: 'ASRReplicatedItems'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_ASRv2HealthEvents 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'ASRv2HealthEvents'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'ASRv2HealthEvents'
      displayName: 'ASRv2HealthEvents'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_ASRv2JobEvents 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'ASRv2JobEvents'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'ASRv2JobEvents'
      displayName: 'ASRv2JobEvents'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_ASRv2ProtectedItems 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'ASRv2ProtectedItems'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'ASRv2ProtectedItems'
      displayName: 'ASRv2ProtectedItems'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_ASRv2ReplicationExtensions 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'ASRv2ReplicationExtensions'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'ASRv2ReplicationExtensions'
      displayName: 'ASRv2ReplicationExtensions'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_ASRv2ReplicationPolicies 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'ASRv2ReplicationPolicies'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'ASRv2ReplicationPolicies'
      displayName: 'ASRv2ReplicationPolicies'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_ASRv2ReplicationVaults 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'ASRv2ReplicationVaults'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'ASRv2ReplicationVaults'
      displayName: 'ASRv2ReplicationVaults'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_ATCExpressRouteCircuitIpfix 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'ATCExpressRouteCircuitIpfix'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'ATCExpressRouteCircuitIpfix'
      displayName: 'ATCExpressRouteCircuitIpfix'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_ATCMicrosoftPeeringMetadata 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'ATCMicrosoftPeeringMetadata'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'ATCMicrosoftPeeringMetadata'
      displayName: 'ATCMicrosoftPeeringMetadata'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_ATCPrivatePeeringMetadata 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'ATCPrivatePeeringMetadata'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'ATCPrivatePeeringMetadata'
      displayName: 'ATCPrivatePeeringMetadata'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AuditLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AuditLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AuditLogs'
      displayName: 'AuditLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AutoscaleEvaluationsLog 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AutoscaleEvaluationsLog'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AutoscaleEvaluationsLog'
      displayName: 'AutoscaleEvaluationsLog'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AutoscaleScaleActionsLog 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AutoscaleScaleActionsLog'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AutoscaleScaleActionsLog'
      displayName: 'AutoscaleScaleActionsLog'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AVNMConnectivityConfigurationChange 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AVNMConnectivityConfigurationChange'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AVNMConnectivityConfigurationChange'
      displayName: 'AVNMConnectivityConfigurationChange'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AVNMIPAMPoolAllocationChange 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AVNMIPAMPoolAllocationChange'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AVNMIPAMPoolAllocationChange'
      displayName: 'AVNMIPAMPoolAllocationChange'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AVNMNetworkGroupMembershipChange 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AVNMNetworkGroupMembershipChange'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AVNMNetworkGroupMembershipChange'
      displayName: 'AVNMNetworkGroupMembershipChange'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AVNMRuleCollectionChange 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AVNMRuleCollectionChange'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AVNMRuleCollectionChange'
      displayName: 'AVNMRuleCollectionChange'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AVSEsxiFirewallSyslog 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AVSEsxiFirewallSyslog'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AVSEsxiFirewallSyslog'
      displayName: 'AVSEsxiFirewallSyslog'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AVSEsxiSyslog 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AVSEsxiSyslog'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AVSEsxiSyslog'
      displayName: 'AVSEsxiSyslog'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AVSNsxEdgeSyslog 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AVSNsxEdgeSyslog'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AVSNsxEdgeSyslog'
      displayName: 'AVSNsxEdgeSyslog'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AVSNsxManagerSyslog 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AVSNsxManagerSyslog'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AVSNsxManagerSyslog'
      displayName: 'AVSNsxManagerSyslog'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AVSSyslog 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AVSSyslog'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AVSSyslog'
      displayName: 'AVSSyslog'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AVSVcSyslog 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AVSVcSyslog'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AVSVcSyslog'
      displayName: 'AVSVcSyslog'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AZFWApplicationRule 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AZFWApplicationRule'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AZFWApplicationRule'
      displayName: 'AZFWApplicationRule'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AZFWApplicationRuleAggregation 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AZFWApplicationRuleAggregation'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AZFWApplicationRuleAggregation'
      displayName: 'AZFWApplicationRuleAggregation'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AZFWDnsFlowTrace 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AZFWDnsFlowTrace'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AZFWDnsFlowTrace'
      displayName: 'AZFWDnsFlowTrace'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AZFWDnsQuery 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AZFWDnsQuery'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AZFWDnsQuery'
      displayName: 'AZFWDnsQuery'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AZFWFatFlow 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AZFWFatFlow'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AZFWFatFlow'
      displayName: 'AZFWFatFlow'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AZFWFlowTrace 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AZFWFlowTrace'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AZFWFlowTrace'
      displayName: 'AZFWFlowTrace'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AZFWIdpsSignature 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AZFWIdpsSignature'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AZFWIdpsSignature'
      displayName: 'AZFWIdpsSignature'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AZFWInternalFqdnResolutionFailure 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AZFWInternalFqdnResolutionFailure'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AZFWInternalFqdnResolutionFailure'
      displayName: 'AZFWInternalFqdnResolutionFailure'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AZFWNatRule 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AZFWNatRule'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AZFWNatRule'
      displayName: 'AZFWNatRule'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AZFWNatRuleAggregation 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AZFWNatRuleAggregation'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AZFWNatRuleAggregation'
      displayName: 'AZFWNatRuleAggregation'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AZFWNetworkRule 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AZFWNetworkRule'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AZFWNetworkRule'
      displayName: 'AZFWNetworkRule'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AZFWNetworkRuleAggregation 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AZFWNetworkRuleAggregation'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AZFWNetworkRuleAggregation'
      displayName: 'AZFWNetworkRuleAggregation'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AZFWThreatIntel 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AZFWThreatIntel'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AZFWThreatIntel'
      displayName: 'AZFWThreatIntel'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AZKVAuditLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AZKVAuditLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AZKVAuditLogs'
      displayName: 'AZKVAuditLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AZKVPolicyEvaluationDetailsLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AZKVPolicyEvaluationDetailsLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AZKVPolicyEvaluationDetailsLogs'
      displayName: 'AZKVPolicyEvaluationDetailsLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AZMSApplicationMetricLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AZMSApplicationMetricLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AZMSApplicationMetricLogs'
      displayName: 'AZMSApplicationMetricLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AZMSArchiveLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AZMSArchiveLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AZMSArchiveLogs'
      displayName: 'AZMSArchiveLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AZMSAutoscaleLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AZMSAutoscaleLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AZMSAutoscaleLogs'
      displayName: 'AZMSAutoscaleLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AZMSCustomerManagedKeyUserLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AZMSCustomerManagedKeyUserLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AZMSCustomerManagedKeyUserLogs'
      displayName: 'AZMSCustomerManagedKeyUserLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AZMSDiagnosticErrorLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AZMSDiagnosticErrorLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AZMSDiagnosticErrorLogs'
      displayName: 'AZMSDiagnosticErrorLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AZMSHybridConnectionsEvents 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AZMSHybridConnectionsEvents'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AZMSHybridConnectionsEvents'
      displayName: 'AZMSHybridConnectionsEvents'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AZMSKafkaCoordinatorLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AZMSKafkaCoordinatorLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AZMSKafkaCoordinatorLogs'
      displayName: 'AZMSKafkaCoordinatorLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AZMSKafkaUserErrorLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AZMSKafkaUserErrorLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AZMSKafkaUserErrorLogs'
      displayName: 'AZMSKafkaUserErrorLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AZMSOperationalLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AZMSOperationalLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AZMSOperationalLogs'
      displayName: 'AZMSOperationalLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AZMSRunTimeAuditLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AZMSRunTimeAuditLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AZMSRunTimeAuditLogs'
      displayName: 'AZMSRunTimeAuditLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AZMSVnetConnectionEvents 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AZMSVnetConnectionEvents'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AZMSVnetConnectionEvents'
      displayName: 'AZMSVnetConnectionEvents'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AzureActivity 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AzureActivity'
  properties: {
    totalRetentionInDays: 90
    plan: 'Analytics'
    schema: {
      name: 'AzureActivity'
      displayName: 'AzureActivity'
    }
    retentionInDays: 90
  }
}

resource workspaces_com754_ls_name_AzureActivityV2 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AzureActivityV2'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AzureActivityV2'
      displayName: 'AzureActivityV2'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AzureAssessmentRecommendation 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AzureAssessmentRecommendation'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AzureAssessmentRecommendation'
      displayName: 'AzureAssessmentRecommendation'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AzureAttestationDiagnostics 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AzureAttestationDiagnostics'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AzureAttestationDiagnostics'
      displayName: 'AzureAttestationDiagnostics'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AzureBackupOperations 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AzureBackupOperations'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AzureBackupOperations'
      displayName: 'AzureBackupOperations'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AzureDevOpsAuditing 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AzureDevOpsAuditing'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AzureDevOpsAuditing'
      displayName: 'AzureDevOpsAuditing'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AzureDiagnostics 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AzureDiagnostics'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AzureDiagnostics'
      displayName: 'AzureDiagnostics'
      columns: [
        {
          name: 'EnqueueTime_t'
          type: 'datetime'
          displayName: 'EnqueueTime_t'
        }
        {
          name: 'CallerIPAddress'
          type: 'string'
          displayName: 'CallerIPAddress'
        }
        {
          name: 'CorrelationId'
          type: 'string'
          displayName: 'CorrelationId'
        }
        {
          name: 'DurationMs'
          type: 'long'
          displayName: 'DurationMs'
        }
        {
          name: 'event_s'
          type: 'string'
          displayName: 'event_s'
        }
        {
          name: 'location_s'
          type: 'string'
          displayName: 'location_s'
        }
        {
          name: 'ResultSignature'
          type: 'string'
          displayName: 'ResultSignature'
        }
        {
          name: 'Tenant_s'
          type: 'string'
          displayName: 'Tenant_s'
        }
        {
          name: 'ResourceId'
          type: 'string'
          displayName: 'ResourceId'
        }
        {
          name: 'Category'
          type: 'string'
          displayName: 'Category'
        }
        {
          name: 'OperationName'
          type: 'string'
          displayName: 'OperationName'
        }
        {
          name: 'properties_s'
          type: 'string'
          displayName: 'properties_s'
        }
        {
          name: 'AssetIdentity_g'
          type: 'guid'
          displayName: 'AssetIdentity_g'
        }
        {
          name: 'SubscriptionId'
          type: 'guid'
          displayName: 'SubscriptionId'
        }
        {
          name: 'ResourceGroup'
          type: 'string'
          displayName: 'ResourceGroup'
        }
        {
          name: 'ResourceProvider'
          type: 'string'
          displayName: 'ResourceProvider'
        }
        {
          name: 'Resource'
          type: 'string'
          displayName: 'Resource'
        }
        {
          name: 'ResourceType'
          type: 'string'
          displayName: 'ResourceType'
        }
        {
          name: '_CustomFieldsCollection'
          type: 'dynamic'
          displayName: 'AdditionalFields'
        }
      ]
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AzureLoadTestingOperation 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AzureLoadTestingOperation'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AzureLoadTestingOperation'
      displayName: 'AzureLoadTestingOperation'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AzureMetrics 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AzureMetrics'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AzureMetrics'
      displayName: 'AzureMetrics'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AzureMetricsV2 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AzureMetricsV2'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AzureMetricsV2'
      displayName: 'AzureMetricsV2'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_AzureMonitorPipelineLogErrors 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'AzureMonitorPipelineLogErrors'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AzureMonitorPipelineLogErrors'
      displayName: 'AzureMonitorPipelineLogErrors'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_BehaviorEntities 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'BehaviorEntities'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'BehaviorEntities'
      displayName: 'BehaviorEntities'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_BehaviorInfo 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'BehaviorInfo'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'BehaviorInfo'
      displayName: 'BehaviorInfo'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_BlockchainApplicationLog 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'BlockchainApplicationLog'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'BlockchainApplicationLog'
      displayName: 'BlockchainApplicationLog'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_BlockchainProxyLog 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'BlockchainProxyLog'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'BlockchainProxyLog'
      displayName: 'BlockchainProxyLog'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_CassandraAudit 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'CassandraAudit'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'CassandraAudit'
      displayName: 'CassandraAudit'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_CassandraLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'CassandraLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'CassandraLogs'
      displayName: 'CassandraLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_CCFApplicationLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'CCFApplicationLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'CCFApplicationLogs'
      displayName: 'CCFApplicationLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_CDBCassandraRequests 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'CDBCassandraRequests'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'CDBCassandraRequests'
      displayName: 'CDBCassandraRequests'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_CDBControlPlaneRequests 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'CDBControlPlaneRequests'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'CDBControlPlaneRequests'
      displayName: 'CDBControlPlaneRequests'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_CDBDataPlaneRequests 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'CDBDataPlaneRequests'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'CDBDataPlaneRequests'
      displayName: 'CDBDataPlaneRequests'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_CDBDataPlaneRequests15M 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'CDBDataPlaneRequests15M'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'CDBDataPlaneRequests15M'
      displayName: 'CDBDataPlaneRequests15M'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_CDBDataPlaneRequests5M 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'CDBDataPlaneRequests5M'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'CDBDataPlaneRequests5M'
      displayName: 'CDBDataPlaneRequests5M'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_CDBGremlinRequests 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'CDBGremlinRequests'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'CDBGremlinRequests'
      displayName: 'CDBGremlinRequests'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_CDBMongoRequests 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'CDBMongoRequests'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'CDBMongoRequests'
      displayName: 'CDBMongoRequests'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_CDBPartitionKeyRUConsumption 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'CDBPartitionKeyRUConsumption'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'CDBPartitionKeyRUConsumption'
      displayName: 'CDBPartitionKeyRUConsumption'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_CDBPartitionKeyStatistics 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'CDBPartitionKeyStatistics'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'CDBPartitionKeyStatistics'
      displayName: 'CDBPartitionKeyStatistics'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_CDBQueryRuntimeStatistics 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'CDBQueryRuntimeStatistics'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'CDBQueryRuntimeStatistics'
      displayName: 'CDBQueryRuntimeStatistics'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_CDBTableApiRequests 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'CDBTableApiRequests'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'CDBTableApiRequests'
      displayName: 'CDBTableApiRequests'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_ChaosStudioExperimentEventLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'ChaosStudioExperimentEventLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'ChaosStudioExperimentEventLogs'
      displayName: 'ChaosStudioExperimentEventLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_CHSMServiceOperationAuditLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'CHSMServiceOperationAuditLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'CHSMServiceOperationAuditLogs'
      displayName: 'CHSMServiceOperationAuditLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_CIEventsAudit 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'CIEventsAudit'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'CIEventsAudit'
      displayName: 'CIEventsAudit'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_CIEventsOperational 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'CIEventsOperational'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'CIEventsOperational'
      displayName: 'CIEventsOperational'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_CloudHsmServiceOperationAuditLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'CloudHsmServiceOperationAuditLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'CloudHsmServiceOperationAuditLogs'
      displayName: 'CloudHsmServiceOperationAuditLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_ComputerGroup 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'ComputerGroup'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'ComputerGroup'
      displayName: 'ComputerGroup'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_ContainerAppConsoleLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'ContainerAppConsoleLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'ContainerAppConsoleLogs'
      displayName: 'ContainerAppConsoleLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_ContainerAppSystemLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'ContainerAppSystemLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'ContainerAppSystemLogs'
      displayName: 'ContainerAppSystemLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_ContainerEvent 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'ContainerEvent'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'ContainerEvent'
      displayName: 'ContainerEvent'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_ContainerImageInventory 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'ContainerImageInventory'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'ContainerImageInventory'
      displayName: 'ContainerImageInventory'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_ContainerInstanceLog 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'ContainerInstanceLog'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'ContainerInstanceLog'
      displayName: 'ContainerInstanceLog'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_ContainerInventory 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'ContainerInventory'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'ContainerInventory'
      displayName: 'ContainerInventory'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_ContainerLog 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'ContainerLog'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'ContainerLog'
      displayName: 'ContainerLog'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_ContainerLogV2 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'ContainerLogV2'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'ContainerLogV2'
      displayName: 'ContainerLogV2'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_ContainerNetworkLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'ContainerNetworkLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'ContainerNetworkLogs'
      displayName: 'ContainerNetworkLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_ContainerNodeInventory 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'ContainerNodeInventory'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'ContainerNodeInventory'
      displayName: 'ContainerNodeInventory'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_ContainerRegistryLoginEvents 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'ContainerRegistryLoginEvents'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'ContainerRegistryLoginEvents'
      displayName: 'ContainerRegistryLoginEvents'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_ContainerRegistryRepositoryEvents 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'ContainerRegistryRepositoryEvents'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'ContainerRegistryRepositoryEvents'
      displayName: 'ContainerRegistryRepositoryEvents'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_ContainerServiceLog 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'ContainerServiceLog'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'ContainerServiceLog'
      displayName: 'ContainerServiceLog'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_CoreAzureBackup 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'CoreAzureBackup'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'CoreAzureBackup'
      displayName: 'CoreAzureBackup'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_DatabricksAccounts 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'DatabricksAccounts'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'DatabricksAccounts'
      displayName: 'DatabricksAccounts'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_DatabricksApps 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'DatabricksApps'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'DatabricksApps'
      displayName: 'DatabricksApps'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_DatabricksBrickStoreHttpGateway 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'DatabricksBrickStoreHttpGateway'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'DatabricksBrickStoreHttpGateway'
      displayName: 'DatabricksBrickStoreHttpGateway'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_DatabricksBudgetPolicyCentral 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'DatabricksBudgetPolicyCentral'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'DatabricksBudgetPolicyCentral'
      displayName: 'DatabricksBudgetPolicyCentral'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_DatabricksCapsule8Dataplane 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'DatabricksCapsule8Dataplane'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'DatabricksCapsule8Dataplane'
      displayName: 'DatabricksCapsule8Dataplane'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_DatabricksClamAVScan 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'DatabricksClamAVScan'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'DatabricksClamAVScan'
      displayName: 'DatabricksClamAVScan'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_DatabricksCloudStorageMetadata 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'DatabricksCloudStorageMetadata'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'DatabricksCloudStorageMetadata'
      displayName: 'DatabricksCloudStorageMetadata'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_DatabricksClusterLibraries 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'DatabricksClusterLibraries'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'DatabricksClusterLibraries'
      displayName: 'DatabricksClusterLibraries'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_DatabricksClusterPolicies 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'DatabricksClusterPolicies'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'DatabricksClusterPolicies'
      displayName: 'DatabricksClusterPolicies'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_DatabricksClusters 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'DatabricksClusters'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'DatabricksClusters'
      displayName: 'DatabricksClusters'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_DatabricksDashboards 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'DatabricksDashboards'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'DatabricksDashboards'
      displayName: 'DatabricksDashboards'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_DatabricksDatabricksSQL 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'DatabricksDatabricksSQL'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'DatabricksDatabricksSQL'
      displayName: 'DatabricksDatabricksSQL'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_DatabricksDataMonitoring 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'DatabricksDataMonitoring'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'DatabricksDataMonitoring'
      displayName: 'DatabricksDataMonitoring'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_DatabricksDataRooms 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'DatabricksDataRooms'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'DatabricksDataRooms'
      displayName: 'DatabricksDataRooms'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_DatabricksDBFS 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'DatabricksDBFS'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'DatabricksDBFS'
      displayName: 'DatabricksDBFS'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_DatabricksDeltaPipelines 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'DatabricksDeltaPipelines'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'DatabricksDeltaPipelines'
      displayName: 'DatabricksDeltaPipelines'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_DatabricksFeatureStore 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'DatabricksFeatureStore'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'DatabricksFeatureStore'
      displayName: 'DatabricksFeatureStore'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_DatabricksFiles 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'DatabricksFiles'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'DatabricksFiles'
      displayName: 'DatabricksFiles'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_DatabricksFilesystem 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'DatabricksFilesystem'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'DatabricksFilesystem'
      displayName: 'DatabricksFilesystem'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_DatabricksGenie 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'DatabricksGenie'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'DatabricksGenie'
      displayName: 'DatabricksGenie'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_DatabricksGitCredentials 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'DatabricksGitCredentials'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'DatabricksGitCredentials'
      displayName: 'DatabricksGitCredentials'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_DatabricksGlobalInitScripts 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'DatabricksGlobalInitScripts'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'DatabricksGlobalInitScripts'
      displayName: 'DatabricksGlobalInitScripts'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_DatabricksGroups 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'DatabricksGroups'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'DatabricksGroups'
      displayName: 'DatabricksGroups'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_DatabricksIAMRole 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'DatabricksIAMRole'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'DatabricksIAMRole'
      displayName: 'DatabricksIAMRole'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_DatabricksIngestion 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'DatabricksIngestion'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'DatabricksIngestion'
      displayName: 'DatabricksIngestion'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_DatabricksInstancePools 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'DatabricksInstancePools'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'DatabricksInstancePools'
      displayName: 'DatabricksInstancePools'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_DatabricksJobs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'DatabricksJobs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'DatabricksJobs'
      displayName: 'DatabricksJobs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_DatabricksLakeviewConfig 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'DatabricksLakeviewConfig'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'DatabricksLakeviewConfig'
      displayName: 'DatabricksLakeviewConfig'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_DatabricksLineageTracking 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'DatabricksLineageTracking'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'DatabricksLineageTracking'
      displayName: 'DatabricksLineageTracking'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_DatabricksMarketplaceConsumer 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'DatabricksMarketplaceConsumer'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'DatabricksMarketplaceConsumer'
      displayName: 'DatabricksMarketplaceConsumer'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_DatabricksMarketplaceProvider 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'DatabricksMarketplaceProvider'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'DatabricksMarketplaceProvider'
      displayName: 'DatabricksMarketplaceProvider'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_DatabricksMLflowAcledArtifact 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'DatabricksMLflowAcledArtifact'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'DatabricksMLflowAcledArtifact'
      displayName: 'DatabricksMLflowAcledArtifact'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_DatabricksMLflowExperiment 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'DatabricksMLflowExperiment'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'DatabricksMLflowExperiment'
      displayName: 'DatabricksMLflowExperiment'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_DatabricksModelRegistry 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'DatabricksModelRegistry'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'DatabricksModelRegistry'
      displayName: 'DatabricksModelRegistry'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_DatabricksNotebook 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'DatabricksNotebook'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'DatabricksNotebook'
      displayName: 'DatabricksNotebook'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_DatabricksOnlineTables 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'DatabricksOnlineTables'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'DatabricksOnlineTables'
      displayName: 'DatabricksOnlineTables'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_DatabricksPartnerHub 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'DatabricksPartnerHub'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'DatabricksPartnerHub'
      displayName: 'DatabricksPartnerHub'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_DatabricksPredictiveOptimization 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'DatabricksPredictiveOptimization'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'DatabricksPredictiveOptimization'
      displayName: 'DatabricksPredictiveOptimization'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_DatabricksRBAC 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'DatabricksRBAC'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'DatabricksRBAC'
      displayName: 'DatabricksRBAC'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_DatabricksRemoteHistoryService 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'DatabricksRemoteHistoryService'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'DatabricksRemoteHistoryService'
      displayName: 'DatabricksRemoteHistoryService'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_DatabricksRepos 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'DatabricksRepos'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'DatabricksRepos'
      displayName: 'DatabricksRepos'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_DatabricksRFA 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'DatabricksRFA'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'DatabricksRFA'
      displayName: 'DatabricksRFA'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_DatabricksSecrets 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'DatabricksSecrets'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'DatabricksSecrets'
      displayName: 'DatabricksSecrets'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_DatabricksServerlessRealTimeInference 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'DatabricksServerlessRealTimeInference'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'DatabricksServerlessRealTimeInference'
      displayName: 'DatabricksServerlessRealTimeInference'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_DatabricksSQL 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'DatabricksSQL'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'DatabricksSQL'
      displayName: 'DatabricksSQL'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_DatabricksSQLPermissions 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'DatabricksSQLPermissions'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'DatabricksSQLPermissions'
      displayName: 'DatabricksSQLPermissions'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_DatabricksSSH 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'DatabricksSSH'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'DatabricksSSH'
      displayName: 'DatabricksSSH'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_DatabricksTables 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'DatabricksTables'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'DatabricksTables'
      displayName: 'DatabricksTables'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_DatabricksUnityCatalog 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'DatabricksUnityCatalog'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'DatabricksUnityCatalog'
      displayName: 'DatabricksUnityCatalog'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_DatabricksVectorSearch 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'DatabricksVectorSearch'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'DatabricksVectorSearch'
      displayName: 'DatabricksVectorSearch'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_DatabricksWebhookNotifications 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'DatabricksWebhookNotifications'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'DatabricksWebhookNotifications'
      displayName: 'DatabricksWebhookNotifications'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_DatabricksWebTerminal 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'DatabricksWebTerminal'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'DatabricksWebTerminal'
      displayName: 'DatabricksWebTerminal'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_DatabricksWorkspace 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'DatabricksWorkspace'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'DatabricksWorkspace'
      displayName: 'DatabricksWorkspace'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_DatabricksWorkspaceFiles 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'DatabricksWorkspaceFiles'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'DatabricksWorkspaceFiles'
      displayName: 'DatabricksWorkspaceFiles'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_DataSetOutput 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'DataSetOutput'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'DataSetOutput'
      displayName: 'DataSetOutput'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_DataSetRuns 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'DataSetRuns'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'DataSetRuns'
      displayName: 'DataSetRuns'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_DataTransferOperations 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'DataTransferOperations'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'DataTransferOperations'
      displayName: 'DataTransferOperations'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_DCRLogErrors 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'DCRLogErrors'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'DCRLogErrors'
      displayName: 'DCRLogErrors'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_DCRLogTroubleshooting 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'DCRLogTroubleshooting'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'DCRLogTroubleshooting'
      displayName: 'DCRLogTroubleshooting'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_DevCenterAgentHealthLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'DevCenterAgentHealthLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'DevCenterAgentHealthLogs'
      displayName: 'DevCenterAgentHealthLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_DevCenterBillingEventLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'DevCenterBillingEventLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'DevCenterBillingEventLogs'
      displayName: 'DevCenterBillingEventLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_DevCenterConnectionLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'DevCenterConnectionLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'DevCenterConnectionLogs'
      displayName: 'DevCenterConnectionLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_DevCenterDiagnosticLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'DevCenterDiagnosticLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'DevCenterDiagnosticLogs'
      displayName: 'DevCenterDiagnosticLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_DevCenterResourceOperationLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'DevCenterResourceOperationLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'DevCenterResourceOperationLogs'
      displayName: 'DevCenterResourceOperationLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_DeviceBehaviorEntities 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'DeviceBehaviorEntities'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'DeviceBehaviorEntities'
      displayName: 'DeviceBehaviorEntities'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_DeviceBehaviorInfo 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'DeviceBehaviorInfo'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'DeviceBehaviorInfo'
      displayName: 'DeviceBehaviorInfo'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_DeviceCustomFileEvents 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'DeviceCustomFileEvents'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'DeviceCustomFileEvents'
      displayName: 'DeviceCustomFileEvents'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_DeviceCustomImageLoadEvents 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'DeviceCustomImageLoadEvents'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'DeviceCustomImageLoadEvents'
      displayName: 'DeviceCustomImageLoadEvents'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_DeviceCustomNetworkEvents 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'DeviceCustomNetworkEvents'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'DeviceCustomNetworkEvents'
      displayName: 'DeviceCustomNetworkEvents'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_DeviceCustomProcessEvents 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'DeviceCustomProcessEvents'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'DeviceCustomProcessEvents'
      displayName: 'DeviceCustomProcessEvents'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_DeviceCustomScriptEvents 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'DeviceCustomScriptEvents'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'DeviceCustomScriptEvents'
      displayName: 'DeviceCustomScriptEvents'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_DNSQueryLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'DNSQueryLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'DNSQueryLogs'
      displayName: 'DNSQueryLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_DSMAzureBlobStorageLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'DSMAzureBlobStorageLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'DSMAzureBlobStorageLogs'
      displayName: 'DSMAzureBlobStorageLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_DSMDataClassificationLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'DSMDataClassificationLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'DSMDataClassificationLogs'
      displayName: 'DSMDataClassificationLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_DSMDataLabelingLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'DSMDataLabelingLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'DSMDataLabelingLogs'
      displayName: 'DSMDataLabelingLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_DurableTaskSchedulerLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'DurableTaskSchedulerLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'DurableTaskSchedulerLogs'
      displayName: 'DurableTaskSchedulerLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_EdgeActionConsoleLog 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'EdgeActionConsoleLog'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'EdgeActionConsoleLog'
      displayName: 'EdgeActionConsoleLog'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_EdgeActionServiceLog 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'EdgeActionServiceLog'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'EdgeActionServiceLog'
      displayName: 'EdgeActionServiceLog'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_EGNFailedHttpDataPlaneOperations 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'EGNFailedHttpDataPlaneOperations'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'EGNFailedHttpDataPlaneOperations'
      displayName: 'EGNFailedHttpDataPlaneOperations'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_EGNFailedMqttConnections 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'EGNFailedMqttConnections'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'EGNFailedMqttConnections'
      displayName: 'EGNFailedMqttConnections'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_EGNFailedMqttPublishedMessages 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'EGNFailedMqttPublishedMessages'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'EGNFailedMqttPublishedMessages'
      displayName: 'EGNFailedMqttPublishedMessages'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_EGNFailedMqttSubscriptions 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'EGNFailedMqttSubscriptions'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'EGNFailedMqttSubscriptions'
      displayName: 'EGNFailedMqttSubscriptions'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_EGNMqttDisconnections 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'EGNMqttDisconnections'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'EGNMqttDisconnections'
      displayName: 'EGNMqttDisconnections'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_EGNSuccessfulHttpDataPlaneOperations 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'EGNSuccessfulHttpDataPlaneOperations'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'EGNSuccessfulHttpDataPlaneOperations'
      displayName: 'EGNSuccessfulHttpDataPlaneOperations'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_EGNSuccessfulMqttConnections 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'EGNSuccessfulMqttConnections'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'EGNSuccessfulMqttConnections'
      displayName: 'EGNSuccessfulMqttConnections'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_EnrichedMicrosoft365AuditLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'EnrichedMicrosoft365AuditLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'EnrichedMicrosoft365AuditLogs'
      displayName: 'EnrichedMicrosoft365AuditLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_ETWEvent 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'ETWEvent'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'ETWEvent'
      displayName: 'ETWEvent'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_Event 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'Event'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'Event'
      displayName: 'Event'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_ExchangeAssessmentRecommendation 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'ExchangeAssessmentRecommendation'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'ExchangeAssessmentRecommendation'
      displayName: 'ExchangeAssessmentRecommendation'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_ExchangeOnlineAssessmentRecommendation 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'ExchangeOnlineAssessmentRecommendation'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'ExchangeOnlineAssessmentRecommendation'
      displayName: 'ExchangeOnlineAssessmentRecommendation'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_FailedIngestion 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'FailedIngestion'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'FailedIngestion'
      displayName: 'FailedIngestion'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_FunctionAppLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'FunctionAppLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'FunctionAppLogs'
      displayName: 'FunctionAppLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_HDInsightAmbariClusterAlerts 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'HDInsightAmbariClusterAlerts'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'HDInsightAmbariClusterAlerts'
      displayName: 'HDInsightAmbariClusterAlerts'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_HDInsightAmbariSystemMetrics 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'HDInsightAmbariSystemMetrics'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'HDInsightAmbariSystemMetrics'
      displayName: 'HDInsightAmbariSystemMetrics'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_HDInsightGatewayAuditLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'HDInsightGatewayAuditLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'HDInsightGatewayAuditLogs'
      displayName: 'HDInsightGatewayAuditLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_HDInsightHadoopAndYarnLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'HDInsightHadoopAndYarnLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'HDInsightHadoopAndYarnLogs'
      displayName: 'HDInsightHadoopAndYarnLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_HDInsightHadoopAndYarnMetrics 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'HDInsightHadoopAndYarnMetrics'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'HDInsightHadoopAndYarnMetrics'
      displayName: 'HDInsightHadoopAndYarnMetrics'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_HDInsightHBaseLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'HDInsightHBaseLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'HDInsightHBaseLogs'
      displayName: 'HDInsightHBaseLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_HDInsightHBaseMetrics 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'HDInsightHBaseMetrics'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'HDInsightHBaseMetrics'
      displayName: 'HDInsightHBaseMetrics'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_HDInsightHiveAndLLAPLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'HDInsightHiveAndLLAPLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'HDInsightHiveAndLLAPLogs'
      displayName: 'HDInsightHiveAndLLAPLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_HDInsightHiveAndLLAPMetrics 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'HDInsightHiveAndLLAPMetrics'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'HDInsightHiveAndLLAPMetrics'
      displayName: 'HDInsightHiveAndLLAPMetrics'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_HDInsightHiveQueryAppStats 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'HDInsightHiveQueryAppStats'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'HDInsightHiveQueryAppStats'
      displayName: 'HDInsightHiveQueryAppStats'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_HDInsightHiveTezAppStats 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'HDInsightHiveTezAppStats'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'HDInsightHiveTezAppStats'
      displayName: 'HDInsightHiveTezAppStats'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_HDInsightJupyterNotebookEvents 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'HDInsightJupyterNotebookEvents'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'HDInsightJupyterNotebookEvents'
      displayName: 'HDInsightJupyterNotebookEvents'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_HDInsightKafkaLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'HDInsightKafkaLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'HDInsightKafkaLogs'
      displayName: 'HDInsightKafkaLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_HDInsightKafkaMetrics 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'HDInsightKafkaMetrics'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'HDInsightKafkaMetrics'
      displayName: 'HDInsightKafkaMetrics'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_HDInsightKafkaServerLog 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'HDInsightKafkaServerLog'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'HDInsightKafkaServerLog'
      displayName: 'HDInsightKafkaServerLog'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_HDInsightOozieLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'HDInsightOozieLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'HDInsightOozieLogs'
      displayName: 'HDInsightOozieLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_HDInsightRangerAuditLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'HDInsightRangerAuditLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'HDInsightRangerAuditLogs'
      displayName: 'HDInsightRangerAuditLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_HDInsightSecurityLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'HDInsightSecurityLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'HDInsightSecurityLogs'
      displayName: 'HDInsightSecurityLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_HDInsightSparkApplicationEvents 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'HDInsightSparkApplicationEvents'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'HDInsightSparkApplicationEvents'
      displayName: 'HDInsightSparkApplicationEvents'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_HDInsightSparkBlockManagerEvents 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'HDInsightSparkBlockManagerEvents'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'HDInsightSparkBlockManagerEvents'
      displayName: 'HDInsightSparkBlockManagerEvents'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_HDInsightSparkEnvironmentEvents 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'HDInsightSparkEnvironmentEvents'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'HDInsightSparkEnvironmentEvents'
      displayName: 'HDInsightSparkEnvironmentEvents'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_HDInsightSparkExecutorEvents 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'HDInsightSparkExecutorEvents'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'HDInsightSparkExecutorEvents'
      displayName: 'HDInsightSparkExecutorEvents'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_HDInsightSparkExtraEvents 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'HDInsightSparkExtraEvents'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'HDInsightSparkExtraEvents'
      displayName: 'HDInsightSparkExtraEvents'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_HDInsightSparkJobEvents 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'HDInsightSparkJobEvents'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'HDInsightSparkJobEvents'
      displayName: 'HDInsightSparkJobEvents'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_HDInsightSparkLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'HDInsightSparkLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'HDInsightSparkLogs'
      displayName: 'HDInsightSparkLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_HDInsightSparkSQLExecutionEvents 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'HDInsightSparkSQLExecutionEvents'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'HDInsightSparkSQLExecutionEvents'
      displayName: 'HDInsightSparkSQLExecutionEvents'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_HDInsightSparkStageEvents 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'HDInsightSparkStageEvents'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'HDInsightSparkStageEvents'
      displayName: 'HDInsightSparkStageEvents'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_HDInsightSparkStageTaskAccumulables 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'HDInsightSparkStageTaskAccumulables'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'HDInsightSparkStageTaskAccumulables'
      displayName: 'HDInsightSparkStageTaskAccumulables'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_HDInsightSparkTaskEvents 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'HDInsightSparkTaskEvents'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'HDInsightSparkTaskEvents'
      displayName: 'HDInsightSparkTaskEvents'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_HDInsightStormLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'HDInsightStormLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'HDInsightStormLogs'
      displayName: 'HDInsightStormLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_HDInsightStormMetrics 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'HDInsightStormMetrics'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'HDInsightStormMetrics'
      displayName: 'HDInsightStormMetrics'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_HDInsightStormTopologyMetrics 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'HDInsightStormTopologyMetrics'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'HDInsightStormTopologyMetrics'
      displayName: 'HDInsightStormTopologyMetrics'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_HealthStateChangeEvent 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'HealthStateChangeEvent'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'HealthStateChangeEvent'
      displayName: 'HealthStateChangeEvent'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_Heartbeat 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'Heartbeat'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'Heartbeat'
      displayName: 'Heartbeat'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_InsightsMetrics 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'InsightsMetrics'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'InsightsMetrics'
      displayName: 'InsightsMetrics'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_IntuneAuditLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'IntuneAuditLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'IntuneAuditLogs'
      displayName: 'IntuneAuditLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_IntuneDeviceComplianceOrg 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'IntuneDeviceComplianceOrg'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'IntuneDeviceComplianceOrg'
      displayName: 'IntuneDeviceComplianceOrg'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_IntuneDevices 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'IntuneDevices'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'IntuneDevices'
      displayName: 'IntuneDevices'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_IntuneOperationalLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'IntuneOperationalLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'IntuneOperationalLogs'
      displayName: 'IntuneOperationalLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_KubeEvents 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'KubeEvents'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'KubeEvents'
      displayName: 'KubeEvents'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_KubeHealth 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'KubeHealth'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'KubeHealth'
      displayName: 'KubeHealth'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_KubeMonAgentEvents 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'KubeMonAgentEvents'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'KubeMonAgentEvents'
      displayName: 'KubeMonAgentEvents'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_KubeNodeInventory 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'KubeNodeInventory'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'KubeNodeInventory'
      displayName: 'KubeNodeInventory'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_KubePodInventory 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'KubePodInventory'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'KubePodInventory'
      displayName: 'KubePodInventory'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_KubePVInventory 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'KubePVInventory'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'KubePVInventory'
      displayName: 'KubePVInventory'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_KubeServices 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'KubeServices'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'KubeServices'
      displayName: 'KubeServices'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_LAJobLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'LAJobLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'LAJobLogs'
      displayName: 'LAJobLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_LAQueryLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'LAQueryLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'LAQueryLogs'
      displayName: 'LAQueryLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_LASummaryLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'LASummaryLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'LASummaryLogs'
      displayName: 'LASummaryLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_LedgerTransactionLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'LedgerTransactionLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'LedgerTransactionLogs'
      displayName: 'LedgerTransactionLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_LedgerUserDefinedLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'LedgerUserDefinedLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'LedgerUserDefinedLogs'
      displayName: 'LedgerUserDefinedLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_LIATrackingEvents 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'LIATrackingEvents'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'LIATrackingEvents'
      displayName: 'LIATrackingEvents'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_LogicAppWorkflowRuntime 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'LogicAppWorkflowRuntime'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'LogicAppWorkflowRuntime'
      displayName: 'LogicAppWorkflowRuntime'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_MCCEventLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'MCCEventLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'MCCEventLogs'
      displayName: 'MCCEventLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_MCVPAuditLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'MCVPAuditLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'MCVPAuditLogs'
      displayName: 'MCVPAuditLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_MCVPOperationLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'MCVPOperationLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'MCVPOperationLogs'
      displayName: 'MCVPOperationLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_MDCDetectionDNSEvents 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'MDCDetectionDNSEvents'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'MDCDetectionDNSEvents'
      displayName: 'MDCDetectionDNSEvents'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_MDCDetectionFimEvents 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'MDCDetectionFimEvents'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'MDCDetectionFimEvents'
      displayName: 'MDCDetectionFimEvents'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_MDCDetectionGatingValidationEvents 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'MDCDetectionGatingValidationEvents'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'MDCDetectionGatingValidationEvents'
      displayName: 'MDCDetectionGatingValidationEvents'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_MDCDetectionK8SApiEvents 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'MDCDetectionK8SApiEvents'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'MDCDetectionK8SApiEvents'
      displayName: 'MDCDetectionK8SApiEvents'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_MDCDetectionProcessV2Events 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'MDCDetectionProcessV2Events'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'MDCDetectionProcessV2Events'
      displayName: 'MDCDetectionProcessV2Events'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_MDCFileIntegrityMonitoringEvents 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'MDCFileIntegrityMonitoringEvents'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'MDCFileIntegrityMonitoringEvents'
      displayName: 'MDCFileIntegrityMonitoringEvents'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_MDECustomCollectionDeviceFileEvents 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'MDECustomCollectionDeviceFileEvents'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'MDECustomCollectionDeviceFileEvents'
      displayName: 'MDECustomCollectionDeviceFileEvents'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_MDPResourceLog 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'MDPResourceLog'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'MDPResourceLog'
      displayName: 'MDPResourceLog'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_MeshControlPlane 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'MeshControlPlane'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'MeshControlPlane'
      displayName: 'MeshControlPlane'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_MicrosoftAzureBastionAuditLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'MicrosoftAzureBastionAuditLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'MicrosoftAzureBastionAuditLogs'
      displayName: 'MicrosoftAzureBastionAuditLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_MicrosoftDataShareReceivedSnapshotLog 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'MicrosoftDataShareReceivedSnapshotLog'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'MicrosoftDataShareReceivedSnapshotLog'
      displayName: 'MicrosoftDataShareReceivedSnapshotLog'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_MicrosoftDataShareSentSnapshotLog 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'MicrosoftDataShareSentSnapshotLog'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'MicrosoftDataShareSentSnapshotLog'
      displayName: 'MicrosoftDataShareSentSnapshotLog'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_MicrosoftDataShareShareLog 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'MicrosoftDataShareShareLog'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'MicrosoftDataShareShareLog'
      displayName: 'MicrosoftDataShareShareLog'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_MicrosoftGraphActivityLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'MicrosoftGraphActivityLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'MicrosoftGraphActivityLogs'
      displayName: 'MicrosoftGraphActivityLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_MicrosoftGraphPolicyLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'MicrosoftGraphPolicyLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'MicrosoftGraphPolicyLogs'
      displayName: 'MicrosoftGraphPolicyLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_MicrosoftHealthcareApisAuditLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'MicrosoftHealthcareApisAuditLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'MicrosoftHealthcareApisAuditLogs'
      displayName: 'MicrosoftHealthcareApisAuditLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_MicrosoftServicePrincipalSignInLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'MicrosoftServicePrincipalSignInLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'MicrosoftServicePrincipalSignInLogs'
      displayName: 'MicrosoftServicePrincipalSignInLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_MNFDeviceUpdates 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'MNFDeviceUpdates'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'MNFDeviceUpdates'
      displayName: 'MNFDeviceUpdates'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_MNFSystemSessionHistoryUpdates 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'MNFSystemSessionHistoryUpdates'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'MNFSystemSessionHistoryUpdates'
      displayName: 'MNFSystemSessionHistoryUpdates'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_MNFSystemStateMessageUpdates 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'MNFSystemStateMessageUpdates'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'MNFSystemStateMessageUpdates'
      displayName: 'MNFSystemStateMessageUpdates'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_MPCIngestionLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'MPCIngestionLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'MPCIngestionLogs'
      displayName: 'MPCIngestionLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_MySqlAuditLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'MySqlAuditLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'MySqlAuditLogs'
      displayName: 'MySqlAuditLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_MySqlSlowLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'MySqlSlowLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'MySqlSlowLogs'
      displayName: 'MySqlSlowLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_NatGatewayFlowlogsV1 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'NatGatewayFlowlogsV1'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'NatGatewayFlowlogsV1'
      displayName: 'NatGatewayFlowlogsV1'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_NCBMBreakGlassAuditLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'NCBMBreakGlassAuditLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'NCBMBreakGlassAuditLogs'
      displayName: 'NCBMBreakGlassAuditLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_NCBMSecurityDefenderLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'NCBMSecurityDefenderLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'NCBMSecurityDefenderLogs'
      displayName: 'NCBMSecurityDefenderLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_NCBMSecurityLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'NCBMSecurityLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'NCBMSecurityLogs'
      displayName: 'NCBMSecurityLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_NCBMSystemLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'NCBMSystemLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'NCBMSystemLogs'
      displayName: 'NCBMSystemLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_NCCIDRACLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'NCCIDRACLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'NCCIDRACLogs'
      displayName: 'NCCIDRACLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_NCCKubernetesAPIAuditLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'NCCKubernetesAPIAuditLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'NCCKubernetesAPIAuditLogs'
      displayName: 'NCCKubernetesAPIAuditLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_NCCKubernetesLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'NCCKubernetesLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'NCCKubernetesLogs'
      displayName: 'NCCKubernetesLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_NCCPlatformOperationsLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'NCCPlatformOperationsLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'NCCPlatformOperationsLogs'
      displayName: 'NCCPlatformOperationsLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_NCCVMOrchestrationLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'NCCVMOrchestrationLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'NCCVMOrchestrationLogs'
      displayName: 'NCCVMOrchestrationLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_NCMClusterOperationsLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'NCMClusterOperationsLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'NCMClusterOperationsLogs'
      displayName: 'NCMClusterOperationsLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_NCSStorageAlerts 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'NCSStorageAlerts'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'NCSStorageAlerts'
      displayName: 'NCSStorageAlerts'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_NCSStorageAudits 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'NCSStorageAudits'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'NCSStorageAudits'
      displayName: 'NCSStorageAudits'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_NCSStorageLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'NCSStorageLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'NCSStorageLogs'
      displayName: 'NCSStorageLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_NetworkAccessAlerts 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'NetworkAccessAlerts'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'NetworkAccessAlerts'
      displayName: 'NetworkAccessAlerts'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_NetworkAccessConnectionEvents 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'NetworkAccessConnectionEvents'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'NetworkAccessConnectionEvents'
      displayName: 'NetworkAccessConnectionEvents'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_NetworkAccessGenerativeAIInsights 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'NetworkAccessGenerativeAIInsights'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'NetworkAccessGenerativeAIInsights'
      displayName: 'NetworkAccessGenerativeAIInsights'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_NetworkAccessTraffic 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'NetworkAccessTraffic'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'NetworkAccessTraffic'
      displayName: 'NetworkAccessTraffic'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_NginxUpstreamUpdateLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'NginxUpstreamUpdateLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'NginxUpstreamUpdateLogs'
      displayName: 'NginxUpstreamUpdateLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_NGXOperationLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'NGXOperationLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'NGXOperationLogs'
      displayName: 'NGXOperationLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_NGXSecurityLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'NGXSecurityLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'NGXSecurityLogs'
      displayName: 'NGXSecurityLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_NSPAccessLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'NSPAccessLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'NSPAccessLogs'
      displayName: 'NSPAccessLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_NTAInsights 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'NTAInsights'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'NTAInsights'
      displayName: 'NTAInsights'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_NTAIpDetails 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'NTAIpDetails'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'NTAIpDetails'
      displayName: 'NTAIpDetails'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_NTANetAnalytics 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'NTANetAnalytics'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'NTANetAnalytics'
      displayName: 'NTANetAnalytics'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_NTANspRuleRecommendation 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'NTANspRuleRecommendation'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'NTANspRuleRecommendation'
      displayName: 'NTANspRuleRecommendation'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_NTARuleRecommendation 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'NTARuleRecommendation'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'NTARuleRecommendation'
      displayName: 'NTARuleRecommendation'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_NTATopologyDetails 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'NTATopologyDetails'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'NTATopologyDetails'
      displayName: 'NTATopologyDetails'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_NWConnectionMonitorDestinationListenerResult 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'NWConnectionMonitorDestinationListenerResult'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'NWConnectionMonitorDestinationListenerResult'
      displayName: 'NWConnectionMonitorDestinationListenerResult'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_NWConnectionMonitorDNSResult 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'NWConnectionMonitorDNSResult'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'NWConnectionMonitorDNSResult'
      displayName: 'NWConnectionMonitorDNSResult'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_NWConnectionMonitorPathResult 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'NWConnectionMonitorPathResult'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'NWConnectionMonitorPathResult'
      displayName: 'NWConnectionMonitorPathResult'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_NWConnectionMonitorTestResult 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'NWConnectionMonitorTestResult'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'NWConnectionMonitorTestResult'
      displayName: 'NWConnectionMonitorTestResult'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_OEPAirFlowTask 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'OEPAirFlowTask'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'OEPAirFlowTask'
      displayName: 'OEPAirFlowTask'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_OEPAuditLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'OEPAuditLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'OEPAuditLogs'
      displayName: 'OEPAuditLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_OEPDataplaneLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'OEPDataplaneLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'OEPDataplaneLogs'
      displayName: 'OEPDataplaneLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_OEPElasticOperator 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'OEPElasticOperator'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'OEPElasticOperator'
      displayName: 'OEPElasticOperator'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_OEPElasticsearch 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'OEPElasticsearch'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'OEPElasticsearch'
      displayName: 'OEPElasticsearch'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_OEWAuditLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'OEWAuditLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'OEWAuditLogs'
      displayName: 'OEWAuditLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_OEWExperimentAssignmentSummary 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'OEWExperimentAssignmentSummary'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'OEWExperimentAssignmentSummary'
      displayName: 'OEWExperimentAssignmentSummary'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_OEWExperimentScorecardMetricPairs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'OEWExperimentScorecardMetricPairs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'OEWExperimentScorecardMetricPairs'
      displayName: 'OEWExperimentScorecardMetricPairs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_OEWExperimentScorecards 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'OEWExperimentScorecards'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'OEWExperimentScorecards'
      displayName: 'OEWExperimentScorecards'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_OGOAuditLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'OGOAuditLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'OGOAuditLogs'
      displayName: 'OGOAuditLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_OLPSupplyChainEntityOperations 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'OLPSupplyChainEntityOperations'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'OLPSupplyChainEntityOperations'
      displayName: 'OLPSupplyChainEntityOperations'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_OLPSupplyChainEvents 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'OLPSupplyChainEvents'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'OLPSupplyChainEvents'
      displayName: 'OLPSupplyChainEvents'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_OmsCustomerProfileFact 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'OmsCustomerProfileFact'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'OmsCustomerProfileFact'
      displayName: 'OmsCustomerProfileFact'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_Operation 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'Operation'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'Operation'
      displayName: 'Operation'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_OracleCloudDatabase 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'OracleCloudDatabase'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'OracleCloudDatabase'
      displayName: 'OracleCloudDatabase'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_OTelEvents 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'OTelEvents'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'OTelEvents'
      displayName: 'OTelEvents'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_OTelLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'OTelLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'OTelLogs'
      displayName: 'OTelLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_OTelResources 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'OTelResources'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'OTelResources'
      displayName: 'OTelResources'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_OTelSpans 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'OTelSpans'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'OTelSpans'
      displayName: 'OTelSpans'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_OTelTraces 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'OTelTraces'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'OTelTraces'
      displayName: 'OTelTraces'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_OTelTracesAgent 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'OTelTracesAgent'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'OTelTracesAgent'
      displayName: 'OTelTracesAgent'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_Perf 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'Perf'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'Perf'
      displayName: 'Perf'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_PerfInsightsFindings 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'PerfInsightsFindings'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'PerfInsightsFindings'
      displayName: 'PerfInsightsFindings'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_PerfInsightsImpactedResources 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'PerfInsightsImpactedResources'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'PerfInsightsImpactedResources'
      displayName: 'PerfInsightsImpactedResources'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_PerfInsightsRun 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'PerfInsightsRun'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'PerfInsightsRun'
      displayName: 'PerfInsightsRun'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_PFTitleAuditLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'PFTitleAuditLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'PFTitleAuditLogs'
      displayName: 'PFTitleAuditLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_PGSQLAutovacuumStats 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'PGSQLAutovacuumStats'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'PGSQLAutovacuumStats'
      displayName: 'PGSQLAutovacuumStats'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_PGSQLDbTransactionsStats 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'PGSQLDbTransactionsStats'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'PGSQLDbTransactionsStats'
      displayName: 'PGSQLDbTransactionsStats'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_PGSQLPgBouncer 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'PGSQLPgBouncer'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'PGSQLPgBouncer'
      displayName: 'PGSQLPgBouncer'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_PGSQLPgStatActivitySessions 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'PGSQLPgStatActivitySessions'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'PGSQLPgStatActivitySessions'
      displayName: 'PGSQLPgStatActivitySessions'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_PGSQLQueryStoreQueryText 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'PGSQLQueryStoreQueryText'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'PGSQLQueryStoreQueryText'
      displayName: 'PGSQLQueryStoreQueryText'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_PGSQLQueryStoreRuntime 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'PGSQLQueryStoreRuntime'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'PGSQLQueryStoreRuntime'
      displayName: 'PGSQLQueryStoreRuntime'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_PGSQLQueryStoreWaits 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'PGSQLQueryStoreWaits'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'PGSQLQueryStoreWaits'
      displayName: 'PGSQLQueryStoreWaits'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_PGSQLServerLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'PGSQLServerLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'PGSQLServerLogs'
      displayName: 'PGSQLServerLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_PowerBIDatasetsTenant 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'PowerBIDatasetsTenant'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'PowerBIDatasetsTenant'
      displayName: 'PowerBIDatasetsTenant'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_PowerBIDatasetsWorkspace 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'PowerBIDatasetsWorkspace'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'PowerBIDatasetsWorkspace'
      displayName: 'PowerBIDatasetsWorkspace'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_PurviewDataSensitivityLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'PurviewDataSensitivityLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'PurviewDataSensitivityLogs'
      displayName: 'PurviewDataSensitivityLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_PurviewScanStatusLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'PurviewScanStatusLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'PurviewScanStatusLogs'
      displayName: 'PurviewScanStatusLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_PurviewSecurityLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'PurviewSecurityLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'PurviewSecurityLogs'
      displayName: 'PurviewSecurityLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_QuantumProviderAccountJobAuditLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'QuantumProviderAccountJobAuditLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'QuantumProviderAccountJobAuditLogs'
      displayName: 'QuantumProviderAccountJobAuditLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_QuantumProviderAccountQueueAuditLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'QuantumProviderAccountQueueAuditLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'QuantumProviderAccountQueueAuditLogs'
      displayName: 'QuantumProviderAccountQueueAuditLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_QuantumProviderAccountTargetAuditLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'QuantumProviderAccountTargetAuditLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'QuantumProviderAccountTargetAuditLogs'
      displayName: 'QuantumProviderAccountTargetAuditLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_QuantumWorkspaceJobAuditLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'QuantumWorkspaceJobAuditLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'QuantumWorkspaceJobAuditLogs'
      displayName: 'QuantumWorkspaceJobAuditLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_REDConnectionEvents 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'REDConnectionEvents'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'REDConnectionEvents'
      displayName: 'REDConnectionEvents'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_RemoteNetworkHealthLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'RemoteNetworkHealthLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'RemoteNetworkHealthLogs'
      displayName: 'RemoteNetworkHealthLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_ResourceManagementPublicAccessLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'ResourceManagementPublicAccessLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'ResourceManagementPublicAccessLogs'
      displayName: 'ResourceManagementPublicAccessLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_RetinaNetworkFlowLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'RetinaNetworkFlowLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'RetinaNetworkFlowLogs'
      displayName: 'RetinaNetworkFlowLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_SCCMAssessmentRecommendation 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'SCCMAssessmentRecommendation'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'SCCMAssessmentRecommendation'
      displayName: 'SCCMAssessmentRecommendation'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_SCGPoolExecutionLog 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'SCGPoolExecutionLog'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'SCGPoolExecutionLog'
      displayName: 'SCGPoolExecutionLog'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_SCGPoolRequestLog 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'SCGPoolRequestLog'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'SCGPoolRequestLog'
      displayName: 'SCGPoolRequestLog'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_SCOMAssessmentRecommendation 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'SCOMAssessmentRecommendation'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'SCOMAssessmentRecommendation'
      displayName: 'SCOMAssessmentRecommendation'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_SecurityCaseEvent 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'SecurityCaseEvent'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'SecurityCaseEvent'
      displayName: 'SecurityCaseEvent'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_ServiceFabricOperationalEvent 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'ServiceFabricOperationalEvent'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'ServiceFabricOperationalEvent'
      displayName: 'ServiceFabricOperationalEvent'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_ServiceFabricReliableActorEvent 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'ServiceFabricReliableActorEvent'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'ServiceFabricReliableActorEvent'
      displayName: 'ServiceFabricReliableActorEvent'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_ServiceFabricReliableServiceEvent 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'ServiceFabricReliableServiceEvent'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'ServiceFabricReliableServiceEvent'
      displayName: 'ServiceFabricReliableServiceEvent'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_SfBAssessmentRecommendation 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'SfBAssessmentRecommendation'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'SfBAssessmentRecommendation'
      displayName: 'SfBAssessmentRecommendation'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_SfBOnlineAssessmentRecommendation 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'SfBOnlineAssessmentRecommendation'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'SfBOnlineAssessmentRecommendation'
      displayName: 'SfBOnlineAssessmentRecommendation'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_SharePointOnlineAssessmentRecommendation 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'SharePointOnlineAssessmentRecommendation'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'SharePointOnlineAssessmentRecommendation'
      displayName: 'SharePointOnlineAssessmentRecommendation'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_SignalRServiceDiagnosticLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'SignalRServiceDiagnosticLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'SignalRServiceDiagnosticLogs'
      displayName: 'SignalRServiceDiagnosticLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_SigninLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'SigninLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'SigninLogs'
      displayName: 'SigninLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_SPAssessmentRecommendation 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'SPAssessmentRecommendation'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'SPAssessmentRecommendation'
      displayName: 'SPAssessmentRecommendation'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_SQLAssessmentRecommendation 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'SQLAssessmentRecommendation'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'SQLAssessmentRecommendation'
      displayName: 'SQLAssessmentRecommendation'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_SQLSecurityAuditEvents 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'SQLSecurityAuditEvents'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'SQLSecurityAuditEvents'
      displayName: 'SQLSecurityAuditEvents'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_StorageAntimalwareScanResults 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'StorageAntimalwareScanResults'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'StorageAntimalwareScanResults'
      displayName: 'StorageAntimalwareScanResults'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_StorageBlobLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'StorageBlobLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'StorageBlobLogs'
      displayName: 'StorageBlobLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_StorageCacheOperationEvents 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'StorageCacheOperationEvents'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'StorageCacheOperationEvents'
      displayName: 'StorageCacheOperationEvents'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_StorageCacheUpgradeEvents 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'StorageCacheUpgradeEvents'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'StorageCacheUpgradeEvents'
      displayName: 'StorageCacheUpgradeEvents'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_StorageCacheWarningEvents 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'StorageCacheWarningEvents'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'StorageCacheWarningEvents'
      displayName: 'StorageCacheWarningEvents'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_StorageFileLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'StorageFileLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'StorageFileLogs'
      displayName: 'StorageFileLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_StorageMalwareScanningResults 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'StorageMalwareScanningResults'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'StorageMalwareScanningResults'
      displayName: 'StorageMalwareScanningResults'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_StorageMoverAuditLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'StorageMoverAuditLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'StorageMoverAuditLogs'
      displayName: 'StorageMoverAuditLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_StorageMoverCopyLogsFailed 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'StorageMoverCopyLogsFailed'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'StorageMoverCopyLogsFailed'
      displayName: 'StorageMoverCopyLogsFailed'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_StorageMoverCopyLogsTransferred 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'StorageMoverCopyLogsTransferred'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'StorageMoverCopyLogsTransferred'
      displayName: 'StorageMoverCopyLogsTransferred'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_StorageMoverJobRunLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'StorageMoverJobRunLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'StorageMoverJobRunLogs'
      displayName: 'StorageMoverJobRunLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_StorageQueueLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'StorageQueueLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'StorageQueueLogs'
      displayName: 'StorageQueueLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_StorageTableLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'StorageTableLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'StorageTableLogs'
      displayName: 'StorageTableLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_SucceededIngestion 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'SucceededIngestion'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'SucceededIngestion'
      displayName: 'SucceededIngestion'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_SVMPoolExecutionLog 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'SVMPoolExecutionLog'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'SVMPoolExecutionLog'
      displayName: 'SVMPoolExecutionLog'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_SVMPoolRequestLog 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'SVMPoolRequestLog'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'SVMPoolRequestLog'
      displayName: 'SVMPoolRequestLog'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_SynapseBigDataPoolApplicationsEnded 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'SynapseBigDataPoolApplicationsEnded'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'SynapseBigDataPoolApplicationsEnded'
      displayName: 'SynapseBigDataPoolApplicationsEnded'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_SynapseBuiltinSqlPoolRequestsEnded 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'SynapseBuiltinSqlPoolRequestsEnded'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'SynapseBuiltinSqlPoolRequestsEnded'
      displayName: 'SynapseBuiltinSqlPoolRequestsEnded'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_SynapseDXCommand 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'SynapseDXCommand'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'SynapseDXCommand'
      displayName: 'SynapseDXCommand'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_SynapseDXFailedIngestion 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'SynapseDXFailedIngestion'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'SynapseDXFailedIngestion'
      displayName: 'SynapseDXFailedIngestion'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_SynapseDXIngestionBatching 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'SynapseDXIngestionBatching'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'SynapseDXIngestionBatching'
      displayName: 'SynapseDXIngestionBatching'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_SynapseDXQuery 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'SynapseDXQuery'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'SynapseDXQuery'
      displayName: 'SynapseDXQuery'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_SynapseDXSucceededIngestion 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'SynapseDXSucceededIngestion'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'SynapseDXSucceededIngestion'
      displayName: 'SynapseDXSucceededIngestion'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_SynapseDXTableDetails 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'SynapseDXTableDetails'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'SynapseDXTableDetails'
      displayName: 'SynapseDXTableDetails'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_SynapseDXTableUsageStatistics 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'SynapseDXTableUsageStatistics'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'SynapseDXTableUsageStatistics'
      displayName: 'SynapseDXTableUsageStatistics'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_SynapseGatewayApiRequests 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'SynapseGatewayApiRequests'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'SynapseGatewayApiRequests'
      displayName: 'SynapseGatewayApiRequests'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_SynapseIntegrationActivityRuns 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'SynapseIntegrationActivityRuns'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'SynapseIntegrationActivityRuns'
      displayName: 'SynapseIntegrationActivityRuns'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_SynapseIntegrationPipelineRuns 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'SynapseIntegrationPipelineRuns'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'SynapseIntegrationPipelineRuns'
      displayName: 'SynapseIntegrationPipelineRuns'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_SynapseIntegrationTriggerRuns 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'SynapseIntegrationTriggerRuns'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'SynapseIntegrationTriggerRuns'
      displayName: 'SynapseIntegrationTriggerRuns'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_SynapseLinkEvent 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'SynapseLinkEvent'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'SynapseLinkEvent'
      displayName: 'SynapseLinkEvent'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_SynapseRbacOperations 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'SynapseRbacOperations'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'SynapseRbacOperations'
      displayName: 'SynapseRbacOperations'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_SynapseScopePoolScopeJobsEnded 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'SynapseScopePoolScopeJobsEnded'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'SynapseScopePoolScopeJobsEnded'
      displayName: 'SynapseScopePoolScopeJobsEnded'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_SynapseScopePoolScopeJobsStateChange 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'SynapseScopePoolScopeJobsStateChange'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'SynapseScopePoolScopeJobsStateChange'
      displayName: 'SynapseScopePoolScopeJobsStateChange'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_SynapseSqlPoolDmsWorkers 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'SynapseSqlPoolDmsWorkers'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'SynapseSqlPoolDmsWorkers'
      displayName: 'SynapseSqlPoolDmsWorkers'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_SynapseSqlPoolExecRequests 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'SynapseSqlPoolExecRequests'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'SynapseSqlPoolExecRequests'
      displayName: 'SynapseSqlPoolExecRequests'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_SynapseSqlPoolRequestSteps 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'SynapseSqlPoolRequestSteps'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'SynapseSqlPoolRequestSteps'
      displayName: 'SynapseSqlPoolRequestSteps'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_SynapseSqlPoolSqlRequests 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'SynapseSqlPoolSqlRequests'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'SynapseSqlPoolSqlRequests'
      displayName: 'SynapseSqlPoolSqlRequests'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_SynapseSqlPoolWaits 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'SynapseSqlPoolWaits'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'SynapseSqlPoolWaits'
      displayName: 'SynapseSqlPoolWaits'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_Syslog 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'Syslog'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'Syslog'
      displayName: 'Syslog'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_TOUserAudits 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'TOUserAudits'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'TOUserAudits'
      displayName: 'TOUserAudits'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_TOUserDiagnostics 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'TOUserDiagnostics'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'TOUserDiagnostics'
      displayName: 'TOUserDiagnostics'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_TSIIngress 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'TSIIngress'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'TSIIngress'
      displayName: 'TSIIngress'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_UCClient 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'UCClient'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'UCClient'
      displayName: 'UCClient'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_UCClientReadinessStatus 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'UCClientReadinessStatus'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'UCClientReadinessStatus'
      displayName: 'UCClientReadinessStatus'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_UCClientUpdateStatus 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'UCClientUpdateStatus'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'UCClientUpdateStatus'
      displayName: 'UCClientUpdateStatus'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_UCDeviceAlert 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'UCDeviceAlert'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'UCDeviceAlert'
      displayName: 'UCDeviceAlert'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_UCDOAggregatedStatus 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'UCDOAggregatedStatus'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'UCDOAggregatedStatus'
      displayName: 'UCDOAggregatedStatus'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_UCDOStatus 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'UCDOStatus'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'UCDOStatus'
      displayName: 'UCDOStatus'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_UCServiceUpdateStatus 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'UCServiceUpdateStatus'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'UCServiceUpdateStatus'
      displayName: 'UCServiceUpdateStatus'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_UCUpdateAlert 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'UCUpdateAlert'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'UCUpdateAlert'
      displayName: 'UCUpdateAlert'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_Usage 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'Usage'
  properties: {
    totalRetentionInDays: 90
    plan: 'Analytics'
    schema: {
      name: 'Usage'
      displayName: 'Usage'
    }
    retentionInDays: 90
  }
}

resource workspaces_com754_ls_name_VCoreMongoRequests 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'VCoreMongoRequests'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'VCoreMongoRequests'
      displayName: 'VCoreMongoRequests'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_VIAudit 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'VIAudit'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'VIAudit'
      displayName: 'VIAudit'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_VIIndexing 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'VIIndexing'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'VIIndexing'
      displayName: 'VIIndexing'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_VMBoundPort 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'VMBoundPort'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'VMBoundPort'
      displayName: 'VMBoundPort'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_VMComputer 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'VMComputer'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'VMComputer'
      displayName: 'VMComputer'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_VMConnection 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'VMConnection'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'VMConnection'
      displayName: 'VMConnection'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_VMProcess 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'VMProcess'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'VMProcess'
      displayName: 'VMProcess'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_W3CIISLog 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'W3CIISLog'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'W3CIISLog'
      displayName: 'W3CIISLog'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_WebPubSubConnectivity 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'WebPubSubConnectivity'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'WebPubSubConnectivity'
      displayName: 'WebPubSubConnectivity'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_WebPubSubHttpRequest 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'WebPubSubHttpRequest'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'WebPubSubHttpRequest'
      displayName: 'WebPubSubHttpRequest'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_WebPubSubMessaging 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'WebPubSubMessaging'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'WebPubSubMessaging'
      displayName: 'WebPubSubMessaging'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_Windows365AuditLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'Windows365AuditLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'Windows365AuditLogs'
      displayName: 'Windows365AuditLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_WindowsClientAssessmentRecommendation 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'WindowsClientAssessmentRecommendation'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'WindowsClientAssessmentRecommendation'
      displayName: 'WindowsClientAssessmentRecommendation'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_WindowsServerAssessmentRecommendation 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'WindowsServerAssessmentRecommendation'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'WindowsServerAssessmentRecommendation'
      displayName: 'WindowsServerAssessmentRecommendation'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_WorkloadDiagnosticLogs 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'WorkloadDiagnosticLogs'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'WorkloadDiagnosticLogs'
      displayName: 'WorkloadDiagnosticLogs'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_WOUserAudits 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'WOUserAudits'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'WOUserAudits'
      displayName: 'WOUserAudits'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_WOUserDiagnostics 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'WOUserDiagnostics'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'WOUserDiagnostics'
      displayName: 'WOUserDiagnostics'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_WVDAgentHealthStatus 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'WVDAgentHealthStatus'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'WVDAgentHealthStatus'
      displayName: 'WVDAgentHealthStatus'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_WVDAutoscaleEvaluationPooled 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'WVDAutoscaleEvaluationPooled'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'WVDAutoscaleEvaluationPooled'
      displayName: 'WVDAutoscaleEvaluationPooled'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_WVDCheckpoints 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'WVDCheckpoints'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'WVDCheckpoints'
      displayName: 'WVDCheckpoints'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_WVDConnectionGraphicsDataPreview 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'WVDConnectionGraphicsDataPreview'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'WVDConnectionGraphicsDataPreview'
      displayName: 'WVDConnectionGraphicsDataPreview'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_WVDConnectionNetworkData 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'WVDConnectionNetworkData'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'WVDConnectionNetworkData'
      displayName: 'WVDConnectionNetworkData'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_WVDConnections 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'WVDConnections'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'WVDConnections'
      displayName: 'WVDConnections'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_WVDErrors 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'WVDErrors'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'WVDErrors'
      displayName: 'WVDErrors'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_WVDFeeds 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'WVDFeeds'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'WVDFeeds'
      displayName: 'WVDFeeds'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_WVDHostRegistrations 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'WVDHostRegistrations'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'WVDHostRegistrations'
      displayName: 'WVDHostRegistrations'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_WVDManagement 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'WVDManagement'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'WVDManagement'
      displayName: 'WVDManagement'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_WVDMultiLinkAdd 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'WVDMultiLinkAdd'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'WVDMultiLinkAdd'
      displayName: 'WVDMultiLinkAdd'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_WVDSessionHostManagement 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'WVDSessionHostManagement'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'WVDSessionHostManagement'
      displayName: 'WVDSessionHostManagement'
    }
    retentionInDays: 30
  }
}

resource workspaces_com754_ls_name_ZTSRequest 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
  parent: workspaces_com754_ls_name_resource
  name: 'ZTSRequest'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'ZTSRequest'
      displayName: 'ZTSRequest'
    }
    retentionInDays: 30
  }
}

resource namespaces_com754_sb_detection_results_name_RootManageSharedAccessKey 'Microsoft.ServiceBus/namespaces/authorizationrules@2025-05-01-preview' = {
  parent: namespaces_com754_sb_detection_results_name_resource
  name: 'RootManageSharedAccessKey'
  location: 'francecentral'
  properties: {
    rights: [
      'Listen'
      'Manage'
      'Send'
    ]
  }
}

resource namespaces_com754_sb_detection_results_name_default 'Microsoft.ServiceBus/namespaces/networkrulesets@2025-05-01-preview' = {
  parent: namespaces_com754_sb_detection_results_name_resource
  name: 'default'
  location: 'francecentral'
  properties: {
    publicNetworkAccess: 'Enabled'
    defaultAction: 'Allow'
    virtualNetworkRules: []
    ipRules: []
    trustedServiceAccessEnabled: false
  }
}

resource namespaces_com754_sb_detection_results_name_detection_results 'Microsoft.ServiceBus/namespaces/queues@2025-05-01-preview' = {
  parent: namespaces_com754_sb_detection_results_name_resource
  name: 'detection-results'
  location: 'francecentral'
  properties: {
    maxMessageSizeInKilobytes: 256
    lockDuration: 'PT5S'
    maxSizeInMegabytes: 1024
    requiresDuplicateDetection: true
    requiresSession: false
    defaultMessageTimeToLive: 'PT10M'
    deadLetteringOnMessageExpiration: false
    enableBatchedOperations: true
    duplicateDetectionHistoryTimeWindow: 'PT10M'
    maxDeliveryCount: 5
    status: 'Active'
    autoDeleteOnIdle: 'P10675199DT2H48M5.4775807S'
    enablePartitioning: false
    enableExpress: false
  }
}

resource sites_com754_as_transcript_and_detect_name_resource 'Microsoft.Web/sites@2024-11-01' = {
  name: sites_com754_as_transcript_and_detect_name
  location: 'France Central'
  tags: {
    'hidden-link: /app-insights-resource-id': '/subscriptions/9c70edb4-d5ee-45a1-9172-a8d0d83136dc/resourceGroups/com754-rg/providers/microsoft.insights/components/com754-as-detector'
  }
  kind: 'app,linux'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    enabled: true
    hostNameSslStates: [
      {
        name: '${sites_com754_as_transcript_and_detect_name}-f5hyctgehcc5ewav.francecentral-01.azurewebsites.net'
        sslState: 'Disabled'
        hostType: 'Standard'
      }
      {
        name: '${sites_com754_as_transcript_and_detect_name}-f5hyctgehcc5ewav.scm.francecentral-01.azurewebsites.net'
        sslState: 'Disabled'
        hostType: 'Repository'
      }
    ]
    serverFarmId: serverfarms_com754_asp_name_resource.id
    reserved: true
    isXenon: false
    hyperV: false
    dnsConfiguration: {}
    outboundVnetRouting: {
      allTraffic: false
      applicationTraffic: false
      contentShareTraffic: false
      imagePullTraffic: false
      backupRestoreTraffic: false
    }
    siteConfig: {
      numberOfWorkers: 1
      linuxFxVersion: 'PYTHON|3.13'
      acrUseManagedIdentityCreds: false
      alwaysOn: true
      http20Enabled: false
      functionAppScaleLimit: 0
      minimumElasticInstanceCount: 1
    }
    scmSiteAlsoStopped: false
    clientAffinityEnabled: true
    clientAffinityProxyEnabled: false
    clientCertEnabled: false
    clientCertMode: 'Required'
    hostNamesDisabled: false
    ipMode: 'IPv4'
    customDomainVerificationId: 'A74AA7203458ED113E5F6DA1D8AE71E0FAE5119667AD3FEE8D0ECEDC0072B693'
    containerSize: 0
    dailyMemoryTimeQuota: 0
    httpsOnly: false
    endToEndEncryptionEnabled: false
    redundancyMode: 'None'
    publicNetworkAccess: 'Enabled'
    storageAccountRequired: false
    keyVaultReferenceIdentity: 'SystemAssigned'
    autoGeneratedDomainNameLabelScope: 'TenantReuse'
    sshEnabled: true
  }
}

resource sites_com754_as_transcript_and_detect_name_ftp 'Microsoft.Web/sites/basicPublishingCredentialsPolicies@2024-11-01' = {
  parent: sites_com754_as_transcript_and_detect_name_resource
  name: 'ftp'
  location: 'France Central'
  tags: {
    'hidden-link: /app-insights-resource-id': '/subscriptions/9c70edb4-d5ee-45a1-9172-a8d0d83136dc/resourceGroups/com754-rg/providers/microsoft.insights/components/com754-as-detector'
  }
  properties: {
    allow: true
  }
}

resource sites_com754_as_transcript_and_detect_name_scm 'Microsoft.Web/sites/basicPublishingCredentialsPolicies@2024-11-01' = {
  parent: sites_com754_as_transcript_and_detect_name_resource
  name: 'scm'
  location: 'France Central'
  tags: {
    'hidden-link: /app-insights-resource-id': '/subscriptions/9c70edb4-d5ee-45a1-9172-a8d0d83136dc/resourceGroups/com754-rg/providers/microsoft.insights/components/com754-as-detector'
  }
  properties: {
    allow: true
  }
}

resource sites_com754_as_transcript_and_detect_name_web 'Microsoft.Web/sites/config@2024-11-01' = {
  parent: sites_com754_as_transcript_and_detect_name_resource
  name: 'web'
  location: 'France Central'
  tags: {
    'hidden-link: /app-insights-resource-id': '/subscriptions/9c70edb4-d5ee-45a1-9172-a8d0d83136dc/resourceGroups/com754-rg/providers/microsoft.insights/components/com754-as-detector'
  }
  properties: {
    numberOfWorkers: 1
    defaultDocuments: [
      'Default.htm'
      'Default.html'
      'Default.asp'
      'index.htm'
      'index.html'
      'iisstart.htm'
      'default.aspx'
      'index.php'
      'hostingstart.html'
    ]
    netFrameworkVersion: 'v4.0'
    linuxFxVersion: 'PYTHON|3.13'
    requestTracingEnabled: false
    remoteDebuggingEnabled: false
    remoteDebuggingVersion: 'VS2022'
    httpLoggingEnabled: true
    acrUseManagedIdentityCreds: false
    logsDirectorySizeLimit: 100
    detailedErrorLoggingEnabled: false
    publishingUsername: '$com754-as-transcript-and-detect'
    scmType: 'None'
    use32BitWorkerProcess: true
    webSocketsEnabled: false
    alwaysOn: true
    appCommandLine: 'python3 -m gunicorn --worker-class uvicorn.workers.UvicornWorker --bind 0.0.0.0:8000 -w 1 application:app'
    managedPipelineMode: 'Integrated'
    virtualApplications: [
      {
        virtualPath: '/'
        physicalPath: 'site\\wwwroot'
        preloadEnabled: true
      }
    ]
    loadBalancing: 'LeastRequests'
    experiments: {
      rampUpRules: []
    }
    autoHealEnabled: false
    vnetRouteAllEnabled: false
    vnetPrivatePortsCount: 0
    localMySqlEnabled: false
    managedServiceIdentityId: 16502
    ipSecurityRestrictions: [
      {
        ipAddress: 'Any'
        action: 'Allow'
        priority: 2147483647
        name: 'Allow all'
        description: 'Allow all access'
      }
    ]
    scmIpSecurityRestrictions: [
      {
        ipAddress: 'Any'
        action: 'Allow'
        priority: 2147483647
        name: 'Allow all'
        description: 'Allow all access'
      }
    ]
    scmIpSecurityRestrictionsUseMain: false
    http20Enabled: false
    minTlsVersion: '1.2'
    scmMinTlsVersion: '1.2'
    ftpsState: 'FtpsOnly'
    preWarmedInstanceCount: 0
    elasticWebAppScaleLimit: 0
    healthCheckPath: '/ping'
    functionsRuntimeScaleMonitoringEnabled: false
    minimumElasticInstanceCount: 1
    azureStorageAccounts: {}
    http20ProxyFlag: 0
  }
}

resource sites_com754_as_transcript_and_detect_name_1f64c6e2_558b_44be_aeb3_9d375f957c18 'Microsoft.Web/sites/deployments@2024-11-01' = {
  parent: sites_com754_as_transcript_and_detect_name_resource
  name: '1f64c6e2-558b-44be-aeb3-9d375f957c18'
  location: 'France Central'
  properties: {
    status: 4
    author_email: 'N/A'
    author: 'ms-azuretools-vscode'
    deployer: 'ms-azuretools-vscode'
    message: 'Created via a push deployment'
    start_time: '2026-02-08T00:40:34.1104719Z'
    end_time: '2026-02-08T00:42:00.8563249Z'
    active: false
  }
}

resource sites_com754_as_transcript_and_detect_name_5979fd9d_c92f_4ee0_99fa_6d302ef65e07 'Microsoft.Web/sites/deployments@2024-11-01' = {
  parent: sites_com754_as_transcript_and_detect_name_resource
  name: '5979fd9d-c92f-4ee0-99fa-6d302ef65e07'
  location: 'France Central'
  properties: {
    status: 4
    author_email: 'N/A'
    author: 'ms-azuretools-vscode'
    deployer: 'ms-azuretools-vscode'
    message: 'Created via a push deployment'
    start_time: '2026-02-07T20:56:35.2332524Z'
    end_time: '2026-02-07T20:58:01.7860834Z'
    active: false
  }
}

resource sites_com754_as_transcript_and_detect_name_6c13c391_f618_4c4a_be80_f09d28d21bf4 'Microsoft.Web/sites/deployments@2024-11-01' = {
  parent: sites_com754_as_transcript_and_detect_name_resource
  name: '6c13c391-f618-4c4a-be80-f09d28d21bf4'
  location: 'France Central'
  properties: {
    status: 4
    author_email: 'N/A'
    author: 'ms-azuretools-vscode'
    deployer: 'ms-azuretools-vscode'
    message: 'Created via a push deployment'
    start_time: '2026-02-07T21:20:17.8789363Z'
    end_time: '2026-02-07T21:21:43.9559377Z'
    active: false
  }
}

resource sites_com754_as_transcript_and_detect_name_8139a4c6_4fd6_4e23_af51_ad689ca59448 'Microsoft.Web/sites/deployments@2024-11-01' = {
  parent: sites_com754_as_transcript_and_detect_name_resource
  name: '8139a4c6-4fd6-4e23-af51-ad689ca59448'
  location: 'France Central'
  properties: {
    status: 4
    author_email: 'N/A'
    author: 'ms-azuretools-vscode'
    deployer: 'ms-azuretools-vscode'
    message: 'Created via a push deployment'
    start_time: '2026-02-08T01:19:53.1511141Z'
    end_time: '2026-02-08T01:21:19.5059434Z'
    active: false
  }
}

resource sites_com754_as_transcript_and_detect_name_9a2ae5b5_aaf0_456a_9527_06bf1601914e 'Microsoft.Web/sites/deployments@2024-11-01' = {
  parent: sites_com754_as_transcript_and_detect_name_resource
  name: '9a2ae5b5-aaf0-456a-9527-06bf1601914e'
  location: 'France Central'
  properties: {
    status: 4
    author_email: 'N/A'
    author: 'ms-azuretools-vscode'
    deployer: 'ms-azuretools-vscode'
    message: 'Created via a push deployment'
    start_time: '2026-02-07T13:00:05.1477896Z'
    end_time: '2026-02-07T13:01:30.9237214Z'
    active: false
  }
}

resource sites_com754_as_transcript_and_detect_name_b37d4309_1407_414c_9522_7bb42fb68ecb 'Microsoft.Web/sites/deployments@2024-11-01' = {
  parent: sites_com754_as_transcript_and_detect_name_resource
  name: 'b37d4309-1407-414c-9522-7bb42fb68ecb'
  location: 'France Central'
  properties: {
    status: 4
    author_email: 'N/A'
    author: 'ms-azuretools-vscode'
    deployer: 'ms-azuretools-vscode'
    message: 'Created via a push deployment'
    start_time: '2026-02-08T00:51:03.7121558Z'
    end_time: '2026-02-08T00:52:32.5688515Z'
    active: false
  }
}

resource sites_com754_as_transcript_and_detect_name_b7b04a43_d319_4662_b34c_fbfc34d0f098 'Microsoft.Web/sites/deployments@2024-11-01' = {
  parent: sites_com754_as_transcript_and_detect_name_resource
  name: 'b7b04a43-d319-4662-b34c-fbfc34d0f098'
  location: 'France Central'
  properties: {
    status: 4
    author_email: 'N/A'
    author: 'ms-azuretools-vscode'
    deployer: 'ms-azuretools-vscode'
    message: 'Created via a push deployment'
    start_time: '2026-02-08T01:34:40.4868993Z'
    end_time: '2026-02-08T01:36:06.4358797Z'
    active: false
  }
}

resource sites_com754_as_transcript_and_detect_name_c93b5e75_e6f6_4007_8c83_46f1c8c51dc4 'Microsoft.Web/sites/deployments@2024-11-01' = {
  parent: sites_com754_as_transcript_and_detect_name_resource
  name: 'c93b5e75-e6f6-4007-8c83-46f1c8c51dc4'
  location: 'France Central'
  properties: {
    status: 4
    author_email: 'N/A'
    author: 'ms-azuretools-vscode'
    deployer: 'ms-azuretools-vscode'
    message: 'Created via a push deployment'
    start_time: '2026-02-07T10:49:03.0897996Z'
    end_time: '2026-02-07T10:50:29.0369137Z'
    active: false
  }
}

resource sites_com754_as_transcript_and_detect_name_d25b0afe_52b8_44a0_94ba_e726d727f3b3 'Microsoft.Web/sites/deployments@2024-11-01' = {
  parent: sites_com754_as_transcript_and_detect_name_resource
  name: 'd25b0afe-52b8-44a0-94ba-e726d727f3b3'
  location: 'France Central'
  properties: {
    status: 4
    author_email: 'N/A'
    author: 'ms-azuretools-vscode'
    deployer: 'ms-azuretools-vscode'
    message: 'Created via a push deployment'
    start_time: '2026-02-07T19:37:02.1110155Z'
    end_time: '2026-02-07T19:38:28.7349441Z'
    active: false
  }
}

resource sites_com754_as_transcript_and_detect_name_ec9de244_f9ca_444a_abae_2154eba5048b 'Microsoft.Web/sites/deployments@2024-11-01' = {
  parent: sites_com754_as_transcript_and_detect_name_resource
  name: 'ec9de244-f9ca-444a-abae-2154eba5048b'
  location: 'France Central'
  properties: {
    status: 4
    author_email: 'N/A'
    author: 'ms-azuretools-vscode'
    deployer: 'ms-azuretools-vscode'
    message: 'Created via a push deployment'
    start_time: '2026-02-08T01:53:29.7608548Z'
    end_time: '2026-02-08T01:54:55.765779Z'
    active: true
  }
}

resource sites_com754_as_transcript_and_detect_name_sites_com754_as_transcript_and_detect_name_f5hyctgehcc5ewav_francecentral_01_azurewebsites_net 'Microsoft.Web/sites/hostNameBindings@2024-11-01' = {
  parent: sites_com754_as_transcript_and_detect_name_resource
  name: '${sites_com754_as_transcript_and_detect_name}-f5hyctgehcc5ewav.francecentral-01.azurewebsites.net'
  location: 'France Central'
  properties: {
    siteName: 'com754-as-transcript-and-detect'
    hostNameType: 'Verified'
  }
}
