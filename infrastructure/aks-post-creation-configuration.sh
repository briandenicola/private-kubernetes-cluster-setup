#!/bin/bash

az account set -s ${SUBSCRIPTION_ID}
az aks enable-addons --addons azure-keyvault-secrets-provider -g ${RG} -n ${CLUSTER_NAME} --enable-secret-rotation
az aks update -g ${RG} -n ${CLUSTER_NAME} --enable-pod-identity