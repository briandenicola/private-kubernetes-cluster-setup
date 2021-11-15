#!/bin/bash

export ADMIN_ROLE="Azure Kubernetes Service RBAC Admin"
export MSI_ROLE="Managed Identity Operator"

CLUSTER_DETAILS=`az aks list --query "[?name=='${CLUSTER_NAME}']"`
CLUSTER_RG=`echo ${CLUSTER_DETAILS} | jq -r ".[].resourceGroup"`

az aks get-credentials -g ${CLUSTER_RG} -n ${CLUSTER_NAME} --overwrite-existing
kubelogin convert-kubeconfig -l msi

#Create Azure Resources 
if [ ${CREATE_AZ_RESOURCES} == "true" ]; then
    LOCATION=`echo ${CLUSTER_DETAILS} | jq -r ".[].location"`
    az group create -n ${IDENTITY_RG} -l ${LOCATION}
    az identity create --name ${IDENTITY_NAME} --resource-group ${IDENTITY_RG}
fi

#Create Namespace
kubectl create ns ${NAMESPACE} || true
kubectl label ns ${NAMESPACE} istio-injection=enabled

#Assign Pod Identity to Namespace
CLUSTER_ID=`echo ${CLUSTER_DETAILS} | jq -r ".[].id"`
CLUSTER_PRINCIPAL_ID=`echo ${CLUSTER_DETAILS} | jq -r ".[].identity.userAssignedIdentities[].principalId"`
IDENTITY_ID=`az identity show --name ${IDENTITY_NAME} --resource-group ${IDENTITY_RG} -o tsv --query id`

az role assignment create --assignee-object-id ${CLUSTER_PRINCIPAL_ID} --assignee-principal-type ServicePrincipal  --role "${MSI_ROLE}" --scope ${IDENTITY_ID}
az aks pod-identity add --resource-group ${CLUSTER_RG} --cluster-name ${CLUSTER_NAME} --namespace ${NAMESPACE} --name ${IDENTITY_NAME} --identity-resource-id ${IDENTITY_ID}

#Assign RBAC permissions to namespace
CLUSTER_ID=`echo ${CLUSTER_DETAILS} | jq -r ".[].id"`
az role assignment create --assignee ${ADMIN_GROUP_ID} --role "${ADMIN_ROLE}" --scope ${CLUSTER_ID}/namespaces/${NAMESPACE}