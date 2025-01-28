terraform {
  required_version = ">= 1.9.0"

  backend "azurerm" {
    resource_group_name  = "tfstate"
    storage_account_name = "tfstatee833c2dev"
    container_name       = "tfstate"
    key                  = "az-foundry-terraform.tfstate"
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.11"
    }

    azapi = {
      source  = "Azure/azapi"
      version = "~> 2.0"
    }
  }
}

provider "azurerm" {
  use_oidc = true
  features {
    # NOTE: This is required because we have the Azure Monitor Baseline Alerts policies in place,
    # which auto-create metric alerts for specific resources types within the Resource Group where the resource is created.
    # The AMBA metic alerts prevent the deletion of the Resource Group, as they are not created by this module.
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

provider "azapi" {}
