resource "azapi_resource" "azure_monitor_workspace" {
  type      = "microsoft.monitor/accounts@2021-06-03-preview"
  name      = "${var.cluster_name}-workspace"
  parent_id = azurerm_resource_group.k8s.id
  location = azurerm_resource_group.k8s.location

  body = jsonencode({
  })
}

locals {
  am_workspace_id = "${data.azurerm_subscription.current.id}/resourcegroups/${azurerm_resource_group.k8s.name}/providers/microsoft.monitor/accounts/${var.cluster_name}-workspace"
}

resource "azurerm_monitor_data_collection_endpoint" "prometheus" {
  name                          = "${var.cluster_name}-prometheus-datacollection-ep"
  resource_group_name           = azurerm_resource_group.k8s.name
  location                      = azurerm_resource_group.k8s.location
  kind                          = "Linux"
  public_network_access_enabled = true
}

resource "azurerm_monitor_data_collection_rule" "prometheus" {
  name                = "${var.cluster_name}-prometheus-datacollection-rules"
  resource_group_name = azurerm_resource_group.k8s.name
  location            = azurerm_resource_group.k8s.location
  depends_on = [
    azapi_resource.azure_monitor_workspace,
    azurerm_monitor_data_collection_endpoint.prometheus
  ]
  kind                        = "Linux"
  data_collection_endpoint_id = azurerm_monitor_data_collection_endpoint.prometheus.id

  destinations {
    monitor_account {
      monitor_account_id = local.am_workspace_id
      name               = "MonitoringAccount1"
    }
  }

  data_flow {
    destinations = ["MonitoringAccount1"]
    streams      = ["Microsoft-PrometheusMetrics"]
  }

  data_sources {
    prometheus_forwarder {
      name    = "PrometheusDataSource"
      streams = ["Microsoft-PrometheusMetrics"]
    }
  }
}

resource "azapi_resource" "monitor_datacollection_rule_associations" {
  type = "Microsoft.Insights/dataCollectionRuleAssociations@2021-09-01-preview"
  name = "${var.cluster_name}-prometheus-datacollection-rules-association"
  parent_id = azurerm_kubernetes_cluster.k8s.id
  body = jsonencode({
    properties = {
      dataCollectionRuleId = azurerm_monitor_data_collection_rule.prometheus.id
    }
  })
}