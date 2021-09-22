#!/bin/bash

az account set -s ${SUBSCRIPTION_ID}
az aks enable-addons --addons open-service-mesh,azure-keyvault-secrets-provider -g ${RG} -n ${CLUSTER_NAME}
az aks update -g ${RG} -n ${CLUSTER_NAME} --enable-pod-identity

az aks get-credentials -g ${RG} -n ${CLUSTER_NAME} --overwrite-existing
kubelogin convert-kubeconfig -l msi

RESOURCEID=`az identity show --name ${INGRESS_IDENTITY} --resource-group ${RG} --query id -o tsv`
az aks pod-identity add --resource-group ${RG} --cluster-name ${CLUSTER_NAME} --namespace default --name ${INGRESS_IDENTITY} --identity-resource-id $RESOURCEID