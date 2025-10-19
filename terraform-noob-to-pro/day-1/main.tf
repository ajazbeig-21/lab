provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "ajaz-instance" {
    ami = "ami-0341d95f75f311023"
    instance_type = "t2.micro"
    key_name = "ajaz-keypair"
}