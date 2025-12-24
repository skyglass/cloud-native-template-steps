#! /bin/bash -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

"$DIR/test-service-chart.sh" "$@" api-gateway-service /swagger-ui/index.html /swagger-ui/index.html
"$DIR/test-service-chart.sh" "$@" --no-build --with-auth customer-service /customers /customers
"$DIR/test-service-chart.sh" "$@" --no-build --with-auth order-service /orders /orders

printf "\nSUCCESS\n\n"

