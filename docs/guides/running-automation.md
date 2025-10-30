# Running Automation: Terraform and Ansible

This guide details the procedures for running the Terraform module to provision the infrastructure and the Ansible playbook to configure it.

## 1. Running the Terraform Module

The Terraform module is responsible for creating the Proxmox resources, including the LXC containers and the virtual network bridge (`vmbr1`).

### Prerequisites

*   Terraform CLI installed.
*   Network access to the Proxmox host.
*   Environment variables configured with the necessary secrets:
    *   `VAULT_ADDR`: The URL of the HashiCorp Vault instance.
    *   `VAULT_TOKEN`: A valid Vault token with access to the project's secrets.
    *   `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`: For any S3 backend state storage.

### Execution Steps

1.  **Navigate to the correct directory**:
    ```bash
    cd infra-terraform/proxmox-vnet
    ```

2.  **Initialize Terraform**:
    This downloads the necessary providers.
    ```bash
    terraform init
    ```

3.  **Review the execution plan**:
    (Optional but recommended) This shows you what resources will be created, modified, or destroyed.
    ```bash
    terraform plan
    ```

4.  **Apply the configuration**:
    This will provision the resources on Proxmox.
    ```bash
    terraform apply
    ```

## 2. Running the Ansible Playbook

The Ansible playbook configures the appliances provisioned by Terraform. It installs Docker, sets up Pi-hole and Traefik, and configures the routing.

### Prerequisites

*   The Terraform module must have been successfully applied first.
*   SSH access to the Proxmox host (`192.168.1.10`) from the machine where you are running the command.
*   A valid SSH private key (e.g., `~/.ssh/id_rsa`) that is authorized on the Proxmox host.
*   Environment variables for Vault (`VAULT_ADDR`, `VAULT_TOKEN`).

### Method 1: Recommended (CI/CD Emulation)

This is the most reliable method as it uses the project's containerized execution environment, ensuring all dependencies and custom plugins are correctly loaded.

1.  **Run the playbook using the custom Docker image**:

    The following command mounts the project directory and your SSH key into the container, sets the correct working directory so `ansible.cfg` is found, and executes the playbook.

    ```bash
    docker run --rm -it \
      -v /path/to/your/blithe-1:/workdir \
      -v ~/.ssh/id_rsa:/root/.ssh/id_rsa \
      -w /workdir/config-ansible \
      -e VAULT_ADDR \
      -e VAULT_TOKEN \
      -e ANSIBLE_SSH_ARGS='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null' \
      ghcr.io/aitbytes/ansible:latest \
      ansible-playbook -i dynamic_inventory.py proxmox_vnet.yml
    ```
    *Replace `/path/to/your/blithe-1` with the absolute path to the project root on your local machine.*

### Method 2: Local Execution (Advanced)

This method runs Ansible directly on your local machine. It requires you to manage the Python environment and dependencies yourself.

1.  **Create and activate a Python virtual environment**:
    ```bash
    python3 -m venv .venv
    source .venv/bin/activate
    ```

2.  **Install Python dependencies**:
    ```bash
    pip install -r config-ansible/requirements.txt
    ```

3.  **Navigate to the Ansible directory**:
    The `ansible.cfg` file is located here, which contains important configuration.
    ```bash
    cd config-ansible
    ```

4.  **Run the playbook**:
    ```bash
    ansible-playbook -i dynamic_inventory.py proxmox_vnet.yml
    ```
