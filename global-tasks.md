# Project Progress Tracker

## Current Status
The Traefik Ansible role has been updated to support basic authentication for services.

## Completed Tasks
- [x] Deconstruct the request into sub-tasks.
- [x] Read traefik role files.
- [x] Update `defaults/main.yml` with basic auth variables.
- [x] Update `templates/dynamic_conf.yml.j2` to create the middleware.

## In Progress
- [ ] Document how to use the new feature.

## Pending Tasks
-

## Environment Status
- Bootstrap: [Not Started]
- Development: [Ansible configuration for local services]
- Production: [Not applicable]

## Notes
To enable basic authentication for a service, you need to perform the following steps:

1.  **Generate `htpasswd` credentials:**
    You can use an online tool or the `htpasswd` command-line utility to generate the user credentials in the required format. For example:
    ```bash
    htpasswd -nb your_username your_password
    ```

2.  **Update your Ansible variables:**
    In your `group_vars` or `host_vars`, define the `traefik_basic_auth_users` variable with the generated credentials. For example:
    ```yaml
    traefik_basic_auth_users:
      - "your_username:$$apr1$$......."
    ```

3.  **Enable basic auth for the service:**
    In the `traefik_services` list, set the `basic_auth` flag to `true` for the desired service. For example:
    ```yaml
    traefik_services:
      - name: my-service
        domain: my-service.example.com
        url: "http://localhost:8080"
        basic_auth: true
    ```

4.  **Run the Ansible playbook:**
    Apply the changes by running the playbook that includes the `traefik` role.