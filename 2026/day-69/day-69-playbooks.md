# Day 69 – Ansible Playbooks and Modules

This document contains my solutions and notes for **Day 69 of 90DaysOfDevOps**. The exercises cover Ansible playbooks, common modules, handlers, execution options, and multi-play automation.

> **Environment note:** My managed EC2 instances run Ubuntu. Therefore, the examples use the `apt` module instead of `yum`, and the Ubuntu Nginx document root `/var/www/html` instead of `/usr/share/nginx/html`.

## Project structure

The working directory is `~/ansible-practice` on the Ansible control node.

```text
ansible-practice/
├── ansible.cfg
├── inventory.ini
├── install-nginx.yml
├── essential-modules.yml
├── nginx-config.yml
├── multi-play.yml
└── files/
    ├── app.conf
    └── nginx.conf
```

Example inventory:

```ini
[web]
web-server ansible_host=35.88.217.144

[app]
app-server ansible_host=35.88.179.68

[db]
db-server ansible_host=52.26.87.117

[all:vars]
ansible_user=ubuntu
ansible_ssh_private_key_file=/home/ubuntu/.ssh/id_ed25519
```

The IP addresses above are examples from my lab inventory. Replace them if the EC2 public IPs change.

Example `ansible.cfg`:

```ini
[defaults]
inventory = ./inventory.ini
host_key_checking = True
```

---

## Task 1 – First playbook: install and configure Nginx

Create `install-nginx.yml`:

```yaml
---
- name: Install and start Nginx on web servers
  hosts: web
  become: true

  tasks:
    - name: Update APT package cache
      apt:
        update_cache: true
        cache_valid_time: 3600

    - name: Install Nginx
      apt:
        name: nginx
        state: present

    - name: Start and enable Nginx
      service:
        name: nginx
        state: started
        enabled: true

    - name: Create a custom index page
      copy:
        content: "<h1>Deployed by Ansible - TerraWeek Server</h1>\n"
        dest: /var/www/html/index.html
        owner: root
        group: root
        mode: '0644'
```

Run a syntax check and execute the playbook:

```bash
ansible-playbook install-nginx.yml --syntax-check
ansible-playbook install-nginx.yml
```

Verify Nginx on the managed web server:

```bash
ansible web -b -m command -a "systemctl is-active nginx"
ansible web -m command -a "curl -s http://localhost"
```

You can also open the web server's public IP in a browser. Make sure the EC2 security group allows inbound HTTP traffic on TCP port `80`.

### Understanding the output and idempotency

On the first run, Ansible may report tasks as `changed` because it installs Nginx, starts the service, or creates the index page.

Run the same playbook again:

```bash
ansible-playbook install-nginx.yml
```

If the system already matches the requested state, the tasks should report `ok` rather than `changed`. This repeatable behavior is called **idempotency**.

---

## Task 2 – Understanding playbook structure

A playbook is a YAML file containing one or more plays. Each play targets a group of hosts and contains tasks. Each task calls a module to perform an operation.

```yaml
---
- name: Example play
  hosts: web
  become: true

  tasks:
    - name: Example task
      apt:
        name: nginx
        state: present
```

| Element | Purpose |
|---|---|
| `---` | Marks the beginning of a YAML document |
| `name` | Describes the play or task |
| `hosts` | Selects the inventory group or hosts |
| `become` | Enables privilege escalation, usually through sudo |
| `tasks` | Lists the operations to perform |
| Module | Performs the requested operation, such as installing a package |
| Module arguments | Define the desired state or configuration |

### Answers

**1. What is the difference between a play and a task?**

A **play** maps a group of managed hosts to a set of instructions. A **task** is one individual operation inside a play, such as installing a package or starting a service.

**2. Can one playbook contain multiple plays?**

Yes. A playbook can contain multiple plays. Each play can target a different inventory group, use different variables, and perform different tasks. This is useful for configuring web, application, and database servers in one run.

**3. What does `become: true` do at the play level versus the task level?**

At the play level, privilege escalation applies by default to all tasks in that play. At the task level, it applies only to the specific task. It is commonly used when a task needs root privileges to install packages or modify system files.

**4. What happens when a task fails? Do the remaining tasks run?**

By default, Ansible stops running further tasks for the affected host after a task fails. Other hosts can continue. Error handling options such as `ignore_errors`, `block`, `rescue`, and `always` can change this behavior.

---

## Task 3 – Essential Ansible modules

The following playbook demonstrates the seven modules requested in the challenge: `apt`, `service`, `copy`, `file`, `command`, `shell`, and `lineinfile`.

Create the supporting directory and sample configuration file:

```bash
mkdir -p files
```

Create `files/app.conf`:

```ini
APP_NAME=TerraWeek
APP_ENV=development
APP_PORT=3000
```

Create `essential-modules.yml`:

```yaml
---
- name: Manage common packages and files on all servers
  hosts: all
  become: true

  tasks:
    - name: Update APT package cache
      apt:
        update_cache: true
        cache_valid_time: 3600

    - name: Install useful packages
      apt:
        name:
          - git
          - curl
          - wget
          - tree
        state: present

    - name: Copy application configuration
      copy:
        src: files/app.conf
        dest: /etc/app.conf
        owner: root
        group: root
        mode: '0644'

    - name: Create application directory
      file:
        path: /opt/myapp
        state: directory
        owner: root
        group: root
        mode: '0755'

    - name: Check disk space
      command: df -h
      register: disk_output
      changed_when: false

    - name: Print disk space
      debug:
        var: disk_output.stdout_lines

    - name: Count running processes
      shell: ps aux | wc -l
      register: process_count
      changed_when: false

    - name: Show process count
      debug:
        msg: "Total processes: {{ process_count.stdout }}"

    - name: Set timezone in environment
      lineinfile:
        path: /etc/environment
        line: 'TZ=Asia/Kolkata'
        create: true

- name: Ensure Nginx is running on web servers
  hosts: web
  become: true

  tasks:
    - name: Install Nginx
      apt:
        name: nginx
        state: present

    - name: Ensure Nginx is running and enabled
      service:
        name: nginx
        state: started
        enabled: true
```

Run it:

```bash
ansible-playbook essential-modules.yml
```

### What the seven modules do

| Module | Purpose | Example use |
|---|---|---|
| `apt` | Installs, updates, or removes Ubuntu packages | Install Git, curl, and wget |
| `service` | Starts, stops, restarts, or enables services | Keep Nginx running at boot |
| `copy` | Copies a file from the control node to a managed host or writes content | Deploy `app.conf` |
| `file` | Manages files, directories, ownership, and permissions | Create `/opt/myapp` |
| `command` | Executes a command without shell interpretation | Run `df -h` |
| `shell` | Executes a command through a shell | Run a pipeline such as `ps aux \| wc -l` |
| `lineinfile` | Ensures a particular line is present, absent, or configured in a file | Set the timezone environment variable |

### Difference between `command` and `shell`

- **`command`** runs a command directly. It does not interpret shell operators such as pipes (`|`), redirects (`>`), or shell variable expansion. Prefer it for simple commands because it is generally safer and more predictable.
- **`shell`** runs the command through a shell, so shell features such as pipes, redirects, and expansions are available. Use it only when those features are actually required.

Both modules can register output in a variable, which can then be displayed with the `debug` module.

---

## Task 4 – Handlers: restart services only when needed

A handler is a special task that runs only when another task notifies it. Handlers normally run at the end of the play, and multiple notifications for the same handler in one play trigger it only once.

Create `files/nginx.conf`:

```nginx
user www-data;
worker_processes auto;
pid /run/nginx.pid;

events {
    worker_connections 768;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    sendfile on;
    keepalive_timeout 65;

    server {
        listen 80 default_server;
        listen [::]:80 default_server;

        server_name _;
        root /var/www/html;
        index index.html;

        location / {
            try_files $uri $uri/ =404;
        }
    }
}
```

Create `nginx-config.yml`:

```yaml
---
- name: Configure Nginx with a custom configuration
  hosts: web
  become: true

  tasks:
    - name: Update APT package cache
      apt:
        update_cache: true
        cache_valid_time: 3600

    - name: Install Nginx
      apt:
        name: nginx
        state: present

    - name: Deploy custom Nginx configuration
      copy:
        src: files/nginx.conf
        dest: /etc/nginx/nginx.conf
        owner: root
        group: root
        mode: '0644'
        validate: '/usr/sbin/nginx -t -c %s'
      notify: Restart Nginx

    - name: Deploy a custom index page
      copy:
        content: "<h1>Managed by Ansible</h1><p>Server: {{ inventory_hostname }}</p>\n"
        dest: /var/www/html/index.html
        owner: root
        group: root
        mode: '0644'

    - name: Ensure Nginx is running
      service:
        name: nginx
        state: started
        enabled: true

  handlers:
    - name: Restart Nginx
      service:
        name: nginx
        state: restarted
```

> **Important:** This example replaces `/etc/nginx/nginx.conf` with a small standalone configuration. Back up an existing configuration before replacing it on a server that already hosts other sites or applications.

Validate and run:

```bash
ansible-playbook nginx-config.yml --syntax-check
ansible-playbook nginx-config.yml
```

Run it a second time:

```bash
ansible-playbook nginx-config.yml
```

### Handler behavior

- **First run:** The configuration file is copied, so the task reports `changed` and notifies the `Restart Nginx` handler. The handler runs at the end of the play.
- **Second run:** If the source and destination configuration are identical, the copy task reports `ok`. No notification is sent, so the handler does not run.

This avoids unnecessary service restarts and makes configuration management more efficient.

---

## Task 5 – Dry run, diff, verbosity, and host targeting

Ansible provides useful options to inspect a playbook before applying changes and to troubleshoot execution.

### 1. Check mode (dry run)

```bash
ansible-playbook install-nginx.yml --check
```

Check mode simulates tasks where the modules support it. It reports what Ansible expects to change without applying those changes. Some tasks may not be fully predictable in check mode, especially when later tasks depend on the output of earlier tasks.

### 2. Diff mode

```bash
ansible-playbook nginx-config.yml --check --diff
```

Diff mode displays file changes for supported modules, such as the `copy` and `template` modules. Combining it with check mode helps review proposed changes before applying them.

### 3. Verbosity

```bash
ansible-playbook install-nginx.yml -v
ansible-playbook install-nginx.yml -vv
ansible-playbook install-nginx.yml -vvv
```

- `-v`: Shows additional execution details.
- `-vv`: Shows more information useful for troubleshooting.
- `-vvv`: Provides detailed connection and execution debugging information.

### 4. Limit execution to a host

```bash
ansible-playbook install-nginx.yml --limit web-server
```

This runs the playbook only against `web-server`, even though the play targets the complete `web` group.

### 5. List affected hosts and tasks

```bash
ansible-playbook install-nginx.yml --list-hosts
ansible-playbook install-nginx.yml --list-tasks
```

These commands show the hosts and tasks selected by the playbook without executing the tasks.

### Why is `--check --diff` useful in production?

The combination is useful because it provides a preview of the changes Ansible intends to make and, for supported file operations, shows the proposed content differences. This helps catch unexpected configuration changes before they reach production.

It is not a replacement for testing: check mode has limitations, so important changes should also be tested in a staging environment.

---

## Task 6 – Multiple plays in one playbook

A single playbook can configure different groups of servers in sequence. In this lab:

- `web` servers install and run Nginx.
- `app` servers install build tools and create an application directory.
- `db` servers install MySQL client tools and create a protected data directory.

Create `multi-play.yml`:

```yaml
---
- name: Configure web servers
  hosts: web
  become: true

  tasks:
    - name: Update APT package cache
      apt:
        update_cache: true
        cache_valid_time: 3600

    - name: Install Nginx
      apt:
        name: nginx
        state: present

    - name: Start and enable Nginx
      service:
        name: nginx
        state: started
        enabled: true

- name: Configure application servers
  hosts: app
  become: true

  tasks:
    - name: Update APT package cache
      apt:
        update_cache: true
        cache_valid_time: 3600

    - name: Install application build tools
      apt:
        name:
          - gcc
          - make
        state: present

    - name: Create application directory
      file:
        path: /opt/app
        state: directory
        owner: root
        group: root
        mode: '0755'

- name: Configure database servers
  hosts: db
  become: true

  tasks:
    - name: Update APT package cache
      apt:
        update_cache: true
        cache_valid_time: 3600

    - name: Install MySQL client
      apt:
        name: default-mysql-client
        state: present

    - name: Create application data directory
      file:
        path: /var/lib/appdata
        state: directory
        owner: root
        group: root
        mode: '0700'
```

Run the playbook:

```bash
ansible-playbook multi-play.yml
```

### Verify each server group

Check Nginx on web servers:

```bash
ansible web -b -m command -a "nginx -v"
ansible web -b -m command -a "systemctl is-active nginx"
```

Check build tools and the application directory on app servers:

```bash
ansible app -b -m shell -a "gcc --version && make --version"
ansible app -b -m command -a "ls -ld /opt/app"
```

Check MySQL client and the data directory on database servers:

```bash
ansible db -b -m command -a "mysql --version"
ansible db -b -m command -a "ls -ld /var/lib/appdata"
```

The `default-mysql-client` package installs client utilities; it does **not** install or configure a MySQL database server.

### Expected behavior

| Server group | Expected configuration |
|---|---|
| `web` | Nginx installed, enabled, and running |
| `app` | `gcc` and `make` installed; `/opt/app` created |
| `db` | MySQL client installed; `/var/lib/appdata` created with `0700` permissions |

Each play targets only its specified inventory group.

---

## Troubleshooting notes

### APT package download returns 404

If a package installation fails because a package URL is no longer available, the package index may be stale. Refresh the cache and retry:

```bash
ansible all -b -m apt -a "update_cache=yes"
ansible-playbook multi-play.yml
```

If the issue persists on a specific host, inspect its APT repository configuration and network connectivity.

### SSH host key verification fails

Confirm that the managed host is reachable and that its SSH host key is correctly present in the control node's `known_hosts` file. Do not disable host key checking as a routine fix.

### Permission errors

Use `become: true` for tasks that require administrative permissions, such as package installation or writing under `/etc`.

### YAML syntax or indentation errors

Use spaces rather than tabs and keep indentation consistent. Validate a playbook before running it:

```bash
ansible-playbook playbook-name.yml --syntax-check
```

---

## Key concepts learned

1. **Playbook:** A YAML file describing automation for managed hosts.
2. **Play:** A set of tasks mapped to a host group.
3. **Task:** One unit of work in a play.
4. **Module:** The Ansible component that performs an operation.
5. **Handler:** A task triggered by a notification, commonly used to restart services after configuration changes.
6. **Idempotency:** Re-running automation does not make unnecessary changes when the desired state is already present.
7. **Privilege escalation:** `become: true` runs tasks with elevated privileges.
8. **Check and diff modes:** Help preview changes before applying them.

## Evidence to add before submission

The challenge asks for screenshots. Add your own terminal screenshots in this section after running the playbooks:

- [ ] First `install-nginx.yml` run showing changed and ok tasks.
- [ ] Second run showing idempotency (tasks already in the desired state).
- [ ] `nginx-config.yml` first run showing the handler being notified and executed.
- [ ] Second `nginx-config.yml` run showing that the handler is not triggered when the configuration has not changed.
- [ ] `multi-play.yml` output showing the web, app, and db plays executing against their respective groups.

## Conclusion

Day 69 provided hands-on practice with Ansible playbooks and essential modules. I automated Nginx installation and configuration, managed packages and files, used handlers to restart services only when needed, explored check and diff modes, and configured multiple server groups using a single playbook.

The key takeaway is that Ansible makes infrastructure configuration repeatable, consistent, and easier to maintain through declarative, idempotent automation.

---

**Learning path:** 90DaysOfDevOps – Day 69  
**Focus:** Ansible Playbooks and Modules  
**Tags:** `#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham`
