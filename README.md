# Blithe-1: Infrastructure as Code for a Personal Server

This repository contains the Infrastructure as Code (IaC) for managing a personal server environment. It uses a combination of Terraform and Ansible to automate the provisioning of cloud resources and the deployment of various containerized services.

## Overview

The goal of this project is to create a fully automated, reproducible, and secure server setup.

-   **Infrastructure Provisioning**: [Terraform](https://www.terraform.io/) is used to provision the server on [Hetzner Cloud](https://www.hetzner.com/cloud), configure DNS with [Cloudflare](https://www.cloudflare.com/), and manage secrets with [HashiCorp Vault](https://www.vaultproject.io/).
-   **Configuration Management**: [Ansible](https://www.ansible.com/) is used to configure the server, install necessary software, and deploy a suite of services running in [Docker](https://www.docker.com/) containers.
-   **Services**: The setup includes a reverse proxy (Traefik), an observability stack (Prometheus, Grafana, Loki), object storage (MinIO), and various other self-hosted applications.

## Getting Started

### Prerequisites

Before you begin, ensure you have the following installed and configured:

-   Terraform
-   Ansible
-   Access to a HashiCorp Vault instance with the required secrets.
-   API tokens for Hetzner Cloud and Cloudflare.

### Setup & Deployment

1.  **Provision Infrastructure**:
    ```bash
    cd infra-terraform
    terraform init
    terraform apply
    ```

2.  **Configure Server**:
    ```bash
    cd config-ansible
    ansible-playbook -i ../infra-terraform/dynamic-inventory.yml site.yml
    ```

## Documentation

For detailed information on the architecture, setup, and available services, please refer to our full documentation site, which is generated from the `/docs` directory in this repository.

**(Note: The documentation site will be available via GitHub Pages once enabled in the repository settings.)**

## Contributing

This project follows the GitFlow branching model. All new work should be done in a `feature` branch and submitted as a pull request to the `develop` branch.