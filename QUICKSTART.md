# ZavaStorefront - Quick Reference Guide

## 🚀 Quick Start (First Time)

```powershell
# 1. Login to Azure
azd auth login
az login

# 2. Initialize environment
azd init
# Enter: dev (or your environment name)
# Select: Your Azure subscription
# Location: westus3

# 3. Deploy everything
azd up
# This runs: provision + deploy in one command
```

## 📝 Common Commands

### Deployment

```powershell
# Provision infrastructure only
azd provision

# Deploy application only  
azd deploy

# Provision + Deploy (full deployment)
azd up

# Deploy with debug output
azd deploy --debug
```

### Environment Management

```powershell
# List environments
azd env list

# Create new environment
azd env new production

# Switch environment
azd env select dev

# View all environment variables
azd env get-values

# Get specific value
azd env get-value APP_SERVICE_NAME
azd env get-value APP_SERVICE_URL
azd env get-value AZURE_CONTAINER_REGISTRY_NAME
```

### Application Management

```powershell
# Get application URL
$appUrl = azd env get-value APP_SERVICE_URL
Start-Process $appUrl

# View streaming logs
az webapp log tail --name $(azd env get-value APP_SERVICE_NAME) --resource-group $(azd env get-value AZURE_RESOURCE_GROUP)

# Restart application
az webapp restart --name $(azd env get-value APP_SERVICE_NAME) --resource-group $(azd env get-value AZURE_RESOURCE_GROUP)

# View app settings
az webapp config appsettings list --name $(azd env get-value APP_SERVICE_NAME) --resource-group $(azd env get-value AZURE_RESOURCE_GROUP)
```

### Monitoring

```powershell
# Open Application Insights in portal
$rgName = azd env get-value AZURE_RESOURCE_GROUP
az monitor app-insights component show --resource-group $rgName --query "[].{Name:name, AppId:appId}" -o table

# View recent log entries
az monitor log-analytics query --workspace $(azd env get-value AZURE_LOG_ANALYTICS_WORKSPACE_ID) --analytics-query "requests | take 10"
```

### Cleanup

```powershell
# Delete all resources
azd down

# Delete with confirmation skip
azd down --force

# Delete and purge (removes soft-deleted resources)
azd down --purge --force
```

## 🗂️ File Structure

```
├── azure.yaml                    # AZD configuration
├── Dockerfile                    # Container definition
├── DEPLOYMENT.md                 # Full deployment guide
├── AZURE_INFRASTRUCTURE_PLAN.md  # Infrastructure plan
├── src/                          # Application source code
│   ├── Program.cs
│   ├── ZavaStorefront.csproj
│   ├── Controllers/
│   ├── Models/
│   ├── Services/
│   └── Views/
└── infra/                        # Infrastructure as Code
    ├── README.md
    ├── main.bicep               # Main entry point
    ├── resources.bicep          # Resource orchestration
    └── core/
        ├── host/                # App Service, ACR, ASP
        ├── monitor/             # Application Insights, Logs
        ├── ai/                  # AI Hub, AI Project
        └── security/            # RBAC
```

## 🔑 Key Outputs

After `azd provision`, these values are available:

```powershell
AZURE_LOCATION                           # westus3
AZURE_TENANT_ID                          # Your tenant ID
AZURE_RESOURCE_GROUP                     # rg-{env}
AZURE_CONTAINER_REGISTRY_ENDPOINT        # {registry}.azurecr.io
AZURE_CONTAINER_REGISTRY_NAME            # cr{unique}
APP_SERVICE_NAME                         # app-{env}-{unique}
APP_SERVICE_URL                          # https://app-{env}-{unique}.azurewebsites.net
APPLICATIONINSIGHTS_CONNECTION_STRING    # InstrumentationKey=...
AZURE_AI_PROJECT_NAME                    # aip-{env}
```

## 🏗️ Resources Created

| Resource Type | Name Pattern | SKU/Tier |
|---------------|-------------|----------|
| Resource Group | rg-{env} | N/A |
| Container Registry | cr{unique} | Basic |
| App Service Plan | asp-{env} | B1 (Linux) |
| App Service | app-{env}-{unique} | N/A |
| Log Analytics | log-{env} | PerGB2018 |
| Application Insights | appi-{env} | Standard |
| AI Hub | aih-{env} | Basic |
| AI Project | aip-{env} | Basic |

## 🔐 Security Notes

- **Managed Identity**: App Service uses system-assigned identity
- **RBAC**: AcrPull role assigned automatically
- **No Secrets**: No passwords or connection strings in code
- **HTTPS Only**: Enforced on App Service

## 🐛 Troubleshooting Quick Fixes

### Issue: Can't authenticate
```powershell
azd auth login --use-device-code
az login --use-device-code
```

### Issue: Deployment slow
```powershell
# Check deployment status
az deployment group show --resource-group $(azd env get-value AZURE_RESOURCE_GROUP) --name resources
```

### Issue: App not starting
```powershell
# View container logs
az webapp log show --name $(azd env get-value APP_SERVICE_NAME) --resource-group $(azd env get-value AZURE_RESOURCE_GROUP)

# Check app service health
az webapp show --name $(azd env get-value APP_SERVICE_NAME) --resource-group $(azd env get-value AZURE_RESOURCE_GROUP) --query "state"
```

### Issue: Need to update single app setting
```powershell
az webapp config appsettings set \
  --name $(azd env get-value APP_SERVICE_NAME) \
  --resource-group $(azd env get-value AZURE_RESOURCE_GROUP) \
  --settings SETTING_NAME=VALUE
```

## 📊 Cost Management

```powershell
# View current month costs
az consumption usage list --start-date 2026-02-01 --end-date 2026-02-28

# Set budget alert (requires budget name)
az consumption budget create \
  --budget-name dev-budget \
  --amount 100 \
  --category cost \
  --time-grain monthly \
  --resource-group $(azd env get-value AZURE_RESOURCE_GROUP)
```

## 🔗 Useful URLs

- **Azure Portal**: https://portal.azure.com
- **Azure AI Studio**: https://ai.azure.com
- **Azure DevOps**: https://dev.azure.com
- **AZD Documentation**: https://learn.microsoft.com/azure/developer/azure-developer-cli/

## 💡 Pro Tips

1. **Use aliases for common commands**:
   ```powershell
   Set-Alias azprov 'azd provision'
   Set-Alias azdep 'azd deploy'
   ```

2. **Quick app URL access**:
   ```powershell
   Start-Process $(azd env get-value APP_SERVICE_URL)
   ```

3. **Watch logs in real-time**:
   ```powershell
   az webapp log tail -n $(azd env get-value APP_SERVICE_NAME) -g $(azd env get-value AZURE_RESOURCE_GROUP) --follow
   ```

4. **Export environment variables for scripts**:
   ```powershell
   azd env get-values > .env
   ```

---

**Quick Ref Version**: 1.0  
**Last Updated**: February 2026
