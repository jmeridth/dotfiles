---
name: repo-reset
description: Pull latest main, switch to it, and clean up merged branches and worktrees for a given repo
---

## Repo Reset

When invoked with a repo name (e.g., `/repo-reset mono`), perform the following steps in order:

### 1. Resolve the repo path

- Check common locations: `/Users/jason.meridth/code/<repo>`
- If the repo path doesn't exist, ask the user for the correct path

### 2. Fetch and update main

```bash
cd <repo-path>
git fetch upstream main 2>/dev/null || git fetch origin main
git checkout main
git merge upstream/main --ff-only 2>/dev/null || git merge origin/main --ff-only
```

- Prefer `upstream` remote if it exists, fall back to `origin`
- If the merge fails (not fast-forward), STOP and tell the user - do not force reset

### 3. Delete merged feature branches

- List all local branches except `main` (and `master` if it exists)
- For each branch, check if its associated PR is merged using: `gh pr list --head <branch> --state merged --json number --jq '.[0].number'`
- If the PR is merged, delete the branch: `git branch -d <branch>`
- If the branch has no PR or the PR is still open, skip it and report it
- **NEVER use `git branch -D` (force delete)** - only use `-d` (safe delete)

### 4. Clean up worktrees

- List worktrees: `git worktree list`
- For any worktree that points to a branch that was just deleted, remove it: `git worktree remove <path>`
- For any worktree marked as "prunable", prune it: `git worktree prune`
- **NEVER force-remove a worktree with uncommitted changes** - report it and skip

### 5. Report summary

Print a summary:
```
Repo: <repo-name>
Branch: main @ <short-sha>
Deleted branches: <list or "none">
Skipped branches: <list with reason, or "none">
Worktrees cleaned: <count or "none">
```
