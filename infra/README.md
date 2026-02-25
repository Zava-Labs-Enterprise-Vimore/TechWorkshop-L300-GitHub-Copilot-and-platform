# ZavaStorefront Azure Infrastructure

This repository contains the complete Azure infrastructure setup for the ZavaStorefront web application, designed for seamless deployment using Azure Developer CLI (AZD) and Bicep.

## 🏗️ Architecture Overview

The infrastructure provisions the following Azure resources in the **westus3** region:

### Core Resources
- **Azure App Service (Linux)**: Hosts the containerized ZavaStorefront web application
- **Azure Container Registry**: Stores and manages Docker container images
- **Application Insights**: Provides monitoring, diagnostics, and performance analytics
- **Log Analytics Workspace**: Centralized logging for observability

### AI/ML Resources
- **Azure AI Hub**: Foundation for Microsoft Foundry integration
- **Azure AI Project**: Provides access to GPT-4 and Phi models via Microsoft Foundry

### Security Features
- **Managed Identity**: App Service uses System-Assigned Managed Identity
- **RBAC Integration**: Passwordless authentication to Container Registry using AcrPull role
- **HTTPS Only**: All web traffic encrypted

## 📋 Prerequisites

Before deploying, ensure you have:

1. **Azure Subscription**: Active Azure subscription with sufficient permissions
2. **Azure Developer CLI (AZD)**: [Install AZD](https://learn.microsoft.com/azure/developer/azure-developer-cli/install-azd)
3. **Azure CLI**: [Install Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli)
4. **.NET 6.0 SDK**: For local development (optional)

**Note**: Docker is NOT required locally - AZD handles container builds in Azure!

## 🚀 Quick Start Deployment

### Step 1: Login to Azure

```powershell
# Login to Azure
azd auth login
az login
```

### Step 2: Initialize Environment

```powershell
# Initialize a new environment (first-time setup)
azd init

# When prompted:
# - Environment name: dev (or your preferred name)
# - Azure subscription: Select your subscription
# - Azure location: westus3
```

### Step 3: Provision Infrastructure

```powershell
# Provision all Azure resources
azd provision
```

This command will:
- Create a resource group in westus3
- Deploy all infrastructure components using Bicep
- Configure RBAC permissions
- Set up Application Insights monitoring

### Step 4: Deploy Application

```powershell
# Build container and deploy to App Service
azd deploy
```

This command will:
- Build the .NET application
- Create a Docker container (in Azure, no local Docker needed!)
- Push container to Azure Container Registry
- Deploy container to App Service

### Step 5: Access Application

```powershell
# Get the application URL
azd env get-value APP_SERVICE_URL
```

Visit the URL in your browser to see your deployed application!

## 🔧 Infrastructure Components

### Resource Naming Convention
Resources are named using the pattern: `{resourceType}-{environmentName}-{uniqueSuffix}`

Example for environment "dev":
- Resource Group: `rg-dev`
- App Service: `app-dev-abc123`
- Container Registry: `crabc123`
- Application Insights: `appi-dev`

### Bicep Module Structure

```
infra/
├── main.bicep                      # Main deployment (subscription scope)
├── resources.bicep                 # Resource orchestration
└── core/
    ├── host/
    │   ├── container-registry.bicep    # ACR configuration
    │   ├── app-service-plan.bicep      # App Service Plan
    │   └── app-service.bicep           # App Service with container
    ├── monitor/
    │   ├── log-analytics.bicep         # Log Analytics Workspace
    │   └── application-insights.bicep  # Application Insights
    ├── ai/
    │   ├── ai-hub.bicep                # Azure AI Hub
    │   └── ai-project.bicep            # Azure AI Project (Foundry)
    └── security/
        └── role-assignment.bicep       # RBAC role assignments
```

## 🔐 Security & RBAC

### Managed Identity Configuration
The App Service uses a **System-Assigned Managed Identity** with the following role:
- **AcrPull** on Container Registry: Allows pulling container images without passwords

### No Secrets Required
- No container registry passwords stored
- No connection strings in code
- Application Insights uses connection string from environment variable

## 📊 Monitoring & Observability

### Application Insights
Automatically configured to collect:
- Request/response telemetry
- Dependency tracking
- Performance metrics
- Exception logging
- Custom events

Access Application Insights:
1. Navigate to Azure Portal
2. Find Application Insights resource: `appi-{environmentName}`
3. View dashboards, logs, and metrics

### Log Analytics
Centralized logging workspace for:
- Application logs
- Container logs
- Platform diagnostics

## 🤖 Microsoft Foundry Integration

The infrastructure includes Azure AI Hub and Project for accessing:
- **GPT-4 models**: Advanced language models
- **Phi models**: Efficient small language models

### Accessing Foundry Models
```powershell
# Get AI Project name
azd env get-value AZURE_AI_PROJECT_NAME

# Navigate to Azure AI Studio to configure model deployments
# URL: https://ai.azure.com
```

## 🛠️ Development Workflow

### Making Infrastructure Changes

1. Edit Bicep files in `infra/` directory
2. Run `azd provision` to update infrastructure
3. Changes are applied incrementally (only modified resources)

### Updating Application Code

1. Make changes in `src/` directory
2. Run `azd deploy` to rebuild and redeploy
3. Container is built in Azure - no local Docker needed!

### Environment Variables

Environment variables for the application are configured in:
- `infra/core/host/app-service.bicep` - `appSettings` section

Current environment variables:
- `APPLICATIONINSIGHTS_CONNECTION_STRING`: Application Insights
- `ApplicationInsightsAgent_EXTENSION_VERSION`: AI agent version
- `DOCKER_REGISTRY_SERVER_URL`: Container registry URL
- `WEBSITES_PORT`: Container port (8080)
- `ASPNETCORE_ENVIRONMENT`: ASP.NET environment

## 📦 Docker-less Development

The infrastructure is designed to eliminate local Docker requirements:

1. **AZD Builds in Cloud**: `azd deploy` builds containers in Azure
2. **ACR Tasks**: Container Registry can build images remotely
3. **GitHub Actions**: CI/CD pipelines build in GitHub-hosted runners

### Optional: Local Docker Testing
If you want to test locally with Docker:

```powershell
cd src
docker build -t zavastorefrontlocal .
docker run -p 8080:8080 zavastorefrontlocal
```

## 🧹 Cleanup Resources

To delete all Azure resources:

```powershell
# Delete everything
azd down

# Delete and purge (removes soft-deleted resources)
azd down --purge --force
```

## 📝 Additional Commands

### View All Environment Variables
```powershell
azd env get-values
```

### View Deployment Logs
```powershell
azd deploy --debug
```

### Switch Environments
```powershell
# Create new environment
azd env new production

# Switch between environments
azd env select dev
azd env select production
```

## 🐛 Troubleshooting

### Common Issues

**Issue**: `azd provision` fails with permissions error
- **Solution**: Ensure you have Contributor role on the subscription

**Issue**: Container deployment fails
- **Solution**: Check App Service logs in Azure Portal

**Issue**: Application Insights not collecting data
- **Solution**: Verify `APPLICATIONINSIGHTS_CONNECTION_STRING` is set in App Service configuration

### View Application Logs
```powershell
# View streaming logs
az webapp log tail --name $(azd env get-value APP_SERVICE_NAME) --resource-group $(azd env get-value AZURE_RESOURCE_GROUP)
```

## 📚 References

- [Azure Developer CLI Documentation](https://learn.microsoft.com/azure/developer/azure-developer-cli/)
- [Bicep Documentation](https://learn.microsoft.com/azure/azure-resource-manager/bicep/)
- [Azure App Service](https://learn.microsoft.com/azure/app-service/)
- [Application Insights](https://learn.microsoft.com/azure/azure-monitor/app/app-insights-overview)
- [Azure AI Studio](https://learn.microsoft.com/azure/ai-studio/)

## 📄 License

See [LICENSE](../LICENSE) file for details.

## 🤝 Contributing

Contributions are welcome! Please read [CONTRIBUTING.md](../CONTRIBUTING.md) for details.

---

**Built with ❤️ using Azure Developer CLI and Bicep**
