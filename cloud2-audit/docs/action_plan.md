# Cloud 2.0 Terraform Modules - Prioritized Remediation Action Plan

**Document Version:** 1.0  
**Created:** 2025-11-25  
**Owner:** Platform Engineering Team

---

## Priority Matrix

| Priority | Severity | Timeline | Description |
|----------|----------|----------|-------------|
| P0 | Critical | Immediate (Days 1-3) | Blocks all work |
| P1 | High | Week 1 | Security risk or major blocker |
| P2 | Medium | Weeks 2-3 | Standards compliance |
| P3 | Low | Week 4+ | Nice to have |

---

## Phase 1: Foundation (Days 1-5)

### P0-001: Create .gitmodules Configuration
**Severity:** Critical  
**Effort:** 4 hours  
**Owner:** Platform Team Lead

**Description:**  
The repository contains 140 submodule references but no `.gitmodules` file to configure their URLs.

**Tasks:**
1. Identify source repository URL for each module
2. Create `.gitmodules` file with all mappings
3. Verify format is correct
4. Commit and push

**Acceptance Criteria:**
- [ ] `.gitmodules` exists with all 140 modules
- [ ] Each entry has valid `path` and `url`
- [ ] File passes git validation

**Template:**
```ini
[submodule "terraform-azurerm-aks-cluster"]
    path = terraform-azurerm-aks-cluster
    url = https://github.com/<org>/terraform-azurerm-aks-cluster.git

[submodule "terraform-azurerm-storageaccount"]
    path = terraform-azurerm-storageaccount
    url = https://github.com/<org>/terraform-azurerm-storageaccount.git
```

---

### P0-002: Initialize Submodules
**Severity:** Critical  
**Effort:** 4 hours  
**Owner:** Platform Team

**Description:**  
After creating `.gitmodules`, initialize all submodules to populate module content.

**Tasks:**
1. Run `git submodule update --init --recursive`
2. Verify all 140 modules populated
3. Fix any failed submodule fetches
4. Document any modules with access issues

**Commands:**
```bash
git submodule update --init --recursive
git submodule status
# Verify no '-' prefixes (uninitialized) or '+' (mismatched commits)
```

**Acceptance Criteria:**
- [ ] All 140 modules contain Terraform code
- [ ] No submodule initialization errors
- [ ] Access documented for any private repos

---

### P0-003: Complete Code Analysis
**Severity:** Critical  
**Effort:** 8 hours  
**Owner:** Infrastructure Team

**Description:**  
Re-run the audit with populated module content to identify actual issues.

**Tasks:**
1. Parse all .tf files in each module
2. Extract variables, outputs, resources
3. Identify hard-coded values
4. Detect security issues
5. Update workspace-analysis.json

**Acceptance Criteria:**
- [ ] workspace-analysis.json updated with real data
- [ ] All modules catalogued
- [ ] Issues documented with line numbers

---

## Phase 2: Security Audit (Week 1)

### P1-001: Security Vulnerability Scan
**Severity:** High  
**Effort:** 16 hours  
**Owner:** Security Team

**Description:**  
Run security scanners against all module code.

**Tasks:**
1. Install and configure tfsec
2. Install and configure checkov
3. Run against all modules
4. Categorize findings by severity
5. Document remediation requirements

**Commands:**
```bash
# Run tfsec on all modules
find . -name "*.tf" -exec dirname {} \; | sort -u | while read dir; do
    echo "Scanning: $dir"
    tfsec "$dir" --format json > "results/${dir//\//_}.json"
done

# Run checkov
checkov -d . --output-file-path results/
```

**Acceptance Criteria:**
- [ ] All modules scanned
- [ ] No Critical findings remain
- [ ] High findings documented with remediation plans

---

### P1-002: Hard-Coded Secrets Detection
**Severity:** High  
**Effort:** 8 hours  
**Owner:** Security Team

**Description:**  
Identify any hard-coded secrets, API keys, or credentials in module code.

**Tasks:**
1. Run git-secrets or similar tool
2. Search for common secret patterns
3. Check for subscription IDs, tenant IDs
4. Verify no API keys in code

**Patterns to Search:**
```bash
# Azure patterns
grep -rn "subscription_id\s*=" . --include="*.tf"
grep -rn "tenant_id\s*=" . --include="*.tf"
grep -rn "client_secret\s*=" . --include="*.tf"

# Generic secret patterns
grep -rn "password\s*=" . --include="*.tf"
grep -rn "api_key\s*=" . --include="*.tf"
grep -rn "secret\s*=" . --include="*.tf"
```

**Acceptance Criteria:**
- [ ] No hard-coded secrets found
- [ ] All secrets use variables or Key Vault
- [ ] Sensitive variables marked `sensitive = true`

---

### P1-003: IAM Policy Review
**Severity:** High  
**Effort:** 8 hours  
**Owner:** Security Team

**Description:**  
Review all role assignments and IAM policies for least privilege.

**Tasks:**
1. Identify all role assignment resources
2. Review scope of assignments
3. Check for wildcard permissions
4. Document overly permissive roles

**Acceptance Criteria:**
- [ ] No wildcard (*) principals
- [ ] Roles scoped appropriately
- [ ] Built-in roles preferred over custom

---

## Phase 3: Standardization (Weeks 2-3)

### P2-001: Create Module Template
**Severity:** Medium  
**Effort:** 8 hours  
**Owner:** Platform Team

**Description:**  
Create and document canonical module template for all modules to follow.

**Tasks:**
1. Create template repository structure
2. Document required files
3. Create variable and output standards
4. Add testing skeleton

**Deliverables:**
- `module-template/` directory (see template in this audit)
- Documentation in SOP.md

**Acceptance Criteria:**
- [ ] Template created and tested
- [ ] Documentation complete
- [ ] Example usage works

---

### P2-002: Provider Version Pinning
**Severity:** Medium  
**Effort:** 8 hours  
**Owner:** Infrastructure Team

**Description:**  
Ensure all modules pin provider versions consistently.

**Tasks:**
1. Audit current provider constraints
2. Define standard versions
3. Update all modules
4. Test compatibility

**Standard Versions:**
```hcl
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

**Acceptance Criteria:**
- [ ] All modules have versions.tf
- [ ] All use same provider version constraint
- [ ] terraform validate passes

---

### P2-003: Variable Standardization
**Severity:** Medium  
**Effort:** 16 hours  
**Owner:** Module Owner

**Description:**  
Standardize variable names across all modules.

**Tasks:**
1. Audit current variable names
2. Map to canonical names
3. Add backward-compatible aliases
4. Update documentation

**Canonical Names:**
| Current Variations | Canonical |
|-------------------|-----------|
| env, environ, environment_name | environment |
| proj, project_name, app | project |
| loc, region, azure_region | location |
| tags, resource_tags | tags |

**Migration Pattern:**
```hcl
# Old variable (deprecated)
variable "env" {
  description = "DEPRECATED: Use 'environment' instead"
  type        = string
  default     = null
}

# New canonical variable
variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

# Backward-compatible local
locals {
  environment = coalesce(var.environment, var.env, "dev")
}
```

**Acceptance Criteria:**
- [ ] All modules use canonical names
- [ ] Old names deprecated but functional
- [ ] 90-day deprecation timeline set

---

### P2-004: Add Missing Documentation
**Severity:** Medium  
**Effort:** 24 hours  
**Owner:** Module Owner

**Description:**  
Create or update README.md for all modules.

**Tasks:**
1. Identify modules missing README
2. Generate README from terraform-docs
3. Add usage examples
4. Document inputs/outputs

**Command:**
```bash
for module in terraform-*; do
    terraform-docs markdown table "$module" > "$module/README.md"
done
```

**Acceptance Criteria:**
- [ ] All modules have README.md
- [ ] All variables documented
- [ ] All outputs documented
- [ ] Usage example provided

---

### P2-005: Consolidate Environment Modules
**Severity:** Medium  
**Effort:** 40 hours  
**Owner:** Infrastructure Team

**Description:**  
Merge environment-specific modules into single parameterized modules.

**Affected Modules:**
- terraform-azurerm-infrastructure-iaas-dev
- terraform-azurerm-infrastructure-iaas-qa
- terraform-azurerm-infrastructure-iaas-uat
- terraform-azurerm-infrastructure-iaas-stg
- terraform-azurerm-infrastructure-iaas-prod
- terraform-azurerm-infrastructure-iaas-dr
- terraform-azurerm-infrastructure-iaas-trng

**Tasks:**
1. Analyze differences between modules
2. Create single parameterized module
3. Add environment variable
4. Create tfvars for each environment
5. Test all environments
6. Deprecate old modules

**Acceptance Criteria:**
- [ ] Single module supports all environments
- [ ] Old modules deprecated
- [ ] Consumer migration guide provided

---

## Phase 4: Quality & CI/CD (Week 4)

### P3-001: Add Testing
**Severity:** Low  
**Effort:** 24 hours  
**Owner:** Infrastructure Team

**Description:**  
Add automated tests to high-priority modules.

**Tasks:**
1. Set up Terratest framework
2. Create tests for key modules
3. Add to CI/CD pipeline
4. Document test procedures

**Priority Modules for Testing:**
1. terraform-azurerm-aks-cluster
2. terraform-azurerm-virtual-network
3. terraform-azurerm-storageaccount
4. terraform-azurerm-azure-key-vault

**Acceptance Criteria:**
- [ ] Terratest framework configured
- [ ] Top 10 modules have tests
- [ ] Tests run in CI/CD

---

### P3-002: Implement Module Registry
**Severity:** Low  
**Effort:** 24 hours  
**Owner:** Platform Team

**Description:**  
Set up private module registry for better version management.

**Options:**
1. Terraform Cloud Private Registry
2. Azure DevOps Artifact Feed
3. Self-hosted (e.g., Artifactory)

**Tasks:**
1. Choose registry solution
2. Configure authentication
3. Publish initial modules
4. Update consumer documentation

**Acceptance Criteria:**
- [ ] Registry deployed
- [ ] Top modules published
- [ ] Consumers can reference via registry

---

### P3-003: CI/CD Pipeline
**Severity:** Low  
**Effort:** 16 hours  
**Owner:** Platform Team

**Description:**  
Create CI/CD pipeline for module validation.

**Pipeline Stages:**
1. Lint (tflint)
2. Format (terraform fmt)
3. Validate (terraform validate)
4. Security (tfsec, checkov)
5. Test (terratest) - on merge
6. Publish - on tag

**Acceptance Criteria:**
- [ ] Pipeline configured
- [ ] All stages working
- [ ] Automatic on PR

---

## Summary Timeline

```
Week 1
├── Days 1-3: Create .gitmodules, initialize submodules
├── Days 3-5: Complete code analysis
└── Days 3-5: Begin security scan

Week 2
├── Complete security scan
├── Remediate critical/high findings
├── Create module template
└── Begin provider standardization

Week 3
├── Complete provider standardization
├── Variable standardization (begin)
├── Add documentation
└── Begin environment module consolidation

Week 4
├── Complete environment consolidation
├── Add testing to key modules
├── Set up module registry
└── Configure CI/CD pipeline
```

## Resource Requirements

| Role | FTE Weeks | Responsibilities |
|------|-----------|------------------|
| Platform Team Lead | 2 | Coordination, .gitmodules |
| Security Engineer | 1.5 | Scans, remediation |
| Infrastructure Engineer | 3 | Analysis, standardization |
| Module Owner(s) | 2 | Documentation, fixes |

**Total Estimated Effort:** 8.5 FTE weeks (~340 hours)

---

## Risk Register

| Risk | Impact | Mitigation |
|------|--------|------------|
| Submodule repos inaccessible | High | Document URLs, request access early |
| Breaking changes during consolidation | High | Maintain backward compatibility |
| Consumer disruption | Medium | Communicate deprecation timeline |
| Resource constraints | Medium | Prioritize P0/P1 items |

---

## Success Metrics

| Metric | Current | Target | Timeline |
|--------|---------|--------|----------|
| Modules with code | 0 | 140 | Week 1 |
| Critical issues | Unknown | 0 | Week 2 |
| High issues | Unknown | 0 | Week 3 |
| Modules with README | Unknown | 140 | Week 3 |
| Modules with tests | Unknown | 20+ | Week 4 |
| Environment modules | 8 | 1 | Week 4 |

---

## Approval

| Role | Name | Date | Signature |
|------|------|------|-----------|
| Platform Lead | | | |
| Security Lead | | | |
| Infrastructure Lead | | | |
