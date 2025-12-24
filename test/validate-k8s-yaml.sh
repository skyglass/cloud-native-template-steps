#! /bin/bash -e

set -o pipefail

SRC_DIRS=(application/*-service/*-deployment)

echo "${SRC_DIRS[@]}"

find "${SRC_DIRS[@]}" -type f -name '*.yaml' -o -name '*.yml' | while read -r file ; do
    echo "INFO - Validating $file"
    d=$(dirname "$file")
    if [ -f "$d/kustomization.yaml" ] ; then
        echo "INFO - Skipping $file as it is part of a kustomization"
    elif [ -f "$d/Chart.yaml" ] || [ -f "$d/../Chart.yaml" ] || [ -f "$d/../../Chart.yaml" ] ; then
        echo "INFO - Skipping $file as it is part of a helm chart"
    else 
        echo "INFO - Validating $file"
        kubeconform -verbose -strict "$file"
    fi
done

find "${SRC_DIRS[@]}" -type f -name 'kustomization.yaml' -o -name 'kustomization.yml' | while read -r file ; do
    KUSTOMIZATION_DIR=$(dirname "$file")
    echo "Validating KUSTOMIZATION_DIR=$KUSTOMIZATION_DIR"
    kustomize build "$KUSTOMIZATION_DIR" | kubeconform -verbose -strict
done

helm repo add eventuate https://raw.githubusercontent.com/eventuate-platform/eventuate-helm-charts/helm-repository

find "${SRC_DIRS[@]}" -name Chart.yaml | while read -r chart ; do
    echo "Validating $chart"
    CHART_DIR=$(dirname "$chart")

    rm -fr "$CHART_DIR/charts"
    helm dependency update "$CHART_DIR"
    helm lint "$CHART_DIR"
    helm template foo "$CHART_DIR" | kubeconform -verbose -strict
done
