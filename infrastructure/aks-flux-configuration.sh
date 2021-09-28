#!/bin/bash

export CLUSTER_BOOTSTRAP_PATH=./cluster-manifests/uat
export APP_NAME=ingress-ee85e06
export REPO_BRANCH=master

az login --identity
az account set -s ${SUBSCRIPTION_ID}
az aks get-credentials -g ${RG} -n ${CLUSTER_NAME} --overwrite-existing
kubelogin convert-kubeconfig -l msi

ACR_PASSWORD=`az acr credential show -n ${ACR_NAME} --subscription ${ACR_SUBSCRIPTION_ID} --query "passwords[0].value" -o tsv | tr -d '\n'`

kubectl create ns flux-system
kubectl -n flux-system create secret generic https-credentials --from-literal=username=${ACR_NAME} --from-literal=password=${ACR_PASSWORD}

flux bootstrap github --owner=${GITHUB_ACCOUNT} --repository=${GITHUB_REPO} --path=${CLUSTER_BOOTSTRAP_PATH} --branch=${REPO_BRANCH} --personal
flux create source git ${APP_NAME} --url=https://github.com/${GITHUB_ACCOUNT}/${GITHUB_REPO} --branch=${REPO_BRANCH} --interval=30s 
