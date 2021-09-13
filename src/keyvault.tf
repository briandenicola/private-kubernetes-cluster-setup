resource "azurerm_key_vault" "k8s" {
  name                        = "${var.cluster_name}-kv"
  resource_group_name         = azurerm_resource_group.k8s.name
  location                    = azurerm_resource_group.k8s.location
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"

  network_acls {
    bypass                    = "AzureServices"
    default_action            = "Deny"
  }

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = azurerm_user_assigned_identity.aks_identity.principal_id 

    secret_permissions = [
      "list",
      "get"
    ]
  }

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id 

    secret_permissions = [
      "set",
      "get",
      "delete",
      "list"
    ]
  }
}

resource "azurerm_private_endpoint" "key_vault" {
  name                      = "${var.cluster_name}-kv-endpoint"
  resource_group_name       = azurerm_resource_group.k8s.name
  location                  = azurerm_resource_group.k8s.location
  subnet_id                 = data.azurerm_subnet.private_endpoint_subnet.id

  private_service_connection {
    name                           = "kv-${var.cluster_name}-kv-endpoint"
    private_connection_resource_id = azurerm_key_vault.k8s.id
    subresource_names              = [ "vault" ]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                          = azurerm_private_dns_zone.privatelink_vaultcore_azure_net.name
    private_dns_zone_ids          = [ azurerm_private_dns_zone.privatelink_vaultcore_azure_net.id ]
  }
}
