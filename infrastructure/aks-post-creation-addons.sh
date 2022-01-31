#!/bin/bash

az account set -s ${SUBSCRIPTION_ID}
az aks update -g ${RG} -n ${CLUSTER_NAME} --enable-pod-identity