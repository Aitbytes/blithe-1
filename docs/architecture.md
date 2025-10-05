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

## CI/CD

The project leverages GitHub Actions for automation and validation.

*   **`dry-run.yaml`**: This workflow runs on every push and pull request to `main` and `develop`. It performs a dry run of both Terraform (`terraform plan`) and Ansible (`ansible-playbook --check`) to validate changes before they are merged.

*   **Self-Hosted Runner**: An on-premise GitHub Actions runner is used for workflows that require access to the local network. It is installed on the `debian003` machine and managed by the `github-runner` Ansible role.

*   **`deploy-runner.yaml`**: A manually triggered workflow used to deploy or update the self-hosted runner on the `debian003` machine. This workflow must be run from a local machine using `act`.

*   **`test-runner-connectivity.yaml`**: A manually triggered workflow that runs on the self-hosted runner to test its ability to connect to other machines on the local network.
