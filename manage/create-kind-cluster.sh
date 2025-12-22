#! /bin/bash -e

CLUSTER_NAME=lp-cluster

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

if kind get clusters | grep -E "^$CLUSTER_NAME$" ; then
  echo cluster $CLUSTER_NAME already exists
else
  kind create cluster --name $CLUSTER_NAME
fi

