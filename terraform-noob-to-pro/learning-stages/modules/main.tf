provider "aws" {
  region = "us-east-1"
}

module "ec2_instance" {
  source = "./ec2-module"
  ami_id = "ami-0341d95f75f311023"
  instance_type = "t2.micro"
}