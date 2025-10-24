terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"  # Change to your desired region
}

resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"  # Make sure this AMI exists in your region!
  instance_type = "t2.micro"
  key_name      = "my-key"                 # This must match an existing key pair in AWS

  # Copy index.html to instance
  provisioner "file" {
    source      = "index.html"
    destination = "/tmp/index.html"
  }

  # Run commands on instance
  provisioner "remote-exec" {
    inline = [
      "sudo apt update -y",
      "sudo apt install nginx -y",
      "sudo mv /tmp/index.html /var/www/html/index.html",
      "sudo systemctl restart nginx"
    ]
  }

  # SSH connection
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("~/.ssh/id_rsa")  # Path to your private key
    host        = self.public_ip
  }

  tags = {
    Name = "Terraform-Provisioner-Demo"
  }
}
