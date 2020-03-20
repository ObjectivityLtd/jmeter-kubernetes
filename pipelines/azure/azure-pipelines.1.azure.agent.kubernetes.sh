#!/bin/bash
#edit CONFIG part of this file in your repo, commit. You will need PAT from your devop org. Makeit available as ENV variable $pat
#echo "export pat=your_devops_org_pat" > .bash_profile && source .bash_profile
#execute this in Azure CLI:
#cd ~ && rm -Rf jmeter-kubernetes && git clone https://github.com/ObjectivityLtd/jmeter-kubernetes && cd jmeter-kubernetes/pipelines/azure && chmod +x *.sh && ./azure-pipelines.1.azure.agent.kubernetes.sh

#CONFIG START
group_name=jmeter-group2
location=uksouth #use location close to your app
cluster_name=jubernetes
cluster_namespace=jmeter
kubernetes_version=1.15.10
node_size=Standard_D2_v2
node_count=3 #for real test use 5
#for test
home_dir=$(pwd)
test_jmx="cloudssky.jmx"
#your devops details
devops_org=gstarczewski
devops_project=jmeter
devops_service_connection_name=k8c #is used in example pipeline
devops_user=gstarczewski
#CONFIG END

#checking PAT exists
if [ -z "$pat" ]; then
    echo "You need to provide your PAT before running this script."
    echo  "Run: echo "export pat=your_devops_org_pat" > .bash_profile && source .bash_profile"
    return
  fi
#1. Delete service connection if exists
echo "Deleting k8 service connection $devops_service_connection_name if exists"
source ../bin/delete_service_connection $devops_org $devops_project $devops_user $pat $devops_service_connection_name

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
echo "Creating service connection"
source ../bin/create_service_connection $devops_org $devops_project $devops_user $pat $devops_service_connection_name $cluster_name $group_name

#6 Ask if we continue
echo "Process to deploy jmeter kubernetes ?"
read answer
echo

#7 Deploy
echo "Hit any key to deploy solution to namespace $cluster_namespace"
cd ../../kubernetes/bin && chmod +x *.sh && ./jmeter_cluster_create.sh "$cluster_namespace"
#wait for all pods to get deployed
source ../bin/wait_for_pods jmeter 1 5 influxdb-jmeter jmeter-master jmeter-grafana

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
echo "Go to https://dev.azure.com/${devops_org}/${devops_project}/_admin/_services "
echo "Grafana is at: "
echo "You can now use the pipeline: jmeter-kubernetes/pipelines/azure/azure-pipelines.1.azure.agent.kubernetes.yaml for starters "
