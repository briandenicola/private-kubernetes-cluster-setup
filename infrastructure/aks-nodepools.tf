resource "azurerm_kubernetes_cluster_node_pool" "default_app_node_pool" {
  lifecycle {
    ignore_changes = [
      node_count
    ]
  }

  name                  = "apps"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.k8s.id
  vnet_subnet_id        = data.azurerm_subnet.k8s_nodes_subnet.id
  vm_size               = "Standard_D4ads_v5"
  enable_auto_scaling   = true
  mode                  = "User"
  os_sku                = "Mariner"
  os_disk_size_gb       = 100
  node_count            = 3
  min_count             = 3
  max_count             = 6
  kubelet_disk_type     = "Temporary"
  max_pods = 250
  upgrade_settings {
    max_surge           = "25%"
  }
}

# resource "azurerm_kubernetes_cluster_node_pool" "eshop_app_node_pool" {
#   lifecycle {
#     ignore_changes = [
#       node_count
#     ]
#   }

#   name                  = "eshop"
#   kubernetes_cluster_id = azurerm_kubernetes_cluster.k8s.id
#   vnet_subnet_id        = data.azurerm_subnet.k8s_nodes_subnet.id
#   vm_size               = "Standard_B4ms"
#   enable_auto_scaling   = true
#   mode                  = "User"
#   os_sku                = "Mariner"
#   os_disk_size_gb       = 100
#   node_count            = 3
#   min_count             = 3
#   max_count             = 6
#   kubelet_disk_type     = "Temporary"
#   max_pods              = 250

#   upgrade_settings {
#     max_surge = "25%"
#   }

#   node_taints = ["reservedFor=eShopOnDapr:NoSchedule"]
# }

# resource "azurerm_kubernetes_cluster_node_pool" "traduire_app_node_pool" {
#   lifecycle {
#     ignore_changes = [
#       node_count
#     ]
#   }
#   name                  = "traduire"
#   kubernetes_cluster_id = azurerm_kubernetes_cluster.k8s.id
#   vnet_subnet_id        = data.azurerm_subnet.k8s_nodes_subnet.id
#   vm_size               = "Standard_B4ms"
#   enable_auto_scaling   = true
#   mode                  = "User"
#   os_sku                = "Mariner"
#   os_disk_size_gb       = 100
#   node_count            = 3
#   min_count             = 3
#   max_count             = 6
#   kubelet_disk_type     = "Temporary"
#   max_pods              = 250

#   upgrade_settings {
#     max_surge         = "25%"
#   }

#   node_taints           = [ "app=traduire:NoSchedule" ]
# }
