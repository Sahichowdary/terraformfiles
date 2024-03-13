terraform {
    backend "s3" {
      bucket = "tfstate"
      key = "app-state"
      region = "us-east-1"
    }
}
