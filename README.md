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
   *  Follow [this](https://github.com/briandenicola/cqrs/blob/master/Infrastructure/terraform/regional-firewall-rules.tf) example of using AKS with Azure Firewall using Terraforms
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
1. az extension add --name aks-preview
2. az extension update --name aks-preview
3. az login
4. az feature register --namespace "Microsoft.ContainerService" --name "AKS-AzureKeyVaultSecretsProvider"
5. az feature register --namespace "Microsoft.ContainerService" --name "EnablePodIdentityPreview"
6. az feature register --namespace "Microsoft.ContainerService" --name "AKS-OpenServiceMesh"
7. az feature register --namespace "Microsoft.ContainerService" --name "DisableLocalAccountsPreview"
8. az feature list -o table --query "[?contains(name, 'Microsoft.ContainerService')].{Name:name,State:properties.state}"
    * Wait till the above features are enabled
9. az provider register --namespace Microsoft.ContainerService
10. cd infrastructure
11. terraform init -backend=true -backend-config="access_key=${access_key}" -backend-config="key=production.terraform.tfstate"
12. terraform plan -out="production.plan" -var "resource_group_name=DevSub_K8S_RG" -var-file="production.tfvars"
13. terraform apply -auto-approve "production.plan"

## GitOps BootStrap
1. Access the Jump VM through Azure Bastion 
2. curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
3. curl -s https://fluxcd.io/install.sh | sudo bash
4. az login --identity
5. az aks install-cli
6. az aks get-credentials -n ${CLUSTER_NAME} -g ${CLUSTER_RESOURCE_GROUP}
7. kubelogin convert-kubeconfig -l msi
8. echo -n ${ACR_NAME} > ./username.txt 
9. az acr credential show -n ${ACR_NAME} --query "passwords[0].value" -o tsv | tr -d '\n' > password.txt 
9. kubectl -n flux-system create secret generic https-credentials --from-file=username=./username.txt --from-file=password=./password.txt
10. flux bootstrap git --url=ssh://git@github.com/${user}/kubernetes-cluster-setup --branch=master --path=./cluster-manifests/uat  --private-key-file=/home/manager/.ssh/id_rsa
