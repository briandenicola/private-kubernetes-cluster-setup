#!/bin/bash

export ROLE="Azure Kubernetes Service RBAC Admin"

az login --identity
az account set -s ${SUBSCRIPTION_ID}

CLUSTER_DETAILS=`az aks list --query "[?name=='${CLUSTER_NAME}']"`
CLUSTER_RG=`echo ${cluster} | jq -r ".[].resourceGroup"`

az aks get-credentials -g ${CLUSTER_RG} -n ${CLUSTER_NAME} --overwrite-existing
kubelogin convert-kubeconfig -l msi

#Create Azure Resources 
if [ ${CREATE_AZ_RESOURCES} == "true" ]; then
    LOCATION=`echo ${cluster} | jq -r ".[].location"`
    az group create -n ${IDENTITY_RG} -l ${LOCATION}
    az identity create --name ${IDENTITY_NAME} --resource-grou ${IDENTITY_RG}
fi

#Create Namespace
kubectl create ns ${NAMESPACE} || true
kubectl label ns ${NAMESPACE} istio-injection=enabled

#Assign Pod Identity to Namespace
RESOURCEID=`az identity show --name ${IDENTITY_NAME} --resource-group ${IDENTITY_RG} --query id -o tsv`
az aks pod-identity add --resource-group ${CLUSTER_RG} --cluster-name ${CLUSTER_NAME} --namespace ${NAMESPACE} --name ${IDENTITY_NAME} --identity-resource-id ${RESOURCEID}

#Assign RBAC permissions to namespace
CLUSTER_ID=`echo ${cluster} | jq -r ".[].id"`
az role assignment create --assignee ${ADMIN_GROUP_IDh} --role ${ROLE} --scope ${CLUSTER_ID}/namespaces/${NAMESPACE}