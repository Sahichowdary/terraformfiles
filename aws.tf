terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.region
}

backend "s3" {
  bucket         = "pocterraformbackendjava"
  key            = "terraform.tfstate"
  region         = var.region
  dynamodb_table = "terraform_locks"
  encrypt        = true
}

