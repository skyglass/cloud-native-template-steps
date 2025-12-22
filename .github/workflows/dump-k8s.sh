#! /bin/bash -e


LOGGING_DIR=~/container-logs

mkdir -p $LOGGING_DIR/pods

for type in $(kubectl api-resources --verbs=list --namespaced -o name) ; do 

if [ -n "$(kubectl get $type 2>/dev/null )" ] ; then
  TYPE_DIR=$LOGGING_DIR/$type
  
  mkdir -p "$TYPE_DIR"

  kubectl describe "$type" > "$TYPE_DIR/describe.txt" || echo could not describe "$type"


  for r in $(kubectl get $type -o name) ; do
    mkdir -p "$LOGGING_DIR/$(dirname $r)"
    kubectl describe "$r" > "$LOGGING_DIR/$r.txt" || echo could not describe "$r"
  done

fi

done


POD_LOG_DIR=$LOGGING_DIR/pods

mkdir -p $POD_LOG_DIR

if kubectl get po >> $POD_LOG_DIR/pods.txt ; then
  for name in $(kubectl get po -o name | sed 's?pod/??') ; do
    (kubectl logs "$name" || echo cannot get log) > "$POD_LOG_DIR/${name}.log"
    if kubectl logs "$name" --previous 2>/dev/null > /dev/null; then 
      (kubectl logs "$name" --previous || echo cannot get previous log) > "$POD_LOG_DIR/${name}-previous.log"
    fi
  done
fi