data "azurerm_kubernetes_service_versions" "current" {
  location = azurerm_resource_group.k8s.location
}

resource "azurerm_kubernetes_cluster" "k8s" {
  depends_on = [
    azurerm_role_assignment.aks_role_assignemnt_dns,
    azurerm_role_assignment.aks_role_assignemnt_msi
  ]
  lifecycle {
    ignore_changes = [
      default_node_pool.0.node_count,
    ]
  }
  name                                = var.cluster_name
  location                            = azurerm_resource_group.k8s.location
  resource_group_name                 = azurerm_resource_group.k8s.name
  node_resource_group                 = "${azurerm_resource_group.k8s.name}_nodes"
  dns_prefix_private_cluster          = var.cluster_name
  kubernetes_version                  = data.azurerm_kubernetes_service_versions.current.latest_version
  private_cluster_enabled             = true
  private_dns_zone_id                 = data.azurerm_private_dns_zone.aks_private_zone.id
  automatic_channel_upgrade           = "patch"
  local_account_disabled              = true
  sku_tier                            = "Paid"
  azure_policy_enabled                = true
  open_service_mesh_enabled           = var.open_service_mesh_enabled
  oidc_issuer_enabled                 = true 
  role_based_access_control_enabled   = true

  azure_active_directory_role_based_access_control {
    managed                 = true
    azure_rbac_enabled      = true
    tenant_id               = data.azurerm_client_config.current.tenant_id
    admin_group_object_ids  = [ var.azure_rbac_group_object_id ] 
  }

  identity {
    type                      = "UserAssigned"
    identity_ids              = [ azurerm_user_assigned_identity.aks_identity.id ]
  }

  kubelet_identity {
    client_id                 = azurerm_user_assigned_identity.aks_kubelet_identity.client_id
    object_id                 = azurerm_user_assigned_identity.aks_kubelet_identity.principal_id
    user_assigned_identity_id = azurerm_user_assigned_identity.aks_kubelet_identity.id
  }

  default_node_pool  {
    name                    = "default"
    node_count              = var.agent_count
    zones                   = ["1", "2", "3"]
    vm_size                 = var.vm_size
    os_disk_size_gb         = 40
    os_disk_type            = "Ephemeral"
    os_sku                  = "CBLMariner"
    vnet_subnet_id          = data.azurerm_subnet.k8s_subnet.id
    type                    = "VirtualMachineScaleSets"
    enable_auto_scaling     = "true"
    min_count               = 1
    max_count               = 5
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

  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.k8s.id
  }

  microsoft_defender {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.k8s.id
  }

  key_vault_secrets_provider {
    secret_rotation_enabled = true
    secret_rotation_interval = "2m"
  }

  tags = {
    ServiceMeshType = var.service_mesh_type
  }
}