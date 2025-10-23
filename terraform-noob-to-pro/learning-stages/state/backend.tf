terraform {
  backend "s3" {
    bucket = "ajaz-unique-terraform-bucket-for-state"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}
