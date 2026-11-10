# Day 71 – Ansible Roles, Galaxy, Templates and Vault

## Overview

Today I learned how to organize and reuse Ansible automation using Roles, Jinja2 Templates, Ansible Galaxy, and Ansible Vault.

The goal was to make playbooks more structured, reusable, and secure while managing multiple servers.

## Tasks Completed

### Task 1: Jinja2 Templates
- Created dynamic Nginx configuration templates.
- Used variables and Ansible facts to generate configuration files.
- Deployed web content using Ansible.
- Verified rendered configurations using the `--diff` option.

### Task 2: Understanding Ansible Roles
- Explored the standard Ansible role directory structure.
- Generated a role skeleton using Ansible Galaxy.
- Learned the purpose of tasks, handlers, templates, files, vars, defaults, and metadata.
- Understood the difference between default variables and role variables.

### Task 3: Custom Webserver Role
- Created a custom webserver role from scratch.
- Organized Nginx installation and configuration into separate files.
- Used Jinja2 templates for dynamic web content.
- Configured handlers to restart Nginx when required.
- Deployed the role through a main playbook.

### Task 4: Ansible Galaxy
- Explored community roles using Ansible Galaxy.
- Installed the Docker role by Geerlingguy.
- Used Galaxy roles to simplify Docker installation.
- Learned how requirements files help manage multiple roles and versions.

### Task 5: Ansible Vault
- Created encrypted files for sensitive information.
- Stored database passwords and API keys securely.
- Practiced viewing, editing, and encrypting Vault files.
- Used Vault variables inside playbooks.
- Learned how to use password files for automated deployments.

### Task 6: Combining Roles, Templates and Vault
- Combined custom and community roles in a single deployment workflow.
- Configured web, application, and database servers.
- Used Jinja2 templates to generate database configuration files.
- Injected encrypted secrets using Ansible Vault.
- Secured database configuration files with restricted permissions.

## Key Learnings

- **Ansible Roles:** Organize automation into reusable components.
- **Jinja2 Templates:** Generate dynamic configuration files using variables and facts.
- **Ansible Galaxy:** Discover and reuse community-maintained roles.
- **Ansible Vault:** Encrypt passwords, API keys, and other sensitive information.
- **Handlers:** Trigger service restarts only when configuration changes occur.
- **Requirements Files:** Maintain consistent role versions across environments.

## Tools & Technologies

- Ansible
- Ansible Galaxy
- Ansible Vault
- Jinja2 Templates
- YAML
- Linux / Ubuntu
- Nginx
- Docker
- AWS EC2

## Outcome

Successfully practiced building reusable Ansible roles, deploying dynamic configurations, using community roles, and managing sensitive information securely.

This exercise helped me understand how Ansible can simplify configuration management and automate infrastructure across multiple servers.

**Day 71 completed! 🚀**

#90DaysOfDevOps #TrainWithShubham #Ansible #DevOps #Automation #Linux #AWS #CloudComputing