#! /bin/bash -e

CONTAINER_IDS=$(docker ps -a -q)

LOG_DIR=build/container-logs

mkdir -p ${LOG_DIR}

for id in $CONTAINER_IDS ; do
  echo "\n--------------------"
  echo "logs of:\n"
  docker ps -a -f "id=$id"
  echo "\n"
  docker logs $id || echo docker logs failed for $id
  echo "--------------------\n"
done

mkdir -p ${LOG_DIR}

docker ps -a > ${LOG_DIR}/containers.txt

for name in $(docker ps -a --format "{{.Names}}") ; do
  echo Getting log for $name
  (docker logs $name  || echo docker logs failed for $name)  > ${LOG_DIR}/${name}.log
done
