# Introduction 
A method of creating an AKS cluster with Kubenet networking

## Azure Resources Created
* An AKS Cluster

## Required Existing Azure Resources
* Azure Container Repostiory 
* Azure Blob Storage - Terraform state storage

# Setups
## Prerequisites
* Update infrastructure/uat.tfvars with correct values

## Cluster Creation
1. cd infrastructure
2. terraform init -backend=true -backend-config="access_key=${access_key}" -backend-config="key=simple.terraform.tfstate"
3. terraform plan -out="simple.plan" -var "resource_group_name=DevSub_K8S_RG" -var-file="uat.tfvars"
4. terraform apply -auto-approve "simple.plan"
