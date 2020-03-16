#!/bin/bash

#This is an example of artifactory upload, report_dir is read from pipeline config, token should be provided in azure
#as secret

upload() {
  artifact_name=$1
  report_dir=$2
  base_url=$3
  repo=$4
  namespace=$5
  access_token=$6
  id=$(date | sed "s/ /_/g" | sed "s/:/_/g") && cd $report_dir && zip -r $artifact_name .
  http_code=$(curl -s -o /dev/null -w "%{http_code}" -H "X-JFrog-Art-Api:$access_token" -X PUT "${base_url}/artifactory/${repo}/${namespace}/${id}/${artifact_name}" -T ${artifact_name})
  if [ "$http_code" != "201" ]; then
    echo "Artifact upload failed with $http_code"
    exit 1
  fi
}

#upload.sh report.zip $(report_dir) http://10.1.137.108:8081 jmeter-artifacts cloudssky $(token)
upload $1 $2 $3 $4 $5 $6
