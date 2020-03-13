#!/bin/bash
#wait until given service scales to desired quantity
wait_for_service_to_scale() {
  cluster_namespace=$1
  service_name=$2
  service_replicas_number=$3
  sleep_time_s=$4
  service_replicas=0/1

  until [ "$service_replicas" == "$service_replicas_number/$service_replicas_number" ]; do
    echo "Wait for service $service_name to scale to $service_replicas_number for $sleep_time_s seconds"
    sleep $sleep_time_s
    service_replicas=$(kubectl get pods -n $cluster_namespace | grep Running | grep $service_name | awk '{print $2}')
    echo "Service $service_name replicas: $service_replicas"
  done
}

wait_for_service_to_scale $1 $2 $3 $4