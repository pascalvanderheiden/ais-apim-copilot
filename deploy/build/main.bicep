// set the target scope for this file
targetScope = 'subscription'

@minLength(3)
@maxLength(11)
param namePrefix string
param location string = deployment().location

var resourceGroupName = '${namePrefix}-rg'

// Create a Resource Group
resource newRG 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: location
}

// Create Application Insights & Log Analytics Workspace
module appInsightsModule '../build/appinsights_loganalytics.bicep' = {
  name: 'appInsightsDeploy'
  scope: newRG
  params: {
    namePrefix: namePrefix
    location: location
  }
}

// Create API Management instance
module apimModule '../build/apim.bicep' = {
  name: 'apimDeploy'
  scope: newRG
  params: {
    namePrefix: namePrefix
    publisherEmail: 'me@example.com'
    publisherName: 'Me Company Ltd.'
    sku: 'Developer'
    location: location
    appInsightsName: appInsightsModule.outputs.appInsightsName
    appInsightsInstrKey: appInsightsModule.outputs.appInsightsInstrKey
  }
  dependsOn:[
    appInsightsModule
  ]
}
