
data "azurerm_container_registry" "acr_repo" {
  name                = var.acr_name
  resource_group_name = var.acr_resource_group
  provider            = azurerm.acr
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
  principal_id         = azurerm_kubernetes_cluster.k8s.kubelet_identity.0.object_id 
  provider             = azurerm.acr
  skip_service_principal_aad_check = true
}
