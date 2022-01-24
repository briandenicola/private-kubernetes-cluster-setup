
data "azurerm_container_registry" "acr_repo" {
  name                = var.acr_name
  resource_group_name = var.acr_resource_group
  provider            = azurerm.core
}

