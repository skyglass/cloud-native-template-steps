#! /bin/bash -e

# use sed to replace DUMMY_.* with DUMP_<current timestamp> in application/customer-service/customer-service-deployment/helm-charts/customer-service/values.yaml

FILE=application/customer-service/customer-service-deployment/helm-charts/customer-service/values.yaml

sed -i '' -e "s/DUMMY_.*$/DUMMY_$(date +%s)/" $FILE

git commit -m "Triggering build" $FILE

git push
