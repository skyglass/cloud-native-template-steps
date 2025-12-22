#!/bin/bash

verify_context() {
  context=$(kubectl config current-context)
  if [ "$context" != "kind-lp-cluster" ]; then
    echo "Error: current context is not kind-lp-cluster" context
    exit 1
  fi
}

verify_kubectl_get_po() {
  kubectl get po
  if [ $? -ne 0 ]; then
    echo "Error: kubectl get po failed"
    exit 1
  fi
}

verify_context
verify_kubectl_get_po
echo "Installation verification successful"
