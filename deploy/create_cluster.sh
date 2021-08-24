#/bin/bash

export RG_NAME=$1
export ENV=$2
export KEY=$3
export ARM_CLIENT_SECRET=$4

today=`date +"%y%m%d"`
uuid=`uuidgen | sed 's/-//g'`

export ARM_CLIENT_ID=$CLIENT_ID
export ARM_SUBSCRIPTION_ID=$SUBSCRIPTION_ID
export ARM_TENANT_ID=$TENANT_ID
export PLAN_FILE="aks.$ENV.plan.${today}-${uuid}" 

cd $AGENT_BUILDDIRECTORY/drop/Code

<<<<<<< HEAD
wget https://releases.hashicorp.com/terraform/1.0.5/terraform_1.0.5_linux_amd64.zip
unzip terraform_1.0.5_linux_amd64.zip
=======
wget https://releases.hashicorp.com/terraform/0.12.31/terraform_0.12.31_linux_amd64.zip    
unzip terraform_0.12.31_linux_amd64.zip
>>>>>>> 720cc2714ceaa5890be94fccc33e997c5acc6442

./terraform init -backend=true -backend-config="access_key=$KEY" -backend-config="key=$ENV.terraform.tfstate"
./terraform plan -out="$PLAN_FILE" -var "resource_group_name=$RG_NAME" -var-file="$ENV.tfvars"
./terraform apply -auto-approve $PLAN_FILE

az login --service-principal -u $ARM_CLIENT_ID -p $ARM_CLIENT_SECRET --tenant $ARM_TENANT_ID
az account set -s $ARM_SUBSCRIPTION_ID
az storage copy --source-local-path "./$PLAN_FILE" --destination-account-name $STORAGE_ACCOUNT --destination-container plans

aks=`az aks list -g $RG_NAME --query "[0].name" -o tsv`
az aks get-credentials -n $aks -g $RG_NAME