param environmentName string
param location string = resourceGroup().location
param tags object = {}

// Generate unique suffix for resources that need globally unique names
var resourceToken = toLower(uniqueString(subscription().id, environmentName, location))

// Container Registry
module containerRegistry 'core/host/container-registry.bicep' = {
  name: 'container-registry'
  params: {
    name: 'cr${resourceToken}'
    location: location
    tags: tags
  }
}

// Log Analytics Workspace for Application Insights
module logAnalytics 'core/monitor/log-analytics.bicep' = {
  name: 'log-analytics'
  params: {
    name: 'log-${environmentName}'
    location: location
    tags: tags
  }
}

// Application Insights
module applicationInsights 'core/monitor/application-insights.bicep' = {
  name: 'application-insights'
  params: {
    name: 'appi-${environmentName}'
    location: location
    tags: tags
    logAnalyticsWorkspaceId: logAnalytics.outputs.id
  }
}

// App Service Plan
module appServicePlan 'core/host/app-service-plan.bicep' = {
  name: 'app-service-plan'
  params: {
    name: 'asp-${environmentName}'
    location: location
    tags: tags
    sku: {
      name: 'B1'
      tier: 'Basic'
    }
    kind: 'linux'
    reserved: true
  }
}

// App Service
module appService 'core/host/app-service.bicep' = {
  name: 'app-service'
  params: {
    name: 'app-${environmentName}-${resourceToken}'
    location: location
    tags: union(tags, { 'azd-service-name': 'web' })
    appServicePlanId: appServicePlan.outputs.id
    applicationInsightsConnectionString: applicationInsights.outputs.connectionString
    containerRegistryName: containerRegistry.outputs.name
    enableContainerRegistry: true
  }
}

// Azure AI Hub (for Microsoft Foundry)
module aiHub 'core/ai/ai-hub.bicep' = {
  name: 'ai-hub'
  params: {
    name: 'aih-${environmentName}'
    location: location
    tags: tags
  }
}

// Azure AI Project (for Foundry models - GPT-4 and Phi)
module aiProject 'core/ai/ai-project.bicep' = {
  name: 'ai-project'
  params: {
    name: 'aip-${environmentName}'
    location: location
    tags: tags
    aiHubName: aiHub.outputs.name
  }
}

// Role assignments for App Service to pull from Container Registry
module containerRegistryRoleAssignment 'core/security/role-assignment.bicep' = {
  name: 'acr-role-assignment'
  params: {
    principalId: appService.outputs.identityPrincipalId
    roleDefinitionId: '7f951dda-4ed3-4680-a7ca-43fe172d538d' // AcrPull role
    principalType: 'ServicePrincipal'
  }
}

// Outputs
output containerRegistryEndpoint string = containerRegistry.outputs.loginServer
output containerRegistryName string = containerRegistry.outputs.name
output appServiceName string = appService.outputs.name
output appServiceUrl string = appService.outputs.uri
output applicationInsightsConnectionString string = applicationInsights.outputs.connectionString
output aiProjectName string = aiProject.outputs.name
output aiHubName string = aiHub.outputs.name
