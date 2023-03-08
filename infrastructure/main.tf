data "azurerm_client_config" "current" {}
data "azurerm_subscription" "current" {}

resource "azurerm_resource_group" "k8s" {
  name     = var.resource_group_name
  location = var.location
  tags = {
    Application = "eshopOnDapr"
    Components  = "aks; key vault; istio"
    DeployedOn  = timestamp()
  }
}

locals {
  ingress_identity      = "${var.service_mesh_type}-ingress-sa-identity"
  zipkin_identity       = "zipkin-sa-identity"
}