variable "location" {
  description = "The Azure Region to deploy AKS"
  default     = "centralus"
}

variable "k8s_vnet_resource_group_name" {
  description = "The Resource Group name that contains the Vnet for AKS"
}

variable "k8s_subnet" {
  description = "The subnet name where AKS will be deployed to"
}

variable "k8s_vnet" {
  description = "The Vnet name where AKS will be deployed to"
}

variable "dns_service_ip" {
  description = "The IP address for the DNS serviced hosted inside AKS cluster"
}

variable "service_cidr" {
  description = "The IP range for internal services in AKS. Should not overlap any other IP space "
}

variable "cluster_name" {
  description = "The cluster name"
}

variable "resource_group_name" {
  description = "The Azure Resource Group to deploy AKS"
}

variable "agent_count" {
  description = "The number of nodes in the cluster"
  default     = "2"
}

variable "vm_size" {
  description = "The VM node size"
  default     = "Standard_DS3_v2"
}

variable "admin_user" {
  description = "The local administrator on Linux"
  default     = "manager"
}

variable "ssh_public_key" {
  description = "The public key for the local administrator"
  default     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDGUfWYw+OI3udPmdcIklEeLapnR/9boHLNOpHwglZ+fxv959rjmXyq+ZB55xfHQqjYgvUARLbYmvnBgIpDDI95fo2tepHjspvw4nmM1OwRCt+DwY7Y7Rmq/5LRIj6RvJe0V2TsS8xE0VI907zLoatqQ6cO9kedlbr9KY4ZrRXYHOZWapHqcliyI29lZIPGdmAFjmtdkngmu4sgss9V+2gwWghp+bnMXyyn96oBxeQjCNDiP/90yucjYgoDPHslkLXc7jgdfnb+oxa0iG9bHutzgTdQ7ZkCZOnd++ZJISIvKhIIJAfqaQNVY1B7cXzFDcTJbZxpptZvKbaUaWhRS1uJ briandenicola@harpocrates.denicolafamily.com"
}

variable "environment" {
  description = "The environment this cluster is"
}

variable "load_balancer_sku" {
  default     = "standard"
  description = "The type of load balancer to deploy as part of the AKS cluster"
}

variable "acr_subscription" {
  default     = "2deb88fe-eca8-499a-adb9-6e0ea8b6c1d2"
  description = "The subscription where Azure Container Repo lives"
}

variable "acr_resource_group" {
  default     = "Core_Infra_ContainerRepo_RG"
  description = "The Resource Grop where Azure Container Repo lives"
}

variable "acr_name" {
  default     = "bjd145"
  description = "The Azure Container Repo name"
}

variable "azure_rbac_group_object_id" {
  description = "GUID of the AKS admin Group"
}