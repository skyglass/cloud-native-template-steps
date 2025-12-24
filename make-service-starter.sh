#! /bin/bash -e

SDIR=helm-starters/service-starter

rm -fr ${SDIR?}

mkdir -p helm-starters

cp -r application/customer-service/customer-service-deployment/helm-charts/customer-service ${SDIR?}

. ./manage/_util.sh

find "${SDIR?}" -type f \(  -name "*.yaml" -o -name "*.tpl" -o -name "*.txt" \) -print0 | \
    xargs -0 "${PORTABLE_SED_COMMAND[@]}" -e 's/customer-service/<CHARTNAME>/'

find "${SDIR?}" -type f -name "*.yaml" -print0 | xargs -0 "${PORTABLE_SED_COMMAND[@]}" -e 's/customer_service/service_database/'

"${PORTABLE_SED_COMMAND[@]}" -e 's?/customers?/testUrlPath?' "${SDIR?}/templates/tests/test-service.yaml"

rm -fr ${SDIR?}/charts ${SDIR?}/Chart.lock
