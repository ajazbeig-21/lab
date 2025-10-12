resource "aws_vpc" "my_vpc" {
  cidr_block = var.cidr

  tags = {
    Name = "my_vpc"
  }
}

resource "aws_subnet" "subnet1"{
    vpc_id = aws_vpc.my_vpc.id
    cidr_block = "10.0.0.0/24"
    availability_zone = "us-east-1a"
    map_public_ip_on_launch = true
}