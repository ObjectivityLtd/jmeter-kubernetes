#!/usr/bin/env bash
#Script created to launch Jmeter tests directly from the current terminal without accessing the jmeter master pod.
#It requires that you supply the path to the jmx file
#After execution, test script jmx file may be deleted from the pod itself but not locally.

working_dir="`pwd`"

#Get namesapce variable
tenant="$1"
jmx="$2"
scenario_dir=$working_dir/../../jmeter/as_jmx
report_dir=$working_dir/../tmp/report_dir


test_name="$(basename "$scenario_dir/$jmx")"
#delete evicted pods first
kubectl get pods --all-namespaces --field-selector 'status.phase==Failed' -o json | kubectl delete -f -
#Get Master pod details

master_pod=`kubectl get po -n $tenant | grep Running | grep jmeter-master | awk '{print $1}'`

kubectl cp "$scenario_dir/$jmx" -n $tenant "$master_pod:/$test_name"

## Echo Starting Jmeter load test

threads=1
tmp=/tmp
jmeter_args=$3

echo "Threads $threads"
echo "Report dir $report_dir"
echo "Jmeter args $jmeter_args"
kubectl exec -ti -n $tenant $master_pod -- rm -Rf "$tmp"
kubectl exec -ti -n $tenant $master_pod -- mkdir -p "$tmp/$report_dir"
kubectl exec -ti -n $tenant $master_pod -- /bin/bash /load_test "$test_name -l $tmp/results.csv -e -Gthreads=$threads $jmeter_args -o $tmp/$report_dir"
kubectl cp "$tenant/$master_pod:$tmp/$report_dir" "$report_dir"
ls -alh
pwd
