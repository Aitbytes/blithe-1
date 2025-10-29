# Project Task Tracker

## Current Focus
Document Virtual Network Architecture and Plan Next Steps

## Completed Tasks
- [x] **Troubleshoot and Stabilize Network Appliance Services**
    - [x] **AdGuard Home Investigation**: Diagnosed and fixed multiple crash-loop issues caused by outdated and incorrect YAML configuration.
    - [x] **Network Connectivity Debugging**: Identified and resolved a missing IPv4 default gateway on the `lxc-network-appliance`, restoring internet connectivity.
    - [x] **Session Management Issues**: Troubleshot a persistent login loop in the AdGuard Home web interface, leading to the discovery of underlying Docker volume permission problems.
    - [x] **Migration to Pi-hole**: To resolve persistent stability and configuration issues with AdGuard Home, the decision was made to migrate to Pi-hole.
- [x] **Implement Pi-hole as DNS/DHCP Server**
    - [x] **Initial Pi-hole Deployment**: Replaced the AdGuard Home configuration in the `network-appliance` role with a new configuration for Pi-hole.
    - [x] **Declarative Configuration**: Refactored the Pi-hole setup to use a fully declarative `pihole.toml` configuration file, making the deployment more robust and idempotent.
    - [x] **DHCP Configuration**: Configured the Pi-hole container to act as the DHCP server for the isolated `net0` virtual network (`10.0.0.0/24`).
- [x] **Expand Virtual Network Infrastructure**
    - [x] **Provision Traefik Appliance**: Extended the Terraform configuration to provision a second LXC container (`lxc-traefik-client`) to serve as a dedicated reverse proxy and a test client for the virtual network.
    - [x] **Ansible Role Refactoring**: Refactored the monolithic `network-appliance` role into two distinct roles: `network-appliance` (for Pi-hole) and `traefik-internal` (for the new Traefik instance), aligning the automation with the infrastructure.
- [x] **Implement Dynamic Infrastructure Management**
    - [x] **Terraform-to-Vault Integration**: Modified the Terraform configuration to securely store the dynamically generated Ansible inventory in HashiCorp Vault.
    - [x] **Dynamic Inventory Script**: Created and debugged a Python script (`dynamic_inventory.py`) to fetch the inventory from Vault.
- [x] **Build Custom CI/CD Execution Environment**
    - [x] **Dockerfile for Ansible**: Created a custom Dockerfile to build a self-contained Ansible execution environment.
    - [x] **CI Workflow for Image Build**: Implemented a GitHub Actions workflow to automatically build and push the custom Ansible image to `ghcr.io`.
- [x] **Implement Virtual Network Routing**
    - [x] **Create Router Role**: Created a new Ansible role (`router`) to configure the Pi-hole appliance to act as a NAT router.
    - [x] **Troubleshoot Connectivity**: Diagnosed and resolved a complex routing issue caused by ICMP redirects and incorrect gateway configurations, ensuring clients on the virtual network could correctly access the internet through the Pi-hole appliance.
- [x] **Finalize Client Configuration**
    - [x] **Dynamic IP Allocation**: Updated the Terraform configuration for the `traefik_appliance` to explicitly configure it to receive its IP address from the Pi-hole DHCP server.
- [x] **Finalize CI/CD Integration**
    - [x] **Sequential Execution**: Refactored the main Ansible playbook to enforce a sequential execution order, ensuring the Pi-hole appliance is fully configured before the dependent Traefik appliance.
    - [x] **End-to-End Verification**: Successfully ran the `test-network-appliance` workflow, confirming that the entire dynamic infrastructure and automation pipeline is working correctly.

## Pending Tasks
- [ ] **Migrate Traefik to a dedicated machine.**
- [ ] **Install Rancher on Talos Cluster**