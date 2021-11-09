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
    object_id = azurerm_user_assigned_identity.aks_ingress_identity.principal_id 

    secret_permissions = [
      "list",
      "get"
    ]
  
    certificate_permissions = [
      "list",
      "get"
    ]
  }

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id 

    key_permissions = [
      "get",
      "list",
      "create",
      "decrypt",
      "encrypt",
      "sign",
      "unwrapKey",
      "verify",
      "wrapKey",
    ]

    certificate_permissions = [
      "create",
      "get",
      "delete",
      "list",
      "backup",
      "deleteissuers",
      "GetIssuers", 
      "Import",
      "ListIssuers", 
      "ManageContacts",
      "ManageIssuers",
      "Purge",
      "Recover",
      "Restore",
      "SetIssuers",
      "Update"
    ]

    secret_permissions = [
      "set",
      "get",
      "delete",
      "list",
      "backup",
      "purge",
      "recover",
      "restore"
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
    name                          = data.azurerm_private_dns_zone.privatelink_vaultcore_azure_net.name
    private_dns_zone_ids          = [ data.azurerm_private_dns_zone.privatelink_vaultcore_azure_net.id ]
  }
}

resource "azurerm_key_vault_certificate" "k8s" {
  name         = var.certificate_name
  key_vault_id = azurerm_key_vault.k8s.id

  depends_on = [
    azurerm_private_endpoint.key_vault
  ]

  certificate {
    contents = var.certificate_base64_encoded
    password = var.certificate_password
  }

  certificate_policy {
    issuer_parameters {
      name = "Self"
    }

    key_properties {
      exportable = true
      key_size   = 2048
      key_type   = "RSA"
      reuse_key  = false
    }

    secret_properties {
      content_type = "application/x-pkcs12"
    }
  }
}

resource "azurerm_key_vault_secret" "zipkin" {
  name         = "otel-collector-config"
  value        = base64encode(templatefile(file("zipkin-config.tpl"), {app_insight_key = "${azurerm_application_insights.k8s.instrumentation_key}"}))
  key_vault_id = azurerm_key_vault.k8s.id

  depends_on = [
    azurerm_private_endpoint.key_vault
  ]
} 
