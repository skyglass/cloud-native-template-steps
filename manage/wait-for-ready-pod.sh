#! /bin/bash -e

NAME=${1?}
NAMESPACE=${2?}
SELECTOR=${3}

if [ -z "$SELECTOR" ] ; then
  SELECTOR="app.kubernetes.io/instance=${NAME}"
fi

test_pod_readiness() {
  kubectl wait --namespace ${NAMESPACE?} \
    --for=condition=ready pod \
    --selector=${SELECTOR?} \
    --timeout=0s
}

echo -n waiting for ${NAME?}..

for i in $(seq 1 1200); do
  if test_pod_readiness > /dev/null 2>&1 ; then
    break;
  fi
  echo -n .
  sleep 1
done

test_pod_readiness

echo found ${NAME?}

