resource "azurerm_role_assignment" "aks_role_assignemnt_msi" {
  scope                     = azurerm_user_assigned_identity.aks_kubelet_identity.id
  role_definition_name      = "Managed Identity Operator"
  principal_id              = azurerm_user_assigned_identity.aks_identity.principal_id
  skip_service_principal_aad_check = true 
}

resource "azurerm_role_assignment" "aks_role_assignemnt_ingress" {
  scope                     = azurerm_user_assigned_identity.aks_service_mesh_identity.id
  role_definition_name      = "Managed Identity Operator"
  principal_id              = azurerm_user_assigned_identity.aks_identity.principal_id
  skip_service_principal_aad_check = true 
}