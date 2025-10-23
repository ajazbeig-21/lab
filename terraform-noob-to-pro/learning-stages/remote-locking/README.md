# DynamoDB table for Terraform state locking

This document explains how to create a DynamoDB table for Terraform state locking, how to add it to an S3 backend, and provides a short troubleshooting/permissions guide.

Why a lock table?
- Prevents concurrent Terraform applies against the same remote state.
- Recommended when using an S3 backend in teams or CI.

Quick AWS CLI create (recommended minimal): 
```bash
aws dynamodb create-table \
  --table-name terraform_lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST
```

Equivalent Terraform resource:
```terraform
resource "aws_dynamodb_table" "terraform_lock" {
  name         = "terraform_lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
```

Add the table to your S3 backend config (backend.tf) so Terraform uses it for locking:
```terraform
terraform {
  backend "s3" {
    bucket         = "ajaz-unique-terraform-bucket-for-state"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform_lock"
  }
}
```

Notes and tips
- Name consistency: the attribute name used when creating the table must match the hash_key in the Terraform resource (LockID above).
- Region: create the DynamoDB table in the same AWS region you configure in the backend.
- Initialization: run `terraform init` after creating the table and updating backend.tf. Terraform will use the DynamoDB table for state locks automatically.
- Migration: if you change backend settings, use `terraform init -reconfigure` (see Terraform docs).

Minimal IAM permissions required (example):
- For S3 state: s3:GetObject, s3:PutObject, s3:DeleteObject, s3:ListBucket
- For locking: dynamodb:GetItem, dynamodb:PutItem, dynamodb:DeleteItem, dynamodb:DescribeTable, dynamodb:Query

Troubleshooting
- "AccessDenied": verify IAM permissions and AWS credentials.
- Stale locks: inspect the lock table; remove entries only if you are certain no active run is in progress.
- Table not found: confirm table name and region match backend settings.

References
- Terraform backend docs: https://www.terraform.io/docs/backends/types/s3.html
- AWS CLI DynamoDB: https://docs.aws.amazon.com/cli/latest/reference/dynamodb/create-table.html