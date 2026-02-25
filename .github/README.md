# GitHub Actions Configuration

## Required Secrets

Configure these secrets in your GitHub repository settings (`Settings` > `Secrets and variables` > `Actions` > `Secrets`):

### AZURE_CREDENTIALS
Azure service principal credentials in JSON format:

```json
{
  "clientId": "<your-service-principal-client-id>",
  "clientSecret": "<your-service-principal-client-secret>",
  "subscriptionId": "<your-azure-subscription-id>",
  "tenantId": "<your-azure-tenant-id>"
}
```

**To create a service principal:**

```bash
az ad sp create-for-rbac \
  --name "github-actions-zava-storefront" \
  --role contributor \
  --scopes /subscriptions/<subscription-id>/resourceGroups/<resource-group-name> \
  --sdk-auth
```

## Required Variables

Configure these variables in your GitHub repository settings (`Settings` > `Secrets and variables` > `Actions` > `Variables`):

| Variable Name | Description | Example |
|---------------|-------------|---------|
| `AZURE_CONTAINER_REGISTRY_NAME` | Name of your Azure Container Registry | `crzavastorefront` |
| `AZURE_APP_SERVICE_NAME` | Name of your Azure App Service | `app-zava-storefront` |
| `AZURE_RESOURCE_GROUP` | Name of your Azure Resource Group | `rg-zava-storefront` |

**To get these values after deploying infrastructure:**

```bash
# Get Container Registry name
az acr list --resource-group <your-rg-name> --query "[0].name" -o tsv

# Get App Service name
az webapp list --resource-group <your-rg-name> --query "[0].name" -o tsv

# Get Resource Group name (you already know this from your deployment)
echo "<your-rg-name>"
```

## Workflow Trigger

The workflow runs automatically on:
- Push to `main` branch
- Manual trigger via GitHub Actions UI

## What the Workflow Does

1. Checks out the code
2. Authenticates to Azure using the service principal
3. Logs in to Azure Container Registry
4. Builds the Docker image from `./src` using the Dockerfile
5. Pushes the image with both commit SHA tag and `latest` tag
6. Updates App Service to use the new container image
7. Restarts the App Service to apply changes
