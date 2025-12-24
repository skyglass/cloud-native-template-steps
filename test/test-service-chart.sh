#! /bin/bash -e

NO_BUILD=
WITH_AUTH=
PRIVATE_REGISTRY=

while [[ "$1" == --* ]] ; do
  case $1 in
    "--no-build" )
      NO_BUILD=yes
      ;;
    "--with-auth" )
      WITH_AUTH=yes
      ;;
    "--private-registry" )
      NO_BUILD=yes
      PRIVATE_REGISTRY=yes
      ;;
    --*)
      echo bad option "$1" - ./test/test-service-chart.sh '[--no-build]' '[--no-load]' '[--with-auth]' 'service-name' '[ingress-test-path]'
      exit 1
      ;;
  esac
  shift
done

service_name=${1:-customer-service}    
ingress_test_path=$2

gradle_build() {
    if [ -z "$NO_BUILD" ] ; then
        (cd application ;  ./gradlew -P imageVersion=0.1.0-SNAPSHOT buildDockerImageLocally)
    else
        echo skipping build
    fi
}

gradle_build

echo installing "$service_name"

if [ -n "$PRIVATE_REGISTRY" ] ; then
  helmOpts=("--set-string" "image.repository=ghcr.io/skyglass/cloud-native-template-steps/${service_name}")
else
  helmOpts=()
fi

helm upgrade --install "$service_name" "application/$service_name/$service_name-deployment/helm-charts/$service_name" \
   "${helmOpts[@]}" --wait

kubectl rollout status deployment "$service_name" --timeout=90s

echo running helm test "$service_name" ...

SUCCESS=

for i in {1..5}; do
    if helm test "$service_name" ; then
        SUCCESS=yes
        break
    fi
    echo retrying
    sleep 1
done

# Don't test again if previously successful

if [ -z "$SUCCESS" ] ; then
    helm test "$service_name"
fi

# At this point the service is ready
#

echo 

if [ -n "$ingress_test_path" ] ; then

    if [ -n "$WITH_AUTH" ] ; then
      authOpts=("-u" "user:password")
    else
      authOpts=()
    fi

    echo accessing ingress "$ingress_test_path" with authOpts "${authOpts[@]}"

    for i in {1..5}; do
        if curl "${authOpts[@]}" --retry-connrefused --retry 5 --retry-delay 1 --fail localhost$ingress_test_path > /dev/null ; then
            break
        fi
        echo retrying
        sleep 1
    done

    curl "${authOpts[@]}" --retry-connrefused --retry 5 --retry-delay 1 --fail "localhost${ingress_test_path?}"

else
    echo skipping ingress path check
fi
echo 


# for i in {1..5}; do done

echo SUCCESS

