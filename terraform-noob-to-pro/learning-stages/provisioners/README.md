# Terraform Provisioners — Complete from scratch

Terraform provisioners are the set of built-in functionalaities that allow you to execute scripts, commands or other configurations on remote server while its creation and/or destroy of it.

### there are 3 types of providers
#### 1. Local-exec provisioner
this local-exec provisioner allows you to run commands or scripts on mahine where the terraform is running. This provisioner is often used for tasks that don’t require access to the remote resource.

#### 2. Remote-exec provisioner
The `remote-exec` provisioner allows you to run commands or scripts on a remote resource over SSH or WinRM after the resource is created. This provisioner is commonly used for tasks like software installations and configuration on remote instances.
#### 3. File provisioner
The `file` provisioner allows you to copy files or directories from the local machine to a remote resource after it’s created. This provisioner is useful for transferring configuration files, scripts, or other assets to a remote instance.

## Practial

This document explains how to run the Terraform configuration in this folder. The module creates a security group, an EC2 instance, and uses the `file` and `remote-exec` provisioners to deploy a simple static page (see `index.html`).

Files
- main Terraform file: `main.tf`
- Local page copied to the instance: `index.html`

What this configuration does
- Creates an AWS Security Group that allows SSH (22) and HTTP (80).
- Launches an EC2 instance (AMI and user may need adjustment per region).
- Uses a `file` provisioner to copy `index.html` to `/tmp/index.html`.
- Uses a `remote-exec` provisioner to install nginx and move the file to `/var/www/html/index.html`.
- Uses an SSH `connection` to perform provisioner actions.

Prerequisites
- Terraform CLI installed (terraform --version).
- AWS CLI installed and configured with credentials able to create EC2 and security groups.
- Local SSH keypair (example uses `~/.ssh/id_rsa` and `~/.ssh/id_rsa.pub`).
- The imported AWS key pair name in `main.tf` is `my-key` (you can change this).

Quick setup (macOS / Linux)
1. Generate an SSH key (if you don't have one):
```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""
ls -l ~/.ssh/id_rsa ~/.ssh/id_rsa.pub
```

2. Import the public key into AWS:
```bash
aws ec2 import-key-pair \
  --key-name "my-key" \
  --public-key-material fileb://~/.ssh/id_rsa.pub \
  --region us-east-1
```

3. Inspect the Terraform files and local `index.html` to confirm values (AMI, user, key_name, etc.).

Run Terraform
1. Change to this directory:
```bash
cd terraform-noob-to-pro/learning-stages/provisioners
```

2. Initialize Terraform:
```bash
terraform init
```

3. Validate and plan:
```bash
terraform validate
terraform plan -out=plan.tfplan
```

4. Apply:
```bash
terraform apply "plan.tfplan"
# or: terraform apply
# confirm with "yes"
```

Post-apply: find the instance IP and open the site
```bash
aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=Terraform-Provisioner-Demo" \
  --query "Reservations[*].Instances[*].PublicIpAddress" \
  --output text
# then open http://<PUBLIC_IP>/ in your browser
```

Important details (provisioners & connection)
- file provisioner
  - Copies a file from the machine running Terraform to the instance.
  - In this config: source `index.html` → destination `/tmp/index.html`.
- remote-exec provisioner
  - Runs commands over SSH on the remote machine.
  - In this config it installs nginx, moves the file into the webroot, and restarts nginx.
- connection block
  - Defines how Terraform connects to the instance:
    - user: `ubuntu` (change if your AMI uses `ec2-user` or another user)
    - private_key: `file("~/.ssh/id_rsa")`
    - host: `self.public_ip`
- Order: provisioners run after the resource is created and after the instance has an IP. They do not wait for cloud-init to finish unless cloud-init sets SSH available earlier.

Security notes
- Do not commit private keys (`~/.ssh/id_rsa`) to the repo.
- The example SG allows SSH from anywhere (0.0.0.0/0). Restrict to your IP for safety.
- Provisioners are a last-resort for bootstrapping. For repeatable builds, prefer user-data, baked AMIs, or config management (Ansible, Packer).

Troubleshooting
- SSH connection fails:
  - Confirm the instance public IP and security group allow port 22 from your IP.
  - Verify the SSH user matches the AMI (ubuntu / ec2-user / admin).
  - Ensure the private key matches the imported key pair (`aws ec2 describe-key-pairs`).
  - Try manual SSH: `ssh -i ~/.ssh/id_rsa ubuntu@<PUBLIC_IP>`
- remote-exec commands fail:
  - Inspect Terraform apply logs for the provisioner output.
  - SSH manually and run commands to debug.

Cleanup
- Destroy resources:
```bash
terraform destroy
# confirm with "yes"
```
- Optionally remove the imported key from AWS:
```bash
aws ec2 delete-key-pair --key-name "my-key" --region us-east-1
```

Notes and tips
- If the AMI in `main.tf` is not valid for your region, replace it with a region-appropriate AMI.
- If your instance takes time to boot, provisioners may attempt connection before SSH is ready. Add retries/timeouts in the `connection` block if needed.
- For production, avoid wide open security groups and prefer more robust provisioning methods.

References
- main Terraform: `main.tf`
- local file copied: `index.html`
- Relevant resources in `main.tf`: `aws_security_group.web_sg`, `aws_instance.web`