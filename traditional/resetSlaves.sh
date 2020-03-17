#!/bin/bash

reset_slaves() {
  local flask_control_port=$1
  local jmeter_server_version=$2
  local server_xms=$3
  local server_xmx=$4
  shift 4
  local jmeter_servers=("$@")

  for host in "${jmeter_servers[@]}"; do
    command="curl -s -o /dev/null -w '%{http_code}' -X GET http://${host}:${flask_control_port}/restart/${jmeter_server_version}/${server_xms}/${server_xmx}"
    echo "c: ${command}"
    http_code=$(command)
    if [ "$http_code" != "200" ]; then
    echo "Operation failed with code:  $http_code"
    exit 1
    fi
  done
}

flask_control_port=$1
jmeter_server_version=$2
server_xms=$3
server_xmx=$4
shift 5
jmeter_servers=$("$@")

reset_slaves "${flask_control_port}" "${jmeter_server_version}" "${server_xms}" "${server_xmx}" "${jmeter_servers[@]}"
