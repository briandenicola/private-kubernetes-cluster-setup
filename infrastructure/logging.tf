resource "azurerm_log_analytics_workspace" "k8s" {
  name                          = "${var.cluster_name}-logs"
  location                      = azurerm_resource_group.k8s.location
  resource_group_name           = azurerm_resource_group.k8s.name
  sku                           = "PerGB2018"
  daily_quota_gb                = 5
  local_authentication_disabled = true
}

resource "azurerm_application_insights" "k8s" {
  name                = "${var.cluster_name}-appinsights"
  location            = azurerm_resource_group.k8s.location
  resource_group_name = azurerm_resource_group.k8s.name
  workspace_id        = azurerm_log_analytics_workspace.k8s.id
  application_type    = "web"
  local_authentication_disabled = false
}

resource "azurerm_monitor_data_collection_rule" "log_analytics" {
  name                = "${var.cluster_name}-law-datacollection-rules"
  location            = azurerm_resource_group.k8s.location
  resource_group_name = azurerm_resource_group.k8s.name
  depends_on = [
    azurerm_log_analytics_workspace.k8s
  ]

  destinations {
    log_analytics {
      workspace_resource_id = azurerm_log_analytics_workspace.k8s.id
      name                  = "ciworkspace"
    }
  }

  data_flow {
    streams      = ["Microsoft-ContainerInsights-Group-Default"]
    destinations = ["ciworkspace"]
  }

  data_sources {
    extension {
      streams        = ["Microsoft-ContainerInsights-Group-Default"]
      extension_name = "ContainerInsights"
      name           = "ContainerInsightsExtension"
    }
  }
}

resource "azapi_resource" "log_analytics_datacollection_rule_associations" {
  type      = "Microsoft.Insights/dataCollectionRuleAssociations@2021-09-01-preview"
  name      = "${var.cluster_name}-law-datacollection-rules-association"
  parent_id = azurerm_kubernetes_cluster.k8s.id
  body = jsonencode({
    properties = {
      dataCollectionRuleId = azurerm_monitor_data_collection_rule.log_analytics.id
    }
  })
}
