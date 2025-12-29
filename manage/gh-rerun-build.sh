#! /bin/bash -e

JOB_ID=$(gh run list --branch $(git branch --show-current) --json databaseId --jq '.[0].databaseId')

gh run rerun "$JOB_ID"

