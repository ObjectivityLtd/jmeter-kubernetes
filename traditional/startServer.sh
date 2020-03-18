#!/bin/bash

restart_jmeter_server() {
  version=$1
  heap=$2
  killall "/usr/bin/java" || :
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
  echo "$pid"
}

version=$1
xms=$2
xmx=$3
restart_jmeter_server "${version}" "${xms} ${xmx}"
~
