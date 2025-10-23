variable "talos_cluster_name" {
  description = "Name of the Talos cluster"
  type        = string
  default     = "talos-cluster"
}

variable "talos_version" {
  description = "Version of Talos to use"
  type        = string
  default     = "1.11.3"
}

variable "control_nodes" {
  description = "Map of talos control node names to proxmox node names"
  type        = map(string)
  default = {
    "m-1-kondeas" = "zsus-pve"
    "m-2-papadides" = "zsus-pve"
    "m-3-andreadelis" = "zsus-pve"
  }
}

variable "worker_nodes" {
  description = "Map of talos worker node names to proxmox node names"
  type        = map(string)
  default = {
    "w-1-aggelos" = "zsus-pve"
    "w-2-vassilios" = "zsus-pve"
    "w-3-fotis" = "zsus-pve"
  }
}

variable "schematic_id" {
  description = "Your image schematic ID"
  type = string
  default =  "ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515"
}

variable "arch" {
  description = "Compute architecture"
  type = string
  default = "amd64"

}
