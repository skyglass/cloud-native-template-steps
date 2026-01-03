#! /bin/bash -e

IFS=

kubectl get hr --all-namespaces -o json | \
    jq -r '.items[] | select(.status.conditions[].message | contains("install retries exhausted")) | .metadata.name, .metadata.namespace'  | while read -r name
do
  read -r namespace
  echo $namespace $name
  ./manage/redo-reconciliation.sh hr -n $namespace $name
done 

