#!/bin/bash

az login --identity
az account set -s ${ARM_SUBSCRIPTION_ID}
az aks get-credentials -g ${CLUSTER_RG} -n ${CLUSTER_NAME} --overwrite-existing
kubelogin convert-kubeconfig -l msi

kubectl create ns flux-system || true
kubectl -n flux-system delete secret https-credentials || true
kubectl -n flux-system create secret generic https-credentials --from-literal=username=${ACR_SPN_ID} --from-literal=password=${ACR_SPN_PASSWORD}

flux bootstrap github --owner=${GITHUB_ACCOUNT} --repository=${GITHUB_REPO} --path=${CLUSTER_BOOTSTRAP_PATH} --branch=${REPO_BRANCH}  --personal=true --private=false