# Deployment 
The following is a detailed guide on how to standup an AKS cluster using the code in this repository via GitHub Actions 

# Prerequisites 
## Subscriptions and Artifacts
* An Azure subscription (two for a more Enterprise Scale-like deployment)
* A GitHub respository 
* A custom domain with a TLS certificate - the following will use bjdazure.tech and a cert from [Let's Encrypt](https://letsencrypt.org/)
* Enable [AKS Preview Features](./preview-features.md) - Once time per subscription

## Required Existing Resources and Configuration
| |  |
--------------- | --------------- 
| Azure Virtual Network (Core) | Azure Virtual Network (Kubernetes) |
| A DNS server | [Private Endpoint DNS Configuration](https://docs.microsoft.com/en-us/azure/private-link/private-endpoint-dns#on-premises-workloads-using-a-dns-forwarder) |
| Virtual Networks Peered |  Vnet DNS set to DNS Server |
| Subnet for Kubernetes (at least /23) | Subnet for Private Endpoints named private-endpoints |
| A [Github Actions Runner VM](https://docs.github.com/en/actions/using-github-hosted-runners/about-github-hosted-runners) with: | A User Assigned Manage Identity | 
|| Identity granted Owner permissions over each subscription |
| Azure Container Repository | Private EndPoint for ACR |
| An Azure SPN | Granted AcrPush/AcrPull RBAC from ACR |
| Azure Firewall| [AKS Egress Policies](https://docs.microsoft.com/en-us/azure/aks/limit-egress-traffic) |
| Route Table | Route 0.0.0.0/0 traffic from Kubernetes subnet to Azure Firewall |
| Azure Storage | Blob Container (for Terraform state files) |
| Private DNS Zones (attached to Core Vnet) | privatelink.${region}.azmk8s.io |
|| privatelink.vaultcore.azure.net |
|| privatelink.azurecr.io |
|| Custom Domain (example - bjdazure.tech) |

# Steps
1. Fork this repository and [eShopOnDapr](https://github.com/briandenicola/eShopOnDapr/) into your own Github Account
1. Package eShopOnDapr and Push to your Azure Container Repository
    *. cd deploy/k8s/helm/
    *. helm package .
    *. az acr helm push -n ${ACR} eshopondapr-2.0.0.tgz 
1. Create the follow Secrets in GitHub:
    | Secret Name | Purpose |
    --------------- | --------------- 
    | ARM_SUBSCRIPTION_ID | The AKS Subscription ID used for Terraform access | 
    | ARM_CLIENT_ID | The Client ID of the Github Managed Identity | 
    | ARM_TENANT_ID | The Azure AD tenant of the Github Managed Identity | 
    | PAT_TOKEN | A GitHub Personal Access Token with Repo permissions | 
    | CERTIFICATE | The base64 encoded string of the TLS cert in PFX format |
    | CERT_PASSWORD | The password for the PFX file |
    | ACR_SPN_ID | The client id of the ACR SPN used for Terraform access |
    | ACR_SPN_PASSWORD | The client secret of the ACR SPN used for Terraform access |
1. Update infrastructure/istio.tfvars with correct values
    | Secret Name |  Purpose | Default |
    --------------- | --------------- | --------------- 
    | location | The Azure Region for the resources| centralus |
    | k8s_vnet_resource_group_name | The Resource Group (RG) where the Azure Vnet for AKS is deployed | DevSub02_Network_RG |
    | k8s_vnet | The AKS Virtual Network Name | DevSub02-Vnet-Sandbox-001 |
    | k8s_subnet | The subnet in k8s_vnet to deploy AKS | kubernetesuat |
    | dns_service_ip | The DNS IP for CoreDNS in AKS| 192.168.0.10 |
    | service_cidr | The Services CIDR in AKS | 192.168.0.0/16 |
    | core_subscription | The Azure Subscription ID for Core Components| |
    | dns_resource_group_name | The RG where the Private Zone DNS resources have been deployed to | Core_Infra_DNS_RG |
    | acr_resource_group |The RG where the Azure Container Repository has been deployed to | Core_Infra_ContainerRepo_RG |
    | acr_name | The name of the Azure Container Repository ||
    | azure_rbac_group_object_id | The GUID of an Azure AD Group that will be granted AKS RBAC Cluster Admin role ||
    | github_actions_identity_name | The name of the managed identity for the Github Actions runner used to bootstrap flux | github-actions-identity |
    | github_actions_identity_resource_group |The RG for the managed identity for the Github Actions runner| Core_Infra_GithubActions_RG |
    | certificate_name | The name of the secret that will store the TLS wildcard certificate | wildcard_certificate |
    | ssh_public_key | A public key for the admin user on the AKS nodes | |
1. Trigger the 'Creates K8s with a Mesh installed' Github Action to create the cluster. 
    * Accept the default cluster name and Service Mesh
1. The pipeline calls the ./scripts/aks-flux-configuration.sh script to confiugre flux and execute the GitOps flow

## Post Creation Steps
1. Create catch-all DNS record pointing to Istio Gateway Service IP for the custom domain