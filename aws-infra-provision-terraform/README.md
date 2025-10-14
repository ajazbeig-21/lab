# AWS Infrastructure Provisioning with Terraform

This project provisions a basic AWS infrastructure using Terraform, including:

- VPC with two public subnets
- Internet Gateway and Route Table
- Security Group for HTTP and SSH access
- Two EC2 instances (Amazon Linux 2) with user data scripts
- S3 bucket for load balancer access logs
- Application Load Balancer with target group and listener

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) installed
- AWS credentials configured (`~/.aws/credentials` or environment variables)

## Usage

1. **Initialize Terraform:**
   ```sh
   terraform init
   ```

2. **Validate the configuration:**
   ```sh
   terraform validate
   ```

3. **Review the execution plan:**
   ```sh
   terraform plan
   ```

4. **Apply the configuration:**
   ```sh
   terraform apply
   ```
   Enter `yes` when prompted.

5. **Output:**
   - The DNS name of the load balancer will be displayed after apply.

## Files

- `main.tf`: Main Terraform configuration
- `provider.tf`: AWS provider configuration
- `variables.tf`: Input variables
- `user_data.sh`: User data script for EC2 instance 1
- `user_data1.sh`: User data script for EC2 instance 2

## Clean Up

To destroy all resources:

```sh
terraform destroy
```

## Notes

- Update the AMI ID in `main.tf` if needed for your region.
- The security group allows HTTP (80) and SSH (22) from anywhere. Restrict as needed for production.
