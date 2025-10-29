# Virtual Network and Services Appliance Setup

This guide provides a detailed overview of the isolated virtual network and the services running within it. The entire environment is managed declaratively using a combination of Terraform and Ansible, ensuring it is reproducible, scalable, and secure.

## Architecture Overview

The virtual network is designed to be an isolated environment for running containerized services, with a single, controlled point of access to the physical network and the internet.

### Key Components:

*   **Proxmox Host**: The hypervisor that hosts the virtual network and all its components.
*   **`vmbr1` (Virtual Bridge)**: A Linux bridge on the Proxmox host that acts as the virtual switch for the isolated network. It is not connected to any physical network interface.
*   **`10.0.0.0/24` Subnet**: The private IP address space used by the virtual network.
*   **`lxc-network-appliance` (Pi-hole)**: An LXC container that serves as the core of the virtual network. It has two network interfaces:
    *   `net0`: Connected to `vmbr1` with a static IP of `10.0.0.2`.
    *   `net1`: Connected to the physical network (`vmbr0`) to provide internet access.
*   **`lxc-traefik-client` (Traefik)**: An LXC container that is connected *only* to the `vmbr1` virtual network. It serves as a reverse proxy for services within the virtual network and as a test client.

### Network Traffic Flow:

1.  The `lxc-traefik-client` (and any other clients on `vmbr1`) receives its IP address, DNS server (`10.0.0.2`), and default gateway (`10.0.0.2`) from the Pi-hole DHCP server.
2.  When the Traefik client needs to access the internet, it sends the traffic to its gateway, the Pi-hole appliance.
3.  The Pi-hole appliance, configured as a NAT router, uses `iptables` to masquerade the traffic and sends it out to the physical network via its `net1` interface.

## Automation and Management

The entire lifecycle of this environment is managed through Infrastructure as Code (IaC).

### Infrastructure Provisioning (Terraform)

*   **Location**: `infra-terraform/proxmox-vnet/`
*   **Function**: The Terraform module in this directory is responsible for provisioning the Proxmox resources, including:
    *   The `vmbr1` Linux bridge.
    *   The `lxc-network-appliance` (Pi-hole) container with its dual network interfaces.
    *   The `lxc-traefik-client` container with its single virtual network interface.
*   **Dynamic Inventory**: After provisioning, Terraform generates an Ansible inventory with the connection details for the new containers and stores it securely in HashiCorp Vault.

### Configuration Management (Ansible)

*   **Location**: `config-ansible/`
*   **Dynamic Inventory**: The `dynamic_inventory.py` script fetches the current infrastructure details from Vault, allowing Ansible to target the dynamically provisioned containers.
*   **Roles**:
    *   **`router`**: Applied to the Pi-hole appliance. It configures `sysctl` for IP forwarding and manages `iptables` to perform NAT.
    *   **`docker`**: Applied to both appliances to install and configure the Docker runtime.
    *   **`network-appliance` (Pi-hole)**: Applied to the Pi-hole appliance. It deploys and configures the Pi-hole Docker container using a declarative `pihole.toml` file, which includes the DHCP server configuration.
    *   **`traefik-internal`**: Applied to the Traefik appliance. It deploys and configures the Traefik Docker container.
*   **Execution Order**: The main playbook (`proxmox_vnet.yml`) is structured to enforce a sequential execution order, ensuring the Pi-hole appliance (including the router and DHCP server) is fully configured before any dependent clients like the Traefik appliance are set up.

### CI/CD (GitHub Actions)

*   **Custom Execution Image**: A custom Docker image, defined in `docker/Dockerfile`, is built and pushed to `ghcr.io`. This image contains Ansible and all necessary Python dependencies, ensuring a consistent and reliable execution environment for all CI/CD workflows.
*   **Testing**: The `test-network-appliance.yaml` workflow provides end-to-end testing of the entire stack. It uses the custom Docker image and the dynamic inventory to run the Ansible playbook against the provisioned infrastructure, verifying that the entire automation pipeline is working correctly.
