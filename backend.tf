terraform {
    backend "s3" {
      bucket = "pocterraformbackendjava"
      key = "app-state"
      region = "us-east-1"
      dynamodb_table = "terraform_locks"
      encrypt        = true

    }
}
