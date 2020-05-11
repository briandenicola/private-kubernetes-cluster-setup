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

variable "cluster_version" {
  description = "The cluster version"
  default     = "1.16.7"
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
  default     = "Standard_B4ms"
}

variable "admin_user" {
  description = "The local administrator on Linux"
  default     = "manager"
}

variable "ssh_public_key" {
  description = "The public key for the local administrator"
  default     = ""
}

variable "log_analytics_workspace_name" {
  description = "The name for the Log Analytics Workspace"
  default     = ""
}

variable "environment" {
  description = "The environment this cluster is"
}

variable "load_balancer_sku" {
  description = "The type of load balancer to deploy as part of the AKS cluster"
  default     = "standard"
}

variable "acr_subscription" {
  description = "The subscription where Azure Container Repo lives"
}

variable "acr_resource_group" {
  description = "The Resource Grop where Azure Container Repo lives"
}

variable "acr_name" {
  description = "The Azure Container Repo name"
}

