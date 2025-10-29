# Secrets Management with HashiCorp Vault — Quick Guide

This document shows how to install Vault on an Ubuntu EC2 instance, run Vault (dev mode for testing), create a KV secret engine, add secrets, create a policy and auth method, and read secrets from Terraform. Use this for hands-on practice and interview prep.

Prerequisites
- An Ubuntu EC2 instance (t2.micro ok for testing).
- SSH access to the instance.
- Basic familiarity with Terraform and AWS CLI.
- Never commit private keys or real secrets to git.

1 — Install Vault (Ubuntu)
```bash
sudo apt-get update
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update
sudo apt-get install -y vault
vault --version
```

2 — Start Vault (dev mode — testing only)
- Dev mode is for local testing only. It should not be used in production.
```bash
# Start Vault in dev mode, listening on all interfaces (0.0.0.0:8200)
vault server -dev -dev-root-token-id=root -dev-listen-address="0.0.0.0:8200"
```
- In a new SSH session set the environment variable:
```bash
export VAULT_ADDR='http://0.0.0.0:8200'
export VAULT_TOKEN='root'   # dev-only example; use proper auth in prod
```
- Vault UI (dev): http://<EC2_PUBLIC_IP>:8200

3 — Enable KV engine and store a secret
```bash
# Enable KV v2 at path "key-value-engine" (if not already enabled)
vault secrets enable -path=key-value-engine kv-v2

# Create a simple secret (example)
vault kv put key-value-engine/json-kv-store google_map_key="REPLACE_WITH_YOUR_KEY"
# List keys
vault kv list -mount=key-value-engine json-kv-store
# Read secret
vault kv get -mount=key-value-engine json-kv-store
```

4 — Create a policy for Terraform (example)
- Create a local policy file `terraform-policy.hcl`:
```hcl
# terraform-policy.hcl
path "key-value-engine/data/json-kv-store/*" {
  capabilities = ["read", "list"]
}
path "auth/token/create" {
  capabilities = ["update", "create", "sudo"]
}
```
- Apply the policy:
```bash
vault policy write terraform-policy terraform-policy.hcl
vault policy list
vault policy read terraform-policy
```

5 — Enable an auth method and create a user (userpass example)
```bash
vault auth enable userpass
vault write auth/userpass/users/terraform password="terraform123" policies="terraform-policy"
# Test login
vault login -method=userpass username="terraform" password="terraform123"
```

6 — Access Vault from Terraform (example)
- Set these environment variables for Terraform (do not hardcode tokens in code):
```bash
export VAULT_ADDR='http://0.0.0.0:8200'
export VAULT_TOKEN='the-token-from-login'   # use a short-lived token in real setups
```
- Example Terraform provider + data block (reads KV v2 secret):
```hcl
provider "vault" {
  address = var.vault_addr
  token   = var.vault_token
}

data "vault_kv_secret_v2" "google_map" {
  mount = "key-value-engine"
  name  = "json-kv-store"
}

output "google_map_key" {
  value     = data.vault_kv_secret_v2.google_map.data["google_map_key"]
  sensitive = true
}
```
- Commands:
```bash
terraform init
terraform apply -var "vault_addr=http://0.0.0.0:8200" -var "vault_token=<token>"
terraform output -raw google_map_key
```

Security notes & best practices
- Do not run Vault dev mode in production.
- Use proper auth (AppRole, Kubernetes, AWS IAM, OIDC) for automation.
- Use short-lived tokens and revoke them when no longer needed.
- Store sensitive values in Vault, never in plain tfvars or git.
- In production use TLS, storage backends, HA, and policies aligned to least privilege.

Troubleshooting
- "permission denied" reading secret: confirm policy allows path and token has that policy.
- "no such secret" or 404: verify mount path and secret name (KV v1 vs v2 differences).
- Unable to reach Vault UI: ensure security group allows inbound 8200 and instance is reachable.

Cleanup (dev)
```bash
# Remove test secret
vault kv delete -mount=key-value-engine json-kv-store
# Remove policy
vault policy delete terraform-policy
# Disable userpass (optional)
vault auth disable userpass
```

References
- Vault concepts: https://developer.hashicorp.com/vault/docs/concepts
- KV secrets engine: https://developer.hashicorp.com/vault/docs/secrets/kv
- Terraform Vault provider: https://registry.terraform.io/providers/hashicorp/vault/latest/docs
