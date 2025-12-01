# -----------------------------------------------------------------------------
# Canonical Terraform Module Template - Provider Requirements
# -----------------------------------------------------------------------------
# Define required Terraform version and provider versions.
# This file should be present in every module.
# 
# IMPORTANT: Do NOT configure providers in modules.
# Provider configuration belongs in root modules only.
# Only declare required_providers here.
# -----------------------------------------------------------------------------

terraform {
  # Minimum Terraform version
  required_version = ">= 1.4"

  # Required provider versions
  required_providers {
    # Azure Resource Manager provider
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.80"
    }

    # Azure Active Directory provider (if needed)
    # azuread = {
    #   source  = "hashicorp/azuread"
    #   version = "~> 2.45"
    # }

    # Kubernetes provider (for AKS modules)
    # kubernetes = {
    #   source  = "hashicorp/kubernetes"
    #   version = "~> 2.23"
    # }

    # Helm provider (for Kubernetes deployments)
    # helm = {
    #   source  = "hashicorp/helm"
    #   version = "~> 2.11"
    # }

    # Random provider (for generating unique names)
    # random = {
    #   source  = "hashicorp/random"
    #   version = "~> 3.5"
    # }

    # Time provider (for delays and timestamps)
    # time = {
    #   source  = "hashicorp/time"
    #   version = "~> 0.9"
    # }
  }
}

# -----------------------------------------------------------------------------
# DO NOT CONFIGURE PROVIDERS IN MODULES
# -----------------------------------------------------------------------------
# Provider configuration should be done in the root module only.
# Modules should only declare required_providers.
#
# INCORRECT (do not do this in modules):
# provider "azurerm" {
#   features {}
#   subscription_id = "xxx"
# }
#
# CORRECT: Configure providers in the root module that calls this module.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# DO NOT CONFIGURE BACKENDS IN MODULES
# -----------------------------------------------------------------------------
# Backend configuration should be done in the root module only.
#
# INCORRECT (do not do this in modules):
# terraform {
#   backend "azurerm" {
#     resource_group_name  = "xxx"
#     storage_account_name = "xxx"
#     container_name       = "xxx"
#     key                  = "xxx"
#   }
# }
#
# CORRECT: Configure backend in the root module that uses this module.
# -----------------------------------------------------------------------------
