# Day 25 – Git Reset vs Revert & Branching Strategies

## 📌 Overview

Today I learned how to safely **undo changes in Git** using `reset` and `revert`. I also explored common **branching strategies** used by development teams.

---

## 1. Git Reset

Git reset moves the current branch to another commit.

### Reset Types

| Command | What happens? |
|---|---|
| `git reset --soft HEAD~1` | Removes commit, keeps changes **staged** |
| `git reset --mixed HEAD~1` | Removes commit, keeps changes **unstaged** |
| `git reset --hard HEAD~1` | Removes commit **and changes** |

### When to Use

- **`--soft`** → Undo a commit but keep changes staged.
- **`--mixed`** → Undo a commit and keep changes unstaged.
- **`--hard`** → Completely discard the commit and changes.

> ⚠️ `--hard` is destructive because uncommitted changes can be lost.

### Important

Avoid using `git reset` on commits that are already pushed to a shared branch because it rewrites Git history.

---

## 2. Git Revert

Git revert creates a **new commit** that reverses the changes of an existing commit.

### Command

```bash
git revert <commit-hash>
```

### Example

```text
X → Y → Z → Revert Y
```

Commit `Y` remains in the history, but its changes are undone by a new commit.

### If a Conflict Occurs

```bash
git add .
git revert --continue
```

To cancel the revert:

```bash
git revert --abort
```

### Why Is Revert Safer?

`git revert` does not rewrite existing history, making it safer for **shared and pushed branches**.

---

## 3. Git Reset vs Revert

| | `git reset` | `git revert` |
|---|---|---|
| What it does | Moves HEAD backward | Creates a new undo commit |
| Removes commit from history? | Yes, locally | No |
| Safe for pushed branches? | ❌ Usually no | ✅ Yes |
| Best used for | Local commits | Shared/pushed commits |

---

# 4. Branching Strategies

## 🌿 GitFlow

### Flow

```text
main
  ↑
release ← develop ← feature
  ↑
hotfix ───────────→ main
```

### How It Works

Uses different branches for:

- `main`
- `develop`
- `feature`
- `release`
- `hotfix`

### Used For

Projects with **scheduled and structured releases**.

### Pros

- Clear release process
- Good separation of features and releases

### Cons

- More branches
- More complex workflow

---

## 🔀 GitHub Flow

### Flow

```text
main
  │
  └── feature → Pull Request → main
```

### How It Works

Developers create short-lived feature branches and merge them into `main` using Pull Requests.

### Used For

Teams that **deploy frequently**.

### Pros

- Simple
- Fast
- Easy to understand

### Cons

- Less suitable for strict release cycles

---

## 🚀 Trunk-Based Development

### Flow

```text
        → short branch →
main ─────────────────────→ main
        → short branch →
```

### How It Works

Developers work with very short-lived branches and frequently merge changes into `main`.

### Used For

Teams practicing **Continuous Integration and frequent deployments**.

### Pros

- Small changes
- Fewer merge conflicts
- Fast delivery

### Cons

- Requires strong CI/CD
- Requires good automated testing

---

# 5. My Answers

### Which strategy would you use for a startup shipping fast?

**GitHub Flow** — It is simple, lightweight, and supports fast development and deployment.

### Which strategy would you use for a large team with scheduled releases?

**GitFlow** — It provides a structured workflow for managing features, releases, and hotfixes.

### Which strategy does an open-source project use?

**Kubernetes** is an example to study. Its repository uses a structured contribution workflow with `main` and short-lived development branches rather than a classic GitFlow setup.

---

# 📝 Key Takeaways

- `git reset` → **Moves/rewrites history**
- `git revert` → **Creates a new commit to undo changes**
- `--soft` → Changes remain **staged**
- `--mixed` → Changes remain **unstaged**
- `--hard` → Changes are **discarded**
- Use `reset` mainly for **local commits**
- Use `revert` for **shared/pushed commits**
- **GitHub Flow** → Simple and fast
- **GitFlow** → Structured releases
- **Trunk-Based Development** → Frequent integration and delivery
