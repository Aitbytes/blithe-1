terraform {
  required_version = ">= 1.0"

  required_providers {
    proxmox = {
      source = "bpg/proxmox"
      version = "~> 0.85.1"
    }
    talos = {
      source = "siderolabs/talos"
      version = "~> 0.7.1"
    }
    vault = {
      source  = "hashicorp/vault"
      version = ">= 3.12.0"
    }
  }
}
