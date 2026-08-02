# 🚀 Day 07 – Linux Scenario-Based Troubleshooting

## Objective
Practice basic Linux troubleshooting by diagnosing common system issues using essential commands.

---

## Scenario 1: Service Not Starting

**Problem:** `myapp` failed to start after reboot.

```bash
systemctl status myapp
journalctl -u myapp -n 50
systemctl is-enabled myapp
systemctl restart myapp
```

---

## Scenario 2: High CPU Usage

**Problem:** Application server is slow.

```bash
top
ps aux --sort=-%cpu | head -10
ps -fp <PID>
```

---

## Scenario 3: Finding Service Logs

**Problem:** Check logs for the Docker service.

```bash
systemctl status docker
journalctl -u docker -n 50
journalctl -u docker -f
```

---

## Scenario 4: File Permissions Issue

**Problem:** `backup.sh` shows **Permission denied**.

```bash
ls -l /home/user/backup.sh
chmod +x /home/user/backup.sh
./backup.sh
```

---

## 📌 Key Takeaways

- Check service health with `systemctl`.
- Use `journalctl` to investigate service logs.
- Monitor CPU usage using `top` and `ps`.
- Fix execution errors using `chmod +x`.
- Follow a step-by-step troubleshooting approach before applying fixes.

---