agent_count                            = 3
k8s_vnet_resource_group_name           = "Apps02_Network_RG"
k8s_vnet                               = "DevSub02-Vnet-001"
k8s_nodes_subnet                       = "kubernetes-nodes"
k8s_pods_subnet                        = "kubernetes-pods"
dns_service_ip                         = "100.66.0.10"
service_cidr                           = "100.66.0.0/16"
core_subscription                      = "ccfc5dda-43af-4b5e-8cc2-1dda18f2382e"
dns_resource_group_name                = "Core_DNS_RG"
acr_resource_group                     = "Core_ContainerRepo_RG"
acr_name                               = "bjdcsa"
azure_rbac_group_object_id             = "21a14843-baa7-43c3-89ea-64505626bc82"
github_actions_identity_name           = "gha-identity"
github_actions_identity_resource_group = "Core_DevOps_RG"
certificate_name                       = "wildcard-bjdazure-tech"
vm_size                                = "Standard_B4ms"
