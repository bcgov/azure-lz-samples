terraform {
  required_version = ">= 1.9.0"

  # backend "azurerm" {
  #   resource_group_name  = "tfstate"
  #   storage_account_name = "tfstate"
  #   container_name       = "tfstate"
  #   key                  = "terraform.tfstate"
  # }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }

    azapi = {
      source  = "Azure/azapi"
      version = "~> 2.0"
    }
  }
}

provider "azurerm" {
  use_oidc = true
  features {}
  # subscription_id is now required with AzureRM provider 4.0. Use either of the following methods:
    # subscription_id = "60e89f81-a15c-4d7a-9be3-c3795a33a277"
    # export ARM_SUBSCRIPTION_ID=60e89f81-a15c-4d7a-9be3-c3795a33a277
}

provider "azapi" {}
