#! /bin/bash -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

export API_GATEWAY_PORT=88

"$DIR/run-end-to-end-tests.sh" 
