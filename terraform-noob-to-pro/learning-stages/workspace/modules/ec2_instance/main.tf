provider "aws" {
  region="us-east-1"
}

variable "ami" {
    description = "The AMI to use for the EC2 instance"
}

variable "instance_type" {
    description = "This is Instance Type"
}

resource "aws_instance" "example"{
    ami = var.ami
    instance_type = var.instance_type
}