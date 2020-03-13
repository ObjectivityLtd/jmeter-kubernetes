#!/usr/bin/env bash
#Kubernetes cluseter must posses enough resources to deploy all the pods

working_dir="$(pwd)"
tenant=$(awk '{print $NF}' "$working_dir/../tmp/tenant_export")

echo "Deleting existing namespace $tenant"
kubectl delete namespace $tenant ||:

echo "Replacing API version in deployment files:  apiVersion: apps/v1beta2 - > apiVersion: apps/v1"
sed -i 's+apps/v1beta2+apps/v1+g' ../config/deployments/*_deploy.yaml

echo "Setting up cluster"
source jmeter_cluster_create.sh
