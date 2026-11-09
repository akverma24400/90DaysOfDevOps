# Day 70 – Variables, Facts, Conditionals and Loops

## Overview

In Day 70 of the 90DaysOfDevOps challenge, I explored how to make Ansible playbooks more dynamic, flexible, and intelligent.

Previously, playbooks performed similar tasks on every server. In real-world infrastructure, different servers require different configurations. Web servers need web services, database servers need database packages, and different environments may require different settings.

Ansible provides variables, facts, conditionals, and loops to handle these requirements efficiently.

## Task 1: Variables in Playbooks

Variables allow us to store reusable values instead of hardcoding information throughout a playbook.

I created variables for:

- Application name
- Application port
- Application directory
- Required packages

I also tested overriding variables through command-line input.

**What I learned:**

- Variables make playbooks reusable and easier to maintain.
- The same playbook can work with different application configurations.
- Command-line variables can override values defined inside a playbook.

## Task 2: Group Variables and Host Variables

I explored how Ansible manages variables for different groups of servers and individual hosts.

I organized the project using dedicated variable directories.

### Group Variables

Group variables apply settings to multiple servers belonging to a particular inventory group.

I worked with:

- **all.yml:** Common configuration shared by all servers.
- **web.yml:** Web server-specific configuration.
- **db.yml:** Database server-specific configuration.

### Host Variables

Host variables apply configuration to one specific server.

I used a dedicated configuration file for the web server to define its custom message and connection settings.

**What I learned:**

- Group variables reduce configuration duplication.
- Host variables allow individual server customization.
- Variables can be maintained separately from playbooks.

### Variable Precedence

Ansible uses variable precedence to decide which value should be applied when the same variable is defined in multiple places.

The simplified order from lower to higher priority is:

1. Role defaults
2. Group variables for all hosts
3. Group-specific variables
4. Host-specific variables
5. Playbook variables
6. Task variables
7. Extra variables supplied through the command line

Higher-priority variables override lower-priority values.

## Task 3: Ansible Facts

Ansible Facts are automatically collected details about managed servers.

They provide useful information about the system without requiring us to manually inspect every machine.

I explored system information from my EC2 instances, including operating system details, memory, IP addresses, and network interfaces.

### Five Useful Ansible Facts

1. **Hostname:** Identifies the managed server and helps with server-specific configuration.
2. **Operating System:** Helps select the correct package manager and OS-specific tasks.
3. **Memory:** Helps determine resource requirements and identify low-memory servers.
4. **IP Address:** Helps with networking, configuration, and service communication.
5. **Network Interfaces:** Helps understand available network devices and configure networking.

**What I learned:**

Ansible Facts make playbooks intelligent because tasks can adapt automatically to the actual system configuration.

## Task 4: Conditionals with When

Conditionals allow Ansible to execute tasks only when specific conditions are satisfied.

I created a conditional playbook to perform different operations based on server groups, operating systems, memory, and environment settings.

Examples from my practice:

- Install Nginx only on web servers.
- Install MySQL only on database servers.
- Display warnings on servers with low memory.
- Execute tasks only on Ubuntu or Amazon Linux.
- Apply production-specific settings only in production.
- Combine multiple conditions using AND and OR logic.

**What I learned:**

- The when condition controls whether a task should execute.
- Tasks that do not match the condition are skipped.
- Group-based conditions help manage different server roles.
- Multiple conditions can be combined to create more flexible automation.

## Task 5: Loops in Ansible

Loops allow us to repeat the same task for multiple items without writing separate tasks for each item.

I created a loop-based playbook to automate multiple server administration activities across my EC2 instances.

The tasks included:

- Creating multiple Linux users.
- Assigning users to appropriate Linux groups.
- Creating multiple application directories.
- Installing multiple packages.
- Displaying information about each created user.

During execution, I encountered an issue because the wheel group was not available on my Ubuntu servers. I resolved it by using the sudo group instead.

**What I learned:**

- Loops reduce repetitive tasks.
- The same task can process multiple users, directories, or packages.
- The loop variable provides access to the current item.
- The modern loop syntax is recommended over older approaches such as with_items.

## Task 6: Register, Debug, and Server Health Report

In the final task, I combined variables, facts, commands, and conditional execution to create a server health report.

The playbook collected information from all managed servers.

### Information Collected

- Disk space usage
- Memory information
- Running system services
- Operating system details
- Server IP address
- Total available memory

I used registered variables to store command results and debug tasks to display the collected information.

The playbook also included a disk-space warning condition and generated a separate report file for each server.

**What I learned:**

- Register stores the output of a task for later use.
- Debug helps display collected information.
- Registered results can be used in conditional tasks.
- Ansible can generate reports using information collected from managed servers.

## Key Concepts Learned

| Concept | Purpose |
|---|---|
| Variables | Store reusable configuration values |
| Group Variables | Apply settings to inventory groups |
| Host Variables | Customize individual servers |
| Ansible Facts | Collect system information automatically |
| Conditionals | Execute tasks based on specific conditions |
| Loops | Repeat tasks for multiple items |
| Register | Store task execution results |
| Debug | Display useful information |
| Variable Precedence | Determine which variable value takes priority |

## Project Structure

The Ansible practice project was organized into separate inventory, variable, host configuration, and playbook directories.

This structure makes the project easier to understand, maintain, and extend as the infrastructure grows.

## Final Outcome

Successfully explored the major Ansible features required to build dynamic and reusable automation playbooks.

Through this hands-on practice, I learned how to:

- Manage configuration using variables.
- Organize settings with group_vars and host_vars.
- Gather system information using Ansible Facts.
- Execute tasks conditionally based on server requirements.
- Automate repetitive operations using loops.
- Collect command outputs using register.
- Generate server health reports.

The biggest takeaway from Day 70 is that Ansible is not just about executing commands remotely. It helps build intelligent automation that adapts to different servers and infrastructure requirements.

**One playbook, multiple servers, and different behaviors based on actual requirements.**

---

## Learning Resources

- [Ansible Official Documentation](https://docs.ansible.com/)
- [Ansible Variables](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_variables.html)
- [Ansible Facts](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_vars_facts.html)
- [Ansible Conditionals](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_conditionals.html)
- [Ansible Loops](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_loops.html)

## Challenge

**90DaysOfDevOps – Day 70**

Part of the Zero to Hero AI Powered UDAAN Batch 11 learning journey by TrainWithShubham.

#90DaysOfDevOps #DevOpsKaJosh #TrainWithShubham #Ansible #DevOps #Automation #AWS #Linux