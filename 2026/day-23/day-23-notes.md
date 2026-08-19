# Day 23 – Git Branching & Working with GitHub

## 1. Understanding Branches

1. **What is a branch in Git?**
   A branch is a separate line of development used to work on features or changes independently.

2. **Why use branches instead of committing everything to `main`?**
   Branches keep new features and experiments separate from the stable `main` branch.

3. **What is `HEAD` in Git?**
   `HEAD` points to the current branch or commit you are working on.

4. **What happens when you switch branches?**
   Git updates the working files to match the selected branch.

---

## 2. Important Branch Commands

```bash
git branch
git branch feature-1
git switch feature-1
git switch -c feature-2
git checkout main
git switch main
git branch -d feature-2
```

### `git switch` vs `git checkout`

* `git switch` → Mainly used for switching/creating branches.
* `git checkout` → Older command that can switch branches and also restore files.

---

## 3. GitHub Commands

```bash
git remote add origin <github-repo-url>
git branch -M main
git push -u origin main
git push -u origin feature-1
```

### `origin` vs `upstream`

* **origin** → Usually points to your own GitHub repository.
* **upstream** → Usually points to the original repository, especially when working with a fork.

---

## 4. Fetch vs Pull

* `git fetch` → Downloads changes from GitHub without merging them.
* `git pull` → Downloads changes and merges them into the current branch.

```bash
git fetch origin
git pull origin main
```

---

## 5. Clone vs Fork

### Clone

Copies a repository from GitHub to your local machine.

```bash
git clone <repository-url>
```

### Fork

Creates your own copy of another user's repository on GitHub.

* **Clone** → Use when you have access to the repository and want to work locally.
* **Fork** → Use when you want to contribute to someone else's repository without direct write access.

### Keeping a Fork Updated

```bash
git remote add upstream <original-repo-url>
git fetch upstream
git switch main
git merge upstream/main
git push origin main
```

---

## Key Learning

Today I learned how to:

* Create and switch branches
* Work independently using branches
* Push branches to GitHub
* Pull changes from GitHub
* Understand `origin` and `upstream`
* Understand clone vs fork
* Keep a fork synchronized with the original repository

**Day 23 completed! 🚀**

#90DaysOfDevOps #DevOpsKaJosh #TrainWithShubham
