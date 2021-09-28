resource "azurerm_role_assignment" "aks_role_assignemnt_msi" {
  scope                     = azurerm_user_assigned_identity.aks_kubelet_identity.id
  role_definition_name      = "Managed Identity Operator"
  principal_id              = azurerm_user_assigned_identity.aks_identity.principal_id
  skip_service_principal_aad_check = true 
}

resource "azurerm_role_assignment" "aks_role_assignemnt_ingress" {
  scope                     = azurerm_user_assigned_identity.aks_ingress_identity.id
  role_definition_name      = "Managed Identity Operator"
  principal_id              = azurerm_user_assigned_identity.aks_identity.principal_id
  skip_service_principal_aad_check = true 
}

data "azurerm_user_assigned_identity" "chat_ee85e06" {
  name                = "${var.chat_ee85e06_identity}"
  resource_group_name = "${var.chat_ee85e06_resource_group}"
}

resource "azurerm_role_assignment" "aks_role_assignemnt_chat_ee85e06" {
  scope                     = data.azurerm_user_assigned_identity.chat_ee85e06.id
  role_definition_name      = "Managed Identity Operator"
  principal_id              = azurerm_user_assigned_identity.aks_identity.principal_id
  skip_service_principal_aad_check = true 
}
