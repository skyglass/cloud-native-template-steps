#! /bin/bash -e

set -o pipefail

gh repo edit --default-branch "$(git branch --show-current)"
