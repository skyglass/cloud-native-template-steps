#! /bin/bash -e

helm uninstall $(helm list --short | grep -E '^(eventuate-cdc|kafka|postgres|zookeeper|keycloak)$')

PVC=$(kubectl get pvc -o=name | grep -E '/(kafka-persistent-storage-kafka|postgres-persistent-storage-postgres|zookeeper-persistent-storage-zookeeper)-0$')

if [ -n "$PVC" ] ; then
    kubectl delete $PVC
fi

