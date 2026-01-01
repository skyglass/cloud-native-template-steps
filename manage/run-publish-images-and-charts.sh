#! /bin/bash -e

set -o pipefail

gh workflow run publish-images-and-charts.yml  --ref "$(git branch --show-current)"
