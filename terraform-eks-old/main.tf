locals {
  name   = "lp2-cluster"
  region = "eu-central-1"

  tags = {
    lp_cluster = local.name
  }
}

terraform {
  required_version = ">= 1.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.25"
    }
  }

  backend "s3" {
    bucket         = "lp-terraform-state.skycomposer.net"
    key            = "lp-terraform-eks-lp2-cluster"
    region         = "eu-central-1"
    dynamodb_table = "lp-terraform-state-lock.skycomposer.net"
  }
}

provider "aws" {
  region = local.region
}
