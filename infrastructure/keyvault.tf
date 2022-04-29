resource "azurerm_key_vault" "k8s" {
  name                        = "${var.cluster_name}-kv"
  resource_group_name         = azurerm_resource_group.k8s.name
  location                    = azurerm_resource_group.k8s.location
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  enable_rbac_authorization   = true

  sku_name = "standard"

  network_acls {
    bypass                    = "AzureServices"
    default_action            = "Deny"
  }
}

resource "azurerm_private_endpoint" "key_vault" {
  name                        = "${var.cluster_name}-kv-endpoint"
  resource_group_name         = azurerm_resource_group.k8s.name
  location                    = azurerm_resource_group.k8s.location
  subnet_id                   = data.azurerm_subnet.private_endpoint_subnet.id
  
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
    azurerm_private_endpoint.key_vault,
    azurerm_kubernetes_cluster.k8s
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
  value        = replace(templatefile("zipkin-config.tpl", {app_insight_key = "${azurerm_application_insights.k8s.instrumentation_key}"}),"/\n/", "\n")
  key_vault_id = azurerm_key_vault.k8s.id

  depends_on = [
    azurerm_private_endpoint.key_vault,
    azurerm_kubernetes_cluster.k8s
  ]
} 

