terraform {
  backend "s3" {
    endpoint                    = "s3.aitbytes.fyi"
    bucket                      = "terraform-backends"
    key                         = "proxmox/terraform.tfstate"
    region                      = "us-east-1"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    force_path_style            = true
  }
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
