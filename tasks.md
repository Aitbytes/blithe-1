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

- [x] **Implement Dynamic Infrastructure Management**
  - [x] **Terraform-to-Vault Integration**: Modified the Terraform configuration to securely store the dynamically generated Ansible inventory in HashiCorp Vault.
  - [x] **Dynamic Inventory Script**: Created and debugged a Python script (`dynamic_inventory.py`) to fetch the inventory from Vault.
- [x] **Build Custom CI/CD Execution Environment**
  - [x] **Dockerfile for Ansible**: Created a custom Dockerfile to build a self-contained Ansible execution environment.
  - [x] **CI Workflow for Image Build**: Implemented a GitHub Actions workflow to automatically build and push the custom Ansible image to `ghcr.io`.
- [x] **Implement Virtual Network Routing**
  - [x] **Create Router Role**: Created a new Ansible role (`router`) to configure the Pi-hole appliance to act as a NAT router.
  - [x] **Troubleshoot Connectivity**: Diagnosed and resolved a complex routing issue caused by ICMP redirects and incorrect gateway configurations, ensuring clients on the virtual network could correctly access the internet through the Pi-hole appliance.

- [x] **Finalize CI/CD Integration**
  - [x] **End-to-End Verification**: Successfully ran the `test-network-appliance` workflow, confirming that the entire dynamic infrastructure and automation pipeline is working correctly.
- [x] **Refactor DNS Configuration and Troubleshoot Tailscale**
  - [x] **Declarative DNS**: Refactored the Pi-hole DNS record management to be fully declarative by passing records to the container via the `FTLCONF_dns_hosts` environment variable.
  - [x] **Tailscale Integration Attempt**: Integrated Tailscale into the `network-appliance` to provide VPN access, routing the Pi-hole container's traffic through a dedicated Tailscale sidecar.
  - [x] **LXC `tun` Device Troubleshooting**: Diagnosed and resolved a critical issue where the Tailscale container could not start due to the LXC container lacking permissions to create a `tun` device. This was fixed by configuring the LXC container to run in privileged mode.
  - [x] **Docker Capability Troubleshooting**: Resolved a subsequent Docker error by removing the unsupported `CAP_SYS_MODULE` from the Tailscale container's capabilities.
  - [x] **Revert Tailscale Integration**: Based on operational requirements, reverted the Tailscale integration in the `network-appliance` role, returning it to a `host` network configuration.
  - [x] **Update Host Routes**: Imperatively updated the Tailscale instance on the Proxmox host to advertise the `10.0.0.0/24` virtual subnet, making it accessible across the Tailnet.

## Pending Tasks

- [ ] **Research Improved Pi-hole DNS Management**: Investigate and implement a method to create DNS records in Pi-hole via Ansible without relying on environment variables in the Docker Compose file, aiming for a more direct and robust integration (e.g., using the Pi-hole API or managing `custom.list`).

- [ ] **Install Rancher on Talos Cluster**
