targetScope = 'resourceGroup'

param apimName string
param appInsightsName string

resource apiManagement 'Microsoft.ApiManagement/service@2020-12-01' existing = {
  name: apimName
}

resource apiManagementLogger 'Microsoft.ApiManagement/service/loggers@2020-12-01' existing = {
  name: '${apimName}/${appInsightsName}'
}

resource apimApiCopilot 'Microsoft.ApiManagement/service/apis@2020-12-01' = {
  name: 'chicken-api-copilot'
  parent: apiManagement
  properties: {
    path: 'chicken-copilot'
    apiRevision: '1'
    displayName: 'Chicken API Copilot'
    description: 'Chicken service is a sample service generated by GitHub Copilot.'
    subscriptionRequired: false
    format: 'openapi-link'
    value:  'https://raw.githubusercontent.com/pascalvanderheiden/ais-apim-copilot/main/deploy/release/openapi/openapi_copilot.json'
    protocols: [
      'https'
    ]
  }
}

resource apimApiChatgpt 'Microsoft.ApiManagement/service/apis@2020-12-01' = {
  name: 'chicken-api-chatgpt'
  parent: apiManagement
  properties: {
    path: 'chicken-gpt'
    apiRevision: '1'
    displayName: 'Chicken API ChatGPT'
    description: 'Chicken service is a sample service generated by ChatGPT.'
    subscriptionRequired: false
    format: 'openapi-link'
    value:  'https://raw.githubusercontent.com/pascalvanderheiden/ais-apim-copilot/main/deploy/release/openapi/openapi_chatgpt.yaml'
    protocols: [
      'https'
    ]
  }
}

resource apiCopilotPolicies 'Microsoft.ApiManagement/service/apis/policies@2020-12-01' = {
  name: 'policy'
  parent: apimApiCopilot
  properties: {
    value: loadTextContent('./policies/api_policy.xml')
    format: 'rawxml'
  }
}

resource apiChatgptPolicies 'Microsoft.ApiManagement/service/apis/policies@2020-12-01' = {
  name: 'policy'
  parent: apimApiChatgpt
  properties: {
    value: loadTextContent('./policies/api_policy.xml')
    format: 'rawxml'
  }
}

resource apiMonitoringCopilot 'Microsoft.ApiManagement/service/apis/diagnostics@2020-06-01-preview' = {
  name: 'appInsightsCopilot'
  parent: apimApiCopilot
  properties: {
    alwaysLog: 'allErrors'
    loggerId: apiManagementLogger.id  
    logClientIp: true
    httpCorrelationProtocol: 'W3C'
    verbosity: 'verbose'
    operationNameFormat: 'Url'
  }
}

resource apiMonitoringChatgpt 'Microsoft.ApiManagement/service/apis/diagnostics@2020-06-01-preview' = {
  name: 'appInsightsChatgpt'
  parent: apimApiChatgpt
  properties: {
    alwaysLog: 'allErrors'
    loggerId: apiManagementLogger.id  
    logClientIp: true
    httpCorrelationProtocol: 'W3C'
    verbosity: 'verbose'
    operationNameFormat: 'Url'
  }
}
