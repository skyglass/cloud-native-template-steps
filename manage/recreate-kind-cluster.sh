#! /bin/bash -e

NO_DELETE=

while [[ "$1" == --* ]] ; do
  case $1 in
    "--no-delete" )
      NO_DELETE=yes
      ;;
    --*)
      echo './manage/recreate-kind-cluster.sh [--no-delete]'
      exit 1
      ;;
  esac
  shift
done

if [ -z "$NO_DELETE" ] ; then
    ./manage/delete-kind-cluster.sh
fi
./manage/create-kind-cluster.sh