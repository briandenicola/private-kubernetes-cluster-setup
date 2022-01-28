
terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm        = "~> 2.76"
  }
}

provider "azurerm" {
  features {}
}

provider "azurerm" {
  alias           = "core"
  subscription_id = var.core_subscription
  features        {}
}
