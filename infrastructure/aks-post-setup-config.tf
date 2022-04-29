resource "azapi_update_resource" "this" {
  depends_on = [
    azurerm_kubernetes_cluster.k8s,
    azurerm_kubernetes_cluster_node_pool.eshop_app_node_pool
    //azurerm_kubernetes_cluster_node_pool.traduire_app_node_pool
  ]

  type        = "Microsoft.ContainerService/managedClusters@2021-07-01"
  resource_id = azurerm_kubernetes_cluster.k8s.id

  body = jsonencode({
    properties = {
      podIdentityProfile = {
        enabled = true
      }
    }
  })
}