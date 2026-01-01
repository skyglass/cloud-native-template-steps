#! /bin/bash -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

set -o pipefail

while [ -n "$*" ] ; do
  case $1 in
    --*)
      echo unknown "$1" - './encrypt-secrets.sh [cluster]'
      ;;
    *)
      break
      ;;

  esac
  shift
done

CLUSTER_NAME=${1:-dev}

ENCRYPTED_GITHUB_TOKEN=flux/apps/${CLUSTER_NAME}/encrypted-github-docker.yaml
ENCRYPTED_DOCKER_SECRET=flux/apps/${CLUSTER_NAME}/encrypted-docker-secret.yaml
AGE_KEY=${AGE_KEY_DIR?}/${CLUSTER_NAME}/keys.txt

PUBLIC_KEY=$(sed -e '/public key:/!d' -e 's/.*public key: //' < "${AGE_KEY?}")

if ! kubectl get secret sops-age > /dev/null 2>&1 ; then
    kubectl create secret generic sops-age \
      --namespace=default \
      --from-file=age.agekey="${AGE_KEY?}"
fi

kubectl create secret -n default docker-registry ghcr.io \
    --docker-server="${GITHUB_DOCKER_SERVER?}" \
    --docker-username="${GITHUB_USER?}" \
    --docker-password="${GITHUB_TOKEN?}" \
    --dry-run=client \
    -o yaml \
    > "$ENCRYPTED_DOCKER_SECRET"


sops --age="$PUBLIC_KEY" \
  --encrypt --encrypted-regex '^(data|stringData)$' --in-place "$ENCRYPTED_DOCKER_SECRET"

kubectl create secret generic github-token \
    --from-literal=token="${GITHUB_TOKEN}" \
    --dry-run=client \
    -o yaml \
    > "$ENCRYPTED_GITHUB_TOKEN"

sops --age="$PUBLIC_KEY" \
  --encrypt --encrypted-regex '^(data|stringData)$' --in-place "$ENCRYPTED_GITHUB_TOKEN"

git add "$ENCRYPTED_GITHUB_TOKEN" "$ENCRYPTED_DOCKER_SECRET"

git commit -m "Updated secret" "$ENCRYPTED_GITHUB_TOKEN" "$ENCRYPTED_DOCKER_SECRET" || echo nothing to commit
