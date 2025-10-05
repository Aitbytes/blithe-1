# Project Overview

This project manages the infrastructure for a personal server, `aitbytes.fyi`, using a combination of Terraform and Ansible. The goal is to automate the provisioning and configuration of a server on Hetzner Cloud and deploy a variety of self-hosted services.

**Key Technologies:**

*   **Terraform:** Used for provisioning the server infrastructure on Hetzner Cloud.
*   **Ansible:** Used for configuring the server and deploying Dockerized services.
*   **Docker:** Used to containerize the deployed services.
*   **Traefik:** Used as a reverse proxy to expose the services.
*   **HashiCorp Vault:** Used for managing secrets.
*   **GitHub Actions:** Used for CI/CD to validate infrastructure and configuration changes.

**Architecture:**

The infrastructure is defined in the `infra-terraform` directory and the configuration is defined in the `config-ansible` directory. Terraform provisions the server and generates an Ansible inventory file. Ansible then connects to the server and runs a series of playbooks to install and configure the services.

The services are deployed as Docker containers and are exposed to the internet through the Traefik reverse proxy. Secrets are managed by HashiCorp Vault and are retrieved by Terraform and Ansible at runtime.

# Building and Running

**Prerequisites:**

*   Terraform installed
*   Ansible installed
*   Hetzner Cloud API token
*   Cloudflare API token
*   HashiCorp Vault instance

**Provisioning the Infrastructure:**

1.  Navigate to the `infra-terraform` directory.
2.  Initialize Terraform: `terraform init`
3.  Review the plan: `terraform plan`
4.  Apply the changes: `terraform apply`

**Configuring the Server:**

1.  Navigate to the `config-ansible` directory.
2.  Run the main playbook: `ansible-playbook -i ../infra-terraform/dynamic-inventory.yml site.yml`

**CI/CD:**

The project includes a GitHub Actions workflow in `.github/workflows/dry-run.yaml` that runs `terraform plan` and `ansible-playbook --check` on every push and pull request to the main branch. This allows for validation of infrastructure and configuration changes before they are applied.

# Development Conventions

*   **Infrastructure as Code:** All infrastructure and configuration is managed as code.
*   **Secrets Management:** All secrets are stored in HashiCorp Vault and are retrieved at runtime. No secrets should be committed to the repository.
*   **CI/CD:** All changes are validated through the CI/CD pipeline before being applied.
*   **Modularity:** The Ansible configuration is organized into roles for each service, promoting reusability and maintainability.
