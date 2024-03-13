terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

backend "s3" {
  bucket         = "pocterraformbackendjava1"
  key            = "terraform.tfstate"
  region         =  var.region
  dynamodb_table = "terraform_locks"
  encrypt        =  true
}

provider "aws" {
  region = var.region
}


