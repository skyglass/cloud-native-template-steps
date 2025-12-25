#! /bin/bash -e

echo describing

mkdir -p ~/container-logs

if kubectl describe all >> ~/container-logs/describe-all.txt ; then
  echo described all SUCCEEDED
else
  echo described all FAILED
fi

echo described

if kubectl get po >> ~/container-logs/pods.txt ; then
  for name in $(kubectl get po -o name | sed 's?pod/??') ; do
    echo getting log for $name
    (kubectl logs $name || echo cannot get log) > ~/container-logs/${name}.txt
    if kubectl logs $name --previous ; then 
      (kubectl logs $name --previous || echo cannot get previous log) > ~/container-logs/${name}-previous.txt
    fi
  done
fi

for x in kustomization helmrelease helmchart ; do
  (kubectl get $x --all-namespaces || echo Cannot get $x) > ~/container-logs/${x}.txt
done