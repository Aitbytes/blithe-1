data "vault_kv_secret_v2" "proxmox_creds" {
  mount = "kv"
  name  = "blithe/proxmox"
}

provider "proxmox" {
  endpoint            = data.vault_kv_secret_v2.proxmox_creds.data["api_url"]
  username            = data.vault_kv_secret_v2.proxmox_creds.data["username"]
  password            = data.vault_kv_secret_v2.proxmox_creds.data["password"]
  insecure            = true # Set to false if you have a valid certificate
}

module "talos_cluster" {
  source  = "bbtechsys/talos/proxmox"
  version = "0.1.5"

  talos_cluster_name = var.talos_cluster_name
  talos_version      = var.talos_version
  control_nodes      = var.control_nodes
  worker_nodes       = var.worker_nodes
  talos_schematic_id = var.schematic_id
  talos_arch         = var.arch
}

provider "vault" {}

resource "vault_kv_secret_v2" "talos_config" {
  mount = "kv"
  name  = "blithe/talos/talosconfig"
  data_json = jsonencode({
    "config" = module.talos_cluster.talos_config
  })
}

resource "vault_kv_secret_v2" "kubeconfig" {
  mount = "kv"
  name  = "blithe/talos/kubeconfig"
  data_json = jsonencode({
    "config" = module.talos_cluster.kubeconfig
  })
}
