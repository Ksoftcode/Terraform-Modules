# Remediation Patches

This directory contains patch files for remediation of Critical and High severity issues.

> **Note:** Since the repository contains empty submodule references without actual Terraform code, these patches are templates that should be applied once the submodules are initialized.

## Patch Index

| Patch File | Severity | Issue | Description |
|------------|----------|-------|-------------|
| 001-add-gitmodules.patch | Critical | ISSUE-001 | Create .gitmodules file |
| 002-add-provider-versions.patch | High | ISSUE-006 | Standard provider version pinning |
| 003-add-tags-implementation.patch | Medium | N/A | Standard tags implementation |
| 004-remove-backend-block.patch | High | N/A | Remove backend from modules |
| 005-add-sensitive-outputs.patch | High | N/A | Mark sensitive outputs |

## How to Apply Patches

```bash
# Apply a specific patch
git apply patches/001-add-gitmodules.patch

# Apply with 3-way merge (recommended)
git apply --3way patches/001-add-gitmodules.patch

# Test patch without applying
git apply --check patches/001-add-gitmodules.patch
```

---

## Patch 001: Create .gitmodules File

**Branch:** `fix/repository-add-gitmodules`  
**Commit Message:** `chore: add .gitmodules configuration file`

### PR Template

**Title:** Add .gitmodules configuration for submodule initialization

**Body:**
```markdown
## Summary
This PR adds the .gitmodules configuration file that was missing from the repository.

## Problem
The repository contains 140 submodule references but no .gitmodules file to configure them.
Without this file, submodules cannot be initialized and the repository is non-functional.

## Solution
Add .gitmodules file with proper path and URL mappings for all modules.

## Testing
1. After applying, run: `git submodule update --init --recursive`
2. Verify all 140 modules are populated with code
3. Run `git submodule status` to check for issues

## Checklist
- [ ] All module URLs are correct
- [ ] All module paths match directory names
- [ ] Submodule initialization succeeds

## Reviewers
Required: @platform-team

## Rollback
```bash
git rm .gitmodules
git config --remove-section submodule.<module-name>  # For each module
```
```

### Patch Content (Template)

Create file `.gitmodules` with the following structure:

```ini
# .gitmodules - Git Submodule Configuration
# This file maps submodule paths to their source repositories

[submodule "terraform-azurerm-aks-cluster"]
    path = terraform-azurerm-aks-cluster
    url = https://github.com/<org>/terraform-azurerm-aks-cluster.git
    branch = main

[submodule "terraform-azurerm-storageaccount"]
    path = terraform-azurerm-storageaccount
    url = https://github.com/<org>/terraform-azurerm-storageaccount.git
    branch = main

[submodule "terraform-azurerm-virtual-network"]
    path = terraform-azurerm-virtual-network
    url = https://github.com/<org>/terraform-azurerm-virtual-network.git
    branch = main

# ... Add entries for all 140 modules ...
```

---

## Patch 002: Add Provider Version Pinning

**Branch:** `fix/modules-add-provider-versions`  
**Commit Message:** `chore: add standardized provider version constraints`

### PR Template

**Title:** Standardize provider version pinning across all modules

**Body:**
```markdown
## Summary
Add consistent provider version constraints to all modules.

## Problem
Modules may have inconsistent or missing provider version constraints, 
leading to unexpected behavior when providers are updated.

## Solution
Add/update versions.tf in each module with standardized constraints:
- Terraform >= 1.4
- azurerm ~> 3.80
- azuread ~> 2.45 (where applicable)

## Testing
1. Run `terraform init` in each module
2. Run `terraform validate`
3. Verify no version conflicts

## Reviewers
Required: @platform-team, @infra-team
```

### Patch Content (Per Module)

Create or update `versions.tf` in each module:

```hcl
# versions.tf - Provider Version Requirements
# DO NOT configure providers here - only declare requirements

terraform {
  required_version = ">= 1.4"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.80"
    }
  }
}
```

---

## Patch 003: Add Tags Implementation

**Branch:** `fix/modules-add-standard-tags`  
**Commit Message:** `feat: add standardized tagging implementation`

### PR Template

**Title:** Implement standardized tagging across modules

**Body:**
```markdown
## Summary
Add consistent tagging implementation to all modules.

## Changes
- Add `tags` variable (map(string))
- Add `project`, `environment`, `owner` variables
- Implement `local.merged_tags` pattern
- Apply tags to all resources

## Testing
1. Verify tags appear on created resources
2. Verify custom tags override defaults
3. Verify required tags are present
```

### Patch Content (Per Module)

Add to `variables.tf`:

```hcl
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

variable "tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}
```

Add to `locals.tf` (or create):

```hcl
locals {
  default_tags = {
    project           = var.project
    environment       = var.environment
    owner             = var.owner
    terraform_managed = "true"
    module_name       = "<module-name>"
    module_version    = "1.0.0"
  }

  merged_tags = merge(local.default_tags, var.tags)
}
```

Update all resources to use `tags = local.merged_tags`.

---

## Patch 004: Remove Backend Block

**Branch:** `fix/modules-remove-backend`  
**Commit Message:** `fix: remove backend configuration from modules`

### PR Template

**Title:** Remove backend configuration from modules (anti-pattern)

**Body:**
```markdown
## Summary
Remove any backend configuration from modules. Backend should only be 
configured in root modules.

## Problem
Backend configuration in reusable modules causes conflicts when the 
module is used from different root configurations.

## Solution
1. Remove `backend` blocks from modules
2. Add documentation about backend configuration
3. Update README with guidance

## Testing
1. Verify `terraform init` works without specifying backend
2. Verify module can be used from root with any backend

## Post-Merge
Notify consumers that they must configure backend in their root modules.
```

### Patch Content

Search for and remove backend blocks like:

```hcl
# REMOVE THIS FROM MODULES
terraform {
  backend "azurerm" {
    resource_group_name  = "..."
    storage_account_name = "..."
    container_name       = "..."
    key                  = "..."
  }
}
```

Add to README.md:

```markdown
## Backend Configuration

**Do NOT configure backend in this module.**

Backend must be configured in the root module that calls this module:

\`\`\`hcl
# In your root module
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "stterraformstate"
    container_name       = "tfstate"
    key                  = "environment/service.tfstate"
  }
}

module "this" {
  source = "path/to/module"
  # ...
}
\`\`\`
```

---

## Patch 005: Add Sensitive Outputs

**Branch:** `fix/modules-sensitive-outputs`  
**Commit Message:** `security: mark sensitive outputs appropriately`

### PR Template

**Title:** Mark sensitive outputs with sensitive = true

**Body:**
```markdown
## Summary
Add `sensitive = true` to outputs that contain credentials or secrets.

## Problem
Sensitive data in outputs is displayed in plain text in logs and state.

## Solution
Identify and mark sensitive outputs:
- Connection strings
- Access keys
- Passwords
- Certificates

## Security Review
Required: @security-team
```

### Patch Content

Update outputs that contain sensitive data:

```hcl
# BEFORE
output "connection_string" {
  description = "Connection string for the resource"
  value       = azurerm_storage_account.main.primary_connection_string
}

# AFTER
output "connection_string" {
  description = "Connection string for the resource"
  value       = azurerm_storage_account.main.primary_connection_string
  sensitive   = true
}
```

Common patterns to look for and mark sensitive:

```hcl
output "primary_access_key" {
  value     = azurerm_storage_account.main.primary_access_key
  sensitive = true
}

output "secondary_access_key" {
  value     = azurerm_storage_account.main.secondary_access_key
  sensitive = true
}

output "admin_password" {
  value     = random_password.admin.result
  sensitive = true
}

output "connection_string" {
  value     = azurerm_cosmosdb_account.main.connection_strings[0]
  sensitive = true
}
```

---

## Applying All Patches

```bash
#!/bin/bash
# apply-all-patches.sh

set -e

echo "Applying all remediation patches..."

for patch in patches/*.patch; do
    echo "Applying: $patch"
    git apply --check "$patch" && git apply "$patch"
done

echo "All patches applied successfully."
echo "Run 'git status' to see changes."
echo "Review changes, then commit."
```

---

## Creating New Patches

When you make changes that should become patches:

```bash
# Make your changes
vim modules/module-name/file.tf

# Generate patch
git diff > patches/NNN-description.patch

# Or for staged changes
git diff --cached > patches/NNN-description.patch
```
