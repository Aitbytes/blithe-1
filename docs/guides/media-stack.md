# Guide: The Media Stack

This guide provides an overview of the media stack, a suite of applications for managing and downloading media.

## Overview

The media stack is deployed on the `debian003` host and consists of the following services:

*   **Series Manager:** For managing and automatically downloading TV shows.
*   **Movie Manager:** For managing and automatically downloading movies.
*   **Music Manager:** For managing and automatically downloading music.
*   **Book Manager:** For managing and automatically downloading books.
*   **Indexer Manager:** An indexer manager for the series and movie managers.
*   **Download Client:** A torrent client used by the managers to download media.

All services are deployed as Docker containers and are managed by Ansible.

## Deployment

The deployment of the media stack is automated through a series of Ansible roles:

*   `series-manager`: Deploys and configures the series manager.
*   `movie-manager`: Deploys and configures the movie manager.
*   `music-manager`: Deploys and configures the music manager.
*   `book-manager`: Deploys and configures the book manager.
*   `indexer-manager`: Deploys and configures the indexer manager.
*   `download-client`: Deploys and configures the download client.
*   `media-network`: Creates a dedicated Docker network named `media-net` for the services to communicate with each other.

The main Ansible playbook (`site.yml`) includes these roles, and they can be deployed by running the playbook with the appropriate tags:

```bash
ansible-playbook site.yml --tags "series-manager,movie-manager,indexer-manager,download-client,music-manager,book-manager"
```

## Configuration

The configuration for each service is managed within its respective Ansible role. The `defaults/main.yml` file in each role's directory contains variables that can be customized, such as data directories and download locations.

The services are exposed through the Traefik reverse proxy, and their hostnames are defined in the `config-ansible/roles/traefik/defaults/main.yml` file.

## Testing

A dedicated GitHub Actions workflow (`.github/workflows/test-media-stack.yaml`) is in place to provide end-to-end testing for the media stack deployment. This workflow is triggered on pull requests that modify any of the media stack roles and ensures that the deployment process is working as expected.
