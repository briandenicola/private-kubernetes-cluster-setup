
# Required Preview Features 
1. az feature register --namespace "Microsoft.ContainerService" --name "AKS-AzureKeyVaultSecretsProvider"
1. az feature register --namespace "Microsoft.ContainerService" --name "EnablePodIdentityPreview"
1. az feature register --namespace "Microsoft.ContainerService" --name "AKS-OpenServiceMesh"
1. az feature register --namespace "Microsoft.ContainerService" --name "DisableLocalAccountsPreview"
1. az feature list -o table --query "[?contains(name, 'Microsoft.ContainerService')].{Name:name,State:properties.state}"
1. az provider register --namespace Microsoft.ContainerService
