#! /bin/bash -e

set -o pipefail

if [ -d app/application ] ; then 
    cd app/application
else
    cd ../application
fi

INGRESS_HOST=$(kubectl get ingress api-gateway-service -o=jsonpath='{.status.loadBalancer.ingress[0].hostname}')

if [ -z "$INGRESS_HOST" ] ; then
    echo "Error: Failed to get ingress hostname"
    exit 1
fi

curl --retry-connrefused --retry 5 --retry-delay 1 --fail "$INGRESS_HOST/swagger-ui/index.html"

./gradlew --no-build-cache :end-to-end-tests:clean \
    :end-to-end-tests:endToEndTest \
    -P endToEndTestMode=Kind \
    -P endToEndTestHostName="$INGRESS_HOST"

