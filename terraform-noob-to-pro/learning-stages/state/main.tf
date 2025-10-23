provider "aws"{
    region = "us-east-1"
}

resource "aws_instance" "example" {
    ami           = "ami-0341d95f75f311023" # Amazon Linux 2 AMI
    instance_type = "t2.micro"

    tags = {
        Name = "TerraformExample"
    }
}

resource "aws_s3_bucket" "state_bucket" {
  bucket = "ajaz-unique-terraform-bucket-for-state"
}
