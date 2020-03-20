#!/bin/bash
template="
{
  \"data\": {
    \"authorizationType\": \"Kubeconfig\"
  },
  \"name\": \"$1\",
  \"type\": \"kubernetes\",
  \"url\": \"$2\",
  \"authorization\": {
    \"parameters\": {
      \"clusterContext\": \"$3\",
      \"kubeConfig\": \"$(cat ~/.kube/config)\"},
    \"scheme\": \"Kubernetes\"
  },
  \"isShared\": false,
  \"isReady\": true,
  \"owner\": \"Library\"
}
"
echo  $template