targetScope='subscription'

@description('Resource group where the resources will be deployed.')
param resourceGroupName string = 'rg-apblog'

@description('The location into which the resources should be deployed.')
param resourceGroupLocation string = 'westus'

@description('Hash to make the deployment name unique.')
param hash string = utcNow('yyyyMMddHHmmss')

param hostingPlanCreate string = 'new'
param hostingPlanName string = 'web${resourceGroupName}'
param hostingPlanResourceGroupName string = resourceGroupName

resource resourceGroup 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: resourceGroupName
  location: resourceGroupLocation
}

@description('Name of the deployment.')
param deploymentName string = 'ap-${resourceGroupName}'

module functionsDeployment 'functions.bicep' = {
  name: '${deploymentName}-${hash}'
  #disable-next-line explicit-values-for-loc-params
  params: {
    location: resourceGroupLocation
    hostingPlanCreate: hostingPlanCreate
    hostingPlanName: hostingPlanName
    hostingPlanResourceGroupName: hostingPlanResourceGroupName
  }
  scope: resourceGroup
}
