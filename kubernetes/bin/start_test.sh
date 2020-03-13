#!/usr/bin/env bash
#Script created to launch Jmeter tests directly from the current terminal without accessing the jmeter master pod.
#It requires that you supply the path to the jmx file
#After execution, test script jmx file may be deleted from the pod itself but not locally.

working_dir="$(pwd)"
scenario_dir=$working_dir/../../jmeter/as_jmx

#Get namesapce variable
tenant=`awk '{print $NF}' "$working_dir/../tmp/tenant_export"`

jmx="$1"
[ -n "$jmx" ] || read -p 'Enter path to the jmx file in jmeter/as_jmx' jmx

if [ ! -f "$scenario_dir/$jmx" ];
then
    echo "Test script file was not found in PATH"
    echo "Kindly check and input the correct file path"
    exit
fi

test_name="$(basename "$scenario_dir/$jmx")"

#Get Master pod details

master_pod=`kubectl get po -n $tenant | grep jmeter-master | awk '{print $1}'`

kubectl cp "$scenario_dir/$jmx" -n $tenant "$master_pod:/$test_name"

## Echo Starting Jmeter load test

kubectl exec -ti -n $tenant $master_pod -- /bin/bash /load_test "$test_name"
