#! /bin/bash -e

BRANCH=$(git rev-parse --abbrev-ref HEAD)
CLUSTER_NAME=dev
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
CLUSTER_TYPE=kind

while [ ! -z "$*" ] ; do
  case $1 in
    "--branch" )
      shift
      BRANCH=$1
      ;;
    "--cluster" )
      shift
      CLUSTER_NAME=$1
      ;;
    "--cluster-type" )
      shift
      CLUSTER_TYPE=$1
      ;;
    * )
      echo ./bootstrap-flux.sh --branch branchName
      exit 0
      ;;
  esac
  shift
done

if [ "$CLUSTER_TYPE" == "kind" ]; then
  if [ "$CLUSTER_NAME" == "dev" ] ; then
    CREATE_ARGS=()
  else
    CREATE_ARGS=("--cluster" "lp2-cluster-$CLUSTER_NAME" "--port" 88)
  fi

  "$DIR/create-kind-cluster.sh" "${CREATE_ARGS[@]}"
fi


git pull 

"$DIR/encrypt-secrets.sh"  "${CLUSTER_NAME}"

git push

flux bootstrap github \
  --components-extra=image-reflector-controller,image-automation-controller \
  --read-write-key \
  --owner="${GITHUB_USER?}" \
  --repository=skyglass/cloud-native-template-steps \
  "--branch=${BRANCH}" \
  "--path=./flux/clusters/${CLUSTER_NAME}" \
  --timeout 10m \
  --personal

