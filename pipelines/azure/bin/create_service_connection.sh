#!/bin/bash
create_service_connection() {
  local org=$1
  local project=$2
  local user=$3
  local pat=$4
  local name=$5

  echo "Creating $name kubernetes connection"
  local cluster_name=$6
  local resource_group=$7

  url=$(az aks show --name $cluster_name --resource-group $resource_group | jq '.fqdn' | sed "s/\"//g") || :
  if [ -z "$url" ]; then
    echo "Cannot get cluster name. Is it created? Skipping connection creation."
    return
  fi
  url=https://$url
  printf "For cluster: \n\t cluster_name: $cluster_name \n\t url: $url"
  local path=$HOME/jmeter-kubernetes/pipelines/azure/bin
  source $path/template.json.sh $name $url $cluster_name $resource_group> $path/payload.json
  echo "Sending payload"
  cat $path/payload.json
  http_code=$(curl -s -o /dev/null -w "%{http_code}" --user $user:$pat -X POST -H "Content-Type: application/json" --data-binary  @$path/payload.json https://dev.azure.com/$org/$project/_apis/serviceendpoint/endpoints?api-version=5.0-preview.2)
  echo "Http code: $http_code"
  if [ "$http_code" != "200" ]; then
    echo "Connection $name was not created"
  else
    echo "Connection $name was created. "
  fi
}
create_service_connection $@