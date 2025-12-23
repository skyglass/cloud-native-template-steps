#! /bin/bash -e

./manage/create-kind-cluster.sh

./manage/install-infrastructure-services.sh

./test/test-all-services.sh 

./manage/install-cdc-service.sh 

(cd application ; ./gradlew endToEndTestsUsingKind)