provider "azurerm" {
  version = "~> 1.35.0"
}

provider "azurerm" {
  alias           = "acr"
  version         = "~> 1.35.0"
  subscription_id = var.acr_subscription
}

terraform {
  backend "azurerm" {
    storage_account_name = ""
    container_name       = "plans"
  }
}

data "azurerm_subnet" "k8s_subnet" {
  name                 = var.k8s_subnet
  virtual_network_name = var.k8s_vnet
  resource_group_name  = var.k8s_vnet_resource_group_name
}

data "azurerm_container_registry" "acr_repo" {
  name                = var.acr_name
  resource_group_name = var.acr_resource_group
  provider            = azurerm.acr
}

resource "azurerm_role_assignment" "acr_pullrole" {
  scope                = data.azurerm_container_registry.acr_repo.id
  role_definition_name = "AcrPull"
  principal_id         = var.client_id
  provider             = azurerm.acr
  skip_service_principal_aad_check = true
}

resource "azurerm_resource_group" "k8s" {
  name                  = var.resource_group_name
  location              = var.location
}

resource "azurerm_log_analytics_workspace" "k8s" {
  name                = var.log_analytics_workspace_name
  location            = azurerm_resource_group.k8s.location
  resource_group_name = azurerm_resource_group.k8s.name
  sku                 = "pergb2018"
}

resource "azurerm_log_analytics_solution" "k8s" {
  solution_name         = "ContainerInsights"
  location              = azurerm_resource_group.k8s.location
  resource_group_name   = azurerm_resource_group.k8s.name
  workspace_resource_id = azurerm_log_analytics_workspace.k8s.id
  workspace_name        = azurerm_log_analytics_workspace.k8s.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }
}

resource "azurerm_kubernetes_cluster" "k8s" {
  name                = var.cluster_name
  location            = azurerm_resource_group.k8s.location
  resource_group_name = azurerm_resource_group.k8s.name
  node_resource_group = "${azurerm_resource_group.k8s.name}_nodes"
  dns_prefix          = var.cluster_name
  kubernetes_version  = var.cluster_version

  linux_profile {
    admin_username = var.admin_user

    ssh_key {
      key_data = var.ssh_public_key
    }
  }

  agent_pool_profile {
    name                = "default"
    count               = var.agent_count
    vm_size             = var.vm_size
    os_type             = "Linux"
    os_disk_size_gb     = 30
    vnet_subnet_id      = data.azurerm_subnet.k8s_subnet.id
    type                = "VirtualMachineScaleSets"
    enable_auto_scaling = "true"
    min_count           = 1
    max_count           = 3
  }

  role_based_access_control {
    enabled = "true"
  }

  network_profile {
    dns_service_ip     = var.dns_service_ip
    service_cidr       = var.service_cidr
    docker_bridge_cidr = "172.17.0.1/16"
    network_plugin     = "azure"
    load_balancer_sku  = var.load_balancer_sku
  }

  service_principal {
    client_id     = var.client_id
    client_secret = var.client_secret
  }

  addon_profile {
    oms_agent {
      enabled                    = true
      log_analytics_workspace_id = azurerm_log_analytics_workspace.k8s.id
    }
  }

  tags = {
    Environment = var.environment
  }
}

