provider "aws" {
    region = "us-east-1"
}

variable "ami" {
    description = "AMI"
}

variable "instance_type" {
    description = "EC2 Instance Type"
    type = map(string)

    default = {
        dev     = "t2.micro"
        staging = "t2.small"
        prod    = "t2.medium"
    }
}

module "ec2_instance" {
    source = "./modules/ec2_instance"
    ami  = var.ami
    instance_type = lookup(var.instance_type, terraform.workspace, "t2.micro")
}