data "azurerm_kubernetes_service_versions" "current" {
  location = azurerm_resource_group.k8s.location
}

resource "azurerm_kubernetes_cluster" "k8s" {
  depends_on = [
    azurerm_role_assignment.aks_role_assignemnt_dns,
    azurerm_role_assignment.aks_role_assignemnt_msi,
    azurerm_role_assignment.aks_role_assignemnt_nework,
    azurerm_role_assignment.aks_role_assignemnt_nework_kubelet
  ]
  name                      = var.cluster_name
  location                  = azurerm_resource_group.k8s.location
  resource_group_name       = azurerm_resource_group.k8s.name
  node_resource_group       = "${azurerm_resource_group.k8s.name}_nodes"
  dns_prefix_private_cluster = var.cluster_name
  private_dns_zone_id       = data.azurerm_private_dns_zone.aks_private_zone.id
  kubernetes_version        = data.azurerm_kubernetes_service_versions.current.latest_version
  private_cluster_enabled   = "true"
  automatic_channel_upgrade = "rapid"

  role_based_access_control {
    enabled = "true"
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
    type                    = "VirtualMachineScaleSets"
    vnet_subnet_id          = data.azurerm_subnet.k8s_subnet.id
    enable_auto_scaling     = "true"
    min_count               = 1
    max_count               = 3
  }

  network_profile {
    dns_service_ip     = var.dns_service_ip
    service_cidr       = var.service_cidr
    docker_bridge_cidr = "172.17.0.1/16"
    pod_cidr           = var.pod_cidr
    network_plugin     = "kubenet"
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
      enabled                    = false
    }
  }

  tags = {
    Environment = var.environment
  }
}