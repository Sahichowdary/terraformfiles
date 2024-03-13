terraform {
    backend "s3" {
      bucket = "pocterraformbackendjava"
      key = "app-state"
      region = "us-east-1"
    }
}
