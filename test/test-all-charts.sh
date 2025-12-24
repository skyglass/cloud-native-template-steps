#! /bin/bash -e

./manage/create-kind-cluster.sh

./manage/install-infrastructure-services.sh

./test/test-service-chart.sh api-gateway-service /swagger-ui/index.html
./test/test-service-chart.sh --no-build customer-service /customers
./test/test-service-chart.sh --no-build order-service /orders


