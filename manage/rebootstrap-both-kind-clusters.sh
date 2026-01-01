#! /bin/bash -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

"$DIR/delete-kind-cluster-dev.sh"
"$DIR/delete-kind-cluster-production.sh"

"$DIR/bootstrap-flux-production.sh"
"$DIR/bootstrap-flux.sh"
