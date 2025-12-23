#! /bin/bash -e

set -o pipefail

CLUSTER_NAME=lp-cluster

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# See https://kind.sigs.k8s.io/docs/user/local-registry/

reg_port=5002
reg_name="registry"

if docker ps --format '{{.Names}}' | grep -E "^${reg_name}\$" ; then
  echo registry container already exists
else
  (cd application ; ./gradlew :api-gateway-service:api-gateway-service-main:startDockerRegistry)
fi

if kind get clusters | grep -E "^$CLUSTER_NAME$" ; then
  echo cluster $CLUSTER_NAME already exists
else
  cat <<EOF | kind create cluster --name $CLUSTER_NAME --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
containerdConfigPatches:
- |-
  [plugins."io.containerd.grpc.v1.cri".registry]
    config_path = "/etc/containerd/certs.d"
EOF
fi

REGISTRY_DIR="/etc/containerd/certs.d/localhost:${reg_port}"
for node in $(kind get nodes --name lp-cluster); do
  echo configuring $node
  docker exec "${node}" mkdir -p "${REGISTRY_DIR}"
  cat <<EOF | docker exec -i "${node}" cp /dev/stdin "${REGISTRY_DIR}/hosts.toml"
[host."http://${reg_name}:5000"]
EOF
done

if [ "$(docker inspect -f='{{json .NetworkSettings.Networks.kind}}' "${reg_name}")" = 'null' ]; then
  docker network connect "kind" "${reg_name}"
fi

echo
echo Finished configuration
echo