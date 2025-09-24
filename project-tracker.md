# Project Tracker

## Current Status
Comprehensive infrastructure automation project for deploying containerized services using Terraform, Ansible, and Docker with full observability stack and security hardening.

---

## Current Architecture & Design

### Infrastructure Layer
* **Terraform Infrastructure**: Hetzner Cloud infrastructure provisioning with Cloudflare DNS management
    * **Primary Logic**: [`infra-terraform/main.tf`](infra-terraform/main.tf:1)
    * **Cloudflare Configuration**: [`infra-terraform/cloudflare.tf`](infra-terraform/cloudflare.tf:1)
    * **Vault Integration**: [`infra-terraform/vault.tf`](infra-terraform/vault.tf:1)
    * **Dynamic Inventory**: [`infra-terraform/inventory.tftpl`](infra-terraform/inventory.tftpl:1)

### Configuration Management
* **Ansible Playbooks**: Multi-stage deployment with security-first approach
    * **Main Playbook**: [`config-ansible/site.yml`](config-ansible/site.yml:1)
    * **Global Variables**: [`config-ansible/group_vars/all.yml`](config-ansible/group_vars/all.yml:1)
    * **Secrets Management**: Vault integration for all sensitive data
    * **Deployment Stages**:
        1. Security hardening (as root)
        2. Docker installation (as admin user)
        3. Service deployment (as admin user)

### Container Orchestration Services

#### Core Infrastructure Services
* **Reverse Proxy**: Traefik with SSL termination and automatic Let's Encrypt
    * **Role**: [`config-ansible/roles/traefik/`](config-ansible/roles/traefik/)
    * **Static Configuration**: [`config-ansible/roles/traefik/templates/traefik.yml.j2`](config-ansible/roles/traefik/templates/traefik.yml.j2:1)
    * **Dynamic Configuration**: [`config-ansible/roles/traefik/templates/dynamic_conf.yml.j2`](config-ansible/roles/traefik/templates/dynamic_conf.yml.j2:1)
    * **Service Discovery**: Hybrid model using both the Docker provider and a file provider for dynamic routing.

* **Monitoring Stack**: Complete observability with Prometheus, Grafana, Loki, Tempo
    * **Role**: [`config-ansible/roles/observability/`](config-ansible/roles/observability/)
    * **Prometheus Config**: [`config-ansible/roles/observability/templates/prometheus-config.yml.j2`](config-ansible/roles/observability/templates/prometheus-config.yml.j2:1)
    * **Services**: Prometheus, Grafana, Loki, Tempo, OpenTelemetry Collector

#### Storage & Object Services
* **Object Storage**: MinIO S3-compatible storage
    * **Role**: [`config-ansible/roles/minio/`](config-ansible/roles/minio/)
    * **Configuration**: [`config-ansible/roles/minio/defaults/main.yml`](config-ansible/roles/minio/defaults/main.yml:1)

* **Distributed Filesystem**: SeaweedFS for distributed storage
    * **Role**: [`config-ansible/roles/seaweedfs/`](config-ansible/roles/seaweedfs/)
    * **Configuration**: [`config-ansible/roles/seaweedfs/defaults/main.yml`](config-ansible/roles/seaweedfs/defaults/main.yml:1)

#### Identity & Security Services
* **Secrets Management**: HashiCorp Vault for secrets management
    * **Role**: [`config-ansible/roles/vault/`](config-ansible/roles/vault/)
    * **Configuration**: [`config-ansible/roles/vault/defaults/main.yml`](config-ansible/roles/vault/defaults/main.yml:1)
    * **API Port**: 8200

* **Identity Provider**: Keycloak (referenced as keecloak)
    * **Role**: [`config-ansible/roles/keecloak/`](config-ansible/roles/keecloak/)

#### Application Services
* **File Sharing**: CopyParty for file sharing and management
    * **Role**: [`config-ansible/roles/copyparty/`](config-ansible/roles/copyparty/)
    * **Web Port**: 3923

* **WordPress**: WordPress deployment with MySQL
    * **Role**: [`config-ansible/roles/wordpress/`](config-ansible/roles/wordpress/)
    * **Configuration**: [`config-ansible/roles/wordpress/defaults/main.yml`](config-ansible/roles/wordpress/defaults/main.yml:1)

* **Database Admin**: Adminer for database management
    * **Role**: [`config-ansible/roles/adminer/`](config-ansible/roles/adminer/)

* **DNS Server**: NSD authoritative DNS
    * **Role**: [`config-ansible/roles/nsd/`](config-ansible/roles/nsd/)

* **Browser Automation**: Browserless Chrome for headless browsing
    * **Role**: [`config-ansible/roles/browserless/`](config-ansible/roles/browserless/)

* **Container Updates**: Watchtower for automatic container updates
    * **Role**: [`config-ansible/roles/watchtower/`](config-ansible/roles/watchtower/)

* **Anki Sync Server**: Self-hosted Anki synchronization server
    * **Role**: [`config-ansible/roles/anki-sync-server/`](config-ansible/roles/anki-sync-server/)

### Security & Hardening
* **Security Role**: System security configuration with SSH hardening
    * **Role**: [`config-ansible/roles/security/`](config-ansible/roles/security/)
    * **Configuration**: [`config-ansible/roles/security/defaults/main.yml`](config-ansible/roles/security/defaults/main.yml:1)
    * **SSH Configuration**: [`config-ansible/roles/security/templates/sshd_config.j2`](config-ansible/roles/security/templates/sshd_config.j2:1)

### Secrets Management Architecture
* **Vault Integration**: All secrets fetched at runtime from HashiCorp Vault
    * **Vault URL**: https://hashi-vault.aitbytes.fyi
    * **Authentication**: Token-based with environment variable fallback
    * **Secret Paths**:
        - `/v1/kv/data/blithe/docker/*` - Service-specific secrets
        - `/v1/kv/data/cloudflare/*` - Cloudflare API tokens
        - `/v1/kv/data/blithe/config-ansible/*` - Ansible configuration secrets

### Network Architecture
* **Docker Networks**:
    - `traefik-net`: External network for reverse proxy communication
    - `monitoring`: Internal network for observability stack
* **SSL/TLS**: Automatic Let's Encrypt certificates via Cloudflare DNS challenge

### Data Flow Architecture
* **Metrics Collection**: Prometheus → Grafana dashboards
* **Log Aggregation**: Container logs → Loki → Grafana
* **Tracing**: OpenTelemetry → Tempo → Grafana
* **Alerting**: Prometheus → Alertmanager (configured via Grafana)

---

## Completed Tasks

- **✅ Initial Project Analysis**: Created comprehensive project-tracker.md documenting complete infrastructure architecture
- **✅ Infrastructure Documentation**: Mapped all Terraform configurations for Hetzner Cloud and Cloudflare
- **✅ Configuration Management**: Documented Ansible playbooks, roles, and deployment stages
- **✅ Service Architecture**: Catalogued 15+ containerized services with their configurations
- **✅ Security Architecture**: Documented secrets management via Vault and security hardening
- **✅ Observability Stack**: Complete monitoring setup with Prometheus, Grafana, Loki, Tempo
- **✅ Network Architecture**: Documented Docker networking, SSL/TLS, and service discovery
- **✅ Data Flow Analysis**: Mapped metrics, logs, and tracing data flows

---

## Architecture Summary

This is a production-ready infrastructure automation project that implements:

1. **Infrastructure as Code**: Complete Terraform setup for Hetzner Cloud with Cloudflare DNS
2. **Configuration Management**: Ansible-driven deployment with security-first approach
3. **Container Orchestration**: Docker-based service deployment with Traefik reverse proxy
4. **Security**: Vault-based secrets management with comprehensive hardening
5. **Observability**: Full monitoring stack with metrics, logs, and distributed tracing
6. **High Availability**: Distributed storage with SeaweedFS and MinIO
7. **Identity Management**: Keycloak integration for SSO
8. **Automated Updates**: Watchtower for container lifecycle management

The project follows best practices for cloud-native deployments with zero-trust security, comprehensive observability, and automated infrastructure management.