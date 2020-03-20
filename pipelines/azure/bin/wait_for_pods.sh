#!/bin/bash
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

wait_for_pods() {
  local service_namespace=$1
  local service_replicas_number=$2
  local sleep_time_s=$3
  shift 3
  IFS=' ' read -r -a services <<<"$@"
  for service in "${services[@]}"; do
    wait_for_pod $service_namespace $service $service_replicas_number $sleep_time_s
  done

}

wait_for_pods $@