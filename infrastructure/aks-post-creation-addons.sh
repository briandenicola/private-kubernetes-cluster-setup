#!/bin/bash

az extension add --name aks-preview   
az account set -s ${SUBSCRIPTION_ID}

az aks update -g ${RG} -n ${CLUSTER_NAME} --enable-pod-identity 
az aks update -g ${RG} -n ${CLUSTER_NAME} --enable-oidc-issuer