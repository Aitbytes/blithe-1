# Project Blithe-1: Assistant Guidelines

Welcome, assistant. This document provides the essential context and rules for working on the Blithe-1 project.

## 1. Project Overview

This is an Infrastructure as Code (IaC) project that automates the setup of a personal server. It uses Terraform for cloud provisioning and Ansible for configuration management.

The primary source of truth for the project's architecture, setup, and guides is the `/docs` directory. **Always refer to it before making changes.**

## 2. Core Principles

This project adheres to a strict set of software engineering and security principles.

### GitFlow Model

We use the GitFlow branching model:

-   **`main`**: Production-ready, stable code. Only merge into `main` from `develop` or `hotfix` branches.
-   **`develop`**: The primary integration branch for new features.
-   **`feature/<feature-name>`**: All new work must be done in a feature branch created from `develop`.
-   **`hotfix/<issue-name>`**: For critical production bugs. Branched from `main` and must be merged back into both `main` and `develop`.

### Automation (CI/CD)

All changes are validated by GitHub Actions workflows before merging.

-   `dry-run.yaml`: Validates Terraform and Ansible changes on pushes/PRs to `develop` and `main`.
-   `deploy-docs.yaml`: Deploys the documentation site on pushes to `main`.

### **MANDATORY TESTING PROTOCOL**

**ALL CHANGES, WITHOUT EXCEPTION, MUST BE ACCOMPANIED BY A NEW OR UPDATED GITHUB ACTIONS WORKFLOW THAT TESTS THE CHANGE.** This ensures that every feature, fix, or refactor is verifiable and robust. Before committing any workflow changes, you **MUST** test them locally using `act`.

**ALL CHANGES, WITHOUT EXCEPTION, MUST BE ACCOMPANIED BY A NEW OR UPDATED GITHUB ACTIONS WORKFLOW THAT TESTS THE CHANGE.** Before committing any workflow changes, you **MUST** test them locally using `act`.

**Example:**

If you add a new Ansible role named `new-service`, you **MUST** also:
1.  Create a new workflow file (e.g., `.github/workflows/test-new-service.yaml`).
2.  This workflow **MUST** contain a job that runs the `new-service` role, likely using tags to isolate it.
3.  You **MUST** then run `act` locally to prove that the new workflow and the Ansible role work correctly.
4.  Only after the local `act` run succeeds can you commit the new role and the new workflow.

### Zero-Trust Secrets Management

**NEVER, under any circumstances, commit secrets to this repository.**

-   All secrets (API tokens, keys, etc.) must be managed in HashiCorp Vault.
-   Code should retrieve secrets from Vault at runtime.
-   This repository's history has been cleaned of secrets once before. Do not repeat that mistake. Any file containing secrets must be added to `.gitignore`.

## 3. Your Golden Rules

1.  **Consult the Docs**: Before taking any action, review the documentation in the `/docs` directory.
2.  **Respect the Workflow**: All code changes must follow the GitFlow model via Pull Requests from a `feature` branch into `develop`.
3.  **Plan Your Work**: For any non-trivial task, create a plan and present it before you start writing code or running commands.
4.  **Update Documentation**: If your changes affect the architecture, setup, or a user-facing guide, you **must** update the relevant files in the `/docs` directory as part of the same commit or pull request.

## 4. Development Patterns & Lessons

This section codifies lessons learned from past work. Apply these principles to all future tasks.

1.  **Verify Host-Specific Conventions**:
    *   **Lesson:** Ansible roles in this project have different structures depending on their target host (`aitbytes.fyi` vs. `debian003`).
    *   **Action:** Before creating or modifying a role, I **must** consult the `docs/reference/ansible-directory-conventions.md` file and replicate the correct pattern for the target host.

2.  **Build True End-to-End Tests**:
    *   **Lesson:** A simple syntax check (`--check`) is not a sufficient test. A CI workflow must replicate the real deployment environment as closely as possible.
    *   **Action:** When creating a new test workflow for Ansible, I **must** follow the pattern established in `deploy-runner.yaml` and `test-arr-stack.yaml`. This includes:
        *   Using a container image with all necessary tools (`cytopia/ansible:latest-tools`).
        *   Generating a temporary, ad-hoc inventory file that defines the target hosts.
        *   Securely loading SSH keys and other secrets required for a full, live connection to the test targets.

3.  **Manage Container Permissions Explicitly**:
    *   **Lesson:** Docker containers running as a non-root user (e.g., UID 1000) do not have automatic write access to host volumes created by Ansible (which runs as `root`).
    *   **Action:** When an Ansible role creates a directory on the host that will be used as a volume for a container, I **must** add a task to explicitly set the ownership of that directory to match the UID/GID of the user inside the container (e.g., `owner: "1000"`, `group: "1000"`).
