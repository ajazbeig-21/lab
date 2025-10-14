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


# > terraform validate 
# Check for the validity of the configuration files in a directory
# Success! The configuration is valid.

# > terraform plan
# An execution plan has been generated and is shown below.
# Resource actions are indicated with the following symbols:
#   + create

# > terraform apply
# Do you want to perform these actions?
#   Terraform will perform the actions described above.
#   Only 'yes' will be accepted to approve.
#   Enter a value: yes

resource "aws_security_group" "my_security_group" {
  vpc_id = aws_vpc.my_vpc.id
  name   = "web_sg"

  ingress {
    description = "TLS from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH 22"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web_server_1" {
    ami           = "ami-052064a798f08f0d3" # Amazon Linux 2 AMI (HVM), SSD Volume Type
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.my_security_group.id]
    subnet_id = aws_subnet.subnet1.id
    tags = {
        Name = "WebServerInstance"
    }
    //When we script start then this script will run
 user_data = file("${path.module}/user_data.sh")
 }

resource "aws_instance" "web_server_2" {
    ami           = "ami-052064a798f08f0d3" # Amazon Linux 2 AMI (HVM), SSD Volume Type
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.my_security_group.id]
    subnet_id = aws_subnet.subnet2.id
    tags = {
        Name = "WebServerInstance"
    }
    //When we script start then this script will run
     user_data = file("${path.module}/user_data1.sh")
}

resource "aws_lb" "ajaz_load_balancer" {
  name               = "ajaz-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.my_security_group.id]
  subnets            = [aws_subnet.subnet1.id, aws_subnet.subnet2.id]

  enable_deletion_protection = true

  tags = {
    Environment = "ajaz_environment"
  }
}

resource "aws_lb_target_group" "ajaz_target_group" {
  name     = "ajaz-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.my_vpc.id

  health_check {
    path = "/"
    port = "traffic-port"
  }
  tags = {
    Environment = "ajaz_environment"
  }
}

resource "aws_lb_target_group_attachment" "ajaz_target_group_attachment_1" {
  target_group_arn = aws_lb_target_group.ajaz_target_group.arn
  target_id        = aws_instance.web_server_1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "ajaz_target_group_attachment_2" {
  target_group_arn = aws_lb_target_group.ajaz_target_group.arn
  target_id        = aws_instance.web_server_2.id
  port             = 80
}

resource "aws_lb_listener" "ajaz_listener" {
load_balancer_arn = aws_lb.ajaz_load_balancer.arn
port              = "80"
protocol          = "HTTP"

default_action {
  type = "forward"
  target_group_arn = aws_lb_target_group.ajaz_target_group.arn
}

}

output "load_balancer_dns" {
  description = "The DNS name of the load balancer"
  value       = aws_lb.ajaz_load_balancer.dns_name
}