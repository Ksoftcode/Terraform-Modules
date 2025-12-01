# -----------------------------------------------------------------------------
# Simple Example - Module Template
# -----------------------------------------------------------------------------
# This example demonstrates basic usage of the module with minimal configuration.
# -----------------------------------------------------------------------------

terraform {
  required_version = ">= 1.4"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.80"
    }
  }
}

# Configure the Azure provider
provider "azurerm" {
  features {}
}

# Use the module with minimal configuration
module "example" {
  source = "../../"

  # Required variables
  project     = "demo"
  environment = "dev"
  owner       = "platform-team@example.com"
  location    = "eastus"

  # Optional: Additional tags
  tags = {
    cost_center = "IT-00000"
    team        = "platform"
  }
}

# Output the results
output "resource_group_name" {
  description = "The name of the resource group"
  value       = module.example.resource_group_name
}

output "resource_group_id" {
  description = "The ID of the resource group"
  value       = module.example.resource_group_id
}

output "applied_tags" {
  description = "Tags applied to resources"
  value       = module.example.tags
}
