data "azurerm_client_config" "current" {}
data "azurerm_subscription" "current" {}

resource "azurerm_resource_group" "k8s" {
  name     = var.resource_group_name
  location = var.location
  tags = {
    Application = "Private AKS Kubernetes Demo"
    Components  = "aks; key vault; istio"
    DeployedOn  = timestamp()
  }
}

locals {
  ingress_identity      = "${var.service_mesh_type}-ingress-sa-identity"
  otel_identity         = "otel-sa-identity"
  flux_repository       = "https://github.com/briandenicola/private-kubernetes-cluster-setup"
  flux_branch           = "cluster/default_cluster_name"
  app_path              = "./cluster-manifests"  
  crd_path              = "./cluster-manifests/common/customresourcedefinitions"
  istio_cfg_path        = "./cluster-manifests/common/istio/configuration"
  istio_gw_path         = "./cluster-manifests/common/istio/gateway"
}