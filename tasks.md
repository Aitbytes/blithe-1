# Project Task Tracker

## Current Focus
Integrate Dynamic Inventory into CI/CD Workflow

## Completed Tasks
- [x] **Troubleshoot and Stabilize Network Appliance Services**
    - [x] **AdGuard Home Investigation**: Diagnosed and fixed multiple crash-loop issues caused by outdated and incorrect YAML configuration.
    - [x] **Network Connectivity Debugging**: Identified and resolved a missing IPv4 default gateway on the `lxc-network-appliance`, restoring internet connectivity.
    - [x] **Session Management Issues**: Troubleshot a persistent login loop in the AdGuard Home web interface, leading to the discovery of underlying Docker volume permission problems.
    - [x] **Migration to Pi-hole**: To resolve persistent stability and configuration issues with AdGuard Home, the decision was made to migrate to Pi-hole.
- [x] **Implement Pi-hole as DNS/DHCP Server**
    - [x] **Initial Pi-hole Deployment**: Replaced the AdGuard Home configuration in the `network-appliance` role with a new configuration for Pi-hole.
    - [x] **DHCP Configuration**: Configured the Pi-hole container to act as the DHCP server for the isolated `net0` virtual network (`10.0.0.0/24`).
- [x] **Expand Virtual Network Infrastructure**
    - [x] **Provision Traefik Appliance**: Extended the Terraform configuration to provision a second LXC container (`lxc-traefik-client`) to serve as a dedicated reverse proxy and a test client for the virtual network.
    - [x] **Ansible Inventory Refactoring**: Restructured the Ansible inventory to support the new two-appliance setup, creating distinct groups for the Pi-hole and Traefik servers.
- [x] **Implement Dynamic Infrastructure Management**
    - [x] **Terraform-to-Vault Integration**: Modified the Terraform configuration to securely store the dynamically generated Ansible inventory in HashiCorp Vault instead of a local file.
    - [x] **Dynamic Inventory Script**: Created a Python script (`dynamic_inventory.py`) to fetch the inventory from Vault, making the Ansible automation aware of the dynamically provisioned infrastructure.
- [x] **Build Custom CI/CD Execution Environment**
    - [x] **Dockerfile for Ansible**: Created a custom Dockerfile to build a self-contained Ansible execution environment with all necessary Python dependencies (`hvac`, `pyyaml`) and tools (`yq`).
    - [x] **CI Workflow for Image Build**: Implemented a GitHub Actions workflow to automatically build and push the custom Ansible image to the GitHub Container Registry (`ghcr.io`).
- [x] **Fix and Refactor Dynamic Inventory Script**
    - [x] **Diagnose Inventory Failure**: Investigated why the dynamic inventory script was not providing hosts to Ansible within the CI/CD environment.
    - [x] **Refactor Inventory Structure**: Updated the Terraform template (`inventory.tftpl`) to generate a flatter, more standard inventory structure, removing complex nesting that was causing parsing issues.
    - [x] **Rewrite Inventory Script**: Based on official Ansible documentation, completely rewrote the script's output generation (`format_for_ansible` function) to produce a JSON structure that is fully compliant with Ansible's expectations for dynamic inventories.
    - [x] **Verify All Script Logic**: Corrected both the `--list` and `--host` functions within the script to ensure all modes of operation work with the new, flatter data model.
- [x] **Integrate Dynamic Inventory into CI/CD Workflow**
    - [x] **Successful Integration**: With the inventory script and data source corrected, the `test-dynamic-inventory` and `test-network-appliance` workflows now execute successfully, confirming the dynamic inventory is fully integrated.

## In Progress
- [ ] **Finalize CI/CD Integration**
    - [ ] Verify that the `test-network-appliance` workflow runs successfully with the new dynamic inventory setup.
- [ ] **Implement Virtual Router/Firewall**
- [ ] **Migrate Existing Services to Virtual Network**
- [ ] **Migrate Traefik to a dedicated machine.**
- [ ] **Install Rancher on Talos Cluster**