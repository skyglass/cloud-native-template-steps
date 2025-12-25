#! /bin/bash -e

BRANCH=$(git rev-parse --abbrev-ref HEAD)
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

while [ ! -z "$*" ] ; do
  case $1 in
    "--branch" )
      shift
      BRANCH=$1
      ;;
    * )
      echo ./bootstrap-flux.sh --branch branchName
      exit 0
      ;;
  esac
  shift
done

"$DIR"/create-kind-cluster.sh

flux bootstrap github \
  --repository=skyglass/cloud-native-template-steps \
  --branch="${BRANCH}" \
  --path=./flux/clusters/dev \
  --timeout 10m \
  --personal
