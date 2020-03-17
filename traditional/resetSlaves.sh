#!/bin/bash

reset_slaves() {
  local flask_control_port=$1
  local jmeter_server_version=$2
  local server_xms=$3
  local server_xmx=$4
  shift 5
  local jmeter_servers=("$@")

  for host in "${jmeter_servers[@]}"; do
    curl -X GET http://${host}:${flask_control_port}/restart/${jmeter_server_version}/${server_xms)}/${server_xmx}
  done
}

flask_control_port=$1
jmeter_server_version=$2
server_xms=$3
server_xmx=$4
shift 5
jmeter_servers=$("$@")

reset_slaves "${flask_control_port}" "${jmeter_server_version}" "${server_xms}" "${server_xmx}" "${jmeter_servers[@]}"
