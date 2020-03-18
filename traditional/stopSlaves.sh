#!/bin/bash

# This script stops all jmeter slaves by calling control endpoint (flask) on teh server that fires stoServer.sh
#
#

reset_slaves() {
  local flask_control_port=$1
  local curl_basic_auth=$2
  shift 2
  #string to list
  IFS=' ' read -r -a servers <<<"$@"
  echo "Servers parsed: ${servers[@]}"
  for host in "${servers[@]}"; do
    command="curl --user ${curl_basic_auth} -s -o /dev/null -w \"%{http_code}\" -X GET http://${host}:${flask_control_port}/stop"
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
curl_basic_auth=$2
shift 2
jmeter_servers=$@
echo "jmeter servers: ${jmeter_servers}"

reset_slaves "${flask_control_port}" "${curl_basic_auth}" "${jmeter_servers[@]}"
