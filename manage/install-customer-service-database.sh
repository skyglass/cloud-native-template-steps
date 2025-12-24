#! /bin/bash -e

helm upgrade --install customer-service-postgres eventuate/postgres \
    $HELM_INFRASTRUCTURE_OPTS \
    --set postgresDatabase=customer_service \
    --set persistentStorage=false \
    --wait
