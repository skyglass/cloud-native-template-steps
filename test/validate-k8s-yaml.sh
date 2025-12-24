#! /bin/bash -e

set -o pipefail

if [ -d application ] ; then
    SRC_DIRS=(application/*-service/*-deployment)
elif [ -d flux ] ; then
    SRC_DIRS=(flux)
else
    SRC_DIRS=(/dev/null)
fi

kc() {

    if [ ! -f /tmp/flux-crd-schemas/master-standalone-strict/alert-notification-v1beta1.json ] ; then
        mkdir -p /tmp/flux-crd-schemas/master-standalone-strict
        curl -sL https://github.com/fluxcd/flux2/releases/latest/download/crd-schemas.tar.gz | tar zxf - -C /tmp/flux-crd-schemas/master-standalone-strict
    fi

    kubeconform "-skip=Secret" -verbose "-strict" "-ignore-missing-schemas" -schema-location default "-schema-location" "/tmp/flux-crd-schemas" \
        -schema-location 'https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/{{.Group}}/{{.ResourceKind}}_{{.ResourceAPIVersion}}.json' \
        "$@"
}


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
        yq e 'true' "$file" > /dev/null
        kc "$file"
    fi
done

find "${SRC_DIRS[@]}" -type f -name 'kustomization.yaml' -o -name 'kustomization.yml' | while read -r file ; do
    KUSTOMIZATION_DIR=$(dirname "$file")
    echo "Validating KUSTOMIZATION_DIR=$KUSTOMIZATION_DIR"
    kustomize build "$KUSTOMIZATION_DIR" | kc
done

helm repo add eventuate https://raw.githubusercontent.com/eventuate-platform/eventuate-helm-charts/helm-repository

find "${SRC_DIRS[@]}" -name Chart.yaml | while read -r chart ; do
    echo "Validating $chart"
    CHART_DIR=$(dirname "$chart")

    rm -fr "$CHART_DIR/charts"
    helm dependency update "$CHART_DIR"
    helm lint "$CHART_DIR"
    helm template foo "$CHART_DIR" | kc
done
