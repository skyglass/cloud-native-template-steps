#! /bin/bash -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

DELETE=

while [ -n "$1" ] ; do 

    case "$1" in
        -d|--delete)
            DELETE=1
            ;;
        --*)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac

    shift

done

if [ -n "$DELETE" ]; then
    "$DIR/delete-kind-cluster-dev.sh"
    "$DIR/delete-kind-cluster-production.sh"
fi

"$DIR/bootstrap-flux-production.sh"
"$DIR/bootstrap-flux.sh"
