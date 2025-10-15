# Deploying a Talos Cluster on Proxmox

This guide details how to use the Terraform module located in `infra-terraform/proxmox` to deploy a Talos Kubernetes cluster on a Proxmox VE host.

## Overview

The module automates the provisioning of virtual machines on Proxmox and configures them as a Talos cluster. It uses the [`bbtechsys/talos/proxmox`](https://registry.terraform.io/modules/bbtechsys/talos/proxmox/latest) module under the hood.

All outputs, including the `talosconfig` and `kubeconfig`, are stored directly in HashiCorp Vault.

## Prerequisites

-   A running Proxmox VE host.
-   A HashiCorp Vault instance with Proxmox credentials stored at `kv/blithe/proxmox`. The secret must contain the following keys:
    -   `api_url`: The Proxmox API URL (e.g., `https://pve.example.com:8006/api2/json`).
    -   `username`: The Proxmox user (e.g., `root@pam`).
    -   `password`: The user's password.
-   Terraform installed locally.
-   Vault credentials (`VAULT_ADDR` and `VAULT_TOKEN`) configured in your environment.

## Usage

1.  **Navigate to the module directory:**

    ```bash
    cd infra-terraform/proxmox
    ```

2.  **Initialize Terraform:**

    ```bash
    terraform init
    ```

3.  **(Optional) Create a `terraform.tfvars` file** to override the default variable values. See the Inputs section below for details on available variables.

4.  **Apply the configuration:**

    ```bash
    terraform apply
    ```

## Inputs

The following variables can be customized by creating a `terraform.tfvars` file or by passing them on the command line.

| Name                 | Description                                          | Type         | Default                                                                                             |
| -------------------- | ---------------------------------------------------- | ------------ | --------------------------------------------------------------------------------------------------- |
| `talos_cluster_name` | Name of the Talos cluster.                           | `string`     | `"talos-cluster"`                                                                                   |
| `talos_version`      | Version of Talos to use.                             | `string`     | `"1.11.3"`                                                                                          |
| `control_nodes`      | Map of Talos control node names to Proxmox node names. | `map(string)`| `{ "cp-Kondeas" = "zsus-pve", "cp-Papadides" = "zsus-pve", "cp-Andreadelis" = "zsus-pve" }`          |
| `worker_nodes`       | Map of Talos worker node names to Proxmox node names.  | `map(string)`| `{ "w-Aggelos" = "zsus-pve", "w-Vassilios" = "zsus-pve", "w-Fotis" = "zsus-pve" }`                  |
| `schematic_id`       | Your image schematic ID.                             | `string`     | `"ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515"`                                  |
| `arch`               | Compute architecture.                                | `string`     | `"amd64"`                                                                                           |

## Outputs

Upon successful application, the following secrets will be created in Vault:

-   **Talos Config**: `kv/blithe/talos/talosconfig`
-   **Kubeconfig**: `kv/blithe/talos/kubeconfig`

You can retrieve them using the Vault CLI:

```bash
# Get the talosconfig
vault kv get -field=config kv/blithe/talos/talosconfig > talosconfig

# Get the kubeconfig
vault kv get -field=config kv/blithe/talos/kubeconfig > kubeconfig
```
