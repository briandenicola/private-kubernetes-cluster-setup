
terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm        = "~> 2.89"
  }
}

provider "azurerm" {
  features  {}
  use_msi   = true
}

provider "azurerm" {
  alias           = "core"
  use_msi         = true
  features        {}

  subscription_id = var.core_subscription
}
