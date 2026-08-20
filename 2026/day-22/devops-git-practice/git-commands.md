# Day 22 – Git Basics

1. Install Git.

2. Verify Git is installed or not by using `git --version` command.

3. Set up Git identity (name and email) using `git config --global user.name "akash9193"` and `git config --global user.email "akashverma919363@gmail.com"`.

4. Verify Git configuration using `git config --global --list` command.

5. Create a folder, navigate to it, initialize it as a Git repository using `git init`, and explore the `.git/` folder.

6. Use `git add <filename>` to move file changes to the staging area.

7. Use `git status` to check the current status of the repository.

8. Use `git commit -m "Some meaningful message"` to create a permanent snapshot of the staged changes.

9. Use `git log` to view the detailed commit history.

10. Use `git log --oneline` to view the commit history in a compact format.


# Day 23 – Git Branching & GitHub Commands

## Git Branching Commands

1. `git branch` — Lists all local branches and shows the current branch.

2. `git checkout -b feature-1` — Creates a new `feature-1` branch and switches to it.

3. `git branch feature-2` — Creates a new `feature-2` branch without switching to it.

4. `git switch feature-2` — Switches to the `feature-2` branch.

5. `git checkout main` — Switches to the `main` branch.

6. `git checkout master` — Switches to the `master` branch.

7. `git checkout feature-1` — Switches to the `feature-1` branch.

8. `git switch master` — Switches to the `master` branch.

9. `git branch -d feature-2` — Deletes the local `feature-2` branch if it has been merged.

## GitHub / Remote Commands

10. `git remote add origin <repo-link>` — Connects the local repository to a GitHub repository named `origin`.

11. `git branch -M main` — Renames the current branch to `main`.

12. `git push -u origin main` — Pushes the `main` branch to GitHub and sets it as the upstream branch.

13. `git push -u origin feature-1` — Pushes the `feature-1` branch to GitHub and sets it as the upstream branch.

14. `git pull origin <branch-name>` — Fetches and integrates changes from the specified remote branch.

15. `git clone <repo-link>` — Clones an existing GitHub repository to the local machine.

# Git Advanced Commands – Day 24

## 1. Merging

1. `git merge <branch-name>` — Combines another branch's changes into the current branch.
2. `git merge --squash <branch-name>` — Combines all changes from a branch into the working tree without creating individual commits.
3. `git merge main` — Merges the latest `main` branch changes into the current branch.
4. `git merge feature-1` — Merges `feature-1` into the currently checked-out branch.

## 2. Rebase

5. `git rebase main` — Replays the current branch's commits on top of the latest `main`.
6. `git rebase --continue` — Continues a rebase after resolving a conflict.
7. `git rebase --skip` — Skips the commit currently being replayed during a rebase.
8. `git rebase --abort` — Cancels the rebase and returns to the previous state.

## 3. Merge & Rebase Conflict Handling

9. `git add <file>` — Marks a conflicted file as resolved after manually fixing it.
10. `git commit -m "Resolve merge conflict"` — Creates a commit after resolving a normal merge conflict.
11. `git status` — Helps identify which files are conflicted and what Git expects you to do next.

## 4. Stashing

12. `git stash` — Temporarily saves uncommitted changes so you can work with a clean working directory.
13. `git stash list` — Shows all saved stashes.
14. `git stash pop` — Applies the latest stash and removes it from the stash list.
15. `git stash apply` — Applies a stash without removing it from the stash list.

## 5. Cherry-Pick

16. `git cherry-pick <commit-hash>` — Applies a specific commit from another branch onto the current branch.
17. `git cherry-pick --continue` — Continues a cherry-pick after resolving a conflict.
18. `git cherry-pick --skip` — Skips the current commit during a cherry-pick operation.
19. `git cherry-pick --abort` — Cancels the cherry-pick and restores the previous state.

