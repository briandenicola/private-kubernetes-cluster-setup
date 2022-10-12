#!/bin/bash 

az extension add --name aks-preview
az extension update --name aks-preview

az feature register --name HTTPProxyConfigPreview --namespace Microsoft.ContainerService
az feature register --name MultiAgentpoolPreview --namespace Microsoft.ContainerService
az feature register --name EnablePodIdentityPreview --namespace Microsoft.ContainerService
az feature register --name RunCommandPreview --namespace Microsoft.ContainerService
az feature register --name AKS-AzureKeyVaultSecretsProvider --namespace Microsoft.ContainerService
az feature register --name AKS-OpenServiceMesh --namespace Microsoft.ContainerService
az feature register --name DisableLocalAccountsPreview --namespace Microsoft.ContainerService
az feature register --name EnableOIDCIssuerPreview --namespace Microsoft.ContainerService
az feature register --name AKS-ExtensionManager --namespace Microsoft.ContainerService 
az feature register --name AKS-AzureDefender --namespace Microsoft.ContainerService
az feature register --name AzureOverlayPreview --namespace Microsoft.ContainerService
az feature register --name EnableWorkloadIdentityPreview --namespace Microsoft.ContainerService
az feature register --namespace Microsoft.ContainerService --name FleetResourcePreview

watch -n 10 -g az feature list --namespace Microsoft.ContainerService -o table --query \"[?properties.state == \'Registering\']\"

az provider register --namespace Microsoft.Kubernetes
az provider register --namespace Microsoft.ContainerService
az provider register --namespace Microsoft.KubernetesConfiguration

az extension add --name k8s-extension
