#! /bin/bash -e

if  ! kubectl get secret "$@" -o name | grep  secret/ghcr.io > /dev/null ; then
    kubectl create secret docker-registry ghcr.io "$@" \
    --docker-server="${GITHUB_DOCKER_SERVER?}" \
    --docker-username="${GITHUB_USER?}" \
    --docker-password="${GITHUB_TOKEN?}"
else
    echo secret exists
fi
