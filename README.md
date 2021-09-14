# Introduction 
A method of creating a private AKS cluster (with or without Egress filtering) using Terraforms and the Flux gitOps operator. 

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
    * AzureFirewallSubnet
* Azure Container Repostiory 
* Azure Blob Storage - Terraform state storage
* Azure Bastion - to access jumpbox VM
* Azure Firewall - required only if using egress filtering
    * A Route Table with a route 0.0.0.0/0 to the Azure Firewall internal IP Address
* Azure AD Group - for Administrator access to the cluster

# Setup
## Prerequisites
* Update infrastructure/default/production.tfvars with correct values

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
10. terraform init -backend=true -backend-config="access_key=${access_key}" -backend-config="key=production.terraform.tfstate"
11. terraform plan -out="production.plan" -var "resource_group_name=DevSub01_AKS_RG" -var-file="production.tfvars"
12. terraform apply -auto-approve "production.plan"

## GitOps BootStrap
1. Access the Jump VM through Azure Bastion 
2. curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
3. wget https://github.com/Azure/kubelogin/releases/download/v0.0.10/kubelogin-linux-amd64.zip
4. curl -s https://fluxcd.io/install.sh | sudo bash
5. unzip kubelogin-linux-amd64.zip
6. mkdir bin
7. mv kubectl bin/.
8. mv bin/linux_amd64/kubelogin bin/.
9. chmod 755 bin/*
10. az login --identity
11. az aks install-cli
12. az aks get-credentials -n ${CLUSTER_NAME} -g ${CLUSTER_RESOURCE_GROUP}
13. kubelogin convert-kubeconfig -l msi
14. flux bootstrap git --url=ssh://git@github.com/${user}/kubernetes-cluster-setup --branch=master --path=./cluster-manifests/uat  --private-key-file=/home/manager/.ssh/id_rsa

## Azure DevOps
* If you are using Azure DevOps then you can setup a pipeline using the  multistage-pipeline.yaml file in the pipelines folder.
* The steps for GitOps will be incorporated into the pipeline eventually.




