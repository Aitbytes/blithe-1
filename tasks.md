# Project Task Tracker

## Current Focus
Install Rancher on Talos Cluster

## Completed Tasks
- [x] Consolidate and structure the project documentation.
- [x] Add Nix environment for reproducible development.
- [x] Add self-hosted GitHub Actions runner.
- [x] Scaffolding for Sonarr, Radarr, Prowlarr, and qBittorrent roles.
- [x] Initial implementation of the Prowlarr role (defaults, docker-compose).
- [x] Document Ansible role directory structure conventions.
- [x] Complete implementation of the ""arr"" stack (Sonarr, Radarr, Prowlarr, qBittorrent).
- [x] Review and refactor ""arr"" stack implementation to align with host-specific directory conventions.
- [x] **Experiment: Create a Single-Node Ceph Cluster on `zsus-pve`**
    -   **Phase 1: Prerequisites & Safety Checks**
        -   [x] **Verify ZFS Pool Health**: Connect to `zsus-pve` and run `zpool status Alpha-Aegialeus`. Confirm the pool is `ONLINE` and not degraded or resilvering before proceeding.
    -   **Phase 2: Network Configuration (Ceph Cluster Network)**
        -   [x] **Define Cluster Network**: We will use the `private0` bridge for a dedicated, isolated cluster network.
        -   [x] **Assign IP Address**: Edit `/etc/network/interfaces` on `zsus-pve` to add a static IP to the `private0` interface (e.g., `address 10.10.10.10/24`).
        -   [x] **Apply Network Changes**: Reload the network configuration using `ifreload -a` or by rebooting the node.
    -   **Phase 3: Storage Partitioning**
        -   [x] **Connect to Host**: SSH into `zsus-pve`.
        -   [x] **Partition `/dev/sda`**: Use `parted /dev/sda` to create a new 100GB partition in the unallocated space.
        -   [x] **Partition `/dev/sdc`**: Use `parted /dev/sdc` to create a new 100GB partition in the unallocated space.
        -   [x] **Verify Partitions**: Note the names of the new partitions (e.g., `/dev/sda4`, `/dev/sdc2`).
    -   **Phase 4: Ceph Installation & Initialization**
        -   [x] **Install Ceph**: From the Proxmox GUI (or `pveceph install`), install the Ceph Quincy packages.
        -   [x] **Initialize Cluster**: Initialize the cluster from the shell: `pveceph init --network 10.10.10.0/24`.
        -   [x] **Create OSDs**: Create one Object Storage Daemon (OSD) on each new partition:
            -   `pveceph osd create /dev/sdaX` (replace X with the correct partition number)
            -   `pveceph osd create /dev/sdcY` (replace Y with the correct partition number)
    -   **Phase 5: Proxmox Integration**
        -   [x] **Create Ceph Pool**: Create a new pool for VM disks. For a single-node, 2-OSD setup, the replica size must be 2: `pveceph pool create rbd-proxmox --size 2 --min_size 1`.
        -   [x] **Add Storage to Proxmox**: From the Proxmox GUI, go to `Datacenter -> Storage -> Add` and select `RBD`. Choose the `rbd-proxmox` pool.
    -   **Phase 6: Verification**
        -   [x] **Check Health**: Run `ceph -s` and verify the cluster is in a `HEALTH_OK` state.
        -   [x] **Test Deployment**: Create a new, small VM or container and place its disk on the new `rbd-proxmox` storage. Verify it boots and operates correctly.

## In Progress
## Completed Tasks
- [x] **Obfuscate Media Stack**
    - [x] Rename Ansible roles (`arr-network` -> `media-network`, `sonarr` -> `series-manager`, etc.).
    - [x] Update `config-ansible/site.yml` with new role names and tags.
    - [x] Update `config-ansible/roles/traefik/defaults/main.yml` to use obfuscated service names.
    - [x] Rename and update `.github/workflows/test-arr-stack.yaml` to `.github/workflows/test-media-stack.yaml`.
    - [x] Rename and update `docs/guides/arr-stack.md` to `docs/guides/media-stack.md`.
    - [x] Update `docs/architecture.md` and `docs/reference/ansible.md` to remove "arr stack" references.
    - [x] Modify Ansible roles to fetch container image names from Vault.
    - [x] Implement declarative authentication and configuration for the media stack.
    - [x] Test the implementation of the obfuscated media stack.
- [ ] **Install Rancher on Talos Cluster**
    - [ ] **Phase 1: Install Ceph CSI Driver**
        - [x] Securely store Ceph admin key in Vault.
        - [x] Install and configure Vault-Kubernetes authentication (`setup-vault-k8s-auth.sh`).
        - [ ] Add `ceph-csi` Helm repository.
        - [ ] Create `ceph-csi-rbd` namespace.
        - [ ] Create `values.yaml` for the `ceph-csi-rbd` chart with Vault integration.
        - [ ] Install the chart using Helm.
    - [ ] **Phase 2: Create Default StorageClass**
        - [ ] Define and apply a `StorageClass` manifest for Ceph RBD.
        - [ ] Set the new `StorageClass` as the default.
    - [ ] **Phase 3: Install Rancher**
        - [ ] Add the Rancher Helm repository.
        - [ ] Create the `cattle-system` namespace.
        - [ ] Install Rancher using Helm.

## Pending Tasks

