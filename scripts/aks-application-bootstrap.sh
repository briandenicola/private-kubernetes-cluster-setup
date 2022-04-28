#!/bin/bash

while (( "$#" )); do
  case "$1" in
    -c|--cluster-name)
      CLUSTER_NAME+=($2)
      shift 2
      ;;
    -n|--namespace)
      NAMESPACE=$2
      shift 2
     ;;
    -g|--group-name)
      GROUP_NAME=$2
      shift 2
      ;;
    -i|--identity-name)
      IDENTITY_NAME=$2
      shift 2
      ;;
    -h|--help)
      echo "Usage: ./workload-identity.sh --cluster-name --namespace --group-name --identity-name --identity-resource-group
        Overview: This script will bootstrap a namespace for develoepers in an AKS cluster
        --cluster-name(c)             - The AKS cluster where this identity will be used
        --namespace(n)                - The Kuberentes namespace where for this development team
        --group-name(g)               - The Azure AD Group Name to onboard
        --identity-name(i)            - The User Assigned Managed Identity to onboard to this namespace
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

DEV_ROLE="Azure Kubernetes Service RBAC Writer"
MSI_ROLE="Managed Identity Operator"

CLUSTER_DETAILS=`az aks list --query "[?name=='${CLUSTER_NAME}']"`
CLUSTER_RG=`echo ${CLUSTER_DETAILS} | jq -r ".[].resourceGroup"`

az aks get-credentials -g ${CLUSTER_RG} -n ${CLUSTER_NAME} --overwrite-existing
kubelogin convert-kubeconfig -l msi

#Create Namespace
kubectl create ns ${NAMESPACE} || true
kubectl label ns ${NAMESPACE} istio-injection=enabled
kubectl -n ${NAMESPACE} create quota ns-limits --hard=requests.cpu=2,limits.cpu=4,requests.memory=10Gi,limits.memory=20Gi,count/gateways.networking.istio.io=0

#Assign Pod Identity to Namespace
CLUSTER_ID=`echo ${CLUSTER_DETAILS} | jq -r ".[].id"`
CLUSTER_PRINCIPAL_ID=`echo ${CLUSTER_DETAILS} | jq -r ".[].identity.userAssignedIdentities[].principalId"`
IDENTITY_ID=`az identity list --query "[?name=='${IDENTITY_NAME}']" | jq -r ".[].id"`

az role assignment create --assignee-object-id ${CLUSTER_PRINCIPAL_ID} --assignee-principal-type ServicePrincipal  --role "${MSI_ROLE}" --scope ${IDENTITY_ID}
az aks pod-identity add --resource-group ${CLUSTER_RG} --cluster-name ${CLUSTER_NAME} --namespace ${NAMESPACE} --name ${IDENTITY_NAME} --identity-resource-id ${IDENTITY_ID}

#Assign RBAC permissions to namespace
CLUSTER_ID=`echo ${CLUSTER_DETAILS} | jq -r ".[].id"`
GROUP_ID=`az ad group show --group "${GROUP_NAME}" --query "objectId" --output tsv`
az role assignment create --assignee ${GROUP_ID} --role "${DEV_ROLE}" --scope ${CLUSTER_ID}/namespaces/${NAMESPACE}

cat <<EOF | kubectl -n ${NAMESPACE} apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: istio-role-binding
roleRef:
  kind: ClusterRole
  name: istio-custom-creator-role
  apiGroup: rbac.authorization.k8s.io
subjects:
- kind: Group
  name: ${GROUP_NAME}
EOF