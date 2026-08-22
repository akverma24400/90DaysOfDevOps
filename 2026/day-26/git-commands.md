
This file contains the main **Git** and **GitHub CLI (`gh`)** commands used during the Day 26 assignment, with a one-line explanation for each.

---

## 1. Installation & Authentication

1. `sudo apt update` — Updates the Ubuntu package list before installing new software.

2. `sudo apt install gh -y` — Installs GitHub CLI (`gh`) on Ubuntu without asking for confirmation.

3. `gh --version` — Displays the installed GitHub CLI version.

4. `gh auth login` — Starts the GitHub authentication process from the terminal.

5. `gh auth status` — Shows the currently authenticated GitHub account and login status.

6. `gh auth refresh -s delete_repo` — Refreshes authentication and requests permission to delete repositories.

---

## 2. Repository Management

7. `gh repo create gh-cli-practice --public --add-readme` — Creates a new public GitHub repository with a README file.

8. `gh repo clone akverma24400/gh-cli-practice` — Clones the specified GitHub repository using GitHub CLI.

9. `gh repo view` — Displays details of the current GitHub repository in the terminal.

10. `gh repo view akverma24400/gh-cli-practice` — Displays details of the specified GitHub repository.

11. `gh repo list akverma24400` — Lists repositories owned by the specified GitHub user.

12. `gh repo list akverma24400 --limit 100` — Lists up to 100 repositories owned by the specified GitHub user.

13. `gh browse` — Opens the current GitHub repository in the default web browser.

14. `gh repo view --web` — Opens the current repository page in the browser.

15. `gh repo delete akverma24400/gh-cli-practice` — Deletes the specified GitHub repository after confirmation.

16. `gh repo delete akverma24400/gh-cli-practice --yes` — Deletes the specified repository without asking for confirmation.

---

## 3. Git Branch & Commit Commands

17. `git branch -a` — Lists all local and remote branches in the repository.

18. `git switch main` — Switches to the `main` branch.

19. `git switch feature-1` — Switches to the existing `feature-1` branch.

20. `git switch -c feature-1` — Creates a new branch named `feature-1` and switches to it.

21. `git branch backup-feature-1` — Creates a backup branch from the current branch.

22. `git branch -D feature-1` — Force-deletes the local `feature-1` branch.

23. `git pull origin main` — Downloads and merges the latest changes from the remote `main` branch.

24. `echo "GitHub CLI PR practice" >> practice.txt` — Appends sample text to `practice.txt` for pull request practice.

25. `git add practice.txt` — Adds `practice.txt` to the Git staging area.

26. `git add .` — Adds all modified and new files in the current directory to the staging area.

27. `git commit -m "Add Day 26 PR practice"` — Creates a commit with the staged Day 26 practice changes.

28. `git push -u origin feature-1` — Pushes `feature-1` to GitHub and sets the remote upstream branch.

29. `git push -u origin feature-1 --force-with-lease` — Safely force-updates the remote `feature-1` branch while protecting against unexpected remote changes.

30. `git log --oneline --graph --all --decorate` — Displays the branch and commit history in a compact graph format.

---

## 4. GitHub Issues

31. `gh issue create --title "Test issue" --body "Issue created using GitHub CLI" --label "bug"` — Creates a GitHub issue with a title, description, and label.

32. `gh issue list` — Lists all open issues in the current repository.

33. `gh issue list --repo akverma24400/90DaysOfDevOps` — Lists open issues from the specified GitHub repository.

34. `gh issue view 1` — Displays complete details of issue number `1`.

35. `gh issue view 1 --repo akverma24400/90DaysOfDevOps` — Displays issue number `1` from the specified repository.

36. `gh issue close 1` — Closes issue number `1`.

37. `gh issue close 1 --comment "Completed as part of Day 26 practice."` — Closes issue number `1` and adds a closing comment.

---

## 5. Pull Requests

38. `gh pr create --base main --head feature-1 --title "Add Day 26 GitHub CLI practice" --body "This PR was created entirely from the terminal using GitHub CLI."` — Creates a pull request from `feature-1` into `main`.

39. `gh pr list` — Lists all open pull requests in the current repository.

40. `gh pr list --repo akverma24400/90DaysOfDevOps` — Lists all open pull requests in the specified repository.

41. `gh pr view 1` — Displays the details of pull request number `1`.

42. `gh pr view` — Displays details of the pull request associated with the current branch.

43. `gh pr view 1 --json state,reviewDecision,reviewRequests,statusCheckRollup` — Shows PR state, reviewers, review status, and checks in JSON format.

44. `gh pr checks 1` — Displays CI/CD and status checks for pull request number `1`.

45. `gh pr diff 1` — Displays the code changes introduced by pull request number `1`.

46. `gh pr merge 1 --merge` — Merges pull request number `1` using a merge commit.

47. `gh pr merge 1 --merge --delete-branch` — Merges the PR using a merge commit and deletes the feature branch.

48. `gh pr merge 1 --squash --delete-branch` — Squashes all PR commits into one commit, merges it, and deletes the branch.

49. `gh pr merge 1 --rebase --delete-branch` — Rebases the PR commits onto the base branch, merges them, and deletes the branch.

50. `gh pr review 5 --approve` — Approves pull request number `5`.

51. `gh pr review 5 --comment --body "Looks good overall."` — Adds a general review comment to pull request number `5`.

52. `gh pr review 5 --request-changes --body "Please fix the validation before merging."` — Requests changes on pull request number `5`.

---

## 6. GitHub Actions & Workflow Runs

53. `gh run list` — Lists recent GitHub Actions workflow runs for the current repository.

54. `gh run list --repo cli/cli` — Lists recent workflow runs for the specified public repository.

55. `gh run view <run-id>` — Displays details of a specific GitHub Actions workflow run.

56. `gh run view <run-id> --repo cli/cli` — Displays a specific workflow run from the specified repository.

57. `gh run view <run-id> --log-failed` — Shows logs only for failed jobs or steps in the workflow run.

58. `gh run watch <run-id>` — Watches a running workflow and continuously displays its status.

59. `gh run rerun <run-id>` — Reruns a previous GitHub Actions workflow run.

60. `gh workflow list` — Lists GitHub Actions workflows configured in the current repository.

61. `gh workflow list --repo cli/cli` — Lists workflows configured in the specified repository.

62. `gh workflow view <workflow-name>` — Displays details of a specific GitHub Actions workflow.

63. `gh workflow run <workflow-name>` — Manually triggers a workflow that supports the `workflow_dispatch` event.

---

## 7. Useful GitHub CLI Tricks

64. `gh api` — Makes direct requests to the GitHub REST or GraphQL API from the terminal.

65. `gh gist list` — Lists GitHub Gists available to the authenticated account.

66. `gh gist create <file>` — Creates a new GitHub Gist from a local file.

67. `gh release list` — Lists releases in the current GitHub repository.

68. `gh release create <tag>` — Creates a new GitHub release using the specified Git tag.

69. `gh alias list` — Lists all custom GitHub CLI aliases.

70. `gh alias set pv "pr view"` — Creates a shortcut named `pv` for the `gh pr view` command.

71. `gh search repos "devops"` — Searches GitHub repositories that match the keyword `devops`.

---

## Quick Summary

The commands above cover:

- GitHub CLI installation and authentication
- Repository creation, cloning, viewing, listing, opening, and deletion
- Git branch creation and commit workflow
- Issue creation and management
- Pull request creation, review, checks, and merging
- GitHub Actions workflow monitoring
- GitHub API, Gists, Releases, Aliases, and repository search
