# Variable Migration Plan

This document outlines the strategy for migrating from legacy variable names to canonical variable names across all Terraform modules.

## Overview

To ensure consistency across all modules, we are standardizing variable names. This migration uses backward-compatible aliasing to prevent breaking changes.

## Canonical Variable Names

| Legacy Name(s) | Canonical Name | Type | Description |
|----------------|---------------|------|-------------|
| env, environ, environment_name | `environment` | string | Environment name (dev, staging, prod) |
| proj, project_name, app, application | `project` | string | Project or application name |
| loc, region, azure_region | `location` | string | Azure region |
| resource_tags, additional_tags | `tags` | map(string) | Tags to apply to resources |
| rg_name, resourcegroup | `resource_group_name` | string | Resource group name |
| subscription | `subscription_id` | string | Azure subscription ID |
| tenant | `tenant_id` | string | Azure tenant ID |
| enable_logging, logging_enabled | `enable_monitoring` | bool | Enable monitoring/logging |

## Migration Pattern

### Step 1: Add Canonical Variable (Keep Legacy)

```hcl
# variables.tf

# NEW: Canonical variable
variable "environment" {
  description = "Environment name (dev, staging, uat, prod)"
  type        = string
  default     = null
}

# DEPRECATED: Legacy variable - remove after v2.0.0
variable "env" {
  description = "DEPRECATED: Use 'environment' instead. Will be removed in v2.0.0."
  type        = string
  default     = null
}
```

### Step 2: Add Backward-Compatible Local

```hcl
# locals.tf

locals {
  # Prefer canonical, fall back to legacy, then default
  environment = coalesce(var.environment, var.env, "dev")
  
  # Emit deprecation warning via validation (Terraform 1.4+)
  _env_deprecation_check = var.env != null ? (
    warn("Variable 'env' is deprecated. Use 'environment' instead.")
  ) : null
}
```

### Step 3: Use Local in Resources

```hcl
# main.tf

locals {
  default_tags = {
    environment = local.environment  # Use local, not var
    # ...
  }
}

resource "azurerm_resource_group" "main" {
  name     = "${var.project}-${local.environment}-rg"
  # ...
}
```

### Step 4: Update Documentation

```markdown
<!-- README.md -->

## Deprecated Variables

| Variable | Replacement | Removal Version | Migration |
|----------|-------------|-----------------|-----------|
| `env` | `environment` | v2.0.0 | Replace in all module calls |
| `proj` | `project` | v2.0.0 | Replace in all module calls |
```

## Complete Migration Example

### Before Migration (Legacy)

```hcl
# Consumer calling the module
module "storage" {
  source = "../terraform-azurerm-storageaccount"
  
  env  = "dev"
  proj = "myapp"
  loc  = "eastus"
  
  resource_tags = {
    team = "platform"
  }
}
```

### After Migration (Backward Compatible)

Module `variables.tf`:
```hcl
# Canonical variables
variable "environment" {
  description = "Environment name (dev, staging, uat, prod, dr)"
  type        = string
  default     = null
  
  validation {
    condition     = var.environment == null || contains(["dev", "staging", "uat", "prod", "dr"], var.environment)
    error_message = "Environment must be one of: dev, staging, uat, prod, dr."
  }
}

variable "project" {
  description = "Project or application name"
  type        = string
  default     = null
}

variable "location" {
  description = "Azure region for resource deployment"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# Deprecated variables (for backward compatibility)
variable "env" {
  description = "DEPRECATED: Use 'environment' instead. Will be removed in v2.0.0."
  type        = string
  default     = null
}

variable "proj" {
  description = "DEPRECATED: Use 'project' instead. Will be removed in v2.0.0."
  type        = string
  default     = null
}

variable "loc" {
  description = "DEPRECATED: Use 'location' instead. Will be removed in v2.0.0."
  type        = string
  default     = null
}

variable "resource_tags" {
  description = "DEPRECATED: Use 'tags' instead. Will be removed in v2.0.0."
  type        = map(string)
  default     = {}
}
```

Module `locals.tf`:
```hcl
locals {
  # Backward-compatible variable resolution
  # Canonical takes precedence, then legacy, then default
  environment = coalesce(var.environment, var.env, "dev")
  project     = coalesce(var.project, var.proj, "unnamed")
  location    = coalesce(var.location, var.loc, "eastus")
  
  # Merge tags: user tags override legacy tags override defaults
  merged_tags = merge(
    {
      environment       = local.environment
      project           = local.project
      terraform_managed = "true"
    },
    var.resource_tags,  # Legacy
    var.tags            # Canonical (highest priority)
  )
}
```

### Consumer Migration Path

**Phase 1: Keep using legacy (still works)**
```hcl
module "storage" {
  source = "../terraform-azurerm-storageaccount"
  
  env  = "dev"   # Still works, but shows deprecation warning
  proj = "myapp"
  loc  = "eastus"
}
```

**Phase 2: Migrate to canonical (recommended)**
```hcl
module "storage" {
  source = "../terraform-azurerm-storageaccount"
  
  environment = "dev"     # New canonical name
  project     = "myapp"   # New canonical name
  location    = "eastus"  # New canonical name
  
  tags = {
    team = "platform"
  }
}
```

## Deprecation Timeline

| Date | Action |
|------|--------|
| Day 0 | Release v1.5.0 with backward-compatible aliases |
| Day 30 | Notify all consumers of deprecation |
| Day 60 | Begin updating consumer configurations |
| Day 90 | Release v2.0.0 removing deprecated variables |

## PR Checklist for Consumer Migration

When updating module calls to use canonical variable names:

- [ ] Review current module call for deprecated variables
- [ ] Update to canonical variable names
- [ ] Run `terraform plan` to verify no changes
- [ ] Update any variable files (.tfvars)
- [ ] Update workspace variables (if using workspaces)
- [ ] Update documentation/README
- [ ] Test in non-production environment first

## Automated Migration Script

```bash
#!/bin/bash
# migrate-variables.sh
# Script to help identify deprecated variable usage

echo "Searching for deprecated variable usage..."

# Find 'env' usage (not 'environment')
echo "=== 'env' variable usage (should use 'environment') ==="
grep -rn "var\.env\b" --include="*.tf" .

# Find 'proj' usage
echo "=== 'proj' variable usage (should use 'project') ==="
grep -rn "var\.proj\b" --include="*.tf" .

# Find 'loc' or 'region' usage
echo "=== 'loc/region' variable usage (should use 'location') ==="
grep -rn "var\.loc\b\|var\.region\b" --include="*.tf" .

# Find 'resource_tags' usage
echo "=== 'resource_tags' variable usage (should use 'tags') ==="
grep -rn "var\.resource_tags\b" --include="*.tf" .

echo "Migration scan complete."
```

## Output Renames

For output renames, follow similar pattern:

```hcl
# outputs.tf

# Canonical output
output "resource_group_id" {
  description = "ID of the resource group"
  value       = azurerm_resource_group.main.id
}

# Deprecated alias (for backward compatibility)
output "rg_id" {
  description = "DEPRECATED: Use 'resource_group_id' instead"
  value       = azurerm_resource_group.main.id
}
```

## Validation Function (Terraform 1.4+)

```hcl
# Can be used to emit warnings for deprecated variable usage
locals {
  _deprecation_warnings = [
    var.env != null ? "WARNING: Variable 'env' is deprecated. Use 'environment' instead." : null,
    var.proj != null ? "WARNING: Variable 'proj' is deprecated. Use 'project' instead." : null,
    var.loc != null ? "WARNING: Variable 'loc' is deprecated. Use 'location' instead." : null,
  ]
  
  # This will cause the warnings to be evaluated
  _check_deprecations = compact(local._deprecation_warnings)
}
```

## Questions?

Contact the Platform Team for assistance with migration.
