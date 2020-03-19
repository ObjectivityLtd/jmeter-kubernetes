#!/bin/bash
#How to prepare all necessary azure resources to keep cost under control ?
#Note: all of this can also be done in UI, howver for automartion I am presenting a CLI version.
#execute this in CLI:
#cd ~ && rm -Rf jmeter-kubernetes && git clone https://github.com/ObjectivityLtd/jmeter-kubernetes && cd jmeter-kubernetes/pipelines/azure && chmod +x *.sh && ./azure-pipelines.1.azure.agent.kubernetes.sh

#config
group_name=jmeter-group
location=uksouth
cluster_name=jubernetes
cluster_namespace=jmeter
kubernetes_version=1.15.10
node_size=Standard_D2_v2
node_count=5
home_dir=$(pwd)
test_jmx="cloudssky.jmx"

#help functions

wait_for_pod() {
  service_replicas="0/1"
  service_namespace=$1
  service=$2
  service_replicas_number=$3
  sleep_time_s=$4

  until [ "$service_replicas" == "$service_replicas_number/$service_replicas_number" ]; do
    echo "Wait for service $service to scale to $service_replicas_number for $sleep_time_s seconds"
    sleep $sleep_time_s
    service_replicas=$($kubectl -n $service_namespace get all | grep pod/$service_name | awk '{print $2}')
    echo "Service $service_name pod: $service_replicas"
  done
}

wait_for_pods(){
  local service_namespace=$1
  local service_replicas_number=$2
  local sleep_time_s=$3
  shift 3
  IFS=' ' read -r -a services <<< "$@"
  for service in "${services[@]}"; do
    wait_for_pod $service_namespace $service $service_replicas_number $sleep_time_s
  done

}}
#PART 1 - create a kubernetes cluster in Azure, execute as one command:

#1. Open Azure CLI
#2. Delete entire resource group if exist:
echo "Deleting group $group_name if exists"
az group delete -n "$group_name" --yes || :
#3. Create resource group in desired location (it might take a while), use: az account list-locations to list locations
echo "Creating group $group_name in location $location"
az group create -l "$location" -n "$group_name"
#4. Create aks cluster
echo "Creating cluster $group_name/$cluster_name with k8 $kubernetes_version and $node_count nodes of size $node_size"
az aks create --resource-group "$group_name" --name "$cluster_name" --kubernetes-version "$kubernetes_version" --node-vm-size "$node_size" --node-count "$node_count" --enable-addons monitoring --generate-ssh-keys
#5 Display nodes
echo "Listing your cluster nodes"
az aks get-credentials --resource-group "$group_name" --name "$cluster_name" --overwrite-existing
kubectl get nodes
#6 Ask if we continue
echo "Process to deploy jmeter kubernetes ?"
read answer
echo
#7 Deploy
echo "Deploying solution to namespace $cluster_namespace"
cd ../../kubernetes/bin && chmod +x *.sh && ./jmeter_cluster_create.sh "$cluster_namespace"
#wait for all pods to get deployed
wait_for_pods jmeter 1 5 influxdb-jmeter jmeter-master jmeter-grafana
#8 Create dashboards
echo "Creating grafana dashboards"
./dashboard.sh
#9 Test
echo "Test solution by running $test_jmx?"
read answer
echo
./start_test.sh
#10 Remaining
echo "Go to https://dev.azure.com/{organization}/{project}/_admin/_services to create a kubernetes service connection"
echo "You can now process to import Grafana Dashboard at .. automate with Selenium/Python 3.5.2"
echo "Login toyoru grafana at ...."
echo "Create aks service connection and permision all pipleines to ise"
#https://stackoverflow.com/questions/52335657/vsts-create-service-connection-via-api
echo "And create your pipeline in yoru azure devops"
echo "get ARtifactory credentials if you plan to use ARtifactiry step"
echo "Configure credentials"

#PART 2 - configure a pipelines in your devops organization

