terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
    }
  }
}

provider "vault" {
  # Vault server address
  address = "http://PUBLIC_IP:8200"

  # Token for authentication (replace with your valid Terraform user token)
  token = "hvs.XXXXXXXXXXXXXXXX"

#   Get this token by logging in as terraform user
# vault login -method=userpass username="terraform-user" password="StrongPassword123"

}

# Fetch the secret from Vault
data "vault_kv_secret_v2" "google_map" {
  mount = "key-value-engine"
  name  = "json-kv-store/GoogleMapKey"
}

# Output the Google Map key
output "google_map_key" {
  value     = data.vault_kv_secret_v2.google_map.data["api_key"]
  sensitive = true
}
