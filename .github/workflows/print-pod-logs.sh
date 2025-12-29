#! /bin/bash -e

echo describing

mkdir -p ~/container-logs

if kubectl describe all >> ~/container-logs/describe-all.txt ; then
  echo described all SUCCEEDED
else
  echo described all FAILED
fi

echo described

if kubectl get po --all-namespaces >> ~/container-logs/pods.txt ; then
  for name in $(kubectl get po -o name | sed 's?pod/??') ; do
    echo getting log for $name
    (kubectl logs $name || echo cannot get log) > ~/container-logs/${name}.txt
    if kubectl logs $name --previous ; then 
      (kubectl logs $name --previous || echo cannot get previous log) > ~/container-logs/${name}-previous.txt
    fi
  done
fi

echo getting FluxCD resources

for x in kustomization helmrelease helmchart helmrepository secret sealedsecret ; do
  (kubectl get $x --all-namespaces || echo Cannot get $x) > ~/container-logs/get-${x}.txt
done

(kubectl get po -l app.kubernetes.io/instance=sealed-secrets-controller || echo could get seal secrets controller) > ~/container-logs/get-sealed-secrets-controller-pod.txt

(kubectl logs -l app.kubernetes.io/instance=sealed-secrets-controller -n flux-system || echo could get seal secrets controller logs) > ~/container-logs/sealed-secrets-controller-logs.txt