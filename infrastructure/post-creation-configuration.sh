#!/bin/bash


az aks enable-addons --addons open-service-mesh,azure-keyvault-secrets-provider -g ${RG} -n ${CLUSTER_NAME}
az aks update -g ${RG} -n ${CLUSTER_NAME} --enable-pod-identity