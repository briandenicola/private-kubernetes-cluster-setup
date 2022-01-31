#!/bin/bash

az account set -s ${SUBSCRIPTION_ID}

CLUSTER_DETAILS=`az aks list --query "[?name=='${CLUSTER_NAME}']"`
CLUSTER_RESOURCEID=`echo ${CLUSTER_DETAILS} | jq -r ".[].id"`
CLUSTER_LOCATION=`echo ${CLUSTER_DETAILS} | jq -r ".[].location"`

CLUSTER_IDENTITY=${CLUSTER_NAME}-cluster-identity
CLUSTER_IDENTITY_ID=`az identity list -g ${RG}  --query "[?name=='${CLUSTER_IDENTITY}'].principalId" | jq -r ".[0]"`

DNS_ZONE=privatelink.${CLUSTER_LOCATION}.azmk8s.io
DNS_ZONE_ID=`echo ${CLUSTER_DETAILS} | jq -r ".[].apiServerAccessProfile.privateDnsZone"`
DNS_RG=`echo ${DNS_ZONE} | awk -F/ '{print $5}'`

POD_IDENTITY_STATE=`echo ${CLUSTER_DETAILS} | jq -r ".[].podIdentityProfile.enabled"`

#Enable Pod Identity Addon (if not present)
if [[ ${POD_IDENTITY_STATE} -eq "false" ]]; then
    az aks update -g ${RG} -n ${CLUSTER_NAME} --enable-pod-identity
fi

#Update Azure Defender Workspace
LOGANALYTICS_RESOURCEID=`echo ${CLUSTER_DETAILS} | jq -r ".[].addonProfiles.omsagent.config.logAnalyticsWorkspaceResourceID"`
BODY="{ \"location\": \"${CLUSTER_LOCATION}\", \"properties\": { \"securityProfile\": { \"azureDefender\": { \"enabled\": true, \"logAnalyticsWorkspaceResourceID\": \"${LOGANALYTICS_RESOURCEID}\"	}}}}"
az rest --method put --url "${CLUSTER_RESOURCEID}?api-version=2021-10-01" --body "${BODY}" --headers content-type=application/json

#Remove Cluster Identity from RBAC (if present)
az account set -s ${CORE_SUBSCRIPTION_ID}
az role assignment delete  --role "Private DNS Zone Contributor" --scope ${DNS_ZONE_ID} --assignee ${CLUSTER_IDENTITY_ID}

#Remove Virtual Network Link (if present)
#az account set -s ${CORE_SUBSCRIPTION_ID}
#az network private-dns link vnet delete -n ${CLUSTER_NAME} -g ${DNS_RG} --zone ${DNS_ZONE} -y