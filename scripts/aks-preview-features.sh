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

az feature list -o table --query "[?contains(name, 'az feature register --name DisableLocalAccountsPreview')].{Name:name,State:properties.state}"

az provider register --namespace Microsoft.ContainerService