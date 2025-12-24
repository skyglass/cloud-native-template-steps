#! /bin/bash -e

helm upgrade --install foo-kafka eventuate/kafka $HELM_INFRASTRUCTURE_OPTS --wait

helm upgrade --install bar-authorization-server eventuate/authorization-server $HELM_INFRASTRUCTURE_OPTS --wait

helm upgrade --install baz-customer-service-postgres eventuate/postgres \
    $HELM_INFRASTRUCTURE_OPTS \
    --set postgresDatabase=customer_service \
    --set persistentStorage=false \
    --wait


helm upgrade --install qux-customer-service \
    --values ./test/customer-service-parameter-values.yaml \
    --wait \
    application/customer-service/customer-service-deployment/helm-charts/customer-service

for _i in {1..5}; do
    if helm test qux-customer-service ; then
        break
    fi
    echo retrying
    sleep 1
done

helm test qux-customer-service

helm uninstall qux-customer-service


printf "\nSUCCESS\n\n"
