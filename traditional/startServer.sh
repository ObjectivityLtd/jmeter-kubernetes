#!/bin/bash

restart_jmeter_server() {
  version=$1
  heap=$2
  killall "/usr/bin/java" || :
  export HEAP="$heap"
  cd ${version}/bin
  ./jmeter-server -Jserver.rmi.ssl.disable=true &
}

version=$1
xms=$2
xmx=$3
restart_jmeter_server "${version}" "${xms} ${xmx}"