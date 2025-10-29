data "vault_kv_secret_v2" "proxmox_creds" {
  mount = "kv"
  name  = "blithe/proxmox"
}

provider "vault" {}

provider "proxmox" {
  endpoint = data.vault_kv_secret_v2.proxmox_creds.data["api_url"]
  username = data.vault_kv_secret_v2.proxmox_creds.data["username"]
  password = data.vault_kv_secret_v2.proxmox_creds.data["password"]

  insecure = true # Set to false if you have a valid certificate
}

resource "proxmox_virtual_environment_network_linux_bridge" "vnet_bridge" {
  node_name = "zsus-pve"
  name      = "vmbr1"

  address = "10.0.0.1/24"
  comment = "Isolated virtual network for services."

  autostart = true
}