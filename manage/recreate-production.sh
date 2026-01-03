#! /bin/bash -e

kind delete cluster --name lp-cluster-production
./manage/bootstrap-flux-production.sh
