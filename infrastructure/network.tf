data "azurerm_virtual_network" "vnet" {
  name                = var.k8s_vnet
  resource_group_name = var.k8s_vnet_resource_group_name
}

data "azurerm_subnet" "k8s_subnet" {
  name                 = var.k8s_subnet
  virtual_network_name = var.k8s_vnet
  resource_group_name  = var.k8s_vnet_resource_group_name
}

data "azurerm_subnet" "management_subnet" {
  name                 = "Servers"
  virtual_network_name = var.k8s_vnet
  resource_group_name  = var.k8s_vnet_resource_group_name
}

data "azurerm_subnet" "private_endpoint_subnet" {
  name                 = "private-endpoints"
  virtual_network_name = var.k8s_vnet
  resource_group_name  = var.k8s_vnet_resource_group_name
}

data "azurerm_private_dns_zone" "aks_private_zone" {
  name                      = "privatelink.${var.location}.azmk8s.io"
  resource_group_name       = var.dns_resource_group_name
  provider                  = azurerm.core
}

data "azurerm_private_dns_zone" "privatelink_vaultcore_azure_net" {
  name                      = "privatelink.vaultcore.azure.net"
  resource_group_name       = var.dns_resource_group_name
  provider                  = azurerm.core
}
