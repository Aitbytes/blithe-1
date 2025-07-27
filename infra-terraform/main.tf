# Configure the Hetzner Cloud provider
terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5"
    }
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.50.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.10.0"
    }
  }
}

resource "hcloud_ssh_key" "main" {
  name       = "my-ssh-key"
  public_key = file("~/.ssh/id_rsa.pub")
}

provider "hcloud" {
  token = data.vault_kv_secret_v2.hcloud.data["token"]
}

# Variables for Cloudflare configuration retrieved from Vault
locals {
  cloudflare_config = {
    api_token    = data.vault_kv_secret_v2.cloudflare.data["api_token"]
    account_id   = data.vault_kv_secret_v2.cloudflare.data["account_id"]
    zone_id      = data.vault_kv_secret_v2.cloudflare.data["zone_id"]
    record_name  = data.vault_kv_secret_v2.cloudflare.data["record_name"]
  }
}

variable "node_count" {
  type        = number
  default     = 1
  description = "Number of nodes to create"
}

variable "node_prefix" {
  type        = string
  default     = "blithe"
  description = "Prefix for the node names"
}

variable "server_type" {
  type        = string
  default     = "cax11"
  description = "Hetzner Cloud server type"
}

variable "image" {
  type        = string
  default     = "debian-12"
  description = "Operating system image"
}

# Generate random prefix
resource "random_id" "node_prefix" {
  byte_length = 4
  prefix      = "${var.node_prefix}-"
}

# Generate timestamp for unique naming
resource "time_static" "creation_time" {}

variable "admin_username" {
  type        = string
  default     = "adminuser"
  description = "Username for the admin user"
}

# Generate random password for admin user
resource "random_password" "admin_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# Create Hetzner Cloud servers
resource "hcloud_server" "nodes" {
  count             = var.node_count
  name              = "${var.node_prefix}-${formatdate("MMDDHHmm", time_static.creation_time.rfc3339)}-${count.index + 1}"
  server_type       = var.server_type
  image             = var.image
  backups           = false
  delete_protection = false
  location          = "nbg1"
  ssh_keys          = [hcloud_ssh_key.main.id]
  lifecycle {
    create_before_destroy = false
  }
  
  user_data = <<-EOF
    #cloud-config
    users:
      - name: ${var.admin_username}
        groups: sudo
        shell: /bin/bash
        sudo: ['ALL=(ALL) NOPASSWD:ALL']
        passwd: ${random_password.admin_password.result}
        ssh_authorized_keys:
          - ${file("~/.ssh/id_rsa.pub")}
    EOF
}

# Create the inventory file
resource "local_file" "ansible_inventory" {
  content  = templatefile("${path.module}/inventory.tftpl", {
    nodes = {
    for i in range(var.node_count) :
    "${var.node_prefix}-${formatdate("MMDDHHmm", time_static.creation_time.rfc3339)}-${i + 1}" => {
        external_ip = hcloud_server.nodes[i].ipv4_address
        admin_username = var.admin_username 
      }
    }
  })
  filename = "dynamic-inventory.yml"
}

# It is necessary to provide the account with a password
# to avoid it being lock, and ansible being becoming 
# unable to connect via ssh 
# https://unix.stackexchange.com/questions/193066/how-to-unlock-account-for-public-key-ssh-authorization-but-not-for-password-aut 

output "admin_password" {
  value     = random_password.admin_password.result
  sensitive = true
  description = "Generated admin password (sensitive)"
}

output "external_ips" {
  value = {
    for i in range(var.node_count) :
    "${random_id.node_prefix.hex}-${formatdate("MMDDHHmm", time_static.creation_time.rfc3339)}-${i + 1}" => hcloud_server.nodes[i].ipv4_address
  }
  description = "External IP addresses of the created servers"
}
