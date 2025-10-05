# Ansible Role Directory Conventions

This document outlines the directory structure conventions for Ansible roles based on the target host. Adhering to these conventions ensures consistency and predictability across the project.

## Host: `aitbytes.fyi`

Roles deployed to `aitbytes.fyi` are considered "centrally managed" services that often interact with each other, primarily through the Traefik reverse proxy.

**Key Conventions:**

*   **Central Docker Directory:** All services use a shared base directory defined by the `docker_base_dir` variable (e.g., `/srv/docker`).
*   **Standardized Layout:** Within the `docker_base_dir`, a consistent structure is used:
    *   `compose/<service_name>/`: Contains the `docker-compose.yml` file.
    *   `config/<service_name>/`: Contains service-specific configuration files.
    *   `data/<service_name>/`: Contains persistent data volumes.
*   **Shared Network:** Services connect to the external `traefik-net` Docker network to be managed by the Traefik reverse proxy.
*   **Variable-driven Paths:** All directory paths within the role are derived from the `docker_base_dir` variable.

**Example (`vault` role):**

*   `defaults/main.yml`:
    ```yaml
    vault_data_dir: "{{ docker_base_dir }}/data/vault/data"
    vault_config_dir: "{{ docker_base_dir }}/config/vault"
    ```
*   `tasks/main.yml`:
    ```yaml
    - name: Template Docker Compose file
      template:
        src: docker-compose.yml.j2
        dest: "{{ docker_base_dir }}/compose/vault/docker-compose.yml"

    - name: Deploy Vault container
      community.docker.docker_compose_v2:
        project_src: "{{ docker_base_dir }}/compose/vault"
    ```

## Host: `debian003`

Roles deployed to `debian003` are treated as "self-contained" or standalone applications.

**Key Conventions:**

*   **Self-Contained Directory:** Each role defines a hardcoded, top-level directory for all its files and data (e.g., `/data/docker/wordpress`).
*   **Co-located Files:** The `docker-compose.yml`, environment files (`.env`), and data volumes are all stored within this single, role-specific directory.
*   **Isolated Networking:** Services typically create and use their own dedicated Docker network. They may expose ports directly to the host.
*   **Hardcoded Paths:** The main data directory is defined as a static path in `defaults/main.yml`.

**Example (`wordpress` role):**

*   `defaults/main.yml`:
    ```yaml
    wordpress_data_dir: /data/docker/wordpress
    ```
*   `tasks/main.yml`:
    ```yaml
    - name: Template docker-compose.yml
      template:
        src: docker-compose.yml.j2
        dest: "{{ wordpress_data_dir }}/docker-compose.yml"

    - name: Deploy WordPress stack
      community.docker.docker_compose_v2:
        project_src: "{{ wordpress_data_dir }}"
    ```
