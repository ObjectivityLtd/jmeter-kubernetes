#!/bin/bash
#edit CONFIG part of this file in your repo, commit. You will need PAT from your devop org. Makeit available as ENV variable $pat
#echo "export pat=your_devops_org_pat" > .bash_profile && source .bash_profile
#execute this in Azure CLI:
#cd ~ && rm -Rf jmeter-kubernetes && git clone https://github.com/ObjectivityLtd/jmeter-kubernetes && cd jmeter-kubernetes/pipelines/azure && chmod +x *.sh && ./azure-pipelines.1.azure.agent.kubernetes.sh jmeter-group2

#CONFIG START
#k8 cluster params
group_name=
location=uksouth #use location close to your app
cluster_name=jubernetes
cluster_namespace=jmeter
kubernetes_version=1.15.10
node_size=Standard_D2_v2
node_count=3 #for real test use 5
test_jmx="cloudssky.jmx"
#devops org details
devops_org=gstarczewski
devops_project=jmeter
devops_service_connection_name=k8c
devops_user=gstarczewski
#CONFIG END

t="\n########################################################################################################\n"
#checking resource_group
if [ -z "$group_name" ]; then
  echo "Group name not set in script. Trying to fetch from commandline."
  if [ -z "$1" ]; then
      echo "Group name not provided on commandline. Setting to default: jmeter-group"
      group_name=jmeter-group
  else
    group_name=$1
  fi
fi
#checking PAT exists
if [ -z "$pat" ]; then
    echo "You need to provide your PAT before running this script."
    echo  "Run: echo "export pat=your_devops_org_pat" > .bash_profile && source .bash_profile"
    exit 1
fi

# Delete service connection if exists
echo "Deleting k8 service connection $devops_service_connection_name if exists"
source bin/delete_service_connection.sh $devops_org $devops_project $devops_user $pat $devops_service_connection_name

# Delete entire resource group if exist:
echo "Deleting group $group_name if exists"
az group delete -n "$group_name" --yes || :

# Create resource group in desired location (it might take a while), use: az account list-locations to list locations
echo "Creating group $group_name in location $location"
az group create -l "$location" -n "$group_name"

# Create aks cluster
echo "Creating cluster $group_name/$cluster_name with k8 $kubernetes_version and $node_count nodes of size $node_size"
az aks create --resource-group "$group_name" --name "$cluster_name" --kubernetes-version "$kubernetes_version" --node-vm-size "$node_size" --node-count "$node_count" --enable-addons monitoring --generate-ssh-keys

# Display nodes
echo "Listing your cluster nodes"
az aks get-credentials --resource-group "$group_name" --name "$cluster_name" --overwrite-existing
kubectl get nodes

# Create service connection in devops org
echo "Creating service connection"
source bin/create_service_connection.sh $devops_org $devops_project $devops_user $pat $devops_service_connection_name $cluster_name $group_name

# Ask if we continue
printf "$t"
echo "Cluster is created. Process to deploy jmeter kubernetes ?"
read answer
echo

# Deploy services
echo "Hit any key to deploy solution to namespace $cluster_namespace"
cd $HOME/jmeter-kubernetes/kubernetes/bin && chmod +x *.sh && ./jmeter_cluster_create.sh "$cluster_namespace"

# Wait for all pods to get deployed
cd $HOME/jmeter-kubernetes/pipelines/azure && source bin/wait_for_pods.sh jmeter 1 5 influxdb-jmeter jmeter-master jmeter-grafana

# Create grafana dashboards
echo "Creating grafana dashboards"
cd $HOME/jmeter-kubernetes/kubernetes/bin && ./dashboard.sh

# Test
printf "$t"
echo "Solution is deployed and scaled. Hit any key to test solution by running $test_jmx from you kubernetes cluster"
read answer

echo
./start_test_from_script_params.sh $cluster_namespace $test_jmx

printf "$t"
echo "Congratulations!! It works!"
printf "$t"
printf "\n\t1. Go to https://dev.azure.com/${devops_org}/${devops_project}/_build to configure pipeline"
printf "\n\t2  Use this pipeline for start: jmeter-kubernetes/pipelines/azure/azure-pipelines.1.azure.agent.kubernetes.yaml"
printf "\n\t3  You service connection is $devops_service_connection_name"
printf  "\n\t4  Grafana is at: http://" && echo $(kubectl get -n $cluster_namespace all | grep service/jmeter-grafana | awk '{print $4}')
