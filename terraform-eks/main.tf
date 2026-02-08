provider "aws" {
  region = local.region
  default_tags {
    tags = local.tags
  }
}

locals {
  name   = "lp2-cluster"
  region = "eu-central-1"

  tags = {
    lp_cluster = local.name
  }

}

terraform {
  backend "s3" {
    bucket = "lp-terraform-state.skycomposer.net"
    key    = "lp-terraform-eks-lp2-cluster"
    region = "eu-central-1"
    dynamodb_table = "lp-terraform-state-lock.skycomposer.net"
  }
}


