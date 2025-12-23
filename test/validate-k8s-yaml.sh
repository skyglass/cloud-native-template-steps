#! /bin/bash -e

set -o pipefail

find application/*-service/*-deployment -type f -name '*.yaml' -o -name '*.yml' | while read -r file ; do
    echo "INFO - Validating $file"
    kubeconform -verbose -strict "$file"
done

