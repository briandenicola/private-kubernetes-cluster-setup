#!/bin/bash

az account set -s ${SUBSCRIPTION_ID}

RESOURCEID=`az identity show --name ${IDENTITY_NAME} --resource-group ${IDENTITY_RG} --query id -o tsv`
az aks pod-identity add --resource-group ${CLUSTER_RG} --cluster-name ${CLUSTER_NAME} --namespace ${NAMESPACE} --name ${IDENTITY_NAME} --identity-resource-id ${RESOURCEID}