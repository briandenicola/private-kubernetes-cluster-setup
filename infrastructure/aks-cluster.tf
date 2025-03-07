data "azurerm_kubernetes_service_versions" "current" {
  location = azurerm_resource_group.k8s.location
}

locals {
  kubernetes_version = data.azurerm_kubernetes_service_versions.current.versions[length(data.azurerm_kubernetes_service_versions.current.versions) - 2]
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

  name                              = var.cluster_name
  location                          = azurerm_resource_group.k8s.location
  resource_group_name               = azurerm_resource_group.k8s.name
  node_resource_group               = replace(var.resource_group_name, "_RG", "_Nodes_RG")
  dns_prefix_private_cluster        = var.cluster_name
  kubernetes_version                = local.kubernetes_version
  private_cluster_enabled           = true
  private_dns_zone_id               = data.azurerm_private_dns_zone.aks_private_zone.id
  sku_tier                          = "Standard"
  automatic_upgrade_channel         = "patch"
  node_os_upgrade_channel           = "NodeImage"
  local_account_disabled            = true
  azure_policy_enabled              = true
  open_service_mesh_enabled         = false
  run_command_enabled               = false
  oidc_issuer_enabled               = true
  workload_identity_enabled         = true
  role_based_access_control_enabled = true
  image_cleaner_enabled             = true
  image_cleaner_interval_hours      = 48
  cost_analysis_enabled             = true

  # api_server_access_profile {
  #   vnet_integration_enabled = true
  #   subnet_id                = data.azurerm_subnet.k8s_apiserver_subnet.id
  # }

  azure_active_directory_role_based_access_control {
    azure_rbac_enabled = true
    tenant_id          = data.azurerm_client_config.current.tenant_id
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aks_identity.id]
  }

  kubelet_identity {
    client_id                 = azurerm_user_assigned_identity.aks_kubelet_identity.client_id
    object_id                 = azurerm_user_assigned_identity.aks_kubelet_identity.principal_id
    user_assigned_identity_id = azurerm_user_assigned_identity.aks_kubelet_identity.id
  }

  default_node_pool {
    name                         = "system"
    node_count                   = var.agent_count
    zones                        = var.location == "northcentralus" ? null : ["1", "2", "3"]
    vm_size                      = var.vm_size
    os_disk_size_gb              = 127
    os_disk_type                 = "Ephemeral"
    os_sku                       = "AzureLinux"
    vnet_subnet_id               = data.azurerm_subnet.k8s_nodes_subnet.id
    type                         = "VirtualMachineScaleSets"
    auto_scaling_enabled         = "true"
    min_count                    = 1
    max_count                    = 5
    kubelet_disk_type            = "Temporary"
    only_critical_addons_enabled = true
    max_pods                     = 250

    upgrade_settings {
      max_surge = "33%"
    }
  }

  network_profile {
    dns_service_ip      = var.dns_service_ip
    service_cidr        = var.service_cidr
    pod_cidr            = var.pod_cidr
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
    load_balancer_sku   = "standard"
    network_data_plane  = "cilium"
    network_policy      = "cilium"
    outbound_type       = "userDefinedRouting"
  }

  maintenance_window_auto_upgrade {
    frequency   = "Weekly"
    interval    = 1
    duration    = 4
    day_of_week = "Friday"
    utc_offset  = "-06:00"
    start_time  = "20:00"
  }

  maintenance_window_node_os {
    frequency   = "Weekly"
    interval    = 1
    duration    = 4
    day_of_week = "Saturday"
    utc_offset  = "-06:00"
    start_time  = "20:00"
  }

  auto_scaler_profile {
    max_unready_nodes = "1"
  }

  workload_autoscaler_profile {
    keda_enabled = true
  }

  storage_profile {
    blob_driver_enabled = true
    disk_driver_enabled = true
    file_driver_enabled = true
  }

  oms_agent {
    log_analytics_workspace_id      = azurerm_log_analytics_workspace.k8s.id
    msi_auth_for_monitoring_enabled = true
  }

  microsoft_defender {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.k8s.id
  }

  monitor_metrics {
  }

  key_vault_secrets_provider {
    secret_rotation_enabled  = true
    secret_rotation_interval = "2m"
  }

  service_mesh_profile {
    mode                             = "Istio"
    internal_ingress_gateway_enabled = true
    revisions                        = local.istio_version
  }

  tags = {
    ServiceMeshType = var.service_mesh_type
  }
}
