# On-Premise Self-Hosted GitHub Runner

This project uses a self-hosted GitHub Actions runner to execute CI/CD workflows in an on-premise environment. This guide explains how to deploy and manage the runner on the `debian003` machine.

## Overview

The `debian003` host is only accessible from your local network. Therefore, the workflow to deploy the runner cannot be run from a standard GitHub-hosted runner. Instead, it must be executed from a machine within the same network that has access to the target host.

There are two recommended methods for deploying the runner:

1.  **Using `act`**: Run the workflow locally.
2.  **Using `ansible-playbook`**: Run the Ansible playbook directly.

Both methods require you to have the necessary secrets available on your local machine.

## Method 1: Deploying with `act`

This is the recommended approach as it simulates the GitHub Actions environment.

### Prerequisites

*   `act` is installed.
*   Docker is running.
*   You have a `.secrets` file in the project root containing the following secrets:
    *   `SSH_PRIVATE_KEY`: The private SSH key that can access `debian003` as the `root` user.
    *   `RUNNER_REGISTRATION_TOKEN`: The registration token from your repository's **Settings > Actions > Runners** page.

### Steps

1.  From the project root, run the following command:

    ```bash
    act workflow_dispatch -j deploy-runner
    ```

2.  `act` will read the `.github/workflows/deploy-runner.yaml` file, pull the necessary Docker image, and execute the Ansible playbook against your `debian003` machine.

## Method 2: Deploying with Ansible Directly

If you prefer not to use `act`, you can run the Ansible playbook directly.

### Prerequisites

*   Ansible is installed (you can use `nix-shell` to get it).
*   You have an SSH key configured to access `debian003` as `root`.
*   You have a GitHub Runner registration token.

### Steps

1.  Navigate to the `config-ansible` directory:

    ```bash
    cd config-ansible
    ```

2.  Run the `ansible-playbook` command, providing the registration token as an extra variable.

    ```bash
    ansible-playbook site.yml --tags github-runner \
      --extra-vars "github_runner_token=YOUR_REGISTRATION_TOKEN"
    ```

This will apply the `github-runner` role to the `debian003` host and set up the runner.
