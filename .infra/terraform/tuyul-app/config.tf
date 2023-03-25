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
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 3.0"
    }
    acme = {
      source  = "vancluever/acme"
      version = "2.13.1"
    }
  }
  backend "s3" {}
}

provider "aws" {
  region = var.region
}

provider "cloudflare" {
  api_token = local.cf_secrets_decoded["api_token"]
}


provider "acme" {
  server_url = "https://acme-v02.api.letsencrypt.org/directory"
}
