
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

   backend "s3" {
     bucket         = "pocterraformbackendjava"
     key            = "aws-poc-demo"
     region         = "us-east-1"
     dynamodb_table = "terraform_locks"
     encrypt        = true
  }

 provider "aws" {
  region = "us-east-1"
}
