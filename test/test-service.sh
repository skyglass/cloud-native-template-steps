#! /bin/bash -e

NO_BUILD=
WITH_AUTH=
NO_DELETE=

while [[ "$1" == --* ]] ; do
  case $1 in
    "--no-build" )
      NO_BUILD=yes
      ;;
    "--with-auth" )
      WITH_AUTH=yes
      ;;
    "--no-delete-existing" )
      NO_DELETE=yes
      ;;
    --*)
      echo ./test/test-service.sh --no-build service_name path
      exit 1
      ;;
  esac
  shift
done

service_name=${1?}
path=${2?}

if [ -z "$service_name" ] ; then
  echo Service name cannot be empty
  exit 1
fi

if [ -z "$path" ] ; then
  echo path cannot be empty
  exit 1
fi

printf "\n== Testing service: %s\n\n" "$service_name"

gradle_build() {
    if [ -z "$NO_BUILD" ] ; then
        (cd application ;  ./gradlew -P imageVersion=0.1.0-SNAPSHOT buildDockerImageLocally)
    else
        echo skipping build
    fi
}

ping_url() {
    pod="${1?}"
    host="${2-localhost:8080}"

    printf "\nPINGING %s %s ...\n\n" "$pod" "$host"

    authOpts=()

    if [ -n "$WITH_AUTH" ] ; then
      echo getting JWT
      JWT=$(./test/get-jwt.sh)
      authOpts=("-H" "Authorization: Bearer $JWT")
    fi

    echo accessing "$host${path?}" with authOpts "${authOpts[@]}"

    kubectl exec "$pod" -- curl "${authOpts[@]}" --retry-connrefused --retry 5 --retry-delay 1 --fail "$host${path?}"

    printf "\nPINGED %s %s\n" "$pod" "$host"
}

deploy_service() {
    k8s_dir="application/${service_name}/${service_name}-deployment/k8s"
    if [ -z "$NO_DELETE" ] ; then
      kubectl delete -R -f "$k8s_dir" --wait || echo nothing to delete
    fi

    kubectl apply -R -f "$k8s_dir"
}

test_deployment_readiness() {
    kubectl wait -n default deployment/${service_name} --for condition=Available=True --timeout=0s
}

wait_for_ready_pod() {
    echo -n Waiting for deployment/${service_name}...
    
    for i in $(seq 1 100); do
      if test_deployment_readiness  ; then
        break;
      fi
      echo -n .
      sleep 1
    done

    test_deployment_readiness
    echo Ready
}

gradle_build

deploy_service

wait_for_ready_pod

service_pod=$(kubectl get pod -l "service-name=${service_name}" -o name)

service_pod=${service_pod#pod/}

ping_url "$service_pod"

ping_url "$service_pod" "$service_name"

printf "\nSUCCESS %s\n\n" "$service_name"



