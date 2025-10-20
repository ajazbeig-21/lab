output "public_ip_instance" {
  description = "Public IP of an instance is"
  value = aws_instance.example.public_ip
}