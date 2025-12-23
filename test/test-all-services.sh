#! /bin/bash -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

"$DIR/test-service.sh" "$@" api-gateway-service /swagger-ui/index.html
"$DIR/test-service.sh" "$@" --no-build --with-auth customer-service /customers
"$DIR/test-service.sh" "$@" --no-build --with-auth order-service /orders

API_GATEWAY_POD=$(kubectl get pod -l service-name=api-gateway-service -o name)

kubectl exec "$API_GATEWAY_POD" -- curl -u user:password localhost:8080/customers
kubectl exec "$API_GATEWAY_POD" -- curl -u user:password localhost:8080/orders

printf "\nSUCCESS\n\n"

