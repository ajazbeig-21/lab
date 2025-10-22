# Terraform Modules — learning-stages/modules

Small repository demonstrating a reusable Terraform module for an EC2 instance and how to consume it from a root module.

## Layout
- ec2-module/  
  - main.tf       — aws_instance resource
  - variables.tf  — module inputs (ami_id, instance_type)
  - output.tf     — module outputs (instance_public_ip)
- main.tf         — root module that instantiates `ec2-module`

## Purpose
Encapsulate EC2 creation logic in a child module so it can be reused across stacks/environments.

## ec2-module (child) — Inputs
- `ami_id` (string) — AMI ID to use for the instance. Required.
- `instance_type` (string) — EC2 instance type. Required.

Example variable declarations are in `ec2-module/variables.tf`.

## ec2-module (child) — Outputs
- `instance_public_ip` — public IP of the created instance (exposed by `ec2-module/output.tf`).

Note: The module returns whatever attributes the `aws_instance` resource produces. If your subnet does not provide a public IP, set `associate_public_ip_address = true` inside the module or launch into a public subnet.

## Usage (root module)
Example root usage (already in `main.tf`):

```hcl
module "ec2_instance" {
  source        = "./ec2-module"
  ami_id        = "ami-0341d95f75f311023"
  instance_type = "t2.micro"
}