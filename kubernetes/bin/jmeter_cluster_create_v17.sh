#!/usr/bin/env bash
#Kubernetes cluseter must posses enough resources to deploy all the pods
#stuff does not get deployed on master so you need minimum of 1 master and 1 worker

working_dir="$(pwd)"
tenant=$(awk '{print $NF}' "$working_dir/../tmp/tenant_export")

echo "Deleting existing namespace $tenant"
kubectl delete namespace $tenant ||:

echo "Replacing API version in deployment files:  apiVersion: apps/v1beta2 - > apiVersion: apps/v1"
sed -i 's+apps/v1beta2+apps/v1+g' ../config/deployments/*_deploy.yaml

echo "Removing Grafana LoadBalancer for local set-up. Keep it on when running on Azure"
sed -i 's+type: LoadBalancer++g' ../config/deployments/jmeter_grafana_svc.yaml


echo "Setting up cluster"
source jmeter_cluster_create.sh
