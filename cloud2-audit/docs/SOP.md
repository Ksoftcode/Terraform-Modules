# Standard Operating Procedure: Terraform Module Management

**Version:** 1.0  
**Effective Date:** 2025-11-25  
**Last Reviewed:** 2025-11-25  
**Owner:** Platform Engineering Team

---

## 1. Purpose and Scope

This SOP defines the standards, processes, and requirements for developing, maintaining, and publishing Terraform modules for the Cloud 2.0 initiative. It applies to all Azure infrastructure modules in the organization's Terraform module repository.

### Scope
- All Terraform modules targeting Azure (azurerm provider)
- Module lifecycle from creation to deprecation
- Security, testing, and documentation requirements
- Version management and publishing

### Out of Scope
- Root module/configuration development (covered in separate SOP)
- CI/CD pipeline configuration (covered in DevOps SOP)

---

## 2. Roles and Responsibilities

### Module Owner
- Develops and maintains module code
- Ensures compliance with this SOP
- Responds to bug reports and feature requests
- Creates and updates documentation
- Reviews and approves PRs for their modules

### Platform Team
- Establishes and maintains module standards
- Reviews modules for architectural compliance
- Manages module registry and publishing
- Provides guidance and tooling
- Approves new module creation

### Security Team
- Reviews modules for security compliance
- Defines security scanning thresholds
- Approves modules with sensitive resources (Key Vault, IAM, etc.)
- Responds to vulnerability reports

### Consumers (Application Teams)
- Use modules according to documentation
- Report issues and provide feedback
- Follow upgrade guidance
- Do not modify module code directly

---

## 3. Module Lifecycle

### 3.1 New Module Proposal

1. Submit proposal via GitHub Issue with:
   - Business justification
   - Resources to be created
   - Similar existing modules considered
   - Proposed name (following naming convention)

2. Platform Team reviews for:
   - Duplication with existing modules
   - Architectural alignment
   - Naming convention compliance

3. Approval required before development begins

### 3.2 Development

1. Clone module template repository
2. Develop following coding standards (Section 5)
3. Create required documentation (Section 6)
4. Implement tests (Section 7)
5. Submit PR for review

### 3.3 Review and Publishing

1. Pass automated checks (linting, security, tests)
2. Obtain required approvals (Section 4)
3. Tag version following semver
4. Publish to module registry

### 3.4 Maintenance

- Monitor for issues and security advisories
- Apply provider updates
- Respond to consumer requests
- Maintain documentation currency

### 3.5 Deprecation

1. Mark as deprecated in module-metadata.json
2. Add deprecation notice to README
3. Notify known consumers
4. Maintain for 90 days minimum
5. Archive after deprecation period

---

## 4. Branch and PR Policy

### Branch Naming Convention
```
feature/<module-name>-<short-description>
fix/<module-name>-<short-description>
security/<module-name>-<short-description>
docs/<module-name>-<short-description>
```

### Required Reviewers

| Change Type | Reviewers Required |
|-------------|-------------------|
| New module | Platform Team + Security Team |
| Major version (breaking) | Platform Team + Security Team |
| Minor version (features) | Module Owner + Platform Team |
| Patch version (fixes) | Module Owner |
| Security-sensitive resources | Security Team (mandatory) |

### Security-Sensitive Resources
- Key Vault
- Managed Identity
- Role Assignments
- Storage Account (public access)
- Network Security Groups
- Private Endpoints

### PR Requirements
- [ ] Passes all automated checks
- [ ] Version bumped appropriately
- [ ] CHANGELOG updated
- [ ] Documentation updated
- [ ] Tests added/updated

---

## 5. Code Review Checklist

### Structure
- [ ] Uses canonical file layout (main.tf, variables.tf, outputs.tf)
- [ ] No backend configuration in module
- [ ] No provider configuration in module (required_providers only)
- [ ] Required terraform version specified (>= 1.4)

### Variables
- [ ] All variables have types specified
- [ ] All variables have descriptions
- [ ] Sensitive variables marked as `sensitive = true`
- [ ] Default values use secure patterns
- [ ] Canonical variable names used (environment, tags, etc.)

### Outputs
- [ ] Key resource IDs exported
- [ ] Sensitive outputs marked as `sensitive = true`
- [ ] Descriptions provided

### Security
- [ ] No hard-coded secrets
- [ ] No hard-coded account IDs or subscription IDs
- [ ] No hard-coded image IDs (use data sources)
- [ ] No public access by default
- [ ] IAM follows least privilege
- [ ] Encryption enabled by default

### Tags
- [ ] Tags variable accepts map(string)
- [ ] Default tags merged with input tags
- [ ] Required tags enforced (project, environment, owner)

### Testing
- [ ] Unit tests present (terratest or equivalent)
- [ ] Example configuration works
- [ ] No provider credentials in code

---

## 6. Security Checklist

### Pre-Commit Requirements
- [ ] tfsec scan passes with no HIGH or CRITICAL findings
- [ ] checkov scan passes threshold (score >= 80)
- [ ] terraform validate succeeds
- [ ] terraform fmt applied

### Security Scan Thresholds

| Severity | Threshold | Action |
|----------|-----------|--------|
| Critical | 0 allowed | Block merge |
| High | 0 allowed | Block merge |
| Medium | 5 allowed | Warning, document exceptions |
| Low | 10 allowed | Informational |

### Required Security Patterns

```hcl
# Storage Account - Require secure transfer
resource "azurerm_storage_account" "example" {
  # ...
  min_tls_version              = "TLS1_2"
  enable_https_traffic_only    = true
  public_network_access_enabled = false
  # ...
}

# Key Vault - Enable soft delete
resource "azurerm_key_vault" "example" {
  # ...
  soft_delete_retention_days = 90
  purge_protection_enabled   = true
  # ...
}
```

---

## 7. Versioning and Publishing

### Semantic Versioning

| Version | When to Bump | Example |
|---------|-------------|---------|
| MAJOR | Breaking changes | 1.0.0 → 2.0.0 |
| MINOR | New features, backward compatible | 1.0.0 → 1.1.0 |
| PATCH | Bug fixes, backward compatible | 1.0.0 → 1.0.1 |

### Breaking Changes (Require Major Version)
- Variable renamed or removed
- Output renamed or removed
- Required variable added without default
- Resource replaced (forces recreation)

### Tagging Process
```bash
# Update module-metadata.json version
# Update CHANGELOG.md
git add .
git commit -m "Release v1.2.0: <summary>"
git tag -a v1.2.0 -m "Release v1.2.0"
git push origin v1.2.0
```

### Publishing to Registry
```bash
# Example for Azure DevOps artifact feed
# Automated via CI/CD pipeline after tag push
```

---

## 8. Testing Strategy

### Test Types

| Type | Scope | When Run |
|------|-------|----------|
| Static Analysis | Code quality, security | Every commit |
| Unit Tests | Module logic | Every PR |
| Integration Tests | Real resources | Nightly/Weekly |
| E2E Tests | Full deployments | Before release |

### Required Tests
1. **Validate** - `terraform validate`
2. **Format** - `terraform fmt -check`
3. **Lint** - `tflint`
4. **Security** - `tfsec`, `checkov`
5. **Unit** - Terratest or BATS

### Terratest Example
```go
func TestModuleBasic(t *testing.T) {
    terraformOptions := &terraform.Options{
        TerraformDir: "../examples/simple",
    }
    defer terraform.Destroy(t, terraformOptions)
    terraform.InitAndApply(t, terraformOptions)
    // Assertions
}
```

---

## 9. Emergency Rollback

### When to Rollback
- Critical bug affecting production
- Security vulnerability discovered
- Provider compatibility issue

### Rollback Procedure
1. Identify affected consumers
2. Notify via established channels
3. Tag new patch version with fix OR
4. Advise consumers to pin to previous version
5. Document issue and resolution

### Consumer Rollback
```hcl
module "example" {
  source  = "registry/module-name"
  version = "1.2.0"  # Pin to known-good version
  # ...
}
```

---

## 10. Onboarding New Module

### Prerequisites
- [ ] Proposal approved by Platform Team
- [ ] Module owner assigned
- [ ] Source repository created (if separate)

### Steps
1. Clone module template:
   ```bash
   git clone <template-repo> terraform-azurerm-<name>
   ```

2. Update module-metadata.json:
   ```json
   {
     "name": "terraform-azurerm-<name>",
     "version": "0.1.0",
     "maintainers": ["team@example.com"],
     "purpose": "Description of module purpose"
   }
   ```

3. Develop module following this SOP

4. Submit PR with:
   - Complete code
   - Documentation
   - Tests
   - Examples

5. After approval, publish initial version

---

## 11. Canonical Standards

### Variable Naming Conventions

| Concept | Canonical Name | Type |
|---------|---------------|------|
| Environment | `environment` | string |
| Project/Application | `project` | string |
| Owner | `owner` | string |
| Region | `location` | string |
| Resource tags | `tags` | map(string) |
| Enable monitoring | `enable_monitoring` | bool |
| Resource name | `name` | string |

### Required Tags

```hcl
variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

locals {
  default_tags = {
    terraform_managed = "true"
    module_name       = "terraform-azurerm-<name>"
    module_version    = "1.0.0"
  }
  merged_tags = merge(local.default_tags, var.tags)
}
```

### File Layout
```
module/
├── main.tf              # Primary resources
├── variables.tf         # Input variables
├── outputs.tf           # Output values
├── versions.tf          # Provider requirements
├── locals.tf            # Local values (optional)
├── data.tf              # Data sources (optional)
├── README.md            # Documentation
├── CHANGELOG.md         # Version history
├── module-metadata.json # Module metadata
├── examples/
│   └── simple/
│       └── main.tf
└── tests/
    └── module_test.go
```

---

## 12. Four-Week Remediation Plan

### Week 1: Foundation
| Task | Owner | Hours |
|------|-------|-------|
| Create .gitmodules | Platform Team | 4 |
| Initialize submodules | Platform Team | 4 |
| Complete code analysis | Infra Team | 8 |
| Document current state | Infra Team | 4 |

### Week 2: Assessment
| Task | Owner | Hours |
|------|-------|-------|
| Security audit | Security Team | 16 |
| Identify duplicates | Module Owner | 8 |
| Create module template | Platform Team | 8 |
| Document deprecations | Infra Team | 4 |

### Week 3: Remediation
| Task | Owner | Hours |
|------|-------|-------|
| Consolidate env-specific modules | Infra Team | 24 |
| Add missing documentation | Module Owner | 16 |
| Fix critical security issues | Security Team | 8 |

### Week 4: Stabilization
| Task | Owner | Hours |
|------|-------|-------|
| Pin provider versions | Infra Team | 8 |
| Implement module registry | Platform Team | 24 |
| Create CI/CD pipeline | Platform Team | 16 |
| Final documentation | Infra Team | 8 |

---

## Appendix A: References

- [Terraform Module Best Practices](https://www.terraform.io/docs/language/modules/develop/index.html)
- [Azure Provider Documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Terratest Documentation](https://terratest.gruntwork.io/)
- [tfsec Documentation](https://aquasecurity.github.io/tfsec/)

---

## Document Control

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2025-11-25 | Platform Engineering | Initial release |
