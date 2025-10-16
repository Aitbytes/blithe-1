# Guide: The "Arr" Stack

This guide provides an overview of the "arr" stack (Sonarr, Radarr, Lidarr, Readarr, Prowlarr, and qBittorrent), a suite of applications for managing and downloading media.

## Overview

The "arr" stack is deployed on the `debian003` host and consists of the following services:

*   **Sonarr:** For managing and automatically downloading TV shows.
*   **Radarr:** For managing and automatically downloading movies.
*   **Lidarr:** For managing and automatically downloading music.
*   **Readarr:** For managing and automatically downloading books.
*   **Prowlarr:** An indexer manager for Sonarr and Radarr.
*   **qBittorrent:** A torrent client used by Sonarr and Radarr to download media.

All services are deployed as Docker containers and are managed by Ansible.

## Deployment

The deployment of the "arr" stack is automated through a series of Ansible roles:

*   `sonarr`: Deploys and configures Sonarr.
*   `radarr`: Deploys and configures Radarr.
*   `lidarr`: Deploys and configures Lidarr.
*   `readarr`: Deploys and configures Readarr.
*   `prowlarr`: Deploys and configures Prowlarr.
*   `qbittorrent`: Deploys and configures qBittorrent.
*   `arr-network`: Creates a dedicated Docker network named `arr-net` for the services to communicate with each other.

The main Ansible playbook (`site.yml`) includes these roles, and they can be deployed by running the playbook with the appropriate tags:

```bash
ansible-playbook site.yml --tags "sonarr,radarr,prowlarr,qbittorrent,lidarr,readarr"
```

## Configuration

The configuration for each service is managed within its respective Ansible role. The `defaults/main.yml` file in each role's directory contains variables that can be customized, such as data directories and download locations.

The services are exposed through the Traefik reverse proxy, and their hostnames are defined in the `config-ansible/roles/traefik/defaults/main.yml` file.

## Testing

A dedicated GitHub Actions workflow (`.github/workflows/test-arr-stack.yaml`) is in place to provide end-to-end testing for the "arr" stack deployment. This workflow is triggered on pull requests that modify any of the "arr" stack roles and ensures that the deployment process is working as expected.
