# Day 02 – Linux Architecture, Processes & systemd

> **#90DaysOfDevOps Challenge – Day 02**

## 🎯 Objective
Understand the basics of Linux architecture, how processes are managed, and the role of **systemd**.

---

## 🐧 Linux Architecture

```text
Applications
     │
User Space
(Shell, Libraries, Utilities)
     │
Linux Kernel
(Process, Memory, File System, Network)
     │
Hardware
(CPU, RAM, Disk, Devices)
```

### Core Components

### 1. Kernel
The core of Linux that manages:
- Processes
- Memory
- File System
- Devices
- Networking

### 2. User Space
Where users and applications (Bash, Git, Docker, Nginx, Python) run and communicate with the kernel.

### 3. systemd
The default **init system (PID 1)** responsible for:
- Booting Linux
- Managing services
- Restarting failed services
- Viewing logs

---

## ⚙️ Process Management

A **process** is a running program. Linux creates processes using **fork()** and **exec()**.

**Process Lifecycle**

```text
New → Ready → Running → Waiting → Terminated
```

Useful commands:

```bash
ps aux          # List processes
top             # Live process monitor
pstree          # Process tree
kill <PID>      # Stop a process
```

---

## 🔧 Common systemd Commands

```bash
systemctl status nginx
systemctl start nginx
systemctl stop nginx
systemctl restart nginx
journalctl -u nginx
```

---


## 5 Commands Used Daily
- ps : View running processes.
- top : Monitor system resources in real time.
- systemctl : Manage services.
- df -h : Check disk usage.
- free -h : Check memory usage.

## 📌 Key Takeaways

- The **Kernel** manages hardware and system resources.
- **User Space** is where applications run.
- **systemd** manages booting and Linux services.
- Every running application is a **process** with a unique **PID**.
- Understanding these concepts is essential for Linux administration and DevOps troubleshooting.

**✅ Day 02 Complete**