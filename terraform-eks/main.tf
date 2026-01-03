provider "aws" {
  region = local.region
  default_tags {
    tags = local.tags
  }
}

locals {
  name            = "lp-cluster"
  region          = "us-west-2"

  tags = {
    lp_cluster    = local.name
  }

}

terraform {
  backend "s3" {
    bucket = "lp-terraform-state.chrisrichardson.net"
    key    = "lp-terraform-eks-lp-cluster"
    region = "us-west-2"
    dynamodb_table = "lp-terraform-state-lock.chrisrichardson.net"
  }
}


