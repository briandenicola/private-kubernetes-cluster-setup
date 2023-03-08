resource "kubernetes_namespace" "istio-gateways" {
  depends_on = [
    azurerm_kubernetes_cluster.k8s
  ]
  metadata {
    name = var.ingress_namespace
    labels = {
      "istio-injection" = "enabled"
    }
  }
}

resource "kubernetes_service_account" "aks_service_mesh_ingress_identity" {
  depends_on = [
    kubernetes_namespace.istio-gateways,
    kubernetes_secret.aks_service_mesh_ingress_identity
  ]
  
  metadata {
    name      = local.ingress_identity
    namespace = var.ingress_namespace
    annotations = {
      "azure.workload.identity/client-id" = azurerm_user_assigned_identity.aks_service_mesh_ingress_identity.client_id
      "azure.workload.identity/tenant-id" = data.azurerm_client_config.current.tenant_id
    }
    labels      = {
      "azure.workload.identity/use"       = "true"
    } 
  }
  secret {
    name = "${kubernetes_secret.aks_service_mesh_ingress_identity.metadata.0.name}"
  }
}

resource "kubernetes_secret" "aks_service_mesh_ingress_identity" {
  depends_on = [
    kubernetes_namespace.istio-gateways 
  ]
  
  metadata {
    name      = local.ingress_identity
    namespace = var.ingress_namespace
  }
}