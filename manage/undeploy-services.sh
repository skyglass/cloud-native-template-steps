#! /bin/bash -e

helm uninstall api-gateway-service || echo uninstall failed
helm uninstall customer-service || echo uninstall failed

for dir in application/*-service/*-deployment/k8s ; do
    kubectl delete -k "$dir" || echo nothing to delete
done
