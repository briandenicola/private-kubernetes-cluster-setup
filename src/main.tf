provider "azurerm" {
  version = "~> 2.73.0"
  features  {}
}

provider "azurerm" {
  alias           = "acr"
  version         = "~> 2.73.0"
  features        {}
  subscription_id = var.acr_subscription
}

terraform {
  backend "azurerm" {
    storage_account_name = "bjdterraform001"
    container_name       = "plans"
  }
}

data "azurerm_virtual_network" "vnet" {
  name                = var.k8s_vnet
  resource_group_name = var.k8s_vnet_resource_group_name
}

data "azurerm_subnet" "k8s_subnet" {
  name                 = var.k8s_subnet
  virtual_network_name = var.k8s_vnet
  resource_group_name  = var.k8s_vnet_resource_group_name
}

data "azurerm_subnet" "management_subnet" {
  name                 = "Servers"
  virtual_network_name = var.k8s_vnet
  resource_group_name  = var.k8s_vnet_resource_group_name
}

data "azurerm_subnet" "private_endpoint_subnet" {
  name                 = "private-endpoints"
  virtual_network_name = var.k8s_vnet
  resource_group_name  = var.k8s_vnet_resource_group_name
}

resource "azurerm_resource_group" "k8s" {
  name                  = var.resource_group_name
  location              = var.location
}

resource "random_id" "management_vm_id" {
     byte_length = 4
 }

resource "azurerm_network_interface" "management" {
  name                = "bjd${random_id.management_vm_id.id}-nic"
  location            = azurerm_resource_group.k8s.location
  resource_group_name = azurerm_resource_group.k8s.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.management_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "management" {
  name                = "bjd${random_id.management_vm_id.id}"
  resource_group_name = azurerm_resource_group.k8s.name
  location            = azurerm_resource_group.k8s.location
  size                = "Standard_B2ms"
  admin_username      = "manager"
  network_interface_ids = [
    azurerm_network_interface.management.id,
  ]


  identity {
    type = "SystemAssigned"
  }

  admin_ssh_key {
    username   = "manager"
    public_key = var.ssh_public_key
  }

  os_disk {
    name                 = "bjd${random_id.management_vm_id.id}-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

resource "azurerm_private_dns_zone" "aks_private_zone" {
  name                = "privatelink.${var.location}.azmk8s.io"
  resource_group_name = azurerm_resource_group.k8s.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "dns_link" {
  name                  = "aks_dns_link"
  resource_group_name   = azurerm_resource_group.k8s.name
  private_dns_zone_name = azurerm_private_dns_zone.aks_private_zone.name
  virtual_network_id    = data.azurerm_virtual_network.vnet.id
}

resource "azurerm_user_assigned_identity" "aks_identity" {
  name                = "${var.cluster_name}-identity"
  resource_group_name = azurerm_resource_group.k8s.name
  location            = azurerm_resource_group.k8s.location
}

resource "azurerm_role_assignment" "aks_role_assignemnt_dns" {
  scope                = azurerm_private_dns_zone.aks_private_zone.id
  role_definition_name = "Private DNS Zone Contributor"
  principal_id         = azurerm_user_assigned_identity.aks_identity.principal_id
  skip_service_principal_aad_check = true
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
  depends_on = [
    azurerm_role_assignment.aks_role_assignemnt_dns
  ]
  name                      = var.cluster_name
  location                  = azurerm_resource_group.k8s.location
  resource_group_name       = azurerm_resource_group.k8s.name
  node_resource_group       = "${azurerm_resource_group.k8s.name}_nodes"
  dns_prefix_private_cluster = "aks-private"
  kubernetes_version        = var.cluster_version
  private_cluster_enabled   = "true"
  private_dns_zone_id       = azurerm_private_dns_zone.aks_private_zone.id
  automatic_channel_upgrade = "patch"

  role_based_access_control {
    enabled = "true"
    azure_active_directory {
      managed                 = "true" 
      azure_rbac_enabled      = "true"  
      admin_group_object_ids  = [
        var.azure_rbac_group_object_id,
      ] 
    }
  }

  linux_profile {
    admin_username = var.admin_user

    ssh_key {
      key_data = var.ssh_public_key
    }
  }

  identity {
    type                      = "UserAssigned"
    user_assigned_identity_id = azurerm_user_assigned_identity.aks_identity.id
  }


  default_node_pool  {
    name                    = "default"
    node_count              = var.agent_count
    availability_zones      = ["1", "2", "3"]
    vm_size                 = var.vm_size
    os_disk_size_gb         = 30
    vnet_subnet_id          = data.azurerm_subnet.k8s_subnet.id
    type                    = "VirtualMachineScaleSets"
    enable_auto_scaling     = "true"
    min_count               = 1
    max_count               = 3
    //local_account_disabled  = "false"
  }

  network_profile {
    dns_service_ip     = var.dns_service_ip
    service_cidr       = var.service_cidr
    docker_bridge_cidr = "172.17.0.1/16"
    network_plugin     = "azure"
    load_balancer_sku  = var.load_balancer_sku
    network_policy     = "calico"
  }

  addon_profile {
    oms_agent {
      enabled                    = true
      log_analytics_workspace_id = azurerm_log_analytics_workspace.k8s.id
    }
    azure_policy {
      enabled  = true
    }
  }

  tags = {
    Environment = var.environment
  }
}

data "azurerm_container_registry" "acr_repo" {
  name                = var.acr_name
  resource_group_name = var.acr_resource_group
  provider            = azurerm.acr
}

resource "azurerm_role_assignment" "acr_pullrole_cluster" {
  scope                 = data.azurerm_container_registry.acr_repo.id
  role_definition_name  = "AcrPull"
  principal_id          = azurerm_user_assigned_identity.aks_identity.principal_id
  provider              = azurerm.acr
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "management_vm" {
  scope                = azurerm_kubernetes_cluster.k8s.id
  role_definition_name = "Azure Kubernetes Service RBAC Cluster Admin"
  principal_id         = azurerm_linux_virtual_machine.management.identity.0.principal_id
  skip_service_principal_aad_check = true
}