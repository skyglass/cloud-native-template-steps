#! /bin/bash -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

"$DIR/wait-for-ready-pod.sh" kafka default
"$DIR/wait-for-ready-pod.sh" authorization-server default
"$DIR/wait-for-ready-pod.sh" customer-service default
"$DIR/wait-for-ready-pod.sh" order-service default
"$DIR/wait-for-ready-pod.sh" api-gateway-service default
"$DIR/wait-for-ready-pod.sh" eventuate-cdc default
