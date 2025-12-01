# -----------------------------------------------------------------------------
# Canonical Terraform Module Template - Outputs
# -----------------------------------------------------------------------------
# All output values exported by the module.
# Follow these conventions:
# - All outputs must have a description
# - Sensitive outputs must be marked sensitive = true
# - Export resource IDs, names, and key attributes
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Resource Group Outputs
# -----------------------------------------------------------------------------

output "resource_group_name" {
  description = "Name of the resource group (created or existing)"
  value       = var.create_resource_group ? azurerm_resource_group.main[0].name : var.resource_group_name
}

output "resource_group_id" {
  description = "ID of the resource group"
  value       = var.create_resource_group ? azurerm_resource_group.main[0].id : data.azurerm_resource_group.existing[0].id
}

output "resource_group_location" {
  description = "Location of the resource group"
  value       = var.create_resource_group ? azurerm_resource_group.main[0].location : data.azurerm_resource_group.existing[0].location
}

# -----------------------------------------------------------------------------
# Primary Resource Outputs
# -----------------------------------------------------------------------------
# Export key attributes of the main resource(s) created by this module

# output "resource_id" {
#   description = "ID of the primary resource"
#   value       = azurerm_<resource_type>.main.id
# }

# output "resource_name" {
#   description = "Name of the primary resource"
#   value       = azurerm_<resource_type>.main.name
# }

# -----------------------------------------------------------------------------
# Network Outputs (if applicable)
# -----------------------------------------------------------------------------
# Export networking information for resources that support it

# output "private_endpoint_ip" {
#   description = "Private IP address of the private endpoint"
#   value       = azurerm_private_endpoint.main[0].private_service_connection[0].private_ip_address
# }

# output "fqdn" {
#   description = "Fully qualified domain name of the resource"
#   value       = azurerm_<resource_type>.main.fqdn
# }

# -----------------------------------------------------------------------------
# Connection Outputs
# -----------------------------------------------------------------------------
# Export connection information (mark sensitive as appropriate)

# output "connection_string" {
#   description = "Connection string for the resource"
#   value       = azurerm_<resource_type>.main.connection_string
#   sensitive   = true
# }

# output "primary_access_key" {
#   description = "Primary access key for the resource"
#   value       = azurerm_<resource_type>.main.primary_access_key
#   sensitive   = true
# }

# -----------------------------------------------------------------------------
# Identity Outputs (if applicable)
# -----------------------------------------------------------------------------
# Export managed identity information

# output "identity_principal_id" {
#   description = "Principal ID of the system-assigned managed identity"
#   value       = azurerm_<resource_type>.main.identity[0].principal_id
# }

# output "identity_tenant_id" {
#   description = "Tenant ID of the system-assigned managed identity"
#   value       = azurerm_<resource_type>.main.identity[0].tenant_id
# }

# -----------------------------------------------------------------------------
# Computed Outputs
# -----------------------------------------------------------------------------
# Export computed or derived values

output "tags" {
  description = "Tags applied to all resources"
  value       = local.merged_tags
}

output "name_prefix" {
  description = "Generated name prefix used for resources"
  value       = local.name_prefix
}
