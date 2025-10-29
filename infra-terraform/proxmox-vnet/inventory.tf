resource "vault_kv_secret_v2" "ansible_inventory" {
  mount = "kv"
  name  = "blithe/ansible-inventory/proxmox-vnet"
  data_json = jsonencode({
    inventory = templatefile("${path.module}/inventory.tftpl", {
      pihole_appliance  = proxmox_virtual_environment_container.pihole_appliance,
      traefik_appliance = proxmox_virtual_environment_container.traefik_appliance
    })
  })
}
