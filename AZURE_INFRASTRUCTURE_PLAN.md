# Azure Infrastructure Plan for ZavaStorefront

## Summary

This document outlines the complete Azure infrastructure plan for GitHub Issue #1: **Provision Azure infrastructure for ZavaStorefront (dev environment, Bicep/AZD, Foundry/Phi, Docker-less)**.

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                     Azure Subscription                       │
│                                                               │
│  ┌───────────────────────────────────────────────────────┐  │
│  │         Resource Group: rg-dev (westus3)              │  │
│  │                                                         │  │
│  │  ┌──────────────────┐      ┌───────────────────────┐ │  │
│  │  │  App Service     │◄─────┤ Application Insights  │ │  │
│  │  │  (Linux)         │      │  + Log Analytics      │ │  │
│  │  │                  │      └───────────────────────┘ │  │
│  │  │  - .NET 6.0      │                                 │  │
│  │  │  - Container     │                                 │  │
│  │  │  - HTTPS         │                                 │  │
│  │  │  - Port 8080     │                                 │  │
│  │  └────────┬─────────┘                                 │  │
│  │           │                                            │  │
│  │           │ Managed Identity (RBAC)                   │  │
│  │           │ AcrPull Role                              │  │
│  │           ▼                                            │  │
│  │  ┌──────────────────┐                                 │  │
│  │  │  Container       │                                 │  │
│  │  │  Registry (ACR)  │                                 │  │
│  │  │                  │                                 │  │
│  │  │  - Basic SKU     │                                 │  │
│  │  │  - RBAC Enabled  │                                 │  │
│  │  └──────────────────┘                                 │  │
│  │                                                         │  │
│  │  ┌──────────────────┐      ┌───────────────────────┐ │  │
│  │  │   Azure AI Hub   │◄─────┤   Azure AI Project    │ │  │
│  │  │                  │      │   (Foundry)           │ │  │
│  │  │  - Foundry       │      │   - GPT-4             │ │  │
│  │  │  - Model Access  │      │   - Phi               │ │  │
│  │  └──────────────────┘      └───────────────────────┘ │  │
│  └───────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

## Resources Provisioned

### 1. Compute & Hosting

| Resource | SKU/Size | Purpose |
|----------|----------|---------|
| App Service Plan | B1 (Basic, Linux) | Hosts the containerized application |
| App Service | Linux Container | Runs the ZavaStorefront web app |

**Configuration**:
- Runtime: .NET 6.0 in Docker container
- Port: 8080 (configured automatically)
- HTTPS: Enforced
- Managed Identity: System-assigned
- Container deployment: Via Azure Container Registry

### 2. Container Management

| Resource | SKU | Purpose |
|----------|-----|---------|
| Azure Container Registry | Basic | Stores Docker images |

**Configuration**:
- Admin user: Disabled (RBAC only)
- Public network: Enabled
- Authentication: Managed Identity (AcrPull role)

### 3. Monitoring & Observability

| Resource | Tier | Purpose |
|----------|------|---------|
| Log Analytics Workspace | PerGB2018 | Centralized logging |
| Application Insights | Standard | APM and telemetry |

**Configuration**:
- Retention: 30 days
- Connected to App Service
- Auto-instrumentation enabled (.NET SDK)

### 4. AI/ML Services

| Resource | SKU | Purpose |
|----------|-----|---------|
| Azure AI Hub | Basic | Foundry foundation |
| Azure AI Project | Basic | Model access (GPT-4, Phi) |

**Configuration**:
- Region: westus3 (Foundry availability)
- Models: GPT-4, Phi (requires manual deployment)
- Integration: Available to all resources in RG

### 5. Security & Identity

| Component | Configuration |
|-----------|---------------|
| Managed Identity | System-assigned on App Service |
| RBAC Role | AcrPull on Container Registry |
| Network | Public access (can be locked down later) |
| Secrets | None stored in code |

## Deployment Workflow

### Infrastructure as Code (IaC)

**Tool**: Azure Developer CLI (AZD) with Bicep

**File Structure**:
```
├── azure.yaml                 # AZD configuration
├── Dockerfile                 # Container definition
├── .dockerignore             # Docker build exclusions
├── DEPLOYMENT.md             # Deployment guide
├── .gitignore                # Git exclusions
└── infra/
    ├── README.md             # Infrastructure docs
    ├── main.bicep            # Subscription-level deployment
    ├── resources.bicep       # Resource orchestration
    └── core/
        ├── host/             # App Service, ACR, ASP
        ├── monitor/          # Application Insights, Log Analytics
        ├── ai/               # AI Hub, AI Project
        └── security/         # RBAC assignments
```

### Deployment Commands

```powershell
# One-time setup
azd init

# Provision infrastructure
azd provision

# Deploy application
azd deploy

# Full deployment (provision + deploy)
azd up
```

## Key Features Delivered

### ✅ Docker-less Development
- **No local Docker required**: AZD builds containers in Azure
- **Remote build**: Container Registry handles image creation
- **CI/CD ready**: GitHub Actions can build without Docker locally

### ✅ RBAC-based Security
- **Passwordless**: No credentials in config files
- **Managed Identity**: App Service authenticates automatically
- **Principle of least privilege**: Only AcrPull role granted

### ✅ Complete Observability
- **Application Insights**: Request tracking, dependencies, exceptions
- **Log Analytics**: Centralized log aggregation
- **Live Metrics**: Real-time performance monitoring

### ✅ Microsoft Foundry Integration
- **AI Hub**: Foundation for AI services
- **AI Project**: Access to GPT-4 and Phi models
- **Region compatibility**: All resources in westus3

### ✅ Developer Experience
- **Single command provisioning**: `azd provision`
- **Single command deployment**: `azd deploy`
- **Environment management**: dev, staging, prod
- **Infrastructure updates**: Incremental Bicep changes

## Acceptance Criteria Status

| Criterion | Status | Notes |
|-----------|--------|-------|
| All resources in westus3 | ✅ | Configured in main.bicep |
| App Service uses RBAC for ACR | ✅ | Managed Identity + AcrPull role |
| Application Insights wired up | ✅ | Connected to App Service + SDK added |
| No local Docker requirement | ✅ | AZD remote build configured |
| Deployment tested | ⏳ | Ready for testing with `azd up` |

## Next Steps

### Immediate Actions

1. **Test Deployment**
   ```powershell
   azd init
   azd up
   ```

2. **Verify Resources**
   - Check Azure Portal for all resources
   - Confirm App Service is running
   - Test application URL

3. **Configure Foundry Models**
   - Navigate to Azure AI Studio
   - Deploy GPT-4 and Phi models
   - Test model access

### Future Enhancements

- [ ] Add custom domain and SSL certificate
- [ ] Implement Azure AD authentication
- [ ] Set up GitHub Actions CI/CD pipeline
- [ ] Configure autoscaling rules
- [ ] Add Azure Front Door for CDN
- [ ] Implement staging slots
- [ ] Add Key Vault for secrets management
- [ ] Configure network isolation (VNet)
- [ ] Set up backup and disaster recovery
- [ ] Implement cost optimization (Reserved Instances)

## Cost Estimates

**Monthly Cost (Dev Environment)**:
- App Service Plan (B1): ~$13/month
- Container Registry (Basic): ~$5/month
- Application Insights: ~$5-20/month (usage-based)
- Log Analytics: ~$5/month (usage-based)
- AI Hub + Project: ~$0 (Basic tier, model usage charged separately)

**Total Estimated**: ~$30-45/month (excluding AI model inference costs)

**Cost Optimization Tips**:
- Use Azure Dev/Test pricing if eligible
- Stop App Service when not in use (dev environment)
- Monitor Application Insights sampling
- Set up budget alerts

## Documentation References

- [Infrastructure README](infra/README.md) - Detailed infrastructure docs
- [DEPLOYMENT.md](DEPLOYMENT.md) - Step-by-step deployment guide
- [Azure Developer CLI](https://learn.microsoft.com/azure/developer/azure-developer-cli/)
- [Bicep Documentation](https://learn.microsoft.com/azure/azure-resource-manager/bicep/)

## Support & Troubleshooting

**Common Issues**:
1. **Permission errors**: Ensure Contributor role on subscription
2. **Region availability**: Foundry requires westus3
3. **Container build fails**: Check Dockerfile and .dockerignore
4. **App won't start**: Review App Service logs

**Get Help**:
- Review logs: `azd deploy --debug`
- Check App Service: `az webapp log tail`
- View resource status: Azure Portal

---

**Plan Created**: February 25, 2026  
**GitHub Issue**: #1  
**Status**: Ready for Deployment ✅
