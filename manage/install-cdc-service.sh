#! /bin/bash -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

helm repo add eventuate https://raw.githubusercontent.com/eventuate-platform/eventuate-helm-charts/helm-repository

helm upgrade --install --version v0.1.0-BUILD.20230710151355 eventuate-cdc eventuate/eventuate-cdc $HELM_INFRASTRUCTURE_OPTS \
    --wait --values ${DIR}/cdc-values.yaml

