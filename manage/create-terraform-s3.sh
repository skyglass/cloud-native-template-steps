#! /bin/bash -e

aws s3 mb s3://lp-terraform-state.skycomposer.net

aws s3api put-bucket-versioning --bucket lp-terraform-state.chrisrichardson.net --versioning-configuration Status=Enabled

aws dynamodb create-table --table-name lp-terraform-state-lock.skycomposer.net \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --provisioned-throughput ReadCapacityUnits=1,WriteCapacityUnits=1
    