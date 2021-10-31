resource "random_id" "management_vm_id" {
     byte_length = 4
 }

resource "azurerm_network_interface" "management" {
  name                = "bjd${random_id.management_vm_id.id}-nic"
  location            = azurerm_resource_group.jumpbox.location
  resource_group_name = azurerm_resource_group.jumpbox.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.management_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "management" {
  name                = "bjd${random_id.management_vm_id.id}"
  resource_group_name = azurerm_resource_group.jumpbox.name
  location            = azurerm_resource_group.jumpbox.location
  size                = "Standard_B2ms"
  admin_username      = "manager"
  network_interface_ids = [
    azurerm_network_interface.management.id,
  ]

  identity {
    type = "SystemAssigned"
  }

  admin_ssh_key {
    username   = "manager"
    public_key = var.ssh_public_key
  }

  os_disk {
    name                 = "bjd${random_id.management_vm_id.id}-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

resource "azurerm_role_assignment" "management_vm" {
  scope                = azurerm_kubernetes_cluster.k8s.id
  role_definition_name = "Azure Kubernetes Service RBAC Cluster Admin"
  principal_id         = azurerm_linux_virtual_machine.management.identity.0.principal_id
  skip_service_principal_aad_check = true
}


resource "azurerm_role_assignment" "management_vm_aks_read" {
  scope                = azurerm_kubernetes_cluster.k8s.id
  role_definition_name = "Azure Kubernetes Service Cluster User Role"
  principal_id         = azurerm_linux_virtual_machine.management.identity.0.principal_id
  skip_service_principal_aad_check = true
}