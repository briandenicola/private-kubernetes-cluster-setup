#/bin/bash

wget https://get.helm.sh/helm-v3.0.2-linux-amd64.tar.gz
    
tar zxvf helm-v3.0.2-linux-amd64.tar.gz  
cd linux-amd64
./helm repo add stable https://kubernetes-charts.storage.googleapis.com/
./helm repo update
./helm upgrade  traefik stable/traefik --install --set rbac.enabled=true

./helm repo add aad-pod-identity https://raw.githubusercontent.com/Azure/aad-pod-identity/master/charts
./helm repo update
./helm upgrade aad-pod-identity aad-pod-identity/aad-pod-identity --install 