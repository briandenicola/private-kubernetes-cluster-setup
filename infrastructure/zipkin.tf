resource "kubernetes_namespace" "zipkin" {
  depends_on = [
    azurerm_kubernetes_cluster.k8s
  ]
  metadata {
    name = var.zipkin_namespace
    labels = {
      "istio-injection" = "enabled"
    }
  }
}

resource "kubernetes_service_account" "aks_zipkin_identity" {
  depends_on = [
    kubernetes_namespace.zipkin,
    kubernetes_secret.aks_zipkin_identity
  ]
  
  metadata {
    name      = local.zipkin_identity
    namespace = var.zipkin_namespace

    annotations = {
      "azure.workload.identity/client-id" = azurerm_user_assigned_identity.aks_zipkin_identity.client_id
      "azure.workload.identity/tenant-id" = data.azurerm_client_config.current.tenant_id
    }

    labels      = {
      "azure.workload.identity/use"       = "true"
    } 
  }
  secret {
    name = "${kubernetes_secret.aks_zipkin_identity.metadata.0.name}"
  }
}

resource "kubernetes_secret" "aks_zipkin_identity" {
  depends_on = [
    kubernetes_namespace.zipkin
  ]
  
  metadata {
    name      = local.zipkin_identity
    namespace = var.zipkin_namespace
  }
}