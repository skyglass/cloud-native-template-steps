#! /bin/bash -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

cd "$DIR/../terraform-eks"

$(command -v caffeinate || echo "") terraform "$@"

