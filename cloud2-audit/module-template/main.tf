# -----------------------------------------------------------------------------
# Canonical Terraform Module Template - Main Configuration
# -----------------------------------------------------------------------------
# This file contains the primary resource definitions for the module.
# Follow HCL v2 style and Terraform >= 1.4 best practices.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Local Values
# -----------------------------------------------------------------------------
# Use locals for computed values, tag merging, and name generation

locals {
  # Merge default tags with user-provided tags
  # Default tags ensure consistency across all resources
  default_tags = {
    project           = var.project
    environment       = var.environment
    owner             = var.owner
    terraform_managed = "true"
    module_name       = "terraform-azurerm-module-template"
    module_version    = "1.0.0"
  }

  # User tags override defaults
  merged_tags = merge(local.default_tags, var.tags)

  # Generate consistent resource names
  # Pattern: <project>-<environment>-<location>-<resource>-<instance>
  name_prefix = "${var.project}-${var.environment}-${var.location}"

  # Resource-specific names
  resource_group_name = coalesce(var.resource_group_name, "${local.name_prefix}-rg-001")
}

# -----------------------------------------------------------------------------
# Data Sources
# -----------------------------------------------------------------------------
# Use data sources instead of hard-coded values for dynamic lookups

# Example: Get current Azure client configuration
data "azurerm_client_config" "current" {}

# Example: Look up existing resource group (if not creating)
data "azurerm_resource_group" "existing" {
  count = var.create_resource_group ? 0 : 1
  name  = var.resource_group_name
}

# Example: Look up Azure region by display name
# This avoids hard-coding region values
data "azurerm_location" "current" {
  location = var.location
}

# -----------------------------------------------------------------------------
# Resources
# -----------------------------------------------------------------------------
# Primary resources created by this module

# Example: Resource Group (optional - can use existing)
resource "azurerm_resource_group" "main" {
  count    = var.create_resource_group ? 1 : 0
  name     = local.resource_group_name
  location = var.location
  tags     = local.merged_tags
}

# Example: Main resource with proper configuration
# Replace with your actual resource type
# resource "azurerm_<resource_type>" "main" {
#   name                = "${local.name_prefix}-<type>-001"
#   resource_group_name = var.create_resource_group ? azurerm_resource_group.main[0].name : data.azurerm_resource_group.existing[0].name
#   location            = var.location
#   
#   # Resource-specific configuration
#   # ...
#   
#   # Apply merged tags
#   tags = local.merged_tags
#   
#   # Lifecycle management for critical resources
#   lifecycle {
#     prevent_destroy = var.prevent_destroy
#   }
# }

# -----------------------------------------------------------------------------
# Diagnostic Settings (if applicable)
# -----------------------------------------------------------------------------
# Enable monitoring and logging for resources that support it

# resource "azurerm_monitor_diagnostic_setting" "main" {
#   count = var.enable_monitoring ? 1 : 0
#   
#   name                       = "${local.name_prefix}-diag"
#   target_resource_id         = azurerm_<resource_type>.main.id
#   log_analytics_workspace_id = var.log_analytics_workspace_id
#   
#   # Configure logs and metrics as appropriate
# }
