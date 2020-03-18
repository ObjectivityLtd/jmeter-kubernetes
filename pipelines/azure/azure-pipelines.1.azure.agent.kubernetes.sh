#!/bin/bash
#How to prepare all necessary azure resources to keep cost under control ?
#Note: all of this can also be done in UI, howver for automartion I am presenting a CLI version.
#PART 1 - create a kubernetes cluster in Azure, execute as one command:
#rm -Rf jmeter-kubernetes && git clone https://github.com/ObjectivityLtd/jmeter-kubernetes && cd jmeter-kubernetes/pipelines/azure && ./azure-pipelines.1.azure.agent.kubernetes.sh

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

#1. Open Azure CLI
#2. Delete entire resource group if exist:
    echo "Deleting group $group_name if exists"
    az group delete -n "$group_name" --yes ||:
#3. Create resource group in desired location (it might take a while), use: az account list-locations to list locations
    echo "Creating group $group_name in location $location"
    az group create -l "$location" -n "$group_name"
#4. Create aks cluster
    echo "Creating cluster $group_name/$cluster_name with k8 $kubernetes_version and $node_count nodes of size $node_size"
    az aks create --resource-group "$group_name" --name "$cluster_name" --kubernetes-version "$kubernetes_version"  --node-vm-size "$node_size" --node-count "$node_count" --enable-addons monitoring --generate-ssh-keys
#5 Display nodes
    echo "Listing your cluster nodes"
    az aks get-credentials --resource-group "$group_name" --name "$cluster_name" --overwrite-existing
    kubectl get nodes
#6 Ask if we continue
    echo "Process to deploy jmeter kubernetes ?"
    read answer
    echo
#7 Checking out the project
#8 Deploy
    echo "Deploying solution to namespace $cluster_namespace"
    cd ../../kubernetes/bin && ./jmeter_cluster_create.sh "$cluster_namespace" && ./dashboard
#9 Test
    echo "Test solution by running $test_jmx?"
    read answer
    echo
    ./start_test.sh
#10
    echo "You can now process to import Grafana Dashboard at .."
    echo "And create your pipeline in yoru azure devops"




#PART 2 - configure a pipelines in your devops organization