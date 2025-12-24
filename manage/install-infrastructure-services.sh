#! /bin/bash -e

helm repo add eventuate https://raw.githubusercontent.com/eventuate-platform/eventuate-helm-charts/helm-repository

helm repo update

helm upgrade --install kafka eventuate/kafka $HELM_INFRASTRUCTURE_OPTS --wait

helm upgrade --install authorization-server eventuate/authorization-server $HELM_INFRASTRUCTURE_OPTS --wait
