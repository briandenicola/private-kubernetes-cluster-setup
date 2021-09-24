# Introduction 
A method of creating a private AKS cluster with Egress filtering using Terraforms and the Flux gitOps operator. 

## Azure Resources Created
* Private AKS Cluster with Azure AD Pod Identity, KeyVault CSI Driver and OpenService Mesh extensions
* Jumpbox VM
* KeyVault
* Private Zones for AKS and Keyvault

## Required Existing Azure Resources
* Virtual Network with subnets
    * kubernetes
    * private-endpoint
    * servers
    * AzureBastionSubnet
* Azure Container Repostiory 
* Azure Blob Storage - Terraform state storage
* Azure Bastion - to access jumpbox VM
* Azure Firewall with proper [network and application rules](https://docs.microsoft.com/en-us/azure/aks/limit-egress-traffic)
* A Route Table with a route 0.0.0.0/0 to the Azure Firewall internal IP Address

# GitHub Actions
## Prerequisites
* A task runner deployed in the virtual network where the AKS cluster will be deployed.
* The task runnre VM need to have a User Managed Identity assigned 
* Update infrastructure/uat.tfvars with correct values
* Create the follow Secrets in GitHub:

    | Secret Name | Secret Name |
    --------------- | --------------- 
    | ARM_CLIENT_ID | ARM_CLIENT_SECRET | 
    | ARM_SUBSCRIPTION_ID | ARM_TENANT_ID | 
    | STORAGE_ACCESS_KEY | PAT_TOKEN |

## Steps
1. Trigger Github Action to create the cluster. 
2. Terraform will the call the aks-post-creation-configuration.sh script to add Pod Identity and KeyVault CSI Driver 
3. Terraform will finally call the aks-flux-configuration.sh script to confiugre flux and execute the GitOps flow

# Manual Setup
## Prerequisites
* Update infrastructure/uat.tfvars with correct values

## Cluster Creation
1. cd infrastructure
2. terraform init -backend=true -backend-config="access_key=${access_key}" -backend-config="key=simple.terraform.tfstate"
3. terraform plan -out="simple.plan" -var "resource_group_name=DevSub_K8S_RG" -var-file="uat.tfvars"
4. terraform apply -auto-approve "simple.plan"
