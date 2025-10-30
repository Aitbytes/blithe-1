data "vault_kv_secret_v2" "network_appliance_creds" {
  mount = "kv"
  name  = "blithe/network-appliance"
}

resource "proxmox_virtual_environment_container" "pihole_appliance" {
  node_name    = "zsus-pve"
  vm_id        = 200
  description  = "Pi-hole DNS and DHCP Server"
  unprivileged = true
  start_on_boot  = true

  depends_on = [
    proxmox_virtual_environment_network_linux_bridge.vnet_bridge
  ]

  features {
    nesting = true
  }

  cpu {
    cores      = 1
    architecture = "amd64"
  }

  memory {
    dedicated = 512
    swap      = 512
  }

  operating_system {
    template_file_id = "local:vztmpl/debian-12-standard_12.7-1_amd64.tar.zst"
    type             = "debian"
  }

  initialization {
    hostname = "lxc-network-appliance"
    ip_config {
      ipv4 {
        address = "10.0.0.2/24"
      }
    }
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
    user_account {
      password = data.vault_kv_secret_v2.network_appliance_creds.data["root_password"]
    }
  }

  disk {
    datastore_id = "local-lvm"
    size         = 8
  }

  network_interface {
    name   = "net0"
    bridge = "vmbr1"
  }

  network_interface {
    name   = "net1"
    bridge = "vmbr0"
  }
}



