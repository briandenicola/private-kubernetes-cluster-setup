terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.45.0"
    }
    azapi = {
      source  = "Azure/azapi"
      version = "1.0.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.18.1"
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

provider "kubernetes" {
  host                   = azurerm_kubernetes_cluster.k8s.kube_config.0.host
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.k8s.kube_config.0.cluster_ca_certificate)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args = [
      "get-token",
      "--environment",
      "AzurePublicCloud",
      "--server-id",
      "6dae42f8-4368-4678-94ff-3960e28e3630",
      "--client-id",
      "80faf920-1908-4b52-b5ef-a8e7bedfc67a",
      "--tenant-id",
      data.azurerm_client_config.current.tenant_id,
      "--login",
      "azurecli",
    ]
    command = "kubelogin"
  }
}
