# Terraform Workspaces — dev / staging / prod

Purpose
- Document workspace setup and commands for the workspace module in this folder.
- Provide a concise reference for practice and interview preparation.

Context
- main.tf uses a map variable and the current workspace to pick instance_type:
  instance_type = lookup(var.instance_type, terraform.workspace, "t2.micro")
- terraform.tfvars contains the AMI. Workspaces control which size (dev/staging/prod) is chosen.

Quick checklist (prereqs)
- Terraform installed and initialized in this folder.
- AWS credentials configured (if using AWS provider).
- terraform.tfvars in this folder contains: ami = "<AMI_ID>"

Workspace commands (create / select / list / delete)
- Initialize (only once per repo or after provider changes):
  ```bash
  terraform init
  ```

- List workspaces:
  ```bash
  terraform workspace list
  ```

- Create a new workspace:
  ```bash
  terraform workspace new dev
  terraform workspace new staging
  terraform workspace new prod
  ```

- Select an existing workspace:
  ```bash
  terraform workspace select dev
  ```

- Show current workspace:
  ```bash
  terraform workspace show
  ```

- Delete a workspace (must not be selected and must be empty / destroyed):
  ```bash
  terraform workspace select default
  terraform workspace delete dev
  ```

Typical workflow (per workspace)
1. Initialize:
   ```bash
   terraform init
   ```

2. Choose workspace:
   ```bash
   terraform workspace select dev    # or terraform workspace new dev
   ```

3. Plan:
   ```bash
   terraform plan -var-file=terraform.tfvars -out=plan.tfplan
   ```

4. Apply:
   ```bash
   terraform apply "plan.tfplan"
   ```

5. Inspect resources and outputs:
   ```bash
   terraform show
   terraform state list
   ```

6. Destroy (when finished):
   ```bash
   terraform destroy -var-file=terraform.tfvars
   ```

Notes on var handling
- var.instance_type is a map(string) with defaults for dev/staging/prod.
- The lookup expression uses the workspace name to pick the instance type. Example:
  - workspace = dev  → instance_type = "t2.micro"
  - workspace = staging → instance_type = "t2.small"
  - workspace = prod → instance_type = "t2.medium"
- To override defaults, pass a map via a var-file:
  ```hcl
  // custom.tfvars
  instance_type = {
    dev     = "t2.nano"
    staging = "t2.small"
    prod    = "t3.medium"
  }
  ```
  Then:
  ```bash
  terraform plan -var-file=custom.tfvars -var-file=terraform.tfvars
  ```

How to verify which instance type will be used
- Use plan output (it shows computed values).
- Or run:
  ```bash
  terraform workspace show
  terraform plan -var-file=terraform.tfvars
  # inspect plan for instance_type
  ```

Best practices
- Keep workspace-specific state isolated (workspaces provide separate state files in the same backend).
- For production, prefer separate backends (different S3 buckets/paths) instead of relying solely on workspaces.
- Do not commit private keys or credentials.
- Avoid encoding environment-specific secrets in workspace state; use a secrets manager or environment variables.
- Use explicit tfvars files (dev.tfvars, staging.tfvars, prod.tfvars) and pass with -var-file to avoid mistakes.

Common pitfalls & fixes
- Error: type mismatch for variables
  - Ensure values in terraform.tfvars match the declared variable type (map vs string).
  - If var is map(string), provide a map in tfvars or remove that var from tfvars and use defaults.
- Workspace creation does not create resources until apply
  - Creating a workspace only switches state context. Plan & apply are still required in that workspace.
- Deleting a workspace fails
  - Workspace must be empty (no resources). Destroy resources first, then select another workspace (default) and delete.

Interview prep — quick Q&A (concise)
- Q: What is a Terraform workspace?
  - A namespaced instance of state within a single backend. Useful for simple environment separation.
- Q: Workspace vs separate backend?
  - Workspaces are lightweight state namespaces. Separate backends provide stronger isolation, access control, and lifecycle boundaries.
- Q: When not to use workspaces?
  - For production isolation or when different teams manage environments — prefer distinct backends.
- Q: How does lookup(var.instance_type, terraform.workspace, "t2.micro") work?
  - It returns var.instance_type[terraform.workspace] if present, otherwise the default "t2.micro".
- Q: How to set per-environment variables safely?
  - Use per-environment var-files (dev.tfvars) passed via -var-file or use a remote secrets store.
- Q: How to avoid accidental deploys to prod?
  - Use CI gates, approval workflows, strict backend access policies, and separate backends for prod.

Useful commands reference (summary)
- terraform init
- terraform workspace new <name>
- terraform workspace list
- terraform workspace select <name>
- terraform workspace show
- terraform plan -var-file=terraform.tfvars -out=plan.tfplan
- terraform apply "plan.tfplan"
- terraform destroy -var-file=terraform.tfvars
- terraform workspace delete <name>

References
- Terraform workspaces: https://www.terraform.io/docs/language/state/workspaces.html
- Terraform CLI commands: https://www.terraform.io/docs/cli