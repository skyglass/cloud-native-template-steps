#! /bin/bash -e

cat $(find application/*/*deployment/k8s -type f) | \
    kubectl delete -f -