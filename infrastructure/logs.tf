resource "azurerm_log_analytics_workspace" "k8s" {
  name                = "${var.cluster_name}-logs"
  location            = azurerm_resource_group.k8s.location
  resource_group_name = azurerm_resource_group.k8s.name
  sku                 = "PerGB2018"
}

resource "azurerm_log_analytics_solution" "k8s" {
  solution_name         = "ContainerInsights"
  location              = azurerm_resource_group.k8s.location
  resource_group_name   = azurerm_resource_group.k8s.name
  workspace_resource_id = azurerm_log_analytics_workspace.k8s.id
  workspace_name        = azurerm_log_analytics_workspace.k8s.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }
}

resource "azurerm_application_insights" "k8s" {
  name                = "${var.cluster_name}-appinsights"
  location            = azurerm_resource_group.k8s.location
  resource_group_name = azurerm_resource_group.k8s.name
  workspace_id        = azurerm_log_analytics_workspace.k8s.id
  application_type    = "web"
}

locals {
  container_insights_tables = ["ContainerLogV2"]
}

resource "azapi_resource_action" "k8s" {
  for_each    = toset(local.container_insights_tables)
  type        = "Microsoft.OperationalInsights/workspaces/tables@2022-10-01"
  resource_id = "${azurerm_log_analytics_workspace.k8s.id}/tables/${each.key}"
  method      = "PATCH"

  body = jsonencode({
    properties = {
      plan = "Basic"
    }
  })

  depends_on = [
    azurerm_log_analytics_solution.k8s,
  ]
}
