resource "azurerm_resource_group_template_deployment" "this" {
  depends_on = [
    null_resource.post_setup_config
  ]

  name                = "defender-for-cloud-update"
  resource_group_name = azurerm_resource_group.k8s.name
  deployment_mode     = "Incremental"
  parameters_content  = jsonencode({
    "aksCluster"      = {
      value = var.cluster_name
    },
    "logAnalyticsId"  = {
      value = azurerm_log_analytics_workspace.k8s.id
    }
  })
  template_content = <<TEMPLATE
    {
      "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
      "contentVersion": "1.0.0.0",
      "parameters": {
        "aksCluster": {
          "type": "string"
        },
        "logAnalyticsId": {
          "type": "string"
        }
      },
      "resources": [
        { 
          "type": "Microsoft.ContainerService/managedClusters", 
          "apiVersion": "2021-07-01", 
          "name": "[parameters('aksCluster')]", 
          "location": "[resourceGroup().location]",
          "properties": {
              "securityProfile": { 
                "azureDefender": { 
                  "enabled": true, 
                  "logAnalyticsWorkspaceResourceId": "[parameters('logAnalyticsId')]"
                }
              }
          }
        }
      ]
    }
TEMPLATE
}