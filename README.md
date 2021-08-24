# Introduction 
A method of creating an AKS cluster Terraforms 1.0.5

# Setup
## Pre-requisites 
* Create an Azure Blob Storage Account and copy the access key. 
    * This will be used to store the TF state file
* Create a Service Principal with a client secret. 
    * Grant Service Pincipal at least contributor on the Azure Subscription
    * Set the follow environmental variable - ARM_CLIENT_ID, ARM_SUBSCRIPTION_ID, and ARM_TENANT_ID=$TENANT_ID
    * This is how Terraform connects to Azure 
1. Set variables.tf and development.tfvars in src folder
2. cd deploy
3. .\create_cluster.sh $(ResourceGroupNameToDeployTO) "development" $(Storage Account Key) $(SPN Client Secret)
4. .\config_cluster.sh

## Azure DevOps
* If you are using Azure DevOps then you can also use the yaml definitions in the pipeline folder
