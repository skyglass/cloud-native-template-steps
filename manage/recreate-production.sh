#! /bin/bash -e

kind delete cluster --name lp2-cluster-production
./manage/bootstrap-flux-production.sh
