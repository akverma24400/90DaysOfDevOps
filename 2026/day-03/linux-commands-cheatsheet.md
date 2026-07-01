# 🐧 Linux Commands Cheat Sheet

A quick reference guide for commonly used Linux commands for **Process Management**, **File System Operations**, and **Networking Troubleshooting**. This cheat sheet is ideal for beginners, DevOps engineers, cloud enthusiasts, and anyone working with Linux.

---

## 📖 Table of Contents

- [⚙️ Process Management](#️-process-management)
- [📁 File System Commands](#-file-system-commands)
- [🌐 Networking Troubleshooting](#-networking-troubleshooting)
- [🚀 Quick Troubleshooting Commands](#-quick-troubleshooting-commands)

---

## ⚙️ Process Management

| Command | Description |
|---------|-------------|
| `ps aux` | Display all running processes |
| `top` | Display real-time system processes |
| `kill -9 <PID>` | Force terminate a process |
| `pkill <process_name>` | Kill a process by name |
| `pgrep <process_name>` | Find process IDs by name |
| `systemctl status <service>` | Check the status of a service |
| `systemctl restart <service>` | Restart a service |

---

## 📁 File System Commands

| Command | Description |
|---------|-------------|
| `pwd` | Print the current working directory |
| `ls -a` | List all files and directories, including hidden ones |
| `mkdir <directory>` | Create a new directory |
| `mkdir -p <directory>` | Create nested directories |
| `touch <file>` | Create an empty file |
| `cp <source> <destination>` | Copy files or directories |
| `mv <source> <destination>` | Move or rename files/directories |

---

## 🌐 Networking Troubleshooting

| Command | Description |
|---------|-------------|
| `ping google.com` | Check network connectivity |
| `ip addr` | Display IP address information |
| `curl https://google.com` | Test website response |
| `dig google.com` | Perform a DNS lookup |
| `ss -tulpn` | Show listening ports and associated processes |
| `hostnamectl` | Display hostname and operating system information |

---

## 🚀 Quick Troubleshooting Commands

```bash
# Running processes
ps -ef
top

# Memory usage
free -h

# Disk usage
df -h
du -sh *

# CPU usage
top

# IP Address
ip addr

# Internet connectivity
ping 8.8.8.8

# DNS resolution
ping google.com
dig google.com
```

---

## 🎯 Use Cases

- ✅ Linux Administration
- ✅ DevOps & Cloud Engineering
- ✅ Server Troubleshooting
- ✅ Interview Preparation
- ✅ Daily Linux Usage

---

## ⭐ Support

If you found this cheat sheet useful, consider giving the repository a **⭐ Star**. It helps others discover the project and motivates future improvements.

Happy Learning! 🚀