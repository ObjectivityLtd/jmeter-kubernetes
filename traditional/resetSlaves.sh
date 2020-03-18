#!/bin/bash

# This script resets all jmeter slaves by calling control endpoint (flask) on teh server that fires starServer.sh
#
#
reset_slaves() {
  local flask_control_port=$1
  local jmeter_server_version=$2
  local server_xms=$3
  local server_xmx=$4
  local curl_basic_auth=$5
  shift 5
  #string to list
  IFS=' ' read -r -a servers <<< "$@"
  echo "Servers parsed: ${servers[@]}"
  for host in "${servers[@]}"; do
    command="curl --user ${curl_basic_auth} -s -o /dev/null -w \"%{http_code}\" -X GET http://${host}:${flask_control_port}/restart/${jmeter_server_version}/${server_xms}/${server_xmx}"
    echo "${command}"
    http_code=$(echo "$command" | bash)
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
curl_basic_auth=$5
shift 5
jmeter_servers=$@

echo "jmeter xmx: ${server_xmx}"
echo "jmeter servers: ${jmeter_servers}"

reset_slaves "${flask_control_port}" "${jmeter_server_version}" "${server_xms}" "${server_xmx}" "${curl_basic_auth}" "${jmeter_servers[@]}"
