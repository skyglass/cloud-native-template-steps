#! /bin/bash -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

set -o pipefail

SKIP_TERRAFORM_DESTROY=
TF_OPTS=

while [ $# -gt 0 ] ; do
  case "$1" in
    --skip-terraform-destroy)
      SKIP_TERRAFORM_DESTROY=1
      ;;
    --auto-approve)
      TF_OPTS=-auto-approve
      ;;
    --*)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
  shift
done


flux uninstall --silent || echo "Flux not installed"

helm uninstall $(helm list --short) || echo "Helm charts not installed"

helm uninstall -n ingress-nginx $(helm list -n ingress-nginx --short) || echo "ingress-nginx Helm charts not installed"

kubectl delete pvc --all || echo "Failed to delete PVCs"

# Remove any load balancers
# kubectl delete namespace ingress-nginx || echo "Ingress Nginx not installed"

if [ -z "$SKIP_TERRAFORM_DESTROY" ] ; then
  "$DIR/run-terraform.sh" destroy $TF_OPTS
fi
