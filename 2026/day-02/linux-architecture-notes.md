# Linux Architecture Notes

## Linux Components
- **Kernel:** Manages hardware, memory, CPU, and processes.
- **User Space:** Runs applications like Bash, Python, and Docker.
- **systemd (PID 1):** Starts the system and manages services.

## Process Management
- Every running program is a **process** with a unique PID.
- Parent processes create child processes.
- The kernel schedules CPU time.

## Process States
- **R** – Running
- **S** – Sleeping
- **D** – Waiting for I/O
- **T** – Stopped
- **Z** – Zombie

## What systemd Does
- Boots Linux
- Starts/stops services
- Restarts failed services
- Shows logs with `journalctl`

## 5 Useful Commands
```bash
ps : View running processes.
top : Monitor system resources in real time.
systemctl : Manage services.
df -h : Check disk usage.
free -h : Check memory usage.
```

### Key Takeaway
Understanding Linux processes and `systemd` helps troubleshoot services, logs, and performance issues efficiently.