# Day 24 – Advanced Git: Merge, Rebase, Stash & Cherry Pick

## Overview
Hands-on guide and notes for Day 24 of the DevOps Git practice series covering Merging, Rebasing, Squashing, Stashing, and Cherry-Picking.

---

## Task 1: Git Merge — Hands-On

### Commands & Execution
```bash
# Fast-Forward Merge
git checkout -b feature-login
echo "Login Form" >> login.html && git add . && git commit -m "feat: login UI"
git checkout main
git merge feature-login

# Merge Commit (Diverged Branches)
git checkout -b feature-signup
echo "Signup Form" >> signup.html && git add . && git commit -m "feat: signup UI"
git checkout main
echo "Docs" >> README.md && git add . && git commit -m "docs: readme update"
git merge feature-signup
```

### Key Concepts
* **Fast-forward Merge:** Occurs when `main` has no new commits since the feature branch was created. Git simply moves the `main` pointer forward without creating a new commit.
* **Merge Commit:** Created when branches have diverged (both have new commits). Git performs a 3-way merge and creates a dedicated merge commit.
* **Merge Conflict:** Happens when Git cannot auto-reconcile conflicting changes on the same line across branches. Requires manual resolution.

---

## Task 2: Git Rebase — Hands-On

### Commands & Execution
```bash
git checkout -b feature-dashboard
echo "Dashboard" > dashboard.html && git add . && git commit -m "feat: dashboard"

git checkout main
echo "CSS" >> style.css && git add . && git commit -m "style: CSS"

git checkout feature-dashboard
git rebase main
git log --oneline --graph --all
```

### Key Concepts
* **What Rebase Does:** Rewrites history by moving feature branch commits and re-applying them individually on top of the latest target branch commit.
* **History Difference:** Merge preserves exact branch timeline with a multi-parent commit. Rebase creates a clean, linear history.
* **Golden Rule of Rebase:** **Never rebase public/shared commits.** It rewrites commit hashes, causing divergence and merge conflicts for collaborators.
* **Rebase vs. Merge:** Use **Rebase** on local feature branches before merging for a clean history. Use **Merge** for integrating major public branches.

---

## Task 3: Squash Commit vs Merge Commit

### Commands & Execution
```bash
# Squash Merge
git checkout -b feature-profile
echo "p1" > profile.txt && git add . && git commit -m "typo fix"
echo "p2" >> profile.txt && git add . && git commit -m "formatting"
git checkout main
git merge --squash feature-profile
git commit -m "feat: profile page complete"

# Regular Merge
git checkout -b feature-settings
echo "s1" > settings.txt && git add . && git commit -m "add settings"
git checkout main
git merge feature-settings --no-ff
```

### Key Concepts
* **Squash Merging:** Combines all commits from a feature branch into a single set of changes applied as one new commit on `main`.
* **When to Use:** Use squash merge for noisy feature branches with trivial commits ("fix typo", "WIP"). Use regular merge when preserving step-by-step history matters.
* **Trade-off:** Squashing cleans history but discards intermediate commit timestamps, granular history, and individual sub-authorship.

---

## Task 4: Git Stash — Hands-On

### Commands & Execution
```bash
# Save uncommitted work
echo "WIP code" >> README.md
git stash save "WIP changes"

# Switch branches, complete work, return
git checkout -b hotfix
git checkout main

# Re-apply changes
git stash list
git stash apply stash@{0}  # Keeps stash in list
git stash pop              # Applies and removes stash from list
```

### Key Concepts
* **`stash pop` vs `stash apply`:** `pop` applies changes and removes the stash from the list; `apply` applies changes but keeps the stash saved.
* **Real-World Usage:** Use stash to quickly clear your working tree to switch branches for urgent hotfixes without committing broken code.

---

## Task 5: Cherry Picking

### Commands & Execution
```bash
git checkout -b feature-hotfix
echo "c1" > f1.txt && git add . && git commit -m "Commit 1"
echo "c2" > f2.txt && git add . && git commit -m "Commit 2: critical fix"
echo "c3" > f3.txt && git add . && git commit -m "Commit 3"

# Pick only Commit 2 onto main
git checkout main
git cherry-pick <COMMIT-2-HASH>
```

### Key Concepts
* **What Cherry-Pick Does:** Applies the specific changes of a single commit from another branch onto your current branch as a new commit.
* **Real-World Usage:** Porting a urgent bug fix from an unreleased dev branch directly into production without bringing along unfinished features.
* **Risks:** Can cause duplicate commits, divergent history, or missing dependency conflicts if the picked commit relies on prior unmerged commits.

---

## Summary of Commands (`git-commands.md` reference)

| Command | Category | Description |
| :--- | :--- | :--- |
| `git merge <branch>` | Merge | Combines specified branch into current branch |
| `git merge --squash <branch>` | Merge | Squashes branch commits into one commit |
| `git rebase <branch>` | Rebase | Re-applies current commits on top of target branch |
| `git stash` | Stash | Temporarily stashes modified tracked files |
| `git stash pop` | Stash | Applies latest stash and deletes it |
| `git stash apply stash@{N}` | Stash | Applies specific stash index without deleting |
| `git stash list` | Stash | Lists all stashed changes |
| `git cherry-pick <hash>` | Cherry-Pick | Applies specific commit onto current branch |