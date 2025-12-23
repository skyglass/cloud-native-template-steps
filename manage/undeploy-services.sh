#! /bin/bash -e

for dir in application/*-service/*-deployment/k8s ; do
    kubectl delete -k "$dir" || echo nothing to delete
done    