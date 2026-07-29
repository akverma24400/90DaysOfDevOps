# Day 04 – Linux Processes, Services & Troubleshooting

## Objective
Learn how to monitor running processes, inspect system services, view logs, and follow a basic troubleshooting workflow in Linux.

---

## 1. Process Management

A **process** is a running instance of a program. Monitoring processes helps identify what is running on the system and troubleshoot performance issues.

**Useful Commands**
```bash
ps -ef          # Display all running processes
pgrep nginx     # Find the PID of a specific process
```

**Key Learning:**  
- View active processes.
- Find the Process ID (PID) of a running application.

---

## 2. systemd Services

**systemd** is the default service manager in most Linux distributions. It is responsible for starting, stopping, and managing background services.

**Useful Commands**
```bash
sudo systemctl status nginx
systemctl list-units --type=service --state=running
```

**Key Learning:**  
- Check whether a service is running.
- View all active services on the system.

---

## 3. Viewing Logs

Logs record system and application events, making them essential for troubleshooting.

**Useful Commands**
```bash
sudo journalctl -u nginx -n 20
sudo tail -n 50 /var/log/nginx/access.log
```

**Key Learning:**  
- `journalctl` displays logs managed by **systemd**.
- `tail` shows the most recent lines of a log file.

---

## 4. Basic Troubleshooting Flow

1. Check running processes.
2. Verify the service status.
3. Review recent logs for errors.
4. Restart the service if needed.
5. Confirm the service is running properly.

---

## Summary

Today I learned how to:
- Monitor running processes using `ps` and `pgrep`.
- Inspect and manage **systemd** services with `systemctl`.
- Analyze system and application logs using `journalctl` and `tail`.
- Perform a simple Linux troubleshooting workflow to diagnose and resolve service-related issues.