# Getting Started

This guide will walk you through the process of setting up the Blithe project infrastructure.

## Development Environment

For a reproducible development environment, this project uses Nix. To activate it, run the following command from the project root:

```bash
nix-shell
```

This will install all the required tools (Terraform, Ansible, etc.) and make them available in your shell.

## Prerequisites

*   Terraform installed
*   Ansible installed
*   Hetzner Cloud API token
*   Cloudflare API token
*   HashiCorp Vault instance

## Provisioning the Infrastructure

1.  Navigate to the `infra-terraform` directory.
2.  Initialize Terraform: `terraform init`
3.  Review the plan: `terraform plan`
4.  Apply the changes: `terraform apply`

## Configuring the Server

1.  Navigate to the `config-ansible` directory.
2.  Run the main playbook: `ansible-playbook -i ../infra-terraform/dynamic-inventory.yml site.yml`

## CI/CD

The project includes a GitHub Actions workflow in `.github/workflows/dry-run.yaml` that runs `terraform plan` and `ansible-playbook --check` on every push and pull request to the main branch. This allows for validation of infrastructure and configuration changes before they are applied.
