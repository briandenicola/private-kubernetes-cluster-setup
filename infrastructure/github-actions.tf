data "azurerm_user_assigned_identity" "github_actions" {
    name                = var.github_actions_identity_name
    resource_group_name = var.github_actions_identity_resource_group
}

resource "azurerm_role_assignment" "github_actions" {
    scope                = azurerm_kubernetes_cluster.k8s.id
    role_definition_name = "Azure Kubernetes Service RBAC Cluster Admin"
    principal_id         = data.azurerm_user_assigned_identity.github_actions.principal_id
    skip_service_principal_aad_check = true
}