resource "azurerm_user_assigned_identity" "aks_identity" {
  name                = "${var.cluster_name}-cluster-identity"
  resource_group_name = azurerm_resource_group.k8s.name
  location            = azurerm_resource_group.k8s.location
}

resource "azurerm_user_assigned_identity" "aks_kubelet_identity" {
  name                = "${var.cluster_name}-kubelet-identity"
  resource_group_name = azurerm_resource_group.k8s.name
  location            = azurerm_resource_group.k8s.location
}

resource "azurerm_user_assigned_identity" "aks_service_mesh_ingress_identity" {
  name                = local.ingress_identity
  resource_group_name = azurerm_resource_group.k8s.name
  location            = azurerm_resource_group.k8s.location
}

resource "azurerm_federated_identity_credential" "aks_service_mesh_ingress_identity" {
  name                = local.ingress_identity
  resource_group_name = azurerm_resource_group.k8s.name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = azurerm_kubernetes_cluster.k8s.oidc_issuer_url
  parent_id           = azurerm_user_assigned_identity.aks_service_mesh_ingress_identity.id
  subject             = "system:serviceaccount:${var.ingress_namespace}:${local.ingress_identity}"
}

resource "azurerm_user_assigned_identity" "aks_zipkin_identity" {
  name                = local.otel_identity
  resource_group_name = azurerm_resource_group.k8s.name
  location            = azurerm_resource_group.k8s.location
}

resource "azurerm_federated_identity_credential" "aks_zipkin_identity" {
  name                = local.otel_identity
  resource_group_name = azurerm_resource_group.k8s.name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = azurerm_kubernetes_cluster.k8s.oidc_issuer_url
  parent_id           = azurerm_user_assigned_identity.aks_zipkin_identity.id
  subject             = "system:serviceaccount:${var.zipkin_namespace}:${local.otel_identity}"
}
