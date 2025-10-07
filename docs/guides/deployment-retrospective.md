# Deployment Retrospective: The "Arr" Stack

This document captures the challenges, solutions, and key lessons learned during the implementation of the "arr" stack (Sonarr, Radarr, Prowlarr, qBittorrent). It serves as a practical guide for future development and troubleshooting.

## 1. Challenge: Host-Specific Conventions

*   **Problem:** The initial Ansible roles were created with a generic structure, assuming a single, centralized layout for all Docker services.
*   **Investigation:** We were reminded that the project has two distinct conventions: a "centrally managed" structure on `aitbytes.fyi` and a "self-contained" structure on `debian003`. The "arr" stack was incorrectly implemented with the former.
*   **Solution:** The roles were refactored to follow the "self-contained" pattern, where each application manages its own data within a single directory (e.g., `/data/docker/sonarr`). This experience led to the creation of the `ansible-directory-conventions.md` document to prevent this in the future.
*   **Lesson:** Always verify and adhere to established, host-specific conventions before writing code.

## 2. Challenge: Building a True End-to-End Test

*   **Problem:** The initial CI workflow was a simple syntax check, which provided no real confidence. Subsequent attempts to run a full playbook with `act` failed due to a series of environment and configuration issues.
*   **Investigation:** We debugged several layers of failure:
    1.  The `self-hosted` runner label was not recognized by `act`.
    2.  The test container was missing the `ansible-playbook` command.
    3.  The dynamic inventory file was git-ignored and thus unavailable in the CI environment.
    4.  SSH credentials were not correctly configured, leading to permission errors.
*   **Solution:** We modeled the final workflow on the existing `deploy-runner.yaml`, which provided a proven pattern. The final, successful workflow now:
    1.  Uses a container image with Ansible pre-installed (`cytopia/ansible:latest-tools`).
    2.  Generates a temporary, ad-hoc inventory file for the specific hosts being tested.
    3.  Securely decodes an SSH key from GitHub secrets and places it where the inventory expects it.
*   **Lesson:** A robust end-to-end test must create a high-fidelity replica of the target environment. This includes generating necessary artifacts (like inventories) and managing credentials securely.


## 3. Challenge: Managing Host vs. Container Permissions

*   **Problem:** After the containers were successfully deployed, the application logs showed errors like `Folder '/movies/' is not writable by user 'abc'`.
*   **Investigation:** The containers run internally with a specific UID/GID (1000), which did not have write permissions on the directories created by the `root` user on the host.
*   **Solution:** We added tasks to the Ansible roles to explicitly set the ownership of the media directories to the correct UID/GID (`owner: "1000"`, `group: "1000"`).
*   **Lesson:** Never assume default permissions will work for host-mounted volumes. Always ensure the user inside the container has the necessary permissions on the directories it needs to write to on the host.
