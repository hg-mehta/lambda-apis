terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.28"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.7"
    }
  }

  backend "s3" {
    # Configure backend in terraform.tfvars or via CLI
    bucket = "lambda-apis-infra-us-east-1"
    key    = "terraform.tfstate"
    region = "us-east-1"
    encrypt = true
    dynamodb_table = "terraform-lock-table"
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "lambda-apis"
      ManagedBy   = "terraform"
      Environment = var.environment
    }
  }
}