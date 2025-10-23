# Remote backend & state management — Terraform (learning-stages/state)

This document shows how to configure and use an S3 remote backend (and optional DynamoDB locking) for the Terraform configuration in this directory.

Files to review:
- Backend config: [backend.tf](terraform-noob-to-pro/learning-stages/state/backend.tf)
- Root module: [main.tf](terraform-noob-to-pro/learning-stages/state/main.tf)

Prerequisites
- Terraform CLI installed (version compatible with the repository lockfiles).
- AWS CLI installed and configured with credentials that can create S3/DynamoDB resources (or an IAM user/role with the required permissions).
- AWS region used: us-east-1 (update backend.tf if you change region).

1) Create the S3 bucket for remote state
Make sure the bucket name in [backend.tf](terraform-noob-to-pro/learning-stages/state/backend.tf) exists and is unique across AWS:

For us-east-1 (no LocationConstraint required):
aws s3api create-bucket --bucket ajaz-unique-terraform-bucket-for-state --region us-east-1

If you prefer a different name, update the `bucket` value in [backend.tf](terraform-noob-to-pro/learning-stages/state/backend.tf) to match.

Optional: enable versioning and block public access (recommended for production):
aws s3api put-bucket-versioning --bucket ajaz-unique-terraform-bucket-for-state --versioning-configuration Status=Enabled
aws s3api put-public-access-block --bucket ajaz-unique-terraform-bucket-for-state --public-access-block-configuration BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true

2) Initialize the backend for this workspace
From this directory (where [backend.tf](terraform-noob-to-pro/learning-stages/state/backend.tf) lives):

terraform init

If you already have local state and want Terraform to reconfigure and copy the local state to the S3 backend automatically (non-interactive), use:

terraform init -reconfigure -backend-config="bucket=ajaz-unique-terraform-bucket-for-state" -backend-config="key=terraform.tfstate" -backend-config="region=us-east-1" -force-copy

Notes:
- If you changed the bucket name in [backend.tf](terraform-noob-to-pro/learning-stages/state/backend.tf), use that name in the `-backend-config` values or update the file first.
- `-force-copy` will copy existing local state to the remote backend without interactive confirmation. Use with care.

3) Standard workflow
- Validate:
  terraform validate
- Plan:
  terraform plan -out=plan.tfplan
- Apply:
  terraform apply "plan.tfplan"
- Destroy:
  terraform destroy

4) Common issues & troubleshooting
- AccessDenied: verify the AWS credentials and IAM permissions for S3 and DynamoDB.
- BucketAlreadyExists: S3 bucket names are global. Pick a unique name or update [backend.tf](terraform-noob-to-pro/learning-stages/state/backend.tf).
- Wrong region: ensure the bucket and backend region match.
- Locks: if a DynamoDB lock remains because of an interrupted run, check the DynamoDB table and remove stale lock entries only if you are sure no active apply is running.

5) Security & best practices
- Do not commit sensitive credentials. Use environment variables, AWS profiles or IAM roles.
- Use server-side encryption for S3 buckets in production.
- Enable S3 versioning and lifecycle rules to retain previous states if helpful.
- Use a dedicated bucket and table for Terraform state per environment (dev/stage/prod).

References
- backend configuration: [backend.tf](terraform-noob-to-pro/learning-stages/state/backend.tf)
- terraform root