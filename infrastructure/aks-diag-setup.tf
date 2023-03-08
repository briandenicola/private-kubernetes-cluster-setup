resource "azurerm_monitor_diagnostic_setting" "aks" {
  name                       = "${var.cluster_name}-diag"
  target_resource_id         = azurerm_kubernetes_cluster.k8s.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.k8s.id

  enabled_log  {
    category = "kube-apiserver"
  }

  enabled_log  {
    category = "kube-audit"
  }

  enabled_log  {
    category = "kube-audit-admin"
  }

  enabled_log  {
    category = "kube-controller-manager"
  }

  enabled_log  {
    category = "kube-scheduler"
  }

  enabled_log  {
    category = "cluster-autoscaler"
  }

  enabled_log  {
    category = "guard"
  }

  metric {
    category = "AllMetrics"
  }
}
