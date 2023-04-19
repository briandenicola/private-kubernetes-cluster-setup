resource "azapi_update_resource" "this" {
  depends_on = [
    azurerm_kubernetes_cluster.k8s,
    azurerm_kubernetes_cluster_node_pool.eshop_app_node_pool,
    //azurerm_kubernetes_cluster_node_pool.default_app_node_pool,
    //azurerm_kubernetes_cluster_node_pool.traduire_app_node_pool
  ]

  type        = "Microsoft.ContainerService/managedClusters@2023-01-01-preview"
  resource_id = azurerm_kubernetes_cluster.k8s.id

  body = jsonencode({
    properties = {
      podIdentityProfile = {
        enabled = true
      }
      autoUpgradeProfile = {
        nodeOSUpgradeChannel = "NodeImage"
      }   
    }
  })
}

data "azapi_resource" "weekend_utc" {
  type = "Microsoft.Maintenance/publicMaintenanceConfigurations@2021-09-01-preview"
  name = "aks-mrp-cfg-weekend_utc-6"
  parent_id = "/subscriptions/${data.azurerm_subscription.current.subscription_id}"
}

resource "azapi_resource" "maintenance_window" {

  depends_on = [
    azurerm_kubernetes_cluster.k8s,
    azurerm_kubernetes_cluster_node_pool.eshop_app_node_pool,
    //azurerm_kubernetes_cluster_node_pool.default_app_node_pool,
    //azurerm_kubernetes_cluster_node_pool.traduire_app_node_pool
  ]

  type = "Microsoft.Maintenance/configurationAssignments@2022-07-01-preview"
  name = "maintenance-window"
  location = var.location
  parent_id = azurerm_kubernetes_cluster.k8s.id
  body = jsonencode({
    properties = {
      maintenanceConfigurationId = data.azapi_resource.weekend_utc.id
      resourceId =  azurerm_kubernetes_cluster.k8s.id
    }
  })
}