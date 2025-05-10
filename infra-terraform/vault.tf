provider "vault" {
  address = "https://hashi-vault.aitbytes.fyi"
  # Token can be set via VAULT_TOKEN environment variable
}

data "vault_kv_secret_v2" "hcloud" {
  mount = "kv"
  name  = "hcloud/blithe"
}

data "vault_kv_secret_v2" "cloudflare" {
  mount = "kv"
  name  = "cloudflare/aitbytes.fyi"
}

