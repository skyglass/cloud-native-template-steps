#! /bin/bash -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

while [ -n "$*" ] ; do
  case $1 in
    *)
      echo unknown "$1" - './encrypt-secrets.sh'
      exit 1
      ;;
  esac
  shift
done

ENCRYPTED_SECRET=flux/apps/base/encrypted-docker-secret.yaml

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
    > $ENCRYPTED_SECRET


sops --age="$PUBLIC_KEY" \
--encrypt --encrypted-regex '^(data|stringData)$' --in-place $ENCRYPTED_SECRET

git add $ENCRYPTED_SECRET
git commit -m "Updated secret" $ENCRYPTED_SECRET || echo nothing to commit

