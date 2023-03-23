terraform {
  required_version = ">= 0.13"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.59.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.4.3"
    }
  }
  backend "s3" {} # using separate backend file. See environments/$ENVIRONMENT/config.s3.tfbackend
}

provider "aws" {
  region = var.region
}
