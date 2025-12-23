#! /bin/bash -e

helm repo add eventuate https://raw.githubusercontent.com/eventuate-platform/eventuate-helm-charts/helm-repository

helm repo update

helm upgrade --install kafka eventuate/kafka $HELM_INFRASTRUCTURE_OPTS --wait

helm upgrade --install authorization-server eventuate/authorization-server $HELM_INFRASTRUCTURE_OPTS --wait

helm upgrade --install customer-service-postgres eventuate/postgres \
    $HELM_INFRASTRUCTURE_OPTS \
    --set postgresDatabase=customer_service \
    --set persistentStorage=false \
    --wait

helm upgrade --install order-service-postgres eventuate/postgres \
    $HELM_INFRASTRUCTURE_OPTS \
    --set postgresDatabase=order_service \
    --set persistentStorage=false \
    --wait
