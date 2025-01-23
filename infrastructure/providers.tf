terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4"
    }
    azapi = {
      source  = "Azure/azapi"
      version = "~> 2"
    }
  }
  
  backend "azurerm" {
    resource_group_name  = "Core_Storage_RG"
    storage_account_name = "bjdterraform003"
    container_name       = "plans"
  }
}

provider "azapi" {
}

provider "azurerm" {
  features {}
}

provider "azurerm" {
  alias = "core"
  features {}

  subscription_id = var.core_subscription
}