data "azurerm_kubernetes_service_versions" "current" {
  location = azurerm_resource_group.k8s.location
}

resource "azurerm_kubernetes_cluster" "k8s" {
  depends_on = [
    azurerm_role_assignment.aks_role_assignemnt_dns,
    azurerm_role_assignment.aks_role_assignemnt_msi
  ]
  name                      = var.cluster_name
  location                  = azurerm_resource_group.k8s.location
  resource_group_name       = azurerm_resource_group.k8s.name
  node_resource_group       = "${azurerm_resource_group.k8s.name}_nodes"
  dns_prefix_private_cluster = var.cluster_name
  kubernetes_version        = data.azurerm_kubernetes_service_versions.current.latest_version
  private_cluster_enabled   = "true"
  private_dns_zone_id       = data.azurerm_private_dns_zone.aks_private_zone.id
  automatic_channel_upgrade = "patch"
  local_account_disabled    = "true"
  sku_tier                  = "Paid"

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

  kubelet_identity {
    client_id                 = azurerm_user_assigned_identity.aks_kubelet_identity.client_id
    object_id                 = azurerm_user_assigned_identity.aks_kubelet_identity.principal_id
    user_assigned_identity_id = azurerm_user_assigned_identity.aks_kubelet_identity.id
  }

  default_node_pool  {
    name                    = "default"
    node_count              = var.agent_count
    availability_zones      = ["1", "2", "3"]
    vm_size                 = var.vm_size
    os_disk_size_gb         = 30
    os_disk_type            = "Ephemeral"
    vnet_subnet_id          = data.azurerm_subnet.k8s_subnet.id
    type                    = "VirtualMachineScaleSets"
    enable_auto_scaling     = "true"
    min_count               = 1
    max_count               = 3
  }

  network_profile {
    dns_service_ip     = var.dns_service_ip
    service_cidr       = var.service_cidr
    docker_bridge_cidr = "172.17.0.1/16"
    network_plugin     = "azure"
    load_balancer_sku  = var.load_balancer_sku
    outbound_type      = "userDefinedRouting"
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

resource "null_resource" "config_setup" {
  provisioner "local-exec" {
    command = "./post-creation-configuration.sh"
    interpreter = ["bash"]

    environment = {
      CLUSTER_NAME = "${var.cluster_name}"
      RG = "${azurerm_resource_group.k8s.name}"
    }
  }
}