# 🐧 Day 12 – Revision (Days 01–11)

## 📌 Goal

Today was a revision day to refresh the Linux concepts learned during Days 01–11. I reviewed my notes, practiced a few commands, and strengthened my understanding of Linux fundamentals.

---

# ✅ Mindset & Plan Review

- My goal of becoming a DevOps Engineer remains the same.
- I will continue practicing Linux daily before moving to advanced DevOps tools.
- Need to improve speed while working with Linux commands.

---

# ✅ Processes & Services Review

### Commands Practiced

```bash
ps aux
```

**Observation:**
- Displayed all running processes with detailed information.

```bash
systemctl status nginx
```

**Observation:**
- Verified that the Nginx service was active and running successfully.

```bash
journalctl -u nginx -n 5
```

**Observation:**
- Viewed the latest Nginx service logs and confirmed there were no major errors.

---

# ✅ File Operations Practice

### Commands Used

```bash
echo "Linux Revision" >> notes.txt
```

- Appended text to a file.

```bash
chmod 644 notes.txt
```

- Changed file permissions.

```bash
ls -l notes.txt
```

- Verified the file permissions.

---

# ✅ Cheat Sheet Refresh

### Top 5 Commands I Use Frequently

- `ls -l` → View files with permissions
- `cd` → Navigate directories
- `ps aux` → Check running processes
- `systemctl status` → Check service status
- `journalctl` → View service logs

---

# ✅ User & Group Practice

### Commands Used

```bash
sudo chown ubuntu:ubuntu notes.txt
```

```bash
ls -l notes.txt
```

**Observation:**
- Successfully changed file ownership and verified it.

---

# ✅ Mini Self-Check

### 1. Which 3 commands save you the most time right now, and why?

- `ls -l` → Quickly checks file permissions.
- `systemctl status` → Checks whether a service is running.
- `journalctl` → Helps troubleshoot service issues by viewing logs.

---

### 2. How do you check if a service is healthy?

Commands I use:

```bash
systemctl status nginx
```

```bash
journalctl -u nginx -n 5
```

```bash
ps aux | grep nginx
```

---

### 3. How do you safely change ownership and permissions?

Example:

```bash
sudo chown ubuntu:ubuntu notes.txt
```

```bash
chmod 644 notes.txt
```

---

### 4. What will you focus on improving in the next 3 days?

- Practice more Linux commands.
- Improve troubleshooting skills.
- Learn more about shell scripting and automation.

---

# 🎯 Key Takeaways

- Linux basics are becoming more comfortable.
- Service management and log analysis are easier now.
- File permissions and ownership are much clearer after practice.
- Consistent daily practice is improving my confidence.