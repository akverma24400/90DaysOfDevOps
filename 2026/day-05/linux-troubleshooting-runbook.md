# Day 05 – Linux Health Check & Troubleshooting Runbook

## Objective
Perform a quick Linux system health check, inspect a running service, review logs, and document the troubleshooting process.

---

## 1. Environment Verification

Check OS and kernel information.

```bash
uname -a
lsb_release -a
# or
cat /etc/os-release
```

**Purpose:** Verify the operating system and kernel version before troubleshooting.

---

## 2. Filesystem Sanity Check

Create a temporary workspace and verify file operations.

```bash
mkdir /tmp/runbook-demo
cp /etc/hosts /tmp/runbook-demo/hosts-copy
ls -l /tmp/runbook-demo
```

**Purpose:** Ensure the filesystem is writable and working correctly.

---

## 3. Capture System Health

### CPU & Memory

```bash
top
free -h
ps -o pid,pcpu,pmem,comm -p <PID>
```

**Check for:**
- High CPU utilization
- Memory exhaustion
- Processes consuming excessive resources

---

### Disk & I/O

```bash
df -h
du -sh /var/log
vmstat
```

**Check for:**
- Low disk space
- Large log files
- High I/O wait

---

### Network

```bash
ss -tulpn
curl -I http://localhost
```

**Check for:**
- Listening services
- Network connectivity
- HTTP response from the service

---

## 4. Service & Log Inspection

Check service status and recent logs.

```bash
systemctl status <service-name>
journalctl -u <service-name> -n 50
tail -n 50 /var/log/<log-file>.log
```

**Purpose:** Identify startup failures, crashes, or recurring errors.

---

# Mini Runbook

### Actions Performed
- Verified Linux environment and OS details.
- Confirmed filesystem accessibility.
- Collected CPU, memory, disk, and network health information.
- Checked running service status.
- Reviewed recent service logs for warnings and errors.

### If the Situation Were Worse
- Restart the affected service.
- Investigate repeated errors in logs.
- Free disk space if storage is critically low.
- Stop or optimize resource-intensive processes.
- Verify network connectivity and firewall rules.
- Escalate with collected logs, metrics, and timestamps if the issue persists.

---

## Outcome

This runbook provides a structured approach to quickly assess system health, identify common issues, and gather enough information for effective troubleshooting before escalating.