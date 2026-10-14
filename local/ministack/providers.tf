terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region                      = var.aws_region
  access_key                  = "mock_access_key"
  secret_key                  = "mock_secret_key"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  s3_use_path_style           = true

  endpoints {
    ec2      = var.ministack_endpoint
    iam      = var.ministack_endpoint
    s3       = var.ministack_endpoint
    dynamodb = var.ministack_endpoint
    elb      = var.ministack_endpoint
    elbv2    = var.ministack_endpoint
    sts      = var.ministack_endpoint
  }
}
