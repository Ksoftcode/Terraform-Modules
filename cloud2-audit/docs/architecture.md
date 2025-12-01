# Terraform Modules Architecture Overview

**Document Version:** 1.0  
**Last Updated:** 2025-11-25

---

## 1. Repository Structure

The repository is structured as an umbrella repository containing references to 140 Terraform modules for Azure infrastructure provisioning. Each module is stored as a git submodule reference.

```
Terraform-Modules/
├── .gitmodules (MISSING - needs to be created)
├── terraform-azurerm-<service>/       # Individual modules (submodule refs)
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── versions.tf
│   ├── README.md
│   ├── examples/
│   └── tests/
└── cloud2-audit/                      # This audit output
    ├── docs/
    ├── module-template/
    └── patches/
```

**Current State:** All module directories are empty submodule stubs pending initialization.

---

## 2. Module Categories

The modules are organized into the following functional categories:

### 2.1 Compute (15 modules)

| Module | Purpose |
|--------|---------|
| terraform-azurerm-linux-virtualmachine | Linux VM provisioning |
| terraform-azurerm-windows-virtualmachine | Windows VM provisioning |
| terraform-azurerm-aks-cluster | AKS cluster |
| terraform-azurerm-aks-cluster-cilium | AKS with Cilium CNI |
| terraform-azurerm-container-instances | Container Instances |
| terraform-azurerm-container-app | Container Apps |
| terraform-azurerm-functionapp-linux | Linux Function App |
| terraform-azurerm-functionapp-windows | Windows Function App |
| terraform-azurerm-appservices-linux | Linux App Service |
| terraform-azurerm-appservices-windows | Windows App Service |

### 2.2 Networking (12 modules)

| Module | Purpose |
|--------|---------|
| terraform-azurerm-virtual-network | VNet provisioning |
| terraform-azure-network-resources | Network resources |
| terraform-azurerm-privateendpoint | Private Endpoints |
| terraform-azurerm-bastion-host | Azure Bastion |
| terraform-azurerm-loadbalancer-aoa | Load Balancer |
| terraform-azurerm-network-interface | Network Interfaces |
| terraform-azurerm-f5-ha | F5 High Availability |
| terraform-azurerm-nginx-plus-vm | NGINX Plus VM |

### 2.3 Storage (5 modules)

| Module | Purpose |
|--------|---------|
| terraform-azurerm-storageaccount | Storage Account |
| terraform-azurerm-anfvolume | Azure NetApp Files |
| terraform-azurerm-anfvolumesnapshot | ANF Snapshots |
| terraform-azurerm-storage_data_lake_gen2_filesystem | ADLS Gen2 |

### 2.4 Database (15 modules)

| Module | Purpose |
|--------|---------|
| terraform-azurerm-mysqlflexibleserver | MySQL Flexible Server |
| terraform-azurerm-postgresqlflexibleserver | PostgreSQL Flexible Server |
| terraform-azurerm-sqlmi | SQL Managed Instance |
| terraform-azurerm-rediscache | Redis Cache |
| terraform-azurerm-mongo-cluster-vcore | MongoDB vCore |

### 2.5 Security & Identity (8 modules)

| Module | Purpose |
|--------|---------|
| terraform-azurerm-azure-key-vault | Key Vault |
| terraform-azurerm-keyvaultaccesspolicy | Key Vault Access Policy |
| terraform-azurerm-userassigned-managed-identity | User-Assigned MI |
| terraform-azurerm-addmembertoadgroup | Azure AD Group Member |

### 2.6 AI & ML (8 modules)

| Module | Purpose |
|--------|---------|
| terraform-azurerm-openai | Azure OpenAI |
| terraform-azurerm-openaideployment | OpenAI Deployment |
| terraform-azurerm-cognitivesearch | Cognitive Search |
| terraform-azurerm-documentintelligence | Document Intelligence |
| terraform-azurerm-translatorservice | Translator |
| terraform-azurerm-speechservices | Speech Services |

### 2.7 Integration & Analytics (12 modules)

| Module | Purpose |
|--------|---------|
| terraform-azurerm-datafactory | Data Factory |
| terraform-azurerm-event-hub-namespace | Event Hub Namespace |
| terraform-azurerm-event-hub-instance | Event Hub Instance |
| terraform-azurerm-synapse-workspace | Synapse Workspace |
| terraform-azurerm-synapse-sql-pool | Synapse SQL Pool |
| terraform-azurerm-api-management | API Management |
| terraform-azurerm-logicapp-standard | Logic App |

### 2.8 Kubernetes (12 modules)

| Module | Purpose |
|--------|---------|
| terraform-azurerm-aks-cluster | AKS Cluster |
| terraform-azurerm-aks-namespace | K8s Namespace |
| terraform-azurerm-aks-pv-creation | Persistent Volume |
| terraform-azurerm-aks-pvc-creation | Persistent Volume Claim |
| terraform-azurerm-aks-role-binding | Role Binding |
| terraform-azurerm-nodepool-creation | Node Pool |

---

## 3. Module Relationships

```
                    ┌─────────────────────┐
                    │   Resource Group    │
                    │     (Foundation)    │
                    └─────────┬───────────┘
                              │
        ┌─────────────────────┼─────────────────────┐
        │                     │                     │
        ▼                     ▼                     ▼
┌───────────────┐    ┌───────────────┐    ┌───────────────┐
│   Networking  │    │   Security    │    │   Storage     │
│   (VNet, NSG) │    │  (Key Vault)  │    │   (SA, ANF)   │
└───────┬───────┘    └───────┬───────┘    └───────┬───────┘
        │                    │                     │
        └────────────────────┼─────────────────────┘
                             │
        ┌────────────────────┼────────────────────┐
        │                    │                    │
        ▼                    ▼                    ▼
┌───────────────┐    ┌───────────────┐    ┌───────────────┐
│    Compute    │    │   Database    │    │  Integration  │
│   (VM, AKS)   │    │  (SQL, PG)    │    │   (ADF, EH)   │
└───────────────┘    └───────────────┘    └───────────────┘
```

### Typical Deployment Order

1. **Resource Group** - Foundation
2. **Networking** - VNet, Subnets, NSGs
3. **Security** - Key Vault, Managed Identity
4. **Storage** - Storage Accounts
5. **Compute/Database** - VMs, AKS, Databases
6. **Integration** - Data Factory, Event Hub
7. **Private Endpoints** - Secure connectivity

---

## 4. Provider Requirements

All modules use the Azure provider ecosystem:

```hcl
terraform {
  required_version = ">= 1.4"
  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
  }
}
```

### Provider Usage by Module Category

| Category | Primary Provider | Secondary Providers |
|----------|------------------|---------------------|
| Compute | azurerm | - |
| Networking | azurerm | - |
| Storage | azurerm | - |
| Database | azurerm | - |
| Security | azurerm | azuread |
| Kubernetes | azurerm | kubernetes, helm |
| AI/ML | azurerm | - |
| Integration | azurerm | - |

---

## 5. Tagging Strategy

### Required Tags

All resources must include these tags:

| Tag Key | Description | Example |
|---------|-------------|---------|
| `project` | Project identifier | `cloud20` |
| `environment` | Environment name | `dev`, `prod` |
| `owner` | Responsible team/person | `platform-team` |
| `cost_center` | Cost allocation code | `IT-12345` |
| `terraform_managed` | Managed by Terraform | `true` |
| `module_name` | Source module name | `terraform-azurerm-aks-cluster` |

### Tag Implementation Pattern

```hcl
# In variables.tf
variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "project" {
  description = "Project name for tagging"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "owner" {
  description = "Owner email or team name"
  type        = string
}

# In locals.tf
locals {
  default_tags = {
    project           = var.project
    environment       = var.environment
    owner             = var.owner
    terraform_managed = "true"
    module_name       = "terraform-azurerm-<module>"
    module_version    = "1.0.0"
  }
  
  merged_tags = merge(local.default_tags, var.tags)
}

# In main.tf
resource "azurerm_resource_group" "example" {
  name     = var.name
  location = var.location
  tags     = local.merged_tags
}
```

---

## 6. Naming Conventions

### Module Naming

Format: `terraform-azurerm-<service>[-<variant>]`

Examples:
- `terraform-azurerm-virtual-network`
- `terraform-azurerm-aks-cluster`
- `terraform-azurerm-aks-cluster-cilium`
- `terraform-azurerm-storageaccount`

### Resource Naming

Pattern: `<project>-<environment>-<location>-<service>-<instance>`

Example: `myapp-prod-eastus-vm-001`

```hcl
locals {
  name_prefix = "${var.project}-${var.environment}-${var.location}"
  
  resource_names = {
    vm           = "${local.name_prefix}-vm-001"
    storage      = lower(replace("${local.name_prefix}sa001", "-", ""))
    key_vault    = "${local.name_prefix}-kv-001"
    aks          = "${local.name_prefix}-aks-001"
  }
}
```

---

## 7. State Management

### Best Practices

1. **No backend in modules** - Backend configuration belongs in root modules
2. **Remote state** - Use Azure Storage Account backend
3. **State locking** - Enable blob lease for consistency
4. **Workspaces** - Use for environment separation if appropriate

### Recommended Backend Configuration (Root Only)

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "stterraformstate"
    container_name       = "tfstate"
    key                  = "project/environment.tfstate"
  }
}
```

---

## 8. Security Architecture

### Defense in Depth

```
┌────────────────────────────────────────────────────┐
│                  Azure Subscription                 │
├────────────────────────────────────────────────────┤
│  ┌──────────────────────────────────────────────┐  │
│  │           Network Security Groups            │  │
│  │         (Perimeter Defense)                  │  │
│  ├──────────────────────────────────────────────┤  │
│  │  ┌────────────────────────────────────────┐  │  │
│  │  │        Private Endpoints               │  │  │
│  │  │    (Network Isolation)                 │  │  │
│  │  ├────────────────────────────────────────┤  │  │
│  │  │  ┌──────────────────────────────────┐  │  │  │
│  │  │  │      Managed Identity            │  │  │  │
│  │  │  │   (Workload Identity)            │  │  │  │
│  │  │  ├──────────────────────────────────┤  │  │  │
│  │  │  │  ┌────────────────────────────┐  │  │  │  │
│  │  │  │  │     Key Vault              │  │  │  │  │
│  │  │  │  │  (Secrets Management)      │  │  │  │  │
│  │  │  │  └────────────────────────────┘  │  │  │  │
│  │  │  └──────────────────────────────────┘  │  │  │
│  │  └────────────────────────────────────────┘  │  │
│  └──────────────────────────────────────────────┘  │
└────────────────────────────────────────────────────┘
```

### Security Module Requirements

1. **No hard-coded secrets** - Use Key Vault or environment variables
2. **No public endpoints by default** - Use private endpoints
3. **Enable encryption** - At rest and in transit
4. **Least privilege IAM** - Minimal required permissions
5. **Enable auditing** - Diagnostic settings configured

---

## 9. Identified Anti-Patterns

### Environment-Specific Modules

**Issue:** Multiple modules for different environments (dev, qa, prod)

```
terraform-azurerm-infrastructure-iaas-dev
terraform-azurerm-infrastructure-iaas-qa
terraform-azurerm-infrastructure-iaas-uat
terraform-azurerm-infrastructure-iaas-stg
terraform-azurerm-infrastructure-iaas-prod
terraform-azurerm-infrastructure-iaas-dr
terraform-azurerm-infrastructure-iaas-trng
```

**Recommendation:** Single parameterized module with environment variable

### NoCode Variants

**Issue:** Separate modules for NoCode deployments

```
terraform-azurerm-loadbalancer-no-code
terraform-azurerm-network-interface-no-code
terraform-azurerm-nocode-poc-*
```

**Recommendation:** Feature flags within standard modules

### Duplicate Service Names

**Issue:** Inconsistent naming for same service

```
terraform-azurerm-app-service-environment
terraform-azurerm-appservices-environment
```

**Recommendation:** Consolidate to single naming pattern

---

## 10. Future Architecture

### Target State

1. **Monorepo or Registry** - Replace submodules with proper module registry
2. **Layered Modules** - Foundation, Platform, Application tiers
3. **Composition** - Root modules compose smaller modules
4. **Versioned** - All modules semantically versioned
5. **Tested** - Automated testing in CI/CD

### Module Composition Example

```hcl
# Root module composition
module "foundation" {
  source = "registry/terraform-azurerm-foundation"
  version = "1.0.0"
  # Creates: Resource Group, VNet, NSG
}

module "aks" {
  source = "registry/terraform-azurerm-aks-cluster"
  version = "2.0.0"
  
  resource_group_name = module.foundation.resource_group_name
  subnet_id           = module.foundation.aks_subnet_id
}

module "database" {
  source = "registry/terraform-azurerm-postgresqlflexibleserver"
  version = "1.5.0"
  
  resource_group_name = module.foundation.resource_group_name
  subnet_id           = module.foundation.db_subnet_id
}
```

---

## Appendix: Module Inventory

Total modules in repository: **140**

See `workspace-analysis.json` for complete module listing with metadata.
