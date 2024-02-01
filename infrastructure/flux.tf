resource "azurerm_kubernetes_cluster_extension" "flux" {
  depends_on = [
    azurerm_kubernetes_cluster_node_pool.default_app_node_pool,
    //azurerm_kubernetes_cluster_node_pool.istio_node_pool
  ]
  name           = "flux"
  cluster_id     = azurerm_kubernetes_cluster.k8s.id
  extension_type = "microsoft.flux"
}

resource "azurerm_kubernetes_flux_configuration" "flux_config" {
  depends_on = [
    azurerm_kubernetes_cluster_extension.flux
  ]

  name       = "aks-flux-extension"
  cluster_id = azurerm_kubernetes_cluster.k8s.id
  namespace  = "flux-system"
  scope      = "cluster"

  git_repository {
    url                      = local.flux_repository
    reference_type           = "branch"
    reference_value          = local.flux_branch
    timeout_in_seconds       = 600
    sync_interval_in_seconds = 30
  }

  kustomizations {
    name                       = "istio-crd"
    path                       = local.crd_path
    timeout_in_seconds         = 600
    sync_interval_in_seconds   = 120
    retry_interval_in_seconds  = 300
    garbage_collection_enabled = true
    depends_on                 = []
  }

  kustomizations {
    name                       = "istio-cfg"
    path                       = local.istio_cfg_path
    timeout_in_seconds         = 600
    sync_interval_in_seconds   = 120
    retry_interval_in_seconds  = 300
    garbage_collection_enabled = true
    depends_on = [
      "istio-crd"
    ]
  }

  kustomizations {
    name                       = "istio-gw"
    path                       = local.istio_gw_path
    timeout_in_seconds         = 600
    sync_interval_in_seconds   = 120
    retry_interval_in_seconds  = 300
    garbage_collection_enabled = true
    depends_on = [
      "istio-cfg"
    ]
  }

  kustomizations {
    name = "apps"
    path = local.app_path

    timeout_in_seconds         = 600
    sync_interval_in_seconds   = 120
    retry_interval_in_seconds  = 300
    garbage_collection_enabled = true
    depends_on = [
      "istio-cfg"
    ]
  }
}
