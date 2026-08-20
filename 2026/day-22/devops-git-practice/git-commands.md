# Git Commands Cheat Sheet 🚀

A quick-reference guide containing the **Git & GitHub commands I practiced from Day 22 to Day 25** of my DevOps learning journey.

---

## 📌 Day 22 – Git Basics

| #  | Command                                              | Description                                                        |
| -- | ---------------------------------------------------- | ------------------------------------------------------------------ |
| 1  | `git --version`                                      | Checks the installed Git version.                                  |
| 2  | `git config --global user.name "username"`           | Sets the global Git username.                                      |
| 3  | `git config --global user.email "email@example.com"` | Sets the global Git email address.                                 |
| 4  | `git config --global --list`                         | Displays the global Git configuration.                             |
| 5  | `git init`                                           | Initializes the current directory as a Git repository.             |
| 6  | `git add <filename>`                                 | Adds a specific file to the staging area.                          |
| 7  | `git add .`                                          | Adds all current changes to the staging area.                      |
| 8  | `git status`                                         | Shows the current state of the working directory and staging area. |
| 9  | `git commit -m "<message>"`                          | Creates a commit containing the staged changes.                    |
| 10 | `git log`                                            | Displays detailed commit history.                                  |
| 11 | `git log --oneline`                                  | Displays commit history in a compact one-line format.              |

---

## 🌿 Day 23 – Git Branching & GitHub

| #  | Command                             | Description                                                 |
| -- | ----------------------------------- | ----------------------------------------------------------- |
| 1  | `git branch`                        | Lists all local branches and highlights the current branch. |
| 2  | `git branch <branch-name>`          | Creates a new branch without switching to it.               |
| 3  | `git checkout -b <branch-name>`     | Creates a new branch and switches to it.                    |
| 4  | `git checkout <branch-name>`        | Switches to an existing branch.                             |
| 5  | `git switch <branch-name>`          | Switches to an existing branch using the newer Git command. |
| 6  | `git switch -c <branch-name>`       | Creates a new branch and switches to it.                    |
| 7  | `git branch -d <branch-name>`       | Safely deletes a merged local branch.                       |
| 8  | `git branch -D <branch-name>`       | Force-deletes a local branch.                               |
| 9  | `git branch -M main`                | Renames the current branch to `main`.                       |
| 10 | `git remote add origin <repo-link>` | Connects the local repository to a remote repository.       |
| 11 | `git push -u origin main`           | Pushes `main` and sets its upstream remote branch.          |
| 12 | `git push -u origin <branch-name>`  | Pushes a branch and sets its upstream branch.               |
| 13 | `git push origin <branch-name>`     | Pushes a local branch to the remote repository.             |
| 14 | `git pull origin <branch-name>`     | Fetches and integrates changes from a remote branch.        |
| 15 | `git clone <repo-link>`             | Creates a local copy of an existing remote repository.      |

---

## 🔀 Day 24 – Merge, Rebase, Stash & Cherry-Pick

### Merge

| # | Command                            | Description                                                        |
| - | ---------------------------------- | ------------------------------------------------------------------ |
| 1 | `git merge <branch-name>`          | Merges another branch into the current branch.                     |
| 2 | `git merge main`                   | Merges changes from `main` into the current branch.                |
| 3 | `git merge --squash <branch-name>` | Combines branch changes without preserving its individual commits. |

### Rebase

| # | Command                 | Description                                         |
| - | ----------------------- | --------------------------------------------------- |
| 4 | `git rebase main`       | Replays current branch commits on top of `main`.    |
| 5 | `git rebase --continue` | Continues a rebase after conflicts are resolved.    |
| 6 | `git rebase --skip`     | Skips the current problematic commit during rebase. |
| 7 | `git rebase --abort`    | Cancels the rebase and restores the previous state. |

### Conflict Handling

| #  | Command                                  | Description                                            |
| -- | ---------------------------------------- | ------------------------------------------------------ |
| 8  | `git status`                             | Shows conflicted files and the current Git operation.  |
| 9  | `git add <file>`                         | Marks a manually resolved conflicted file as resolved. |
| 10 | `git commit -m "Resolve merge conflict"` | Creates a commit after resolving a merge conflict.     |

### Stashing

| #  | Command           | Description                                                  |
| -- | ----------------- | ------------------------------------------------------------ |
| 11 | `git stash`       | Temporarily saves uncommitted changes.                       |
| 12 | `git stash list`  | Displays all saved stashes.                                  |
| 13 | `git stash pop`   | Applies the latest stash and removes it from the stash list. |
| 14 | `git stash apply` | Applies a stash without deleting it from the stash list.     |

### Cherry-Pick

| #  | Command                         | Description                                      |
| -- | ------------------------------- | ------------------------------------------------ |
| 15 | `git cherry-pick <commit-hash>` | Applies a specific commit to the current branch. |
| 16 | `git cherry-pick --continue`    | Continues cherry-pick after resolving conflicts. |
| 17 | `git cherry-pick --skip`        | Skips the current commit during cherry-pick.     |
| 18 | `git cherry-pick --abort`       | Cancels the cherry-pick operation.               |

---

## ↩️ Day 25 – Git Reset & Revert

### Git Reset

| # | Command                    | Description                                                 |
| - | -------------------------- | ----------------------------------------------------------- |
| 1 | `git reset --soft HEAD~1`  | Removes the last commit while keeping its changes staged.   |
| 2 | `git reset --mixed HEAD~1` | Removes the last commit while keeping its changes unstaged. |
| 3 | `git reset HEAD~1`         | Performs a mixed reset, which is Git's default reset mode.  |
| 4 | `git reset --hard HEAD~1`  | Removes the last commit and discards its changes.           |

### Git Revert

| # | Command                              | Description                                                 |
| - | ------------------------------------ | ----------------------------------------------------------- |
| 5 | `git revert <commit-hash>`           | Creates a new commit that reverses a specific commit.       |
| 6 | `git revert HEAD`                    | Creates a new commit that reverses the latest commit.       |
| 7 | `git revert --no-edit <commit-hash>` | Reverts a commit without opening the commit-message editor. |

### Recovery & History

| #  | Command             | Description                                                   |
| -- | ------------------- | ------------------------------------------------------------- |
| 8  | `git reflog`        | Shows recent `HEAD` movements and helps recover lost commits. |
| 9  | `git log`           | Shows detailed commit history.                                |
| 10 | `git log --oneline` | Shows compact commit history and commit hashes.               |

---

