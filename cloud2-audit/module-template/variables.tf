# -----------------------------------------------------------------------------
# Canonical Terraform Module Template - Variables
# -----------------------------------------------------------------------------
# All input variables for the module.
# Follow these conventions:
# - All variables must have a type
# - All variables must have a description
# - Sensitive variables must be marked sensitive = true
# - Use canonical variable names for common concepts
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Required Variables
# -----------------------------------------------------------------------------

variable "project" {
  description = "Project or application name used for resource naming and tagging"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project))
    error_message = "Project name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "uat", "prod", "dr"], var.environment)
    error_message = "Environment must be one of: dev, staging, uat, prod, dr."
  }
}

variable "owner" {
  description = "Owner email or team name for resource tagging"
  type        = string
}

variable "location" {
  description = "Azure region for resource deployment"
  type        = string
  default     = "eastus"

  validation {
    condition     = can(regex("^[a-z]+[a-z0-9]*$", var.location))
    error_message = "Location must be a valid Azure region name."
  }
}

# -----------------------------------------------------------------------------
# Optional Variables
# -----------------------------------------------------------------------------

variable "name" {
  description = "Optional custom name for the primary resource. If not provided, name is auto-generated."
  type        = string
  default     = null
}

variable "resource_group_name" {
  description = "Name of existing resource group. Required if create_resource_group is false."
  type        = string
  default     = null
}

variable "create_resource_group" {
  description = "Whether to create a new resource group or use existing"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Additional tags to apply to all resources. Merged with default tags."
  type        = map(string)
  default     = {}
}

# -----------------------------------------------------------------------------
# Feature Flags
# -----------------------------------------------------------------------------

variable "enable_monitoring" {
  description = "Enable diagnostic settings and monitoring for resources"
  type        = bool
  default     = true
}

variable "prevent_destroy" {
  description = "Prevent accidental destruction of critical resources"
  type        = bool
  default     = false
}

# -----------------------------------------------------------------------------
# Monitoring Variables
# -----------------------------------------------------------------------------

variable "log_analytics_workspace_id" {
  description = "Log Analytics Workspace ID for diagnostic settings"
  type        = string
  default     = null
}

# -----------------------------------------------------------------------------
# Deprecated Variables (Backward Compatibility)
# -----------------------------------------------------------------------------
# These variables are deprecated and will be removed in the next major version.
# Use the canonical variable names instead.

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

variable "region" {
  description = "DEPRECATED: Use 'location' instead. Will be removed in v2.0.0."
  type        = string
  default     = null
}

# -----------------------------------------------------------------------------
# Sensitive Variables
# -----------------------------------------------------------------------------
# Mark sensitive variables to prevent accidental exposure in logs

# variable "admin_password" {
#   description = "Administrator password for the resource"
#   type        = string
#   sensitive   = true
# }

# variable "connection_string" {
#   description = "Connection string for database access"
#   type        = string
#   sensitive   = true
#   default     = null
# }
