#! /bin/bash -e

gh secret set PAT_LP_PACKAGE_ACCESS --body "${GITHUB_TOKEN?}"
