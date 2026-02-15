terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.52.0" # Stable as of early 2025, compatible with EKS 1.32+
    }
  }

  required_version = ">= 1.8.2"
}

provider "aws" {
  region = local.aws_region
}