# Terraform Module Template

## Overview

A brief description of what this module creates and its purpose.

## Table of Contents

- [Overview](#overview)
- [Quick Start](#quick-start)
- [Requirements](#requirements)
- [Providers](#providers)
- [Inputs](#inputs)
- [Outputs](#outputs)
- [Resources Created](#resources-created)
- [Examples](#examples)
- [Tagging](#tagging)
- [Security](#security)
- [Testing](#testing)
- [Migration Notes](#migration-notes)
- [Changelog](#changelog)

## Quick Start

```hcl
module "example" {
  source = "path/to/module-template"

  # Required variables
  project     = "myapp"
  environment = "dev"
  owner       = "platform-team@example.com"
  location    = "eastus"

  # Optional: Custom tags
  tags = {
    cost_center = "IT-12345"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.4 |
| azurerm | ~> 3.80 |

## Providers

| Name | Version |
|------|---------|
| azurerm | ~> 3.80 |

## Inputs

| Name | Description | Type | Required | Default |
|------|-------------|------|----------|---------|
| project | Project or application name | `string` | yes | n/a |
| environment | Environment name (dev, staging, uat, prod, dr) | `string` | yes | n/a |
| owner | Owner email or team name | `string` | yes | n/a |
| location | Azure region | `string` | no | `"eastus"` |
| name | Custom name for primary resource | `string` | no | `null` |
| resource_group_name | Existing resource group name | `string` | no | `null` |
| create_resource_group | Create new resource group | `bool` | no | `true` |
| tags | Additional tags | `map(string)` | no | `{}` |
| enable_monitoring | Enable diagnostic settings | `bool` | no | `true` |
| prevent_destroy | Prevent accidental destruction | `bool` | no | `false` |
| log_analytics_workspace_id | Log Analytics Workspace ID | `string` | no | `null` |

### Deprecated Inputs

| Name | Replacement | Removal Version |
|------|-------------|-----------------|
| env | environment | v2.0.0 |
| proj | project | v2.0.0 |
| region | location | v2.0.0 |

## Outputs

| Name | Description | Sensitive |
|------|-------------|-----------|
| resource_group_name | Name of the resource group | no |
| resource_group_id | ID of the resource group | no |
| resource_group_location | Location of the resource group | no |
| tags | Tags applied to resources | no |
| name_prefix | Generated name prefix | no |

## Resources Created

This module creates the following resources:

- `azurerm_resource_group.main` - Resource group (optional)
- Additional resources as needed

## Examples

### Basic Usage

```hcl
module "basic" {
  source = "../"

  project     = "webapp"
  environment = "dev"
  owner       = "team@example.com"
  location    = "eastus"
}
```

### With Existing Resource Group

```hcl
module "existing_rg" {
  source = "../"

  project               = "webapp"
  environment           = "prod"
  owner                 = "team@example.com"
  location              = "eastus"
  create_resource_group = false
  resource_group_name   = "existing-rg-name"
}
```

### Full Configuration

```hcl
module "full" {
  source = "../"

  project     = "webapp"
  environment = "prod"
  owner       = "team@example.com"
  location    = "westus2"

  enable_monitoring          = true
  log_analytics_workspace_id = "/subscriptions/.../providers/Microsoft.OperationalInsights/workspaces/..."
  prevent_destroy            = true

  tags = {
    cost_center = "IT-12345"
    compliance  = "hipaa"
  }
}
```

## Tagging

All resources are tagged with the following default tags:

| Tag | Description | Source |
|-----|-------------|--------|
| project | Project name | `var.project` |
| environment | Environment | `var.environment` |
| owner | Owner | `var.owner` |
| terraform_managed | Managed by Terraform | Static `"true"` |
| module_name | Module name | Static |
| module_version | Module version | Static |

Additional tags can be provided via the `tags` variable and will be merged with defaults.

## Security

### Best Practices

- No secrets are stored in module code
- All sensitive outputs marked as `sensitive = true`
- Default configurations follow security best practices

### Backend Configuration

**Do NOT configure backend in this module.** Backend configuration belongs in the root module.

```hcl
# Root module backend (not in this module)
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "stterraformstate"
    container_name       = "tfstate"
    key                  = "myapp/dev.tfstate"
  }
}
```

## Testing

### Run Tests

```bash
cd tests
go test -v -timeout 30m
```

### Validate Module

```bash
terraform init
terraform validate
terraform fmt -check
```

### Security Scan

```bash
tfsec .
checkov -d .
```

## Migration Notes

### v1.x to v2.x

The following variables are deprecated and will be removed in v2.0.0:

```hcl
# Before (deprecated)
module "example" {
  source = "../"
  
  env  = "dev"    # Deprecated
  proj = "myapp"  # Deprecated
}

# After (recommended)
module "example" {
  source = "../"
  
  environment = "dev"    # New canonical name
  project     = "myapp"  # New canonical name
}
```

## Changelog

### [1.0.0] - 2025-11-25

#### Added
- Initial release
- Resource group creation
- Tagging support
- Monitoring support

### [Unreleased]

#### Planned
- Additional resource types
- Enhanced validation

---

## License

Copyright © 2025. All rights reserved.
