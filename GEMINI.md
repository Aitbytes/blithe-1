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

All changes are validated by GitHub Actions workflows before merging:

-   `dry-run.yaml`: Validates Terraform and Ansible changes on pushes/PRs to `develop` and `main`.
-   `deploy-docs.yaml`: Deploys the documentation site on pushes to `main`.

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
