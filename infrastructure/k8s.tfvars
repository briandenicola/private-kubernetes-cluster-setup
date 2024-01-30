agent_count                            = 3
location                               = "soutcentralus"
k8s_vnet_resource_group_name           = "Apps03_Network_RG"
k8s_vnet                               = "DevSub02-Vnet-002"
k8s_nodes_subnet                       = "kubernetes-nodes"
k8s_apiserver_subnet                   = "kubernetes-api-server"
dns_service_ip                         = "100.66.0.10"
service_cidr                           = "100.66.0.0/16"
pods_cidr                              = "100.99.0.0/16"
core_subscription                      = "ccfc5dda-43af-4b5e-8cc2-1dda18f2382e"
dns_resource_group_name                = "Core_DNS_RG"
acr_resource_group                     = "Core_ContainerRepo_RG"
acr_name                               = "bjdcsa"
github_actions_identity_name           = "gha-identity"
github_actions_identity_resource_group = "Core_DevOps_RG"
certificate_name                       = "wildcard-bjdazure-tech"
vm_size                                = "Standard_B4ms"
