
terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm        = "~> 2.89"
  }
}

provider "azurerm" {
  features  {}
}

provider "azurerm" {
  alias           = "core"
  features        {}

  subscription_id = var.core_subscription
}
