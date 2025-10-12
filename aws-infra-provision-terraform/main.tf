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

resource "aws_subnet" "subnet2"{
    vpc_id = aws_vpc.my_vpc.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "us-east-1b"
    map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "main"
  }
}

resource "aws_route_table" "rtable" {
  vpc_id = aws_vpc.my_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_route_table_association" "rtableassociation" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.rtable.id
}

resource "aws_route_table_association" "rtableassociation2" {
  subnet_id      = aws_subnet.subnet2.id
  route_table_id = aws_route_table.rtable.id
}