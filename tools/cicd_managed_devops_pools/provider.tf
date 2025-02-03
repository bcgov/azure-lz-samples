terraform {
  required_version = ">= 1.9.0"

  backend "azurerm" {
    resource_group_name  = "tfstate"
    storage_account_name = "tfstate"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.116"
      # NOTE: Aligned with the version used in the AVM module (unable to update to v4.x until the AVM module is updated)
    }

    azapi = {
      source  = "Azure/azapi"
      version = "~> 2.0"
    }

    modtm = {
      source  = "azure/modtm"
      version = "~> 0.3"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
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

provider "azapi" {
}
