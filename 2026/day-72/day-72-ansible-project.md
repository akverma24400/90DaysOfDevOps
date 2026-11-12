# Day 72 – Ansible Project: Automate Docker and Nginx Deployment

## Overview

On Day 72 of the 90DaysOfDevOps challenge, I built an end-to-end automation project using **Ansible, Docker, and Nginx**.

The objective was to automate the complete application deployment process on remote servers using Ansible roles and playbooks.

Instead of manually installing packages, configuring Docker, running containers, and setting up Nginx, the entire deployment is managed through a single master playbook.

This project brings together the Ansible concepts learned over the previous days, including inventories, playbooks, modules, variables, handlers, templates, roles, Ansible Vault, and task tags.

## Project Objectives

- Automate common server configuration.
- Install and configure Docker on managed nodes.
- Pull application images from Docker Hub.
- Run Docker containers with automatic restart policies.
- Configure Nginx as a reverse proxy.
- Secure Docker Hub credentials using Ansible Vault.
- Organize automation using reusable Ansible roles.
- Deploy the complete application stack using a single command.
- Verify application availability through Nginx on port 80.

## Architecture

The project follows a role-based Ansible architecture.

**Deployment workflow:**

1. Ansible Controller connects to remote managed nodes through SSH.
2. The Common role installs baseline packages and configures the server.
3. The Docker role installs Docker and configures the Docker service.
4. Ansible Vault provides encrypted Docker Hub credentials.
5. Docker pulls the required application image and starts the container.
6. Nginx is installed and configured as a reverse proxy.
7. Incoming HTTP requests on port 80 are forwarded to the application running inside the Docker container on port 8080.
8. Health checks verify that the application is responding successfully.

## Project Structure

The project is organized into reusable roles:

- **ansible.cfg:** Defines Ansible configuration, inventory, SSH settings, and Vault password file.
- **inventory.ini:** Contains remote managed server information.
- **site.yml:** Master playbook that executes all deployment roles.
- **group_vars/all.yml:** Stores common variables and server configuration.
- **group_vars/web/vars.yml:** Contains web-server-specific variables.
- **group_vars/web/vault.yml:** Stores encrypted Docker Hub credentials.

### Roles

**1. Common Role**

Responsible for baseline server configuration:

- Updates the package cache.
- Installs commonly used system packages.
- Configures the hostname.
- Sets the system timezone.
- Creates a dedicated deployment user.

**2. Docker Role**

Responsible for Docker installation and application deployment:

- Installs Docker dependencies.
- Configures the Docker repository.
- Installs Docker Engine.
- Starts and enables the Docker service.
- Adds the deployment user to the Docker group.
- Installs Docker Compose.
- Authenticates with Docker Hub using encrypted credentials.
- Pulls the application image.
- Creates and starts the application container.
- Performs application health checks.

**3. Nginx Role**

Responsible for reverse proxy configuration:

- Installs Nginx.
- Removes the default configuration.
- Deploys the main Nginx configuration.
- Configures the application reverse proxy using Jinja2 templates.
- Tests Nginx configuration before applying changes.
- Starts and enables the Nginx service.
- Uses handlers to reload or restart Nginx when required.

## Ansible Vault – Credential Security

Docker Hub credentials should never be stored as plain text in a GitHub repository.

For this project, Ansible Vault was used to encrypt sensitive credentials.

The encrypted variables include:

- Docker Hub username.
- Docker Hub access token.

The Vault password file is kept locally and excluded from Git using `.gitignore`.

This ensures that sensitive authentication details remain protected while allowing Ansible to authenticate with Docker Hub during deployment.

## Reverse Proxy Configuration

Nginx acts as the entry point for incoming application traffic.

The Docker container runs on port **8080**, while Nginx listens on port **80**.

When a client sends an HTTP request to the server:

1. The request reaches Nginx on port 80.
2. Nginx forwards the request to the Docker application on localhost port 8080.
3. The container processes the request.
4. The response is returned through Nginx to the client.

This separates the public-facing web server from the application container.

The Nginx configuration also includes forwarded headers to preserve important client request information.

## Deployment Workflow

The entire infrastructure and application deployment are controlled through the master playbook.

The playbook executes three stages:

1. Common server configuration across all managed nodes.
2. Docker installation and application deployment on web servers.
3. Nginx installation and reverse proxy configuration on web servers.

### Deployment Verification

The following checks are used to verify the deployment:

**Docker verification**
- Confirm that Docker is installed and running.
- Check that the application container is running.
- Verify the container's port mapping.
- Confirm that the container has the correct restart policy.

**Application verification**
- Access the application directly through port 8080.
- Access the application through Nginx on port 80.
- Verify that Nginx successfully forwards requests to the Docker container.

**Nginx verification**
- Validate the Nginx configuration.
- Confirm that the Nginx service is active.
- Verify that the reverse proxy responds successfully.

## Important Ansible Concepts Practiced

| Concept | Implementation |
|---|---|
| Inventory | Remote server management |
| Playbooks | Automated deployment workflow |
| Roles | Reusable Docker, Nginx, and Common configurations |
| Variables | Centralized configuration management |
| Jinja2 Templates | Dynamic Docker and Nginx configurations |
| Handlers | Service reload and restart operations |
| Ansible Vault | Encrypted Docker Hub credentials |
| Tags | Selective role execution |
| Modules | Package, service, user, hostname, Docker, and URI management |
| Idempotency | Consistent configuration across repeated runs |
| Health Checks | Application availability verification |

## Key Learnings

Through this project, I learned how to:

- Build a complete Ansible project using a role-based architecture.
- Automate Docker installation and container deployment.
- Configure Nginx as a reverse proxy for containerized applications.
- Secure sensitive credentials using Ansible Vault.
- Use Jinja2 templates for dynamic configuration management.
- Implement handlers to manage service changes.
- Organize complex automation using reusable roles.
- Deploy an application stack through a single master playbook.
- Verify application availability using health checks.

## Final Outcome

Successfully bringing together multiple Ansible concepts into one practical deployment project helped me understand how configuration management can simplify real-world infrastructure operations.

The final goal is a fully automated deployment where a fresh managed server can be configured, Docker can be installed, an application container can be launched, and Nginx can be configured as a reverse proxy without manually performing each step.

**One Playbook. Three Roles. Complete Application Deployment.**

---

## 90DaysOfDevOps – Day 72

Part of my ongoing **90DaysOfDevOps Challenge**, where I am learning and implementing DevOps tools through practical, hands-on projects.

**Technologies Used:**

- Ansible
- AWS EC2
- Docker
- Docker Hub
- Nginx
- Ansible Vault
- YAML
- Jinja2 Templates
- Linux
- SSH

**Credits:** Shubham Londhe | TrainWithShubham

#90DaysOfDevOps #Ansible #Docker #Nginx #DevOps #AWS #Automation #InfrastructureAsCode #Linux #LearningInPublic