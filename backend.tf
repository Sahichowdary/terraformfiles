backend "s3" {
  bucket         = "pocterraformbackendjava"
  key            = "terraform.tfstate"
  region         = var.region
  dynamodb_table = "terraform_locks"
  encrypt        = true
}
