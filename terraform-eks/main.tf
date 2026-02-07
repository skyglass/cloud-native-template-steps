provider "aws" {
  region = local.region

  default_tags {
    tags = local.tags
  }
}

locals {
  name   = "liveproject-cluster"
  region = "eu-central-1"

  tags = {
    lp_cluster = local.name
  }
}
