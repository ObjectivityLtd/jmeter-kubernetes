#!/bin/bash

reset_slaves() {
  local flask_control_port=$1
  local jmeter_server_version=$2
  local server_xms=$3
  local server_xmx=$4
  shift 5
  local servers=("$@")
  echo "Servers: $servers"
  for host in "${servers[@]}"; do
    command="curl -s -o /dev/null -w '%{http_code}' -X GET http://${host}:${flask_control_port}/restart/${jmeter_server_version}/${server_xms}/${server_xmx}"
    echo "c: ${command}"
    http_code=$(command)
    if [ "$http_code" != "200" ]; then
    echo "Operation failed with code:  $http_code"
    exit 1
    fi
    echo "Result: ${http_code}"
  done
}

flask_control_port=$1
jmeter_server_version=$2
server_xms=$3
server_xmx=$4
shift 4
jmeter_servers=$("$@")

echo "jmeter servers: ${jmeter_servers}"

reset_slaves "${flask_control_port}" "${jmeter_server_version}" "${server_xms}" "${server_xmx}" "${jmeter_servers[@]}"
