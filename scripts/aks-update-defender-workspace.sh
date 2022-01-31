#az login --identity
az account set -s ${ARM_SUBSCRIPTION_ID}

CLUSTER_DETAILS=`az aks list --query "[?name=='${CLUSTER_NAME}']"`
CLUSTER_RESOURCEID=`echo ${CLUSTER_DETAILS} | jq -r ".[].id"`
CLUSTER_LOCATION=`echo ${CLUSTER_DETAILS} | jq -r ".[].location"`

LOGANALYTICS_RESOURCEID=`echo ${CLUSTER_DETAILS} | jq -r ".[].addonProfiles.omsagent.config.logAnalyticsWorkspaceResourceID"`

BODY="{ \"location\": \"${CLUSTER_LOCATION}\", \"properties\": { \"securityProfile\": { \"azureDefender\": { \"enabled\": true, \"logAnalyticsWorkspaceResourceID\": \"${LOGANALYTICS_RESOURCEID}\"	}}}}"


az rest --method put --url "${CLUSTER_RESOURCEID}?api-version=2021-10-01" --body "${BODY}" --headers content-type=application/json