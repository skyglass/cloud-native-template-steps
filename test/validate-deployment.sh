#! /bin/bash -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
MANAGE_DIR="$( cd "$DIR/../manage" >/dev/null 2>&1 && pwd )"

set -o pipefail

SKIP_TERRAFORM_APPLY=

while [ $# -gt 0 ] ; do
  case "$1" in
    --skip-terraform-apply)
      SKIP_TERRAFORM_APPLY=1
      ;;
    --*)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
  shift
done

if [ -z "$SKIP_TERRAFORM_APPLY" ] ; then
  $MANAGE_DIR/run-terraform.sh apply -auto-approve
fi

eval "$($MANAGE_DIR/run-terraform.sh output -raw update_config_command)"

kubectl get po

run_nginx() {
  helm upgrade --install --wait my-nginx oci://registry-1.docker.io/bitnamicharts/nginx

  kubectl get pods

  kubectl wait --for=condition=ready pod --selector=app.kubernetes.io/name=nginx 


  kubectl port-forward service/my-nginx 8888:http &

  PID=$!

  trap "kill $PID" EXIT

  echo
  echo

  if curl --retry-connrefused --retry 5 --retry-delay 1 --fail localhost:8888/index.html | grep 'Welcome to nginx!' ; then
    echo "=== SUCCESS!"
  else
    echo "=== FAILURE!"
  fi
  echo

  helm uninstall my-nginx
}

run_nginx
