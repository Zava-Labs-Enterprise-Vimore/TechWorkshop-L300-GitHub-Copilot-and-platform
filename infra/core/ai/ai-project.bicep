param name string
param location string = resourceGroup().location
param tags object = {}
param aiHubName string

resource aiHub 'Microsoft.MachineLearningServices/workspaces@2024-04-01' existing = {
  name: aiHubName
}

resource aiProject 'Microsoft.MachineLearningServices/workspaces@2024-04-01' = {
  name: name
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  kind: 'project'
  properties: {
    friendlyName: name
    description: 'Azure AI Project with access to GPT-4 and Phi models via Foundry'
    hubResourceId: aiHub.id
    publicNetworkAccess: 'Enabled'
  }
  sku: {
    name: 'Basic'
    tier: 'Basic'
  }
}

output id string = aiProject.id
output name string = aiProject.name
output principalId string = aiProject.identity.principalId
