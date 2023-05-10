#!/bin/bash 

az extension add --name aks-preview
az extension update --name aks-preview

az feature register --namespace Microsoft.ContainerService --name HTTPProxyConfigPreview 
az feature register --namespace Microsoft.ContainerService --name MultiAgentpoolPreview
az feature register --namespace Microsoft.ContainerService --name EnablePodIdentityPreview
az feature register --namespace Microsoft.ContainerService --name RunCommandPreview
az feature register --namespace Microsoft.ContainerService --name AKS-AzureKeyVaultSecretsProvider
az feature register --namespace Microsoft.ContainerService --name AKS-OpenServiceMesh
az feature register --namespace Microsoft.ContainerService --name DisableLocalAccountsPreview
az feature register --namespace Microsoft.ContainerService --name EnableOIDCIssuerPreview
az feature register --namespace Microsoft.ContainerService --name AKS-ExtensionManager
az feature register --namespace Microsoft.ContainerService --name AKS-AzureDefender
az feature register --namespace Microsoft.ContainerService --name AzureOverlayPreview
az feature register --namespace Microsoft.ContainerService --name EnableWorkloadIdentityPreview
az feature register --namespace Microsoft.ContainerService --name FleetResourcePreview
az feature register --namespace Microsoft.ContainerService --name AKS-PrometheusAddonPreview
az feature register --namespace Microsoft.ContainerService --name EnableImageCleanerPreview
az feature register --namespace Microsoft.ContainerService --name AKS-KedaPreview 
az feature register --namespace Microsoft.ContainerService --name EnableAPIServerVnetIntegrationPreview
az feature register --namespace Microsoft.ContainerService --name EnableAzureDiskCSIDriverV2
az feature register --namespace Microsoft.ContainerService --name AKS-Dapr
az feature register --namespace Microsoft.ContainerService --name EnableMultipleStandardLoadBalancers
az feature register --namespace Microsoft.ContainerService --name AKSNodelessPreview
az feature register --namespace Microsoft.ContainerService --name NodeOsUpgradeChannelPreview
az feature register --namespace Microsoft.ContainerService --name AzureServiceMeshPreview
az feature register --namespace Microsoft.ContainerService --name CiliumDataplanePreview

watch -n 10 -g az feature list --namespace Microsoft.ContainerService -o table --query \"[?properties.state == \'Registering\']\"

az provider register --namespace Microsoft.Kubernetes
az provider register --namespace Microsoft.ContainerService
az provider register --namespace Microsoft.KubernetesConfiguration

az extension add --name k8s-extension
az extension add --name fleet
