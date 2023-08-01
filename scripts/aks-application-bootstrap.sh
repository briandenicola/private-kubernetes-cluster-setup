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

CLUSTER_DETAILS=`az aks list --query "[?name=='${CLUSTER_NAME}']"`
CLUSTER_RG=`echo ${CLUSTER_DETAILS} | jq -r ".[].resourceGroup"`

az aks get-credentials -g ${CLUSTER_RG} -n ${CLUSTER_NAME} --overwrite-existing
kubelogin convert-kubeconfig -l msi

#Create Namespace
kubectl create ns ${NAMESPACE} || true
kubectl label ns ${NAMESPACE} istio-injection=enabled
kubectl -n ${NAMESPACE} create quota ns-limits --hard=requests.cpu=2,limits.cpu=4,requests.memory=10Gi,limits.memory=20Gi,count/gateways.networking.istio.io=0

#Create Servcie Account in Namespace
IDENTITY_DETAILS=`az identity list --query "[?name=='${IDENTITY_NAME}']"`
IDENTITY_ID=`echo ${IDENTITY_DETAILS} | jq -r ".[].clientId"`
IDENTITY_TENANT_ID=`echo ${IDENTITY_DETAILS} | jq -r ".[].tenantId"`
kubectl -n ${NAMESPACE} create serviceaccount ${IDENTITY_NAME}
kubectl -n ${NAMESPACE} annotate serviceaccount ${IDENTITY_NAME} azure.workload.identity/client-id=${IDENTITY_ID}
kubectl -n ${NAMESPACE} annotate serviceaccount ${IDENTITY_NAME} azure.workload.identity/tenant-id=${IDENTITY_TENANT_ID}
kubectl -n ${NAMESPACE} label serviceaccount ${IDENTITY_NAME} azure.workload.identity/use: "true"

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