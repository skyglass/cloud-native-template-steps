#! /bin/bash -e

LATEST=${1:-HEAD}

DIR=${2:-application}


SHA=$(cat $DIR/SHA.txt)

SRC_DIR=$(echo ~/src/eventuate-examples/eventuate-tram-sagas-examples-customers-and-orders)

TMP_FILE=$(mktemp /tmp/foo.XXXXXXXXX)

echo $TMP_FILE

git -C ${SRC_DIR?} format-patch ${SHA?}..${LATEST} --stdout  > $TMP_FILE
git am --reject -p0 --directory=$DIR < $TMP_FILE

git -C ${SRC_DIR?} rev-parse ${LATEST} > $DIR/SHA.txt

git tag merged-$(date +%Y-%m-%d-%H-%M-%S)