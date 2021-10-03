terraform {
  required_providers {
    aws          = {
      source  = "hashicorp/aws"
      version = "3.61.0"
    }
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "2.12.1"
    }
  }
}

provider "aws" {
  region     = var.aws-region
  access_key = var.aws-access-key
  secret_key = var.aws-secret-key
}

provider "digitalocean" {
  token = var.do-token
}