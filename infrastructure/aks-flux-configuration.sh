#!/bin/bash

az login --identity
az account set -s ${SUBSCRIPTION_ID}
az aks get-credentials -g ${RG} -n ${CLUSTER_NAME} --overwrite-existing
kubelogin convert-kubeconfig -l msi

RESOURCEID=`az identity show --name ${INGRESS_IDENTITY} --resource-group ${RG} --query id -o tsv`
az aks pod-identity add --resource-group ${RG} --cluster-name ${CLUSTER_NAME} --namespace default --name ${INGRESS_IDENTITY} --identity-resource-id $RESOURCEID

ACR_PASSWORD=`az acr credential show -n ${ACR_NAME} --subscription ${ACR_SUBSCRIPTION_ID} --query "passwords[0].value" -o tsv | tr -d '\n'`

kubectl create ns flux-system
kubectl -n flux-system create secret generic https-credentials --from-literal=username=${ACR_NAME} --from-literal=password=${ACR_PASSWORD}

flux bootstrap github --owner=briandenicola --repository=kubernetes-cluster-setup --path=./cluster-manifests/uat --branch=master --personal
flux create source git appee85e06 --url=https://github.com/briandenicola/kubernetes-cluster-setup --branch=master --interval=30s 
