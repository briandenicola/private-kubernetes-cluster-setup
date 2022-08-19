terraform {
  required_providers {
    azurerm  = {
      source = "hashicorp/azurerm"
      version = "3.17.0"
    }
    azapi = {
      source = "Azure/azapi"
      version = "0.4.0"
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
  features  {}
}

provider "azurerm" {
  alias           = "core"
  features        {}

  subscription_id = var.core_subscription
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "k8s" {
  name                  = var.resource_group_name
  location              = var.location
  tags     = {
    Application = "eshopOnDapr"
    Components  = "aks; key vault; "
    DeployedOn  = timestamp()
  }
}
