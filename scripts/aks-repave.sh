#!/bin/bash

while (( "$#" )); do
  case "$1" in
    -i)
      CLIENT_ID=$2
      shift 2
      ;;
    -s)
      SUBSCRIPTION_ID=$2
      shift 2
      ;;
    -n)
      CLUSTER_NAME=$2
      shift 2
      ;;
    -g)
      CLUSTER_RG=$2
      shift 2
      ;;
    -v)
      KEY_VAULT_NAME=$2
      shift 2
      ;;
    --secret-name)
      KEY_VAULT_SECRET_NAME=$2
      shift 2
      ;;
    -h|--help)
      echo "Usage: ./aks-repave.sh -i {MSI_GUID} -s {SUBSCRIPTION_GUID} -n {AKS_NAME} -g {AKS_RG} -v {KeyVault_NAME} --secret-name {SSH_SECRET_NAME}
        -i: The Managed Identity to access the Azure Resources
        -s: The Azure Subscription for the resources
        -n: The AKS name
        -g: The Resource Group for AKS and Key Vault
        -v: The Key Vault to store the SSH Private Key
        --secret-name: The name of the SSH secret in Key Vault
      "
      exit 0
      ;;
    --) 
      shift
      break
      ;;
    -*|--*=) 
      echo "Error: Unsupported flag $1" >&2
      exit 1
      ;;
  esac
done

if [[ -z "${CLIENT_ID}" ]]; then
  CLIENT_ID=${ARM_CLIENT_ID}
fi 

if [[ -z "${SUBSCRIPTION_ID}" ]]; then
  SUBSCRIPTION_ID=${ARM_SUBSCRIPTION_ID}
fi 

az login --identity -u ${CLIENT_ID}
az account set -s ${SUBSCRIPTION_ID}

az aks get-credentials -g ${CLUSTER_RG} -n ${CLUSTER_NAME} --overwrite-existing --format azure
kubelogin convert-kubeconfig -l azurecli

ID=${RANDOM}
PRIVATE_KEY_FILE=/tmp/id_rsa_${ID}
PUBLIC_KEY_FILE=/tmp/id_rsa_${ID}.pub
ssh-keygen -q -b 4096 -f ${PRIVATE_KEY_FILE} -t rsa

az keyvault secret set --name ${KEY_VAULT_SECRET_NAME} --vault-name ${KEY_VAULT_NAME} --file ${PRIVATE_KEY_FILE} --encoding ascii
az aks update  -g ${CLUSTER_RG} -n ${CLUSTER_NAME} --ssh-key-value ${PUBLIC_KEY_FILE}

rm -rf ${PUBLIC_KEY_FILE}
rm -rf ${PRIVATE_KEY_FILE}