terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = ">= 1.6.0"
}

provider "aws" {
  region     = local.dot_env["AWS_DEFAULT_REGION"]
  access_key = local.dot_env["AWS_ACCESS_KEY_ID"]
  secret_key = local.dot_env["AWS_SECRET_ACCESS_KEY"]
}


