#!/bin/bash 

az extension add --name aks-preview
az extension update --name aks-preview

#Features Have Gone GA and no longer require preview flag
#az feature register --namespace Microsoft.ContainerService --name HTTPProxyConfigPreview 
#az feature register --namespace Microsoft.ContainerService --name MultiAgentpoolPreview
#az feature register --namespace Microsoft.ContainerService --name EnablePodIdentityPreview
#az feature register --namespace Microsoft.ContainerService --name RunCommandPreview
#az feature register --namespace Microsoft.ContainerService --name AKS-OpenServiceMesh
#az feature register --namespace Microsoft.ContainerService --name AKS-AzureKeyVaultSecretsProvider
#az feature register --namespace Microsoft.ContainerService --name EnableOIDCIssuerPreview
#az feature register --namespace Microsoft.ContainerService --name FleetResourcePreview
#az feature register --namespace Microsoft.ContainerService --name AzureServiceMeshPreview
#az feature register --namespace Microsoft.ContainerService --name EnableWorkloadIdentityPreview

features=(
    "DisableLocalAccountsPreview"
    "AKS-ExtensionManager"
    "AKS-AzureDefender"
    "AzureOverlayPreview"
    "AKS-PrometheusAddonPreview"
    "EnableImageCleanerPreview"
    "AKS-KedaPreview"
    "EnableAPIServerVnetIntegrationPreview"
    "EnableAzureDiskCSIDriverV2"
    "AKS-Dapr"
    "EnableMultipleStandardLoadBalancers"
    "AKSNodelessPreview"
    "NodeOsUpgradeChannelPreview"
    "CiliumDataplanePreview"
    "TrustedAccessPreview"
    "KubeletDisk"
    "KataVMIsolationPreview"
    "KataCcIsolationPreview"
    "EnableBYOKOnEphemeralOSDiskPreview"
    "NetworkObservabilityPreview"
    "EnableCloudControllerManager"
    "EnableImageIntegrityPreview"
    "AKS-AzurePolicyExternalData"
    "KubeProxyConfigurationPreview"
    "NodeAutoProvisioningPreview"
    "NRGLockdownPreview"
    "IstioNativeSidecarModePreview"
    "SafeguardsPreview"
    "DisableSSHPreview"
    "AutomaticSKUPreview"
    "AdvancedNetworkingPreview"
)

for feature in ${features[*]}
do
    az feature register --namespace Microsoft.ContainerService --name $feature
done 

watch -n 10 -g az feature list --namespace Microsoft.ContainerService -o table --query \"[?properties.state == \'Registering\']\"

az provider register --namespace Microsoft.Kubernetes
az provider register --namespace Microsoft.ContainerService
az provider register --namespace Microsoft.KubernetesConfiguration

az extension add --name k8s-extension
az extension add --name fleet
