# Day 68 – Introduction to Ansible and Inventory Setup

## 1. Introduction to Ansible

Ansible is an open-source configuration management and automation tool used to configure servers, deploy applications, install packages, manage services, and automate repetitive IT operations.

It follows an **agentless architecture**, meaning we do not need to install any additional agent software on managed nodes. Ansible communicates with Linux servers using SSH and executes tasks remotely.

### Why Do We Need Configuration Management?

Configuration management helps maintain consistency across multiple servers by automating tasks such as:

- Installing and updating software packages.
- Managing users and permissions.
- Configuring system services.
- Deploying applications.
- Managing server configurations.
- Maintaining the desired state of infrastructure.

Without configuration management, administrators must manually configure every server, which is time-consuming and can lead to configuration differences.

### Ansible vs Other Configuration Management Tools

| Tool | Architecture | Communication |
|---|---|---|
| Ansible | Agentless | SSH / WinRM |
| Chef | Agent-based | Chef Client |
| Puppet | Agent-based (typically) | Puppet Agent |
| SaltStack | Agent-based or agentless | Salt Minion / SSH |

**Key advantage:** Ansible uses simple YAML-based Playbooks and does not require agents on Linux managed nodes.

---

## 2. Ansible Architecture

Ansible architecture consists of the following components:

### Control Node
The machine where Ansible is installed and commands are executed.

In this project, an Ubuntu EC2 instance acts as the control node.

### Managed Nodes
Remote servers that Ansible manages and configures.

For this project, three Ubuntu EC2 instances are used:

- Web Server
- Application Server
- Database Server

### Inventory
An inventory file contains the IP addresses or hostnames of managed nodes. It also allows us to organize servers into logical groups.

### Modules
Modules are reusable units of work that perform specific operations on managed nodes.

Examples:
- `ping` – Test Ansible connectivity.
- `apt` – Manage Ubuntu packages.
- `copy` – Copy files to remote servers.
- `command` – Execute commands.
- `service` – Manage system services.

### Playbooks
Playbooks are YAML files that define a sequence of automation tasks and the hosts on which those tasks should execute.

### Architecture Flow

```text
              CONTROL NODE
          Ubuntu EC2 Instance
                 |
             Ansible CLI
                 |
              Inventory
                 |
             SSH (Port 22)
                 |
       -----------------------
       |          |          |
       v          v          v
   WEB SERVER  APP SERVER  DB SERVER
   Ubuntu EC2  Ubuntu EC2  Ubuntu EC2
       |          |          |
       v          v          v
    Modules    Modules    Modules
       |          |          |
       -----------------------
                 |
          Desired State
```

---

## 3. AWS Lab Environment Setup

Three EC2 instances were used as managed nodes, and one Ubuntu EC2 instance was configured as the Ansible control node.

### Infrastructure Details

| Component | Configuration |
|---|---|
| Cloud Provider | AWS |
| Operating System | Ubuntu |
| Instance Type | t2.micro |
| Control Node | Ubuntu EC2 |
| Managed Nodes | 3 Ubuntu EC2 instances |
| Communication | SSH |
| SSH Port | 22 |
| Authentication | Ed25519 SSH Key |

### Server Roles

| Instance | Role | Public IP |
|---|---|---|
| Instance 1 | Web Server | 184.34.215.65 |
| Instance 2 | App Server | 34.221.60.150 |
| Instance 3 | DB Server | 54.149.150.189 |

**Note:** These are the public IP addresses used during this lab. EC2 public IPs can change when instances are stopped and restarted unless Elastic IPs are configured.

### Security Group Configuration

The EC2 security groups must allow:

- Inbound SSH traffic on port 22.
- SSH access from the control node's public IP or private network, depending on the architecture.

---

## 4. Installing Ansible on the Control Node

Ansible needs to be installed only on the control node. Managed nodes do not require an Ansible agent.

### Update Ubuntu Packages

```bash
sudo apt update
```

### Install Ansible

```bash
sudo apt install ansible -y
```

### Verify Installation

```bash
ansible --version
```

This displays:

- Ansible version.
- Configuration file location.
- Python version.
- Executable location.

**Why only the control node?**

Ansible uses SSH to connect to managed nodes and execute tasks remotely. Therefore, installing Ansible separately on every managed server is unnecessary.

---

## 5. SSH Authentication Setup

Ansible uses SSH to communicate with remote Linux servers.

The control node contains an Ed25519 SSH key pair.

### Check SSH Directory

```bash
cd ~/.ssh
ls -la
```

Files used in this project:

```text
authorized_keys
id_ed25519
id_ed25519.pub
known_hosts
known_hosts.old
```

### SSH Key Details

- `id_ed25519`: Private SSH key.
- `id_ed25519.pub`: Public SSH key.
- `known_hosts`: Stores previously trusted SSH server host keys.
- `authorized_keys`: Stores public keys authorized to access an account.

### Verify Private Key Permissions

```bash
chmod 600 ~/.ssh/id_ed25519
```

The private key must remain secure and should never be uploaded to GitHub.

### Test SSH Connectivity

```bash
ssh -i ~/.ssh/id_ed25519 ubuntu@184.34.215.65
```

Repeat for the other managed nodes:

```bash
ssh -i ~/.ssh/id_ed25519 ubuntu@34.221.60.150

ssh -i ~/.ssh/id_ed25519 ubuntu@54.149.150.189
```

On the first connection, SSH may ask you to verify the server's host fingerprint. Verify it using a trusted source before accepting it.

---

## 6. Creating the Ansible Project Directory

Create a dedicated directory for the Ansible practice project.

```bash
mkdir ansible-practice
cd ansible-practice
```

Create the inventory file:

```bash
vim inventory.ini
```

### Inventory Configuration

```ini
[web]
web-server ansible_host=184.34.215.65

[app]
app-server ansible_host=34.221.60.150

[db]
db-server ansible_host=54.149.150.189

[all:vars]
ansible_user=ubuntu
ansible_ssh_private_key_file=/home/ubuntu/.ssh/id_ed25519
```

### Understanding the Inventory

- `[web]`: Defines the web server group.
- `[app]`: Defines the application server group.
- `[db]`: Defines the database server group.
- `ansible_host`: Specifies the public IP address of the managed node.
- `ansible_user`: Specifies the SSH username.
- `ansible_ssh_private_key_file`: Specifies the private key used for SSH authentication.

The `[all:vars]` section applies the specified connection variables to all inventory hosts.

### Verify Inventory

```bash
ansible-inventory -i inventory.ini --list
```

This displays the inventory in JSON format.

---

## 7. Troubleshooting SSH Host Key Verification

### Problem Encountered

During the first Ansible connectivity test, all three managed nodes returned:

```text
UNREACHABLE!

Task failed: Failed to connect to the host via ssh:
Host key verification failed.
```

### Understanding the Error

SSH host key verification is a security mechanism that checks whether the remote server's identity matches a trusted host key.

The SSH client maintains previously trusted server fingerprints in the `known_hosts` file.

If a host key is missing, changed, or does not match the expected fingerprint, SSH may reject the connection.

### Step 1: Check Existing Host Keys

```bash
cat ~/.ssh/known_hosts
```

### Step 2: Remove Existing Host Fingerprints

```bash
ssh-keygen -R 184.34.215.65
ssh-keygen -R 34.221.60.150
ssh-keygen -R 54.149.150.189
```

In this lab, the command returned:

```text
Host 184.34.215.65 not found in
/home/ubuntu/.ssh/known_hosts

Host 34.221.60.150 not found in
/home/ubuntu/.ssh/known_hosts

Host 54.149.150.189 not found in
/home/ubuntu/.ssh/known_hosts
```

This indicates that these IP addresses were not found in the current user's `known_hosts` file. It does not itself resolve the verification problem.

### Step 3: Connect Manually Through SSH

```bash
ssh -i ~/.ssh/id_ed25519 ubuntu@184.34.215.65
```

Verify the server fingerprint before accepting the first-time connection.

Repeat for the remaining servers:

```bash
ssh -i ~/.ssh/id_ed25519 ubuntu@34.221.60.150

ssh -i ~/.ssh/id_ed25519 ubuntu@54.149.150.189
```

After successfully connecting, exit the remote server:

```bash
exit
```

The verified host fingerprints are then stored in `known_hosts`.

### Step 4: Retry Ansible Connectivity

```bash
ansible all -i inventory.ini -m ping
```

**Alternative for temporary lab troubleshooting:**

```bash
export ANSIBLE_HOST_KEY_CHECKING=False
```

Then retry the Ansible command.

This disables SSH host-key verification for the current shell session. It should not be used as a permanent production solution because it weakens protection against man-in-the-middle attacks.

---

## 8. Testing Ansible Connectivity

The Ansible ping module checks whether Ansible can connect to a managed node and execute a Python-based module.

It is not an ICMP network ping.

### Execute Ping Against All Hosts

```bash
ansible all -i inventory.ini -m ping
```

### Expected Output

```text
web-server | SUCCESS => {
    "changed": false,
    "ping": "pong"
}

app-server | SUCCESS => {
    "changed": false,
    "ping": "pong"
}

db-server | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

A successful `pong` response confirms that Ansible can communicate with the managed nodes.

---

## 9. Running Ansible Ad-Hoc Commands

Ad-hoc commands allow us to execute individual automation tasks without creating a Playbook.

### 1. Check Server Uptime

```bash
ansible all -i inventory.ini -m command -a "uptime"
```

This displays how long each managed server has been running.

### 2. Check Free Memory on Web Servers

```bash
ansible web -i inventory.ini -m command -a "free -h"
```

This displays memory usage only for servers belonging to the web group.

### 3. Check Disk Space on All Servers

```bash
ansible all -i inventory.ini -m command -a "df -h"
```

This displays filesystem disk usage.

### 4. Install Git on the Web Server

Since the managed nodes use Ubuntu, the `apt` module is used instead of `yum`.

```bash
ansible web -i inventory.ini -m apt -a "name=git state=present update_cache=yes" --become
```

Verify Git installation:

```bash
ansible web -i inventory.ini -m command -a "git --version"
```

### Understanding --become

`--become` allows Ansible to execute tasks with elevated privileges, typically using `sudo`.

It is required for operations such as:

- Installing software packages.
- Managing system services.
- Modifying protected system files.
- Changing system-level configurations.

### 5. Create and Copy a File to All Servers

Create a local file:

```bash
echo "Hello from Ansible" > hello.txt
```

Copy it to all managed nodes:

```bash
ansible all -i inventory.ini -m copy -a "src=hello.txt dest=/tmp/hello.txt"
```

### 6. Verify the Copied File

```bash
ansible all -i inventory.ini -m command -a "cat /tmp/hello.txt"
```

Expected output:

```text
Hello from Ansible
```

The file should be available on all three managed nodes.

---

## 10. Exploring Inventory Groups and Patterns

Ansible allows us to organize multiple servers into groups and execute commands against selected groups.

### Create Groups of Groups

Update `inventory.ini`:

```ini
[web]
web-server ansible_host=184.34.215.65

[app]
app-server ansible_host=34.221.60.150

[db]
db-server ansible_host=54.149.150.189

[application:children]
web
app

[all_servers:children]
application
db

[all:vars]
ansible_user=ubuntu
ansible_ssh_private_key_file=/home/ubuntu/.ssh/id_ed25519
```

### Understanding Children Groups

- `[application:children]` combines the web and app groups.
- `[all_servers:children]` combines the application group and database group.

This allows us to manage multiple server groups through a single parent group.

### Test Different Inventory Groups

**1. Test application group:**

```bash
ansible application -i inventory.ini -m ping
```

This targets both web and app servers.

**2. Test database group:**

```bash
ansible db -i inventory.ini -m ping
```

This targets only the database server.

**3. Test all servers:**

```bash
ansible all_servers -i inventory.ini -m ping
```

This targets all three managed nodes.

### Understanding Ansible Host Patterns

Ansible supports different host selection patterns.

**OR Pattern:**

```bash
ansible 'web:app' -i inventory.ini -m ping
```

Targets web or app servers.

**NOT Pattern:**

```bash
ansible 'all:!db' -i inventory.ini -m ping
```

Targets all servers except the database server.

---

## 11. Creating ansible.cfg

Instead of specifying the inventory file and SSH settings in every command, we can configure Ansible using `ansible.cfg`.

Create the configuration file:

```bash
vim ansible.cfg
```

Add:

```ini
[defaults]
inventory = ./inventory.ini
host_key_checking = True
remote_user = ubuntu
private_key_file = /home/ubuntu/.ssh/id_ed25519
```

**Note:** Host-key checking is kept enabled for secure SSH communication. Verify and trust the server fingerprints before running Ansible.

### Benefits of ansible.cfg

- Defines the default inventory.
- Specifies the default remote SSH user.
- Defines the private key location.
- Centralizes Ansible configuration.
- Reduces repetitive command-line arguments.

### Verify Configuration

```bash
ansible --version
```

The output should show the path of the active configuration file.

### Run Ansible Without Specifying Inventory

```bash
ansible all -m ping
```

Ansible automatically reads the inventory configuration from `ansible.cfg`.

---

## 12. Important Ansible Commands Cheat Sheet

| Command | Purpose |
|---|---|
| `ansible --version` | Check Ansible version |
| `ansible-inventory --list` | Display inventory |
| `ansible all -m ping` | Test all managed nodes |
| `ansible web -m ping` | Test web servers |
| `ansible all -m command -a "uptime"` | Check server uptime |
| `ansible all -m command -a "df -h"` | Check disk space |
| `ansible web -m apt -a "name=git state=present" --become` | Install Git |
| `ansible all -m copy -a "src=hello.txt dest=/tmp/hello.txt"` | Copy a file |
| `ansible-config dump --only-changed` | Display customized settings |

---

## 13. Key Learnings

During Day 68, I learned:

1. What configuration management is and why it is important in DevOps.
2. How Ansible differs from Chef, Puppet, and SaltStack.
3. How agentless automation works using SSH.
4. How to install Ansible on an Ubuntu control node.
5. How to configure an inventory file with multiple server groups.
6. How SSH authentication and host-key verification work.
7. How to troubleshoot SSH connectivity issues.
8. How to execute Ansible ad-hoc commands.
9. How to install packages and copy files remotely.
10. How to create parent and child inventory groups.
11. How to use Ansible host patterns.
12. How to configure default settings using `ansible.cfg`.

---

## 14. Project Structure

```text
ansible-practice/
│
├── inventory.ini
├── ansible.cfg
└── hello.txt
```

**Note:** Keep private SSH keys outside the project directory. Never commit private keys, credentials, or sensitive server information to GitHub.

---

## 15. Conclusion

Day 68 introduced me to Ansible and configuration management.

I configured an Ubuntu EC2 instance as an Ansible control node and connected three remote Ubuntu EC2 instances as managed nodes using SSH.

I created an inventory file, explored inventory groups, executed ad-hoc commands, installed packages, copied files, and learned how to troubleshoot SSH host-key verification issues.

This exercise demonstrated how Ansible can automate server administration without requiring agents on managed nodes.

**Next Step:** Explore Ansible Playbooks and YAML-based automation to manage infrastructure through reusable and repeatable configurations.

---

**Challenge:** Day 68 – 90DaysOfDevOps / AI-Powered UDAAN

**Focus Areas:** Ansible | Configuration Management | AWS EC2 | Ubuntu | SSH | Inventory | Ad-Hoc Commands | Infrastructure Automation