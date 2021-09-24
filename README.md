# Introduction 
A method of creating an AKS cluster with Kubenet networking

## Azure Resources Created
* An AKS Cluster

## Required Existing Azure Resources
* Azure Container Repostiory 
* Azure Blob Storage - Terraform state storage

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
