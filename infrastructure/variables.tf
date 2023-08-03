variable "location" {
  description = "The Azure Region to deploy AKS"
  default     = "southcentralus"
}

variable "k8s_vnet_resource_group_name" {
  description = "The Resource Group name that contains the Vnet for AKS"
}

variable "k8s_nodes_subnet" {
  description = "The subnet name where AKS nodes will be deployed to"
}

variable "k8s_apiserver_subnet" {
  description = "The subnet name where AKS master server will be projected into"
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

variable "core_subscription" {
  default     = "2deb88fe-eca8-499a-adb9-6e0ea8b6c1d2"
  description = "The subscription where Azure Container Repo lives"
}

variable "acr_resource_group" {
  default     = "Core_Infra_ContainerRepo_RG"
  description = "The Resource Grop where Azure Container Repo lives"
}

variable "acr_name" {
  default     = "bjdcsa"
  description = "The Azure Container Repo name"
}

variable "dns_resource_group_name" {
  description = "The Resource Group name that contains Private DNS Zones"
}

variable "github_actions_identity_name" {
  description = "The name of the Github Task runner Managed Identity"
}

variable "github_actions_identity_resource_group" {
  description = "The Resource Group name that Github Taskrunner Identity"
}

variable "service_mesh_type" {
  default     = "istio"
  description = "The type of Service Mesh to install onto the cluster"
}

variable "certificate_name" {
  description = "The name of the certificate to use for TLS"
}

variable "certificate_base64_encoded" {
  description = "The name of the certificate to use for TLS"
}

variable "certificate_password" {
  description = "The password for the certificate"
}

variable "ingress_namespace" {
  description = "The namespace to deploy Istio gateway components to"
  default     = "istio-gateways"
}

variable "zipkin_namespace" {
  description = "The namespace to deploy Istio gateway components to"
  default     = "otel-system"
}