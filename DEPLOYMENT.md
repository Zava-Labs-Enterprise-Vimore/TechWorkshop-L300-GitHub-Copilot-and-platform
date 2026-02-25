# ZavaStorefront Deployment Guide

This guide provides step-by-step instructions for deploying the ZavaStorefront application to Azure.

## Prerequisites Checklist

- [ ] Azure subscription with Contributor permissions
- [ ] Azure Developer CLI (AZD) installed
- [ ] Azure CLI installed  
- [ ] Authenticated to Azure (`azd auth login` and `az login`)

## Deployment Steps

### 1. First-Time Setup

```powershell
# Clone the repository (if not already done)
cd c:\Victor\TechWorkshop-L300-GitHub-Copilot-and-platform

# Initialize AZD environment
azd init

# Enter environment name when prompted (e.g., "dev")
# Select Azure subscription
# Confirm location: westus3
```

### 2. Provision Azure Infrastructure

```powershell
# Deploy all infrastructure resources
azd provision
```

**Expected Duration**: 5-10 minutes

**Resources Created**:
- Resource Group (rg-dev)
- Container Registry (cr{unique})
- App Service Plan (asp-dev)
- App Service (app-dev-{unique})
- Log Analytics Workspace (log-dev)
- Application Insights (appi-dev)
- AI Hub (aih-dev)
- AI Project (aip-dev)

### 3. Deploy Application

```powershell
# Build and deploy the application
azd deploy
```

**Expected Duration**: 3-5 minutes

**What Happens**:
1. Application code is packaged
2. Docker container is built in Azure (no local Docker needed!)
3. Container image pushed to Container Registry
4. App Service updated with new container
5. Application starts automatically

### 4. Verify Deployment

```powershell
# Get the application URL
$appUrl = azd env get-value APP_SERVICE_URL
Write-Host "Application URL: $appUrl"

# Open in browser
Start-Process $appUrl
```

### 5. View Application Insights

```powershell
# Get Application Insights details
$appInsightsName = "appi-dev"
$resourceGroup = azd env get-value AZURE_RESOURCE_GROUP

# Open in Azure Portal
az monitor app-insights component show --app $appInsightsName --resource-group $resourceGroup --query "appId" -o tsv
```

Navigate to https://portal.azure.com and search for your Application Insights resource.

## Post-Deployment Configuration

### Configure Microsoft Foundry Models

1. Navigate to [Azure AI Studio](https://ai.azure.com)
2. Sign in with your Azure credentials
3. Find your AI Project: `aip-dev`
4. Deploy models:
   - **GPT-4**: For advanced language tasks
   - **Phi**: For efficient inference

### Set Up Custom Application Settings

```powershell
# Add custom app settings
$appName = azd env get-value APP_SERVICE_NAME
$rgName = azd env get-value AZURE_RESOURCE_GROUP

az webapp config appsettings set --name $appName --resource-group $rgName --settings KEY=VALUE
```

## Updating the Application

### Code Changes

```powershell
# Make changes to src/ directory
# Then deploy updates
azd deploy
```

### Infrastructure Changes

```powershell
# Edit Bicep files in infra/ directory
# Then provision updates
azd provision
```

## Monitoring & Debugging

### Stream Application Logs

```powershell
$appName = azd env get-value APP_SERVICE_NAME
$rgName = azd env get-value AZURE_RESOURCE_GROUP

az webapp log tail --name $appName --resource-group $rgName
```

### View Container Logs

```powershell
az webapp log show --name $appName --resource-group $rgName
```

### Check App Service Status

```powershell
az webapp show --name $appName --resource-group $rgName --query "state" -o tsv
```

## Environment Management

### Create Additional Environments

```powershell
# Create production environment
azd env new production

# Switch to production
azd env select production

# Provision and deploy
azd provision
azd deploy
```

### List All Environments

```powershell
azd env list
```

### View Environment Variables

```powershell
azd env get-values
```

## Troubleshooting

### Issue: Deployment Fails

**Check logs**:
```powershell
azd deploy --debug
```

**Verify resource status**:
```powershell
az group show --name $(azd env get-value AZURE_RESOURCE_GROUP)
```

### Issue: Application Not Starting

**Check App Service logs**:
```powershell
az webapp log tail --name $(azd env get-value APP_SERVICE_NAME) --resource-group $(azd env get-value AZURE_RESOURCE_GROUP)
```

**Restart App Service**:
```powershell
az webapp restart --name $(azd env get-value APP_SERVICE_NAME) --resource-group $(azd env get-value AZURE_RESOURCE_GROUP)
```

### Issue: Container Registry Authentication Failed

**Verify role assignment**:
```powershell
$appName = azd env get-value APP_SERVICE_NAME
$rgName = azd env get-value AZURE_RESOURCE_GROUP

# Get App Service identity
$principalId = az webapp identity show --name $appName --resource-group $rgName --query "principalId" -o tsv

# Check role assignments
az role assignment list --assignee $principalId --all
```

## Cleanup

### Delete All Resources

```powershell
# Delete all resources
azd down

# Confirm deletion when prompted
```

### Delete Specific Environment

```powershell
# Switch to environment
azd env select dev

# Delete
azd down
```

## Best Practices

1. **Use Separate Environments**: Create dev, staging, and production environments
2. **Monitor Costs**: Use Azure Cost Management to track spending
3. **Enable Alerts**: Configure Application Insights alerts for errors
4. **Regular Updates**: Keep dependencies and base images updated
5. **Backup Configuration**: Store `azd` environment variables securely

## Next Steps

- [ ] Configure custom domain and SSL certificate
- [ ] Set up GitHub Actions for CI/CD
- [ ] Enable Azure AD authentication
- [ ] Configure scaling rules
- [ ] Set up backup and disaster recovery

## Support

For issues or questions:
- Check [Azure Developer CLI Documentation](https://learn.microsoft.com/azure/developer/azure-developer-cli/)
- Review [Application Insights Troubleshooting](https://learn.microsoft.com/azure/azure-monitor/app/troubleshoot)
- Open an issue in this repository

---

**Deployment Guide Version**: 1.0  
**Last Updated**: February 2026
