# Day 08 – Cloud Deployment with Nginx

## 🎯 Objective
Deploy a real web server on a cloud instance, configure it, and manage basic server operations like a DevOps Engineer.

---

# 🖥️ Environment

- **Cloud Platform:** AWS EC2
- **Operating System:** Ubuntu
- **Web Server:** Nginx
- **Access Method:** SSH

---

# 🚀 Steps Performed

## 1. Connect to the EC2 Instance

```bash
ssh -i "skillpulse-key.pem" ubuntu@<EC2-Public-IP>
```

**Theory:** Connects securely to the remote Linux server using an SSH private key.

---

## 2. Update the Package List

```bash
sudo apt update
```

**Theory:** Updates the package list so the latest software can be installed.

---

## 3. Install Nginx

```bash
sudo apt install nginx -y
```

**Theory:** Installs the Nginx web server.

---

## 4. Check Nginx Status

```bash
systemctl status nginx
```

**Theory:** Checks whether the Nginx service is running properly.

---

## 5. Edit the Default Nginx Web Page

```bash
cd /var/www/html
nano index.nginx-debian.html
```

**Theory:** Opens the default Nginx HTML page for editing.

### ❌ Problem Faced

While editing the HTML page, I received a **Permission Denied** error because the `/var/www/html` directory is owned by the **root** user.

### ✅ Solution

```bash
sudo su
```

**Theory:** Switches to the superuser (root).

After switching to the root user, I edited the HTML file successfully and saved the changes.

---

## 6. Verify the Website

Open the EC2 Public IP in a browser:

```
http://<EC2-Public-IP>
```

**Theory:** Confirms that the website is accessible from the internet.

---

## 7. Save Nginx Logs to a File

```bash
cat /var/log/nginx/access.log > ~/nginx-logs.txt
```

**Theory:** Copies the Nginx access logs into a new file.

---

## 8. Download the Log File to the Local Machine

```bash
scp -i "skillpulse-key.pem" ubuntu@<EC2-Public-IP>:~/nginx-logs.txt .
```

**Theory:** Securely copies the log file from the EC2 instance to the current local directory.

### ❌ Problem Faced

The `scp` command failed because I was not inside the folder where my private key (`skillpulse-key.pem`) was stored.

### ✅ Solution

I navigated to the folder containing my private key and executed the command again.

The `.` at the end of the command tells `scp` to download the file into the **current local directory**.

---

# 📁 Files Created

- `day-08-cloud-deployment.md`
- `nginx-logs.txt`

---

# 📸 Screenshots Captured

- SSH connection to the EC2 instance
- Nginx webpage opened in the browser
- Contents of `nginx-logs.txt`

---

# 📚 What I Learned

- How to launch and connect to an AWS EC2 instance using SSH.
- How to install and manage the Nginx web server.
- Why root permissions are required for system files.
- How to troubleshoot Linux permission issues.
- How to transfer files securely using the `scp` command.
- How to verify that a web server is publicly accessible.

---

# ✅ Conclusion

Today I successfully deployed an Nginx web server on an AWS EC2 instance. During the process, I solved permission issues while editing system files and learned how to securely download log files using the `scp` command. This hands-on practice improved my understanding of cloud server management and real-world DevOps tasks.