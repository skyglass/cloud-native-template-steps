#! /bin/bash -e

service_name="${1?}"
test_url_path="${2?}"

CDIR="application/${service_name}/${service_name}-deployment/helm-charts/${service_name}"

rm -fr "${CDIR?}"

helm create "${CDIR?}" --starter "$(PWD)/helm-starters/service-starter"

. ./manage/_util.sh

db_name="${service_name//-/_}"

find "${CDIR?}" -type f -name "*.yaml" -print0 | xargs -0 "${PORTABLE_SED_COMMAND[@]}" -e "s/service_database/${db_name}/"

"${PORTABLE_SED_COMMAND[@]}" -e 's/appVersion:.*/appVersion: 0.1.0-SNAPSHOT/' "$CDIR/Chart.yaml"

"${PORTABLE_SED_COMMAND[@]}" -e "s?/testUrlPath?$test_url_path?" "${CDIR?}/templates/tests/test-service.yaml"

sed '/dependencies/,$!d' < application/customer-service/customer-service-deployment/helm-charts/customer-service/Chart.yaml \
  >> "$CDIR/Chart.yaml"

echo SUCCESSFULLY generated "$CDIR"