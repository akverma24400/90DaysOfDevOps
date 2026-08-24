# Day 28 – Revision Day: Everything from Day 1 to Day 27

## Overview

Day 28 was focused entirely on revision. I revisited the major DevOps concepts covered from Day 1 to Day 27, identified a few areas that needed more practice, and repeated hands-on tasks to strengthen my understanding.

---

## Task 1: Self-Assessment Checklist

### Linux

- [x] Navigate the file system, create/move/delete files and directories
- [x] Manage processes — list, kill, background/foreground
- [x] Work with systemd — start, stop, enable, check status of services
- [x] Read and edit text files using vi/vim or nano
- [x] Troubleshoot CPU, memory, and disk issues using `top`, `free`, `df`, and `du`
- [x] Explain the Linux file system hierarchy (`/`, `/etc`, `/var`, `/home`, `/tmp`, etc.)
- [x] Create users and groups, manage passwords
- [x] Set file permissions using `chmod` (numeric and symbolic)
- [x] Change file ownership with `chown` and `chgrp`
- [x] Create and manage LVM volumes
- [x] Check network connectivity using `ping`, `curl`, `netstat`, `ss`, `dig`, and `nslookup`
- [x] Explain DNS resolution, IP addressing, subnets, and common ports

### Shell Scripting

- [x] Write a script with variables, arguments, and user input
- [x] Use `if/elif/else` and `case` statements
- [x] Write `for`, `while`, and `until` loops
- [x] Define and call functions with arguments and return values
- [x] Use `grep`, `awk`, `sed`, `sort`, and `uniq` for text processing
- [x] Handle errors with `set -e`, `set -u`, `set -o pipefail`, and `trap`
- [x] Schedule scripts with `crontab`

### Git & GitHub

- [x] Initialize a repo, stage, commit, and view history
- [x] Create and switch branches
- [x] Push to and pull from GitHub
- [x] Explain clone vs fork
- [x] Merge branches — understand fast-forward vs merge commit
- [x] Rebase a branch and explain when to use it vs merge
- [x] Use `git stash` and `git stash pop`
- [x] Cherry-pick a commit from another branch
- [x] Explain squash merge vs regular merge
- [x] Use `git reset` (`soft`, `mixed`, `hard`) and `git revert`
- [x] Explain GitFlow, GitHub Flow, and Trunk-Based Development
- [x] Use GitHub CLI to create repos, PRs, and issues

---

## Task 2: Revisit My Weak Spots

I revisited the following topics and repeated hands-on practice.

### 1. Users, Groups, and Password Management

Commands practiced:

```bash
sudo useradd -m akash
sudo passwd akash
sudo groupadd developers
sudo usermod -aG developers akash

getent group developers
id akash
groups akash

cat /etc/group
cat /etc/passwd
```

What I revised:

- Creating Linux users
- Creating groups
- Assigning users to supplementary groups
- Setting and managing passwords
- Checking UID, GID, and group membership
- Viewing user and group information

---

### 2. File Permissions and Ownership

#### Numeric Permissions

```bash
sudo chmod 760 test.txt
```

`760` means:

- Owner → `rwx`
- Group → `rw-`
- Others → `---`

#### Symbolic Permissions

```bash
sudo chmod -x test.txt
```

This removes execute permission from the file.

#### Ownership

```bash
sudo chown akash test.txt
sudo chgrp developers test.txt
```

What I revised:

- Numeric and symbolic permissions
- Read, write, and execute permissions
- Changing file ownership with `chown`
- Changing group ownership with `chgrp`

---

### 3. LVM – Logical Volume Management

Commands practiced:

```bash
lsblk
df -h

sudo pvcreate /dev/sdb
sudo vgcreate devops-vg /dev/sdb
sudo lvcreate -L 500M -n app-data devops-vg
```

Format the Logical Volume:

```bash
sudo mkfs.ext4 /dev/devops-vg/app-data
```

Create a mount point:

```bash
sudo mkdir /app-data
```

Mount it:

```bash
sudo mount /dev/devops-vg/app-data /app-data
```

Extend the Logical Volume:

```bash
sudo lvextend -L +200M /dev/devops-vg/app-data
sudo resize2fs /dev/devops-vg/app-data
```

What I revised:

```text
Disk
  ↓
Physical Volume (PV)
  ↓
Volume Group (VG)
  ↓
Logical Volume (LV)
  ↓
Filesystem
  ↓
Mount Point
```

---

## Shell Scripting Practice

### Conditional Statements

Practiced:

```text
if
if/else
if/elif/else
case
```

### Loops

Practiced:

```text
for
while
until
```

Example:

```bash
#!/bin/bash

cities=("Delhi" "Mumbai" "Roorkee" "noida")

for city in "${cities[@]}"
do
    if [ ! -f "${city}.txt" ]; then
        touch "${city}.txt"
        echo "${city}.txt created"
    else
        echo "${city}.txt already exists"
    fi
done
```

### Crontab

Commands revised:

```bash
crontab -e
crontab -l
```

Example — run a script every day at 3 AM:

```cron
0 3 * * * /home/ubuntu/script.sh
```

### Text Processing

Commands practiced:

```bash
grep
awk
sed
sort
uniq
```

Examples:

```bash
grep "ERROR" app.log
```

```bash
df -h | awk 'NR==2 {print $4}'
```

```bash
sort file.txt
```

```bash
sort file.txt | uniq
```

---

## Task 3: Quick-Fire Questions

### 1. What does `chmod 755 script.sh` do?

It gives:

- Owner → read, write, execute (`rwx`)
- Group → read and execute (`r-x`)
- Others → read and execute (`r-x`)

---

### 2. What is the difference between a process and a service?

A **process** is a running instance of a program, while a **service** is usually a background process managed by the operating system, often through `systemd`.

---

### 3. How do you find which process is using port 8080?

```bash
sudo ss -tulpn | grep 8080
```

or:

```bash
sudo netstat -tulpn | grep 8080
```

---

### 4. What does `set -euo pipefail` do in a shell script?

- `-e` → Exit when a command fails
- `-u` → Exit when an undefined variable is used
- `-o pipefail` → A pipeline fails if any command in the pipeline fails

---

### 5. What is the difference between `git reset --hard` and `git revert`?

`git reset --hard` moves the branch pointer and removes changes from the working tree, while `git revert` creates a new commit that safely reverses an earlier commit.

`git revert` is generally safer for shared branches.

---

### 6. What branching strategy would you recommend for a team of 5 developers shipping weekly?

For a small team shipping frequently, **GitHub Flow** is a simple and effective choice because developers work on short-lived feature branches, create pull requests, review changes, and merge into `main`.

---

### 7. What does `git stash` do and when would you use it?

`git stash` temporarily saves uncommitted changes so that I can switch branches or work on something else without committing incomplete work.

Example:

```bash
git stash
git stash pop
```

---

### 8. How do you schedule a script to run every day at 3 AM?

```cron
0 3 * * * /path/to/script.sh
```

---

### 9. What is the difference between `git fetch` and `git pull`?

`git fetch` downloads changes from the remote repository without merging them.

`git pull` downloads the changes and integrates them into the current branch.

---

### 10. What is LVM and why would you use it instead of regular partitions?

LVM stands for **Logical Volume Management**. It provides flexible disk management and makes it easier to create, resize, extend, and manage storage volumes compared with fixed disk partitions.

---

## Task 4: Organize My Work

- [x] Checked daily submissions from Day 1 to Day 27
- [x] Reviewed Git and GitHub commands
- [x] Reviewed the Shell Scripting cheat sheet
- [x] Checked GitHub repositories
- [x] Reviewed GitHub profile setup from Day 27

---

## Task 5: Teach It Back

### Understanding Linux File Permissions

Linux file permissions control who can read, write, or execute a file or directory.

There are three permission categories:

- **User (`u`)** — Owner of the file
- **Group (`g`)** — Users belonging to the file's group
- **Others (`o`)** — Everyone else

The permissions are:

- `r` → Read
- `w` → Write
- `x` → Execute

Numeric values are:

```text
r = 4
w = 2
x = 1
```

For example:

```bash
chmod 755 script.sh
```

gives the owner full permission and gives the group and others read and execute permissions.

---

## Day 28 Summary

Day 28 was a complete revision of everything learned during Days 1–27.

Main areas revised:

- Linux fundamentals
- Users and groups
- Password management
- File permissions
- File ownership
- LVM
- Networking
- Shell scripting
- Conditional statements
- Loops
- Crontab
- Text processing
- Git and GitHub
- GitHub CLI
- Git branching strategies

This revision helped me identify weak areas, repeat hands-on tasks, and strengthen my understanding before moving forward with the next part of the DevOps journey.
