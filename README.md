# Introduction 
A method of creating a private AKS cluster with Egress filtering using Terraforms and the Flux gitOps operator. The cluster will be setup with either Open Service Mesh or Istio with couple demo applications deployed. 

## Azure Resources Created
* Private AKS Cluster with Azure AD Pod Identity and KeyVault CSI Driver extensions
* KeyVault with Private Link

## Ressourced Deploy Inside Cluster
* Istio 
    * Ingress Gateway with TLS certificate from Key Vault
* Dapr
* Kured
* Demo Applications
    * A Todo application with Azure AD B2C integration
    * A Chat application with Azure Cognitive Services
    * eShopOnDapr

## Required Existing Azure Resources
_[This](https://github.com/briandenicola/kubernetes-cluster-setup/blob/master/infrastructure/prereqs/azuredeploy.template.json) can help setup some of the pre-reqs._
* Virtual Network with subnets
    * kubernetes
    * private-endpoint
* Azure Private Zone DNS attached the virtual network
* Azure Container Repostiory 
* Azure Blob Storage - Terraform state storage
* Azure Firewall with proper [network and application rules](https://docs.microsoft.com/en-us/azure/aks/limit-egress-traffic)
   *  Follow [this](https://github.com/briandenicola/cqrs/blob/master/Infrastructure/terraform/regional-firewall-rules.tf) example of using AKS with Azure Firewall using Terraforms
* A Route Table with a route 0.0.0.0/0 to the Azure Firewall internal IP Address

## Other Required Resources
* A domain with Private DNS Zone 
* A TLS certificate 

# GitHub Actions
## Prerequisites
* One time run - ./scripts/aks-preview-features.sh to register subscription features
* A task runner deployed in the virtual network where the AKS cluster will be deployed.
* The task runner VM need to have a User Managed Identity assigned 
* Update infrastructure/istio.tfvars with correct values
* Create the follow Secrets in GitHub:

    | Secret Name | Secret Name |
    --------------- | --------------- 
    | ARM_CLIENT_ID | ARM_CLIENT_SECRET | 
    | ARM_SUBSCRIPTION_ID | ARM_TENANT_ID | 
    | STORAGE_ACCESS_KEY | PAT_TOKEN |
    | CERTIFICATE | CERT_PASSWORD |

## Steps
1. Trigger Github Action to create the cluster. 
1. Terraform will the call the ./infrastructure/aks-post-creation-addons.sh script to add Pod Identity
1. The pipeline will call the ./scripts/aks-pod-identity-creation.sh script to create a couple Pod Identities 
1. The pipeline will call the ./scripts/aks-flux-configuration.sh script to confiugre flux and execute the GitOps flow
1. The pipeline will call the ./scripts/aks-update-defender-workspace.sh script to update Microsoft Defender for Cloud Log Analytics Workspace

## Post Creation Steps
1. Create *.${domain} DNS record pointing to Istio Gateway Service IP
1. Create gatewayDnsNameOrIP (eshop-api.${domain}), identityDnsNameOrIP (identity-api.${domain}) and blazorDnsNameOrIP (shop.${domain})

# Manual Setup
## Prerequisites
* Update infrastructure/osm|istio.tfvars with correct values for your environment

## Cluster Creation
1. az extension add --name aks-preview
1. az extension update --name aks-preview
1. az login
1. az feature register --namespace "Microsoft.ContainerService" --name "AKS-AzureKeyVaultSecretsProvider"
1. az feature register --namespace "Microsoft.ContainerService" --name "EnablePodIdentityPreview"
1. az feature register --namespace "Microsoft.ContainerService" --name "AKS-OpenServiceMesh"
1. az feature register --namespace "Microsoft.ContainerService" --name "DisableLocalAccountsPreview"
1. az feature list -o table --query "[?contains(name, 'Microsoft.ContainerService')].{Name:name,State:properties.state}"
    * Wait till the above features are enabled
1. az provider register --namespace Microsoft.ContainerService
1. cd infrastructure
1. terraform init -backend=true -backend-config="access_key=${access_key}" -backend-config="e534wq.terraform.tfstate"
1. terraform plan -out="e534wq.plan" -var "cluster_name=e534wq" -var "resource_group_name=DevSub_K8S_e534wq_RG" -var "certificate_base64_encoded=${CERTIFICATE}"  -var "certificate_password=${CERTIFICATE_PASSWORD}" -var "service_mesh_type=istio" -var-file="istio.tfvars" 
1. terraform apply -auto-approve "e534wq.plan"
1. ./scripts/aks-pod-identity-creation.sh
1. ./scripts/aks-flux-configuration.sh
1. ./scripts/aks-update-defender-workspace.sh 

## GitOps BootStrap
1. Access the Jump VM through Azure Bastion 
1. export GITHUB_TOKEN=${PAT_TOKEN_FOR_YOUR_REPO}
1. curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
1. curl -s https://fluxcd.io/install.sh | sudo bash
1. az login --identity
1. az aks install-cli
1. az aks get-credentials -n ${CLUSTER_NAME} -g ${CLUSTER_RESOURCE_GROUP}
1. kubelogin convert-kubeconfig -l msi
1. echo -n ${ACR_NAME} > ./username.txt 
1. az acr credential show -n ${ACR_NAME} --query "passwords[0].value" -o tsv | tr -d '\n' > password.txt 
1. kubectl -n flux-system create secret generic https-credentials --from-file=username=./username.txt --from-file=password=./password.txt
1. flux bootstrap git --url=ssh://git@github.com/${user}/kubernetes-cluster-setup --branch=master --path=./cluster-manifests/uat  --personal=true --private=false
