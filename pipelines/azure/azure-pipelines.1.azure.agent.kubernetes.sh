#!/bin/bash
#How to prepare all necessary azure resources to keep cost under control ?
#Note: all of this can also be done in UI, howver for automartion I am presenting a CLI version.
#edit this file, commit, in your devops org create PAT and make it available as env variable $pat
#execute this in CLI:
#cd ~ && rm -Rf jmeter-kubernetes && git clone https://github.com/ObjectivityLtd/jmeter-kubernetes && cd jmeter-kubernetes/pipelines/azure && chmod +x *.sh && ./azure-pipelines.1.azure.agent.kubernetes.sh

#config cluster
group_name=jmeter-group
location=uksouth
cluster_name=jubernetes
cluster_namespace=jmeter
kubernetes_version=1.15.10
node_size=Standard_D2_v2
node_count=3
#for test
home_dir=$(pwd)
test_jmx="cloudssky.jmx"
#your devops details
devops_org=gstarczewski
devops_project=jmeter
devops_service_connection_name=k8c
devops_user=gstarczewski
devops_pat=calzm6eokgoy7m3m54ikqkocdzqfxskaw6o2h3al34wgj4jngoxa

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
    service_replicas=$(kubectl -n $service_namespace get all | grep pod/$service | awk '{print $2}')
    echo "Service $service_name pods ready: $service_replicas"
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

}

delete_service_connection(){
  local org=$1
  local project=$2
  local user=$3
  local pat=$4
  local service_connection_name=$5
  silent=" -s -o /dev/null"
  verbose=" -v"
  opts="$silent"

  service_connection_id=$(curl --user $user:$pat https://dev.azure.com/$org/project/_apis/serviceendpoint/endpoints?endpointNames=${service_connection_name} | jq '.value[0].id' | sed "s/\"//g" )
 echo "id: $service_connection_id"
 if [ -z "$service_connection_id" ]; then
        echo "Cannot get id. skipping connection deletion"
        return
 fi

 http_code=$(curl $opts -w "%{http_code}"  --user $user:$pat -X DELETE https://dev.azure.com/$org/$project/_apis/serviceendpoint/endpoints/${service_connection_id}?api-version=5.1-preview.2)

  echo "Http code: $http_code"
  if [ "$http_code" != "204" ]; then
      echo "Connection $service_connection_name by id $service_connection_id was not deleted."
  else
      echo "Connection $service_connection_name was deleted. "
  fi

}

#1. Delete service connection if exists
echo "Deleting k8 service connection $devops_service_connection_name if exists"
delete_service_connection $devops_org $devops_project $devops_user calzm6eokgoy7m3m54ikqkocdzqfxskaw6o2h3al34wgj4jngoxa $devops_service_connection_name
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
echo "Hit any key to deploy solution to namespace $cluster_namespace"
cd ../../kubernetes/bin && chmod +x *.sh && ./jmeter_cluster_create.sh "$cluster_namespace"
#wait for all pods to get deployed
wait_for_pods jmeter 1 5 influxdb-jmeter jmeter-master jmeter-grafana
#8 Create dashboards
echo "Creating grafana dashboards"
cd $HOME/jmeter-kubernetes/kubernetes/bin && ./dashboard.sh
#9 Test
echo
echo "Hit any key to test solution by running $test_jmx from you kubernetes cluster"
read answer
echo
./start_test_from_script_params.sh $cluster_namespace $test_jmx
#10 Remaining

echo "Congratulations!! It works!"
echo "########################################################################################################"
echo "Go to https://dev.azure.com/${devops_org}/${devops_project}/_admin/_services to create a kubernetes $devops_service_connection_name service connection"
echo "Grafana is at: "
echo "You can now use that pipeline: "