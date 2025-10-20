# 🌍 Terraform — From Noob to Pro (Complete Course)

A practical, step-by-step guide to mastering Terraform (Infrastructure as Code) for DevOps, Cloud, and SRE roles. This repository takes you from beginner concepts to production-ready patterns with hands-on examples.

---

## Table of Contents

- [What you'll learn](#what-youll-learn)  
- [Course outline](#course-outline)  
- [Who this is for](#who-this-is-for)  
- [Prerequisites](#prerequisites)  
- [How to use this repo](#how-to-use-this-repo)  
- [Contributing](#contributing)  
- [Support](#support)

---

## What you'll learn

This course covers the core Terraform concepts and practical workflows needed to deploy and manage cloud infrastructure reliably.

---

## Course outline

### 1. Terraform basics
- What is Terraform and why use it  
- IaC concepts  
- Terraform architecture: Core, Providers, State, Backend  
- Workflow: `terraform init` → `terraform plan` → `terraform apply` → `terraform destroy`  
- Hands-on: first Terraform configuration

### 2. Installation
- Install Terraform on macOS, Linux, and Windows  
- Configure the CLI and environment variables  
- Version management and verification

### 3. Providers & multi-provider setups
- Providers explained (AWS / Azure / GCP)  
- Using multiple providers in one configuration  
- Version pinning and provider source configuration

### 4. Variables & outputs
- Input variables (string, list, map, object)  
- Defaults, validation, and sensitive variables  
- `.tfvars` files and outputs

### 5. Modules
- Local and registry modules  
- Reusable module patterns and best practices  
- Example: build an AWS VPC module

### 6. State management
- Understanding the state file  
- Local vs remote state  
- Backends (S3, Azure Blob, GCS) and state locking

### 7. Workspaces
- Use workspaces to manage environments (dev/stage/prod)  
- Switching and isolating state

### 8. Interview questions & scenarios
- Real-world Terraform interview questions  
- Debugging common errors and production best practices

---

## Who this is for
- DevOps engineers  
- Cloud engineers  
- SREs  
- Backend developers learning IaC  
- Candidates preparing for Terraform interviews or certifications

---

## Prerequisites
- Basic cloud knowledge (AWS/Azure/GCP)  
- Terraform CLI installed (`terraform --version`)  
- Optional: free-tier cloud account for hands-on labs

---

## How to use this repo
1. Clone the repository:
   `git clone git@github.com:ajazbeig-21/lab.git`
2. Open the relevant lesson directory.
    `cd terraform-noob-to-pro`
3. Run `terraform init` then `terraform plan` to preview changes, and `terraform apply` to create resources.
4. Use `terraform destroy` to clean up resources when done.

---

## Contributing
Contributions (bug fixes, typos, examples) are welcome — please open a Pull Request.

---

## Support
If this repo helps you, please star it. It motivates continued improvements and new content.

## Social
- LinkedIn: https://www.linkedin.com/in/ajaz-beig-6b0402193/
- YouTube: https://www.youtube.com/@TechWithAjaz
- Medium: https://medium.com/@ajaz-beig
- GitHub: https://github.com/ajazbeig-21