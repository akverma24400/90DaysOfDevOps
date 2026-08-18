# Day 22 – Introduction to Git

## 🎯 What I Learned

Today I learned the basics of Git and created my first local Git repository.

### Git Setup

```bash
git --version
git config --global user.name "Your Name"
git config --global user.email "your@email.com"
git config --list
```

### Create Repository

```bash
mkdir devops-git-practice
cd devops-git-practice
git init
git status
ls -la
```

`git init` creates the hidden `.git/` directory that stores Git's repository information.

---

## 🔄 Basic Git Workflow

```text
Working Directory
       ↓ git add
Staging Area
       ↓ git commit
Git Repository
```

### Important Commands

| Command                   | Purpose                 |
| ------------------------- | ----------------------- |
| `git init`                | Initialize a repository |
| `git status`              | Check repository status |
| `git add .`               | Stage all changes       |
| `git commit -m "message"` | Save staged changes     |
| `git diff`                | View unstaged changes   |
| `git log`                 | View commit history     |
| `git log --oneline`       | View compact history    |
| `git branch`              | View branches           |

---

## 🧠 Questions & Answers

**1. `git add` vs `git commit`**

`git add` stages changes, while `git commit` saves those staged changes as a snapshot.

**2. What is the staging area?**

It allows me to select which changes should be included in the next commit.

**3. What does `git log` show?**

It shows commit history, including commit ID, author, date, and message.

**4. What is `.git/`?**

It contains Git's internal repository data. Deleting it removes the Git history and repository information.

**5. Working Directory vs Staging Area vs Repository**

```text
Working Directory → Files I'm editing
       ↓ git add
Staging Area      → Changes ready to commit
       ↓ git commit
Repository        → Saved commit history
```

## 🚀 Key Takeaway

I learned the fundamental Git workflow:

```bash
git add .
git commit -m "Meaningful message"
git log --oneline
```

This is the foundation for working with Git and GitHub in DevOps.
