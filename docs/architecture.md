# Architecture

This project manages the infrastructure for a personal server, `aitbytes.fyi`, using a combination of Terraform and Ansible. The goal is to automate the provisioning and configuration of a server on Hetzner Cloud and deploy a variety of self-hosted services.

**Key Technologies:**

*   **Terraform:** Used for provisioning the server infrastructure on Hetzner Cloud.
*   **Ansible:** Used for configuring the server and deploying Dockerized services.
*   **Docker:** Used to containerize the deployed services.
*   **Traefik:** Used as a reverse proxy to expose the services.
*   **HashiCorp Vault:** Used for managing secrets.
*   **GitHub Actions:** Used for CI/CD to validate infrastructure and configuration changes.

## Infrastructure Layer
* **Terraform Infrastructure**: Hetzner Cloud infrastructure provisioning with Cloudflare DNS management
    * **Primary Logic**: [`infra-terraform/main.tf`](../infra-terraform/main.tf)
    * **Cloudflare Configuration**: [`infra-terraform/cloudflare.tf`](../infra-terraform/cloudflare.tf)
    * **Vault Integration**: [`infra-terraform/vault.tf`](../infra-terraform/vault.tf)
    * **Dynamic Inventory**: [`infra-terraform/inventory.tftpl`](../infra-terraform/inventory.tftpl)

## Configuration Management
* **Ansible Playbooks**: Multi-stage deployment with security-first approach
    * **Main Playbook**: [`config-ansible/site.yml`](../config-ansible/site.yml)
    * **Global Variables**: [`config-ansible/group_vars/all.yml`](../config-ansible/group_vars/all.yml)
    * **Secrets Management**: Vault integration for all sensitive data
    * **Deployment Stages**:
        1. Security hardening (as root)
        2. Docker installation (as admin user)
        3. Service deployment (as admin user)
