#!/bin/bash

restart_jmeter_server() {
  home=$(pwd)
  version=$1
  heap=$2
  source stopServer.sh
  export HEAP="$heap"
  cd ${version}/bin
  ./jmeter-server -Jserver.rmi.ssl.disable=true &
  heap_filter=$(echo $heap | sed "s/-/\\\-/g")
  pid=""
  until [ "$pid" != "" ]; do
         pid=$(ps -au | grep java | grep ApacheJMeter.jar | grep "$heap_filter" | awk '{print $2}')
         sleep 3
         echo "pid: $pid, waiting for new pid"
  done
  cd "$home"
  echo "$pid">jmeter.pid
}

version=$1
xms=$2
xmx=$3
restart_jmeter_server "${version}" "${xms} ${xmx}"
