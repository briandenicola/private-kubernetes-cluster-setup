# Deployment 
The following is a detailed guide on how to standup an AKS cluster using the code in this repository via GitHub Actions 

# Prerequisites 
## Subscriptions and Artifacts
* An Azure subscription (two for a more Enterprise Scale-like deployment)
* A GitHub respository 
* A custom domain with a TLS certificate - the following will use bjdazure.tech and a cert from [Let's Encrypt](https://letsencrypt.org/)
* Enable [AKS Preview Features](./scripts/aks-preview-features.sh) - Once time per subscription

## Required Existing Resources and Configuration
| |  |
--------------- | --------------- 
| Azure Virtual Network (Core Components) | Azure Virtual Network (Kubernetes Cluster) |
| A DNS server | [Private Endpoint DNS Configuration](https://docs.microsoft.com/en-us/azure/private-link/private-endpoint-dns#on-premises-workloads-using-a-dns-forwarder) |
| The  two Virtual Networks Peered |  Vnets DNS set to DNS Server |
| Subnets | Subnet for Kubernetes API Server (at least /24) | 
|| Subnet for Kubernetes Nodes (/24) |
|| Subnet for Private Endpoints named private-endpoints |
| A [Github Actions Runner VM](https://docs.github.com/en/actions/using-github-hosted-runners/about-github-hosted-runners) with: | A User Assigned Manage Identity | 
|| Identity granted Owner permissions over each subscription |
| Azure Container Repository | Private EndPoint for ACR |
| An Azure SPN for ACR Access | Granted AcrPush/AcrPull RBAC from ACR |
| Azure Firewall| [AKS Egress Policies](https://docs.microsoft.com/en-us/azure/aks/limit-egress-traffic) |
| Route Table | Route 0.0.0.0/0 traffic from Kubernetes subnet to Azure Firewall |
| Azure Storage | Blob Container (for Terraform state files) |
| Private DNS Zones (attached to Core Vnet) | privatelink.${region}.azmk8s.io |
|| privatelink.vaultcore.azure.net |
|| privatelink.azurecr.io |
|| Custom Domain (example - bjdazure.tech) |
> **Note**: These [ARM Templates](https://github.com/briandenicola/kubernetes-cluster-setup/tree/main/infrastructure/prereqs) can help create most of the require Azure networking resources

# Steps for Complete Environment with Flux and Istio Service Mesh
1. Fork this repository and [eShopOnDapr](https://github.com/briandenicola/eShopOnDapr/) into your own Github Account
1. Package eShopOnDapr and Push to your Azure Container Repository
    *. cd deploy/k8s/helm/
    *. helm package .
    *. az acr helm push -n ${ACR} eshopondapr-2.0.0.tgz 
1. Fork repository
1. Create a new branch for the cluster 
1. Search and Replace k8995b with the new name of the cluster
1. Commit branch to your repository
1. Create the follow Secrets in GitHub:
    | Secret Name | Purpose |
    --------------- | --------------- 
    | ARM_SUBSCRIPTION_ID | The AKS Subscription ID used for Terraform access | 
    | ARM_CLIENT_ID | The Client ID of the Github Managed Identity | 
    | ARM_TENANT_ID | The Azure AD tenant of the Github Managed Identity | 
    | PAT_TOKEN | A GitHub Personal Access Token with Repo permissions for flux | 
    | CERTIFICATE | The base64 encoded string of the TLS cert in PFX format |
    | CERT_PASSWORD | The password for the PFX file |
    | ACR_SPN_ID | The client id of the ACR SPN used for Terraform access |
    | ACR_SPN_PASSWORD | The client secret of the ACR SPN used for Terraform access |
    | MSI_CLIENT_ID | The client id of the managed identity for the Github Actions Task Runner |
1. Update infrastructure/istio.tfvars with correct values
    | Secret Name |  Purpose | Default |
    --------------- | --------------- | --------------- 
    | agent_count | Number of nodes in default node pool | 3 |
    | location | The Azure Region for the resources| centralus |
    | k8s_vnet_resource_group_name | The Resource Group (RG) where the Azure Vnet for AKS is deployed | Apps02_Network_RG |
    | k8s_vnet | The AKS Virtual Network Name | DevSub02-Vnet-Sandbox-001 |
    | k8s_nodes_subnet | The subnet for the AKS nodes to deploy into | kubernetes-nodes |
    | k8s_apiserver_subnet | The subnet for the AKS API to deploy into | kubernetes-apiserver |
    | dns_service_ip | The DNS IP for CoreDNS in AKS| 192.168.0.10 |
    | service_cidr | The Services CIDR in AKS | 192.168.0.0/16 |
    | core_subscription | The Azure Subscription ID for Core Components| |
    | dns_resource_group_name | The RG where the Private Zone DNS resources have been deployed to | Core_Infra_DNS_RG |
    | acr_resource_group |The RG where the Azure Container Repository has been deployed to | Core_Infra_ContainerRepo_RG |
    | acr_name | The name of the Azure Container Repository ||
    | github_actions_identity_name | The name of the managed identity for the Github Actions runner used to bootstrap flux | github-actions-identity |
    | github_actions_identity_resource_group |The RG for the managed identity for the Github Actions runner| Core_Infra_GithubActions_RG |
    | certificate_name | The name of the secret that will store the TLS wildcard certificate | wildcard_certificate |
    | vm_size | The VM size of the default node pool | Standard_B4ms |
1. Trigger the 'Creates K8s with a Mesh installed' Github Action to create the cluster. 
    * Accept the default cluster name and Service Mesh
1. Search and Replace 0c237e7c-2007-4392-96e5-bec4323fa4c1 with the client id of Istio Service Mesh Ingress managed identity
1. Search and Replace 5adeae46-7597-426f-a40d-a8938f206444 with the client id of Zipkin managed identity 
1. Search and Replace 16b3c013-d300-468d-ac64-7eda0820b6d3 with ther proper Azure AD tenant ID
1. Commit branch to your repository
1. The pipeline calls the ./scripts/aks-flux-configuration.sh script to confiugre flux and execute the GitOps flow

## Post Creation Steps
1. Create wildcard '*' DNS record pointing to Istio Gateway Service IP for the custom domain

# Steps for Basic Private Cluster
1. Fork repository
1. Create a new branch for the cluster 
1. Search and Replace k8995b with the new name of the cluster
1. Commit branch to your repository
1. Create the follow Secrets in GitHub:
    | Secret Name | Purpose |
    --------------- | --------------- 
    | ARM_SUBSCRIPTION_ID | The AKS Subscription ID used for Terraform access | 
    | ARM_CLIENT_ID | The Client ID of the Github Managed Identity | 
    | ARM_TENANT_ID | The Azure AD tenant of the Github Managed Identity | 
    | PAT_TOKEN | A GitHub Personal Access Token with Repo permissions for flux | 
    | CERTIFICATE | The base64 encoded string of the TLS cert in PFX format |
    | CERT_PASSWORD | The password for the PFX file |
    | ACR_SPN_ID | The client id of the ACR SPN used for Terraform access |
    | ACR_SPN_PASSWORD | The client secret of the ACR SPN used for Terraform access |
    | MSI_CLIENT_ID | The client id of the managed identity for the Github Actions Task Runner |
1. Update infrastructure/k8s.tfvars with correct values
    | Secret Name |  Purpose | Default |
    --------------- | --------------- | --------------- 
    | agent_count | Number of nodes in default node pool | 3 |
    | location | The Azure Region for the resources| centralus |
    | k8s_vnet_resource_group_name | The Resource Group (RG) where the Azure Vnet for AKS is deployed | Apps02_Network_RG |
    | k8s_vnet | The AKS Virtual Network Name | DevSub02-Vnet-Sandbox-001 |
    | k8s_nodes_subnet | The subnet for the AKS nodes to deploy into | kubernetes-nodes |
    | k8s_apiserver_subnet | The subnet for the AKS API to deploy into | kubernetes-apiserver |
    | dns_service_ip | The DNS IP for CoreDNS in AKS| 192.168.0.10 |
    | service_cidr | The Services CIDR in AKS | 192.168.0.0/16 |
    | core_subscription | The Azure Subscription ID for Core Components| |
    | dns_resource_group_name | The RG where the Private Zone DNS resources have been deployed to | Core_Infra_DNS_RG |
    | acr_resource_group |The RG where the Azure Container Repository has been deployed to | Core_Infra_ContainerRepo_RG |
    | acr_name | The name of the Azure Container Repository ||
    | github_actions_identity_name | The name of the managed identity for the Github Actions runner used to bootstrap flux | github-actions-identity |
    | github_actions_identity_resource_group |The RG for the managed identity for the Github Actions runner| Core_Infra_GithubActions_RG |
    | certificate_name | The name of the secret that will store the TLS wildcard certificate | wildcard_certificate |
    | vm_size | The VM size of the default node pool | Standard_B4ms |
1. Trigger the 'Creates K8s without a Mesh installed' Github Action to create the cluster. 
    * Accept the new cluster name