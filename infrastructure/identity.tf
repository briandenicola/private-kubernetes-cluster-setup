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

resource "azurerm_role_assignment" "acr_pullrole_cluster" {
  scope                 = data.azurerm_container_registry.acr_repo.id
  role_definition_name  = "AcrPull"
  principal_id          = azurerm_user_assigned_identity.aks_identity.principal_id
  provider              = azurerm.acr
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "acr_pullrole_nodepool" {
  scope                = data.azurerm_container_registry.acr_repo.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.aks_kubelet_identity.principal_id
  provider             = azurerm.acr
  skip_service_principal_aad_check = true
}

