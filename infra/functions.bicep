
@description('Required for Linux app to represent runtime stack in the format of \'runtime|runtimeVersion\'. For example: \'python|3.9\'')
param linuxFxVersion string = 'DOTNET-ISOLATED|8.0'

@description('The name of the Azure Function app.')
param functionAppName string = 'func-${uniqueString(resourceGroup().id)}'

@description('Storage Account type')
@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_RAGRS'
])
param storageAccountType string = 'Standard_LRS'

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Location for Application Insights')
param appInsightsLocation string = resourceGroup().location

@description('The language worker runtime to load in the function app.')
@allowed([
  'dotnet'
  'dotnet-isolated'
  'node'
  'python'
  'java'
])
param functionWorkerRuntime string = 'dotnet-isolated'

@description('The path to the web index document.')
param indexDocumentPath string = 'index.html'

@description('The contents of the web index document.')
param indexDocumentContents string = '<h1>Example static website</h1>'

@description('The path to the web error document.')
param errorDocument404Path string = 'error.html'

@description('The contents of the web error document.')
param errorDocument404Contents string = '<h1>Example 404 error page</h1>'

param hostingPlanCreate string = 'new'
param hostingPlanName string = functionAppName
param hostingPlanResourceGroupName string = resourceGroup().name

var applicationInsightsName = functionAppName
param storageAccountName string

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-05-01' = {
  name: storageAccountName
  location: location
  kind: 'StorageV2'
  sku: {
    name: storageAccountType
  }
}

resource hostingPlan 'Microsoft.Web/serverfarms@2022-03-01' = if (hostingPlanCreate == 'new'){
  name: hostingPlanName
  location: location
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
    size: 'Y1'
    family: 'Y'
  }
  properties: {
    reserved: true
  }
}

resource hostingPlanExisting 'Microsoft.Web/serverfarms@2022-03-01' existing = if (hostingPlanCreate == 'existing') {
  name: hostingPlanName
  scope: resourceGroup(hostingPlanResourceGroupName)
}

var hostingPlanId = ((hostingPlanCreate == 'new') ? hostingPlan.id : hostingPlanExisting.id)

resource applicationInsight 'Microsoft.Insights/components@2020-02-02' = {
  name: applicationInsightsName
  location: appInsightsLocation
  tags: {
    'hidden-link:${resourceId('Microsoft.Web/sites', functionAppName)}': 'Resource'
  }
  properties: {
    Application_Type: 'web'
  }
  kind: 'web'
}

resource functionApp 'Microsoft.Web/sites@2022-03-01' = {
  name: functionAppName
  location: location
  kind: 'functionapp,linux'
  properties: {
    reserved: true
    serverFarmId: hostingPlanId
    siteConfig: {
      linuxFxVersion: linuxFxVersion
      appSettings: [
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: reference(resourceId('Microsoft.Insights/components', functionAppName), '2020-02-02').InstrumentationKey
        }
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'CoreStorageConnection'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: toLower(functionAppName)
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: functionWorkerRuntime
        }
        {
          name: 'WEBSITE_USE_PLACEHOLDER_DOTNETISOLATED'
          value: '1'
        }
      ]
    }
  }
  dependsOn: [
    applicationInsight
  ]
}

// This template deploys an Azure Storage account, and then configures it to support static website hosting.
// Enabling static website hosting isn't possible directly in Bicep or an ARM template,
// so this sample uses a deployment script to enable the feature.

resource contributorRoleDefinition 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  scope: subscription()
  // This is the Storage Account Contributor role, which is the minimum role permission we can give. See https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#:~:text=17d1049b-9a84-46fb-8f53-869881c3d3ab
  name: '17d1049b-9a84-46fb-8f53-869881c3d3ab'
}

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: 'DeploymentScript'
  location: location
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  scope: storageAccount
  name: guid(resourceGroup().id, managedIdentity.id, contributorRoleDefinition.id)
  properties: {
    roleDefinitionId: contributorRoleDefinition.id
    principalId: managedIdentity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

resource deploymentScript 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'deploymentScript'
  location: location
  kind: 'AzurePowerShell'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentity.id}': {}
    }
  }
  dependsOn: [
    // we need to ensure we wait for the role assignment to be deployed before trying to access the storage account
    roleAssignment
  ]
  properties: {
    azPowerShellVersion: '3.0'
    scriptContent: loadTextContent('./scripts/enable-static-website.ps1')
    retentionInterval: 'PT4H'
    environmentVariables: [
      {
        name: 'ResourceGroupName'
        value: resourceGroup().name
      }
      {
        name: 'StorageAccountName'
        value: storageAccount.name
      }
      {
        name: 'IndexDocumentPath'
        value: indexDocumentPath
      }
      {
        name: 'IndexDocumentContents'
        value: indexDocumentContents
      }
      {
        name: 'ErrorDocument404Path'
        value: errorDocument404Path
      }
      {
        name: 'ErrorDocument404Contents'
        value: errorDocument404Contents
      }
    ]
  }
}

output staticWebsiteUrl string = storageAccount.properties.primaryEndpoints.web
output azureFunctionsName string = functionApp.name
output azureFunctionsEndpoint string = functionApp.properties.defaultHostName
