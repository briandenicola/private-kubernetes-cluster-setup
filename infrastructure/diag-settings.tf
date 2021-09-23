resource "azurerm_monitor_diagnostic_setting" "aks" {
  name                        = "diag"
  target_resource_id          = azurerm_kubernetes_cluster.k8s.id
  log_analytics_workspace_id  = azurerm_log_analytics_workspace.k8s.id

  log {
    category = "kube-apiserver"
    enabled  = true
  }

  log {
    category = "kube-audit"
    enabled  = true
  }

  log {
    category = "kube-audit-admin"
    enabled  = true
  }

  log {
    category = "kube-controller-manager"
    enabled  = true
  }
  
  log {
    category = "kube-scheduler"
    enabled  = true
  }
  
  log {
    category = "cluster-autoscaler"
    enabled  = true
  }

  log {
    category = "guard"
    enabled  = true
  }

  metric {
    category = "AllMetrics"
  }
}